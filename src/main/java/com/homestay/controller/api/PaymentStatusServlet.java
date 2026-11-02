package com.homestay.controller.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Real-time payment status polling endpoint.
 *
 * GET /api/payment/status?bookingId=5
 * or GET /api/payment/status?bookingCode=BK-123...
 */
@WebServlet(
        name = "PaymentStatusServlet",
        urlPatterns = {"/api/payment/status"}
)
public class PaymentStatusServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private PaymentDAO paymentDAO;
    private ObjectMapper objectMapper;

    @Override
    public void init() throws ServletException {
        super.init();
        bookingDAO = new BookingDAO();
        paymentDAO = new PaymentDAO();
        objectMapper = new ObjectMapper();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String bookingIdParam = request.getParameter("bookingId");
        String bookingCodeParam = request.getParameter("bookingCode");

        Optional<Booking> bookingOpt = Optional.empty();

        if (bookingIdParam != null && !bookingIdParam.isBlank()) {
            try {
                int bookingId = Integer.parseInt(bookingIdParam.trim());
                bookingOpt = bookingDAO.findById(bookingId);
            } catch (NumberFormatException ignored) {
            }
        } else if (bookingCodeParam != null && !bookingCodeParam.isBlank()) {
            bookingOpt = bookingDAO.findByBookingCode(bookingCodeParam.trim());
        }

        Map<String, Object> result = new HashMap<>();

        if (bookingOpt.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            result.put("success", false);
            result.put("message", "Booking not found");
            objectMapper.writeValue(response.getWriter(), result);
            return;
        }

        Booking booking = bookingOpt.get();
        String status = booking.getStatus() != null ? booking.getStatus().toUpperCase() : "PENDING";
        boolean isPaid = "CONFIRMED".equals(status) || "PAID".equals(status);

        Payment payment = paymentDAO.findLatestByBookingId(booking.getId());

        result.put("success", true);
        result.put("bookingId", booking.getId());
        result.put("bookingCode", booking.getBookingCode());
        result.put("status", status);
        result.put("isPaid", isPaid);
        result.put("totalAmount", booking.getTotalAmount());

        if (payment != null) {
            result.put("paymentStatus", payment.getStatus());
            result.put("transactionId", payment.getTransactionId());
            result.put("paidAt", payment.getPaidAt() != null ? payment.getPaidAt().toString() : null);
        }

        objectMapper.writeValue(response.getWriter(), result);
    }
}

