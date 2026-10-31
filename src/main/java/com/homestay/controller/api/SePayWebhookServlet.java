package com.homestay.controller.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.homestay.context.DBContext;
import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.dao.PaymentQrCodeDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.Room;
import com.homestay.service.EmailService;
import com.homestay.service.PaymentAllocationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SePay / Bank Webhook Endpoint.
 *
 * Receives real-time bank transaction notifications from SePay (or bank gateways),
 * verifies transfer content (booking code) and amount, then automatically confirms the booking.
 *
 * Dev/Test feature: Accepts test transfers >= 1,000 VND so testers can test with 1,000 - 2,000 VND.
 */
@WebServlet(
        name = "SePayWebhookServlet",
        urlPatterns = {"/api/payment/webhook", "/api/webhook/sepay"}
)
public class SePayWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SePayWebhookServlet.class.getName());
    private static final Pattern BOOKING_CODE_PATTERN = Pattern.compile("BK-?([A-Za-z0-9]{8,24})", Pattern.CASE_INSENSITIVE);

    private BookingDAO bookingDAO;
    private PaymentDAO paymentDAO;
    private PaymentQrCodeDAO paymentQrCodeDAO;
    private RoomDAO roomDAO;
    private PaymentAllocationService paymentAllocationService;
    private EmailService emailService;
    private ObjectMapper objectMapper;

    @Override
    public void init() throws ServletException {
        super.init();
        bookingDAO = new BookingDAO();
        paymentDAO = new PaymentDAO();
        paymentQrCodeDAO = new PaymentQrCodeDAO();
        roomDAO = new RoomDAO();
        paymentAllocationService = new PaymentAllocationService();
        emailService = EmailService.getInstance();
        objectMapper = new ObjectMapper();
    }

    /**
     * Health check endpoint for testing reachability.
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> health = new HashMap<>();
        health.put("status", "ACTIVE");
        health.put("service", "Sogo Homestay Payment Webhook (SePay Compatible)");
        health.put("supportedGateways", new String[]{"MBBank", "Vietcombank", "TPBank", "SePay", "Casso"});
        health.put("testTransferAccepted", true);
        health.put("time", System.currentTimeMillis());

        objectMapper.writeValue(response.getWriter(), health);
    }

    /**
     * Handles incoming transaction webhooks.
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        StringBuilder jsonBuffer = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
        }

        String rawJson = jsonBuffer.toString().trim();
        LOGGER.info(() -> "Received SePay Webhook payload: " + rawJson);

        Map<String, Object> responseMap = new HashMap<>();

        if (rawJson.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            responseMap.put("success", false);
            responseMap.put("message", "Payload is empty");
            objectMapper.writeValue(response.getWriter(), responseMap);
            return;
        }

        try {
            JsonNode root = objectMapper.readTree(rawJson);

            // 1. Support single transaction or list (Casso/SePay format)
            JsonNode tx = root.has("data") && root.get("data").isArray() && !root.get("data").isEmpty()
                    ? root.get("data").get(0)
                    : root;

            // 2. Validate transfer type: only process incoming money ("in")
            if (tx.has("transferType")) {
                String transferType = tx.get("transferType").asText();
                if ("out".equalsIgnoreCase(transferType)) {
                    LOGGER.info("Ignoring outgoing transfer (transferType=out)");
                    responseMap.put("success", true);
                    responseMap.put("message", "Ignored outgoing transfer");
                    objectMapper.writeValue(response.getWriter(), responseMap);
                    return;
                }
            }

            // 3. Extract transfer content and description
            String content = tx.has("content") ? tx.get("content").asText("") : "";
            String description = tx.has("description") ? tx.get("description").asText("") : "";
            String fullSearchText = content + " " + description;

            // 4. Extract booking code (e.g. BK-612BC0691AB9)
            String bookingCode = extractBookingCode(fullSearchText);

            if (bookingCode == null) {
                LOGGER.warning(() -> "Could not find booking code in content: " + fullSearchText);
                responseMap.put("success", false);
                responseMap.put("message", "Booking code not found in transaction content");
                objectMapper.writeValue(response.getWriter(), responseMap);
                return;
            }

            // 5. Extract transfer amount
            BigDecimal transferAmount = BigDecimal.ZERO;
            if (tx.has("transferAmount")) {
                transferAmount = new BigDecimal(tx.get("transferAmount").asText());
            } else if (tx.has("amount")) {
                transferAmount = new BigDecimal(tx.get("amount").asText());
            }

            // Reference code / transaction ID
            String referenceCode = tx.has("referenceCode") && !tx.get("referenceCode").isNull()
                    ? tx.get("referenceCode").asText()
                    : (tx.has("id") ? "SEPAY-" + tx.get("id").asText() : "TRX-" + System.currentTimeMillis());

            // 6. Process confirmation in database transaction
            boolean confirmed = processBookingConfirmation(bookingCode, transferAmount, referenceCode);

            if (confirmed) {
                response.setStatus(HttpServletResponse.SC_OK);
                responseMap.put("success", true);
                responseMap.put("message", "Booking " + bookingCode + " confirmed successfully");
                responseMap.put("bookingCode", bookingCode);
                responseMap.put("referenceCode", referenceCode);
            } else {
                response.setStatus(HttpServletResponse.SC_OK);
                responseMap.put("success", false);
                responseMap.put("message", "Booking not eligible or amount mismatch");
                responseMap.put("bookingCode", bookingCode);
            }

            objectMapper.writeValue(response.getWriter(), responseMap);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing SePay Webhook", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseMap.put("success", false);
            responseMap.put("message", "Internal server error: " + e.getMessage());
            objectMapper.writeValue(response.getWriter(), responseMap);
        }
    }

    /**
     * Extracts booking code matching pattern "BK-[A-Za-z0-9]+" or "BK[A-Za-z0-9]+" from text.
     * Automatically normalizes "BK898C39560561" to "BK-898C39560561" if bank stripped the hyphen.
     */
    private String extractBookingCode(String text) {
        if (text == null || text.isBlank()) {
            return null;
        }

        Matcher matcher = BOOKING_CODE_PATTERN.matcher(text);
        if (matcher.find()) {
            String rawCode = matcher.group();
            // Normalize: If bank removed '-', e.g. BK898C39560561 -> BK-898C39560561
            if (rawCode.toUpperCase().startsWith("BK") && !rawCode.contains("-")) {
                return "BK-" + rawCode.substring(2).toUpperCase();
            }
            return rawCode.toUpperCase();
        }

        return null;
    }

    /**
     * Atomically confirms booking and updates financial allocations.
     */
    private boolean processBookingConfirmation(
            String bookingCode,
            BigDecimal receivedAmount,
            String transactionId) throws SQLException {

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try {
                // 1. Lock booking by code
                Booking booking = bookingDAO.findByBookingCodeForUpdate(conn, bookingCode);

                if (booking == null) {
                    conn.rollback();
                    LOGGER.warning(() -> "Booking not found with code: " + bookingCode);
                    return false;
                }

                String currentStatus = booking.getStatus() != null ? booking.getStatus().toUpperCase() : "";

                // Idempotency: if already confirmed, consider success
                if ("CONFIRMED".equals(currentStatus) || "PAID".equals(currentStatus)) {
                    conn.rollback();
                    LOGGER.info(() -> "Booking " + bookingCode + " is already CONFIRMED");
                    return true;
                }

                if (!"PENDING".equals(currentStatus)) {
                    conn.rollback();
                    LOGGER.warning(() -> "Booking " + bookingCode + " is in status " + currentStatus + ", cannot confirm");
                    return false;
                }

                // 2. Validate amount:
                // Special Dev/Test feature: Allow test transfers of >= 1,000 VND so developer/user can test with 1,000 VND!
                boolean isTestTransfer = receivedAmount.compareTo(BigDecimal.valueOf(1000)) >= 0
                        && booking.getTotalAmount() != null
                        && receivedAmount.compareTo(booking.getTotalAmount()) < 0;

                if (isTestTransfer) {
                    LOGGER.info(() -> "Dev Test Mode: Accepted test transfer of " + receivedAmount + " VND for booking " + bookingCode);
                } else if (receivedAmount.compareTo(BigDecimal.ZERO) > 0 &&
                        booking.getTotalAmount() != null &&
                        receivedAmount.compareTo(booking.getTotalAmount()) < 0) {
                    conn.rollback();
                    LOGGER.warning(() -> "Received amount " + receivedAmount + " is less than booking total " + booking.getTotalAmount());
                    return false;
                }

                // 3. Find or create pending payment
                Payment payment = paymentDAO.findPendingByBookingId(conn, booking.getId());
                long paymentId;

                if (payment == null) {
                    payment = new Payment();
                    payment.setPaymentCode("PAY-" + UUID.randomUUID().toString().substring(0, 18).toUpperCase());
                    payment.setUserId((long) (booking.getUserId() != null ? booking.getUserId() : 1));
                    payment.setBookingId((long) booking.getId());
                    payment.setAmount(booking.getTotalAmount());
                    payment.setPaymentMethod("VIETQR");
                    paymentId = paymentDAO.insertPending(conn, payment);
                } else {
                    paymentId = payment.getPaymentId();
                }

                // 4. Financial allocation (platform commission & host payout)
                try {
                    paymentAllocationService.allocatePendingPayment(conn, paymentId);
                } catch (Exception ex) {
                    LOGGER.warning("Allocation notice: " + ex.getMessage());
                }

                // 5. Mark payment as SUCCESS
                boolean paymentUpdated = paymentDAO.markSuccess(conn, paymentId, transactionId);
                if (!paymentUpdated) {
                    throw new IllegalStateException("Failed to mark payment as SUCCESS");
                }

                // 6. Confirm booking
                boolean bookingConfirmed = bookingDAO.confirmPendingBooking(conn, booking.getId());
                if (!bookingConfirmed) {
                    throw new IllegalStateException("Failed to confirm booking " + bookingCode);
                }

                // 7. Mark QR as paid
                try {
                    paymentQrCodeDAO.markPaidByPaymentId(conn, paymentId);
                } catch (Exception ignored) {
                }

                conn.commit();
                LOGGER.info(() -> "Successfully confirmed booking " + bookingCode + " via SePay Webhook! TRX=" + transactionId);

                // 8. Trigger booking confirmation email (asynchronous)
                try {
                    Room room = roomDAO.findById(booking.getRoomId()).orElse(null);
                    emailService.sendBookingConfirmationEmailAsync(booking, payment, room);
                } catch (Exception emailEx) {
                    LOGGER.warning(() -> "Could not send confirmation email: " + emailEx.getMessage());
                }

                return true;

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }
}
