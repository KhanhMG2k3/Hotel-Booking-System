package com.homestay.controller;

import com.homestay.context.DBContext;
import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.dao.PaymentQrCodeDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.SystemBankAccountDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.PaymentQrCode;
import com.homestay.model.Room;
import com.homestay.model.SystemBankAccount;
import com.homestay.security.CsrfToken;
import com.homestay.service.EmailService;
import com.homestay.service.PaymentAllocationService;
import com.homestay.service.PaymentService;
import com.homestay.service.VietQrGenerator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

/**
 * CheckoutController - Handles booking checkout, VietQR payment generation,
 * and payment confirmation.
 */
@WebServlet(
        name = "CheckoutController",
        urlPatterns = {"/checkout"}
)
public class CheckoutController extends HttpServlet {

    private BookingDAO bookingDAO;
    private PaymentDAO paymentDAO;
    private PaymentQrCodeDAO paymentQrCodeDAO;
    private SystemBankAccountDAO systemBankAccountDAO;
    private RoomDAO roomDAO;
    private PaymentService paymentService;
    private PaymentAllocationService paymentAllocationService;
    private EmailService emailService;

    @Override
    public void init() throws ServletException {
        super.init();
        bookingDAO = new BookingDAO();
        paymentDAO = new PaymentDAO();
        paymentQrCodeDAO = new PaymentQrCodeDAO();
        systemBankAccountDAO = new SystemBankAccountDAO();
        roomDAO = new RoomDAO();
        paymentService = new PaymentService();
        paymentAllocationService = new PaymentAllocationService();
        emailService = EmailService.getInstance();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        // ==================== AUTHENTICATION ====================

        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendRedirect(request.getContextPath() + "/login?error="
                    + URLEncoder.encode("Vui lòng đăng nhập để thanh toán.", StandardCharsets.UTF_8));
            return;
        }

        int currentUserId = (Integer) session.getAttribute("userId");

        // ==================== CSRF TOKEN ====================

        if (!(session.getAttribute("csrfToken") instanceof String)) {
            session.setAttribute("csrfToken", CsrfToken.generate());
        }

        // ==================== VALIDATE BOOKING ID ====================

        String bookingIdParam = request.getParameter("bookingId");

