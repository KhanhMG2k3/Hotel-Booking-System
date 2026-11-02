package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.dao.RefundDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.Refund;
import com.homestay.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * MyBookingsServlet - Manages customer booking history and status filtering.
 * URL: /my-bookings
 */
@WebServlet(name = "MyBookingsServlet", urlPatterns = {"/my-bookings"})
public class MyBookingsServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final RefundDAO refundDAO = new RefundDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/my-bookings");
            return;
        }

        // Fetch user's bookings with joined property and room details
        List<Booking> allBookings = bookingDAO.findByUserId(userId);

        // Attach refund and payment information to each booking
        int pendingCount = 0;
        int confirmedCount = 0;
        int cancelledCount = 0;
        int refundedCount = 0;

        for (Booking booking : allBookings) {
            // Find latest refund request if any
            Optional<Refund> refundOpt = refundDAO.findLatestByBookingId(booking.getId());
            refundOpt.ifPresent(booking::setRefund);

            // Find payment record
            Payment payment = paymentDAO.findLatestByBookingId(booking.getId());
            if (payment != null) {
                booking.setPayment(payment);
            }

            String st = booking.getStatus() != null ? booking.getStatus().toUpperCase() : "";
            switch (st) {
                case "PENDING" -> pendingCount++;
                case "CONFIRMED" -> confirmedCount++;
                case "CANCELLED" -> cancelledCount++;
                case "REFUNDED" -> refundedCount++;
            }
        }

        // Status tab filtering: ALL, PENDING, CONFIRMED, CANCELLED, REFUNDED
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isBlank()) {
            statusFilter = "ALL";
        } else {
            statusFilter = statusFilter.trim().toUpperCase();
        }

        List<Booking> displayBookings = new ArrayList<>();
        if ("ALL".equals(statusFilter)) {
            displayBookings = allBookings;
        } else {
            for (Booking b : allBookings) {
                if (statusFilter.equalsIgnoreCase(b.getStatus())) {
                    displayBookings.add(b);
                }
            }
        }

        // Quick search filter by booking code or property/room name
        String keyword = request.getParameter("q");
        if (keyword != null && !keyword.isBlank()) {
            String lowerKw = keyword.trim().toLowerCase();
            List<Booking> searched = new ArrayList<>();
            for (Booking b : displayBookings) {
                boolean matchCode = b.getBookingCode() != null && b.getBookingCode().toLowerCase().contains(lowerKw);
                boolean matchProp = b.getPropertyName() != null && b.getPropertyName().toLowerCase().contains(lowerKw);
                boolean matchRoom = b.getRoomName() != null && b.getRoomName().toLowerCase().contains(lowerKw);
                if (matchCode || matchProp || matchRoom) {
                    searched.add(b);
                }
            }
            displayBookings = searched;
            request.setAttribute("searchKeyword", keyword.trim());
        }

        request.setAttribute("bookings", displayBookings);
        request.setAttribute("totalCount", allBookings.size());
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("refundedCount", refundedCount);
        request.setAttribute("currentFilter", statusFilter);

        // Flash message from actions
        String msg = request.getParameter("msg");
        if ("refund_requested".equals(msg)) {
            request.setAttribute("successMessage", "Yêu cầu hủy phòng và hoàn tiền đã được gửi tới Host thành công!");
        } else if ("cancel_success".equals(msg)) {
            request.setAttribute("successMessage", "Đã hủy đơn đặt phòng thành công.");
        }

        request.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp").forward(request, response);
    }

    private Integer getLoggedInUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object userIdObj = session.getAttribute("userId");
        if (userIdObj instanceof Integer id) {
            return id;
        }
        Object userObj = session.getAttribute("user");
        if (userObj instanceof User u) {
            return u.getId();
        }
        return null;
    }
}