        if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Thiếu mã đơn đặt phòng."
            );
            return;
        }

        final int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdParam.trim());
            if (bookingId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Mã đơn đặt phòng không hợp lệ."
            );
            return;
        }

        // ==================== LOAD BOOKING ====================

        Optional<Booking> bookingOptional = bookingDAO.findById(bookingId);

        if (bookingOptional.isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy đơn đặt phòng."
            );
            return;
        }

        Booking booking = bookingOptional.get();

        // ==================== AUTHORIZATION (IDOR Check) ====================

        if (booking.getUserId() == null || booking.getUserId() != currentUserId) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền truy cập đơn đặt phòng này."
            );
            return;
        }

        // ==================== STATUS: ALREADY CONFIRMED / PAID ====================

        String bookingStatus = booking.getStatus() != null ? booking.getStatus() : "PENDING";
        boolean isSuccessParam = "true".equalsIgnoreCase(request.getParameter("paymentSuccess"));

        if ("CONFIRMED".equalsIgnoreCase(bookingStatus) || "PAID".equalsIgnoreCase(bookingStatus) || isSuccessParam) {
            Payment payment = paymentDAO.findLatestByBookingId(bookingId);

            request.setAttribute("booking", booking);
            request.setAttribute("payment", payment);
            request.setAttribute("isConfirmed", true);
            request.setAttribute("subtotal", booking.getSubtotal());
            request.setAttribute("discountAmount", booking.getDiscountAmount());
            request.setAttribute("totalAmount", booking.getTotalAmount());
            request.setAttribute("activePage", "checkout");

            request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
            return;
        }

        // ==================== STATUS: CANCELLED ====================

        if ("CANCELLED".equalsIgnoreCase(bookingStatus)) {
            request.setAttribute("booking", booking);
            request.setAttribute("isCancelled", true);
            request.setAttribute("activePage", "checkout");
            request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
            return;
        }

        // ==================== STATUS: PENDING - PREPARE PAYMENT & VIETQR ====================

        BigDecimal totalAmount = booking.getTotalAmount();
        if (totalAmount == null || totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "Số tiền thanh toán không hợp lệ."
            );
            return;
        }

        // 1. Beneficiary Bank Account
        SystemBankAccount bankAccount = null;
        try {
            bankAccount = systemBankAccountDAO.findActiveDefaultAccount().orElse(null);
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (bankAccount == null) {
            bankAccount = new SystemBankAccount();
            bankAccount.setBankCode("MB");
            bankAccount.setBankName("Ngân hàng Quân Đội (MBBank)");
            bankAccount.setAccountNumber("0987654321");
            bankAccount.setAccountHolder("CONG TY TNHH SOGO HOMESTAY");
            bankAccount.setBinCode("970422");
            bankAccount.setQrTemplate("compact2");
        }

        // 2. Transfer content
        String bookingCode = booking.getBookingCode() != null && !booking.getBookingCode().isBlank()
                ? booking.getBookingCode()
                : "BK" + booking.getId();
        String transferContent = "HOMESTAY " + bookingCode;

        // 3. Create or reuse pending Payment record
        Payment payment = null;
        try {
            payment = paymentService.createPendingPayment(booking.getId(), currentUserId, "VIETQR");
        } catch (Exception e) {
            // If already exists or error, try finding it directly
            payment = paymentDAO.findLatestByBookingId(booking.getId());
        }

        // 4. Generate VietQR Napas URL
        String bin = bankAccount.getBinCode() != null && !bankAccount.getBinCode().isBlank()
                ? bankAccount.getBinCode()
                : "970422";
        String accNo = bankAccount.getAccountNumber();
        String template = bankAccount.getQrTemplate() != null && !bankAccount.getQrTemplate().isBlank()
                ? bankAccount.getQrTemplate()
                : "compact2";
        String amountStr = totalAmount.stripTrailingZeros().toPlainString();

        String qrImageUrl = String.format(
                "https://img.vietqr.io/image/%s-%s-%s.png?amount=%s&addInfo=%s&accountName=%s",
                bin,
                accNo,
                template,
                amountStr,
                URLEncoder.encode(transferContent, StandardCharsets.UTF_8),
                URLEncoder.encode(bankAccount.getAccountHolder(), StandardCharsets.UTF_8)
        );

        // 5. Generate local Base64 QR code via ZXing
        String qrBase64 = null;
        try {
            qrBase64 = VietQrGenerator.generateBase64(qrImageUrl, 320, 320);
        } catch (Exception e) {
            try {
                qrBase64 = VietQrGenerator.generateBase64(transferContent, 320, 320);
            } catch (Exception ignored) {
            }
        }

        // 6. Record PaymentQrCode if payment exists
        if (payment != null) {
            try (Connection conn = DBContext.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    PaymentQrCode existingQr = paymentQrCodeDAO.findPendingByPaymentIdForUpdate(conn, payment.getPaymentId());
                    if (existingQr == null) {
                        PaymentQrCode qr = new PaymentQrCode();
                        qr.setPaymentId(payment.getPaymentId());
                        qr.setBookingId((long) booking.getId());
                        qr.setBankCode(bankAccount.getBankCode());
                        qr.setAccountNumber(bankAccount.getAccountNumber());
                        qr.setAccountHolder(bankAccount.getAccountHolder());
                        qr.setAmount(totalAmount);
                        qr.setTransferContent(transferContent);
                        qr.setQrDataUrl(qrBase64 != null ? qrBase64 : qrImageUrl);
                        qr.setQrRawString(qrImageUrl);
                        qr.setExpiresAt(Timestamp.valueOf(LocalDateTime.now().plusMinutes(30)));
                        paymentQrCodeDAO.insertPending(conn, qr);
                    }
                    conn.commit();
                } catch (Exception ex) {
                    conn.rollback();
                }
            } catch (SQLException ignored) {
            }
        }

        // ==================== PASS DATA TO VIEW ====================

        request.setAttribute("booking", booking);
        request.setAttribute("payment", payment);
        request.setAttribute("bankAccount", bankAccount);
        request.setAttribute("transferContent", transferContent);
        request.setAttribute("qrImageUrl", qrImageUrl);
        request.setAttribute("qrBase64", qrBase64);
        request.setAttribute("subtotal", booking.getSubtotal());
        request.setAttribute("discountAmount", booking.getDiscountAmount());
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("activePage", "checkout");
        request.setAttribute("csrfToken", session.getAttribute("csrfToken"));

        request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
    }

    /**
     * Handles payment confirmation and cancellation.
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ==================== AUTHENTICATION ====================

        HttpSession session = request.getSession(false);

        if (session == null ||
                !(session.getAttribute("userId") instanceof Integer)) {

            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Vui lòng đăng nhập trước khi thực hiện thao tác."
            );
            return;
        }

        int currentUserId = (Integer) session.getAttribute("userId");

        // ==================== CSRF VALIDATION ====================

        String reqCsrf = request.getParameter("csrfToken");
        String sessionCsrf = (String) session.getAttribute("csrfToken");

        if (reqCsrf == null || sessionCsrf == null || !reqCsrf.equals(sessionCsrf)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Yêu cầu không hợp lệ (CSRF Token mismatch)."
            );
            return;
        }

        // ==================== PARSE PARAMETERS ====================

        String bookingIdParam = request.getParameter("bookingId");
        String action = request.getParameter("action");

        if (bookingIdParam == null || bookingIdParam.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã đơn đặt phòng.");
            return;
        }

        final int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdParam.trim());
            if (bookingId <= 0) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã đơn đặt phòng không hợp lệ.");
            return;
        }

        // ==================== ACTION: CANCEL BOOKING ====================

        if ("cancel".equalsIgnoreCase(action)) {
            try (Connection conn = DBContext.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    Booking booking = bookingDAO.findByIdForUpdate(conn, bookingId);
                    if (booking != null && booking.getUserId() != null && booking.getUserId() == currentUserId) {
                        bookingDAO.cancelPendingBooking(conn, bookingId, "Khách hàng hủy trên trang thanh toán");
                    }
                    conn.commit();
                    response.sendRedirect(request.getContextPath() + "/rooms?message="
                            + URLEncoder.encode("Đã hủy đơn đặt phòng thành công.", StandardCharsets.UTF_8));
                    return;
                } catch (Exception e) {
                    conn.rollback();
                    throw new ServletException("Lỗi khi hủy đơn đặt phòng: " + e.getMessage(), e);
                }
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        // ==================== ACTION: CONFIRM PAYMENT ====================

        if ("confirm".equalsIgnoreCase(action)) {
            try (Connection conn = DBContext.getConnection()) {
                conn.setAutoCommit(false);

                try {
                    // 1. Lock and verify booking
                    Booking booking = bookingDAO.findByIdForUpdate(conn, bookingId);

                    if (booking == null) {
                        conn.rollback();
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt phòng.");
                        return;
                    }

                    if (booking.getUserId() == null || booking.getUserId() != currentUserId) {
                        conn.rollback();
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thanh toán cho đơn này.");
                        return;
                    }

                    if (!"PENDING".equalsIgnoreCase(booking.getStatus())) {
                        conn.rollback();
                        response.sendRedirect(request.getContextPath() + "/checkout?bookingId=" + bookingId);
                        return;
                    }

                    // 2. Lock or create pending payment
                    Payment payment = paymentDAO.findPendingByBookingId(conn, bookingId);
                    long paymentId;

                    if (payment == null) {
                        payment = new Payment();
                        payment.setPaymentCode("PAY-" + UUID.randomUUID().toString().substring(0, 18).toUpperCase());
                        payment.setUserId((long) currentUserId);
                        payment.setBookingId((long) bookingId);
                        payment.setAmount(booking.getTotalAmount());
                        payment.setPaymentMethod("VIETQR");
                        paymentId = paymentDAO.insertPending(conn, payment);
                    } else {
                        paymentId = payment.getPaymentId();
                    }

                    // 3. Allocate platform fee and host net amount
                    try {
                        paymentAllocationService.allocatePendingPayment(conn, paymentId);
                    } catch (Exception allocationEx) {
                        System.err.println("Notice on allocation: " + allocationEx.getMessage());
                    }

                    // 4. Mark payment as SUCCESS
                    String trxId = "TRX-QR-" + System.currentTimeMillis();
                    boolean paymentUpdated = paymentDAO.markSuccess(conn, paymentId, trxId);

                    if (!paymentUpdated) {
                        throw new IllegalStateException("Không thể cập nhật trạng thái thanh toán.");
                    }

                    // 5. Confirm booking
                    boolean bookingConfirmed = bookingDAO.confirmPendingBooking(conn, bookingId);

                    if (!bookingConfirmed) {
                        throw new IllegalStateException("Không thể cập nhật trạng thái đơn đặt phòng.");
                    }

                    // 6. Mark QR code as PAID if exists
                    try {
                        paymentQrCodeDAO.markPaidByPaymentId(conn, paymentId);
                    } catch (Exception ignored) {
                    }

                    // 7. Commit transaction
                    conn.commit();

                    // 8. Trigger booking confirmation email (asynchronous)
                    try {
                        Room room = roomDAO.findById(booking.getRoomId()).orElse(null);
                        emailService.sendBookingConfirmationEmailAsync(booking, payment, room);
                    } catch (Exception emailEx) {
                        System.err.println("Could not dispatch confirmation email: " + emailEx.getMessage());
                    }

                    // Redirect back to checkout with success indicator
                    response.sendRedirect(request.getContextPath() + "/checkout?bookingId=" + bookingId + "&paymentSuccess=true");
                    return;

                } catch (Exception e) {
                    conn.rollback();
                    e.printStackTrace();
                    request.setAttribute("messageError", "Lỗi xử lý thanh toán: " + e.getMessage());
                    doGet(request, response);
                    return;
                }
            } catch (SQLException e) {
                throw new ServletException("Database error: " + e.getMessage(), e);
            }
        }

        // Unknown action
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thao tác không được hỗ trợ.");
    }
}
