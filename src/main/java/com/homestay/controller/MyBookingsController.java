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
 * Controller for managing customer's booking history (/my-bookings).
 * Combines status filtering, keyword search, refund tracking, and cancellation.
 */
@WebServlet(name = "MyBookingsController", urlPatterns = {"/my-bookings", "/my-bookings/*"})
public class MyBookingsController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final BookingDAO bookingDAO;
    private final RefundDAO refundDAO;
    private final PaymentDAO paymentDAO;

    public MyBookingsController() {
        this(new BookingDAO(), new RefundDAO(), new PaymentDAO());
    }

    public MyBookingsController(BookingDAO bookingDAO, RefundDAO refundDAO, PaymentDAO paymentDAO) {
        this.bookingDAO = bookingDAO;
        this.refundDAO = refundDAO;
        this.paymentDAO = paymentDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/my-bookings");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.equals("/cancel")) {
            handleCancel(request, response, userId, user);
            return;
        }

        // Fetch bookings for this user
        List<Booking> allBookings = bookingDAO.findByUserId(userId);
        if (allBookings == null || allBookings.isEmpty()) {
            allBookings = bookingDAO.findBookingsByUser(userId, user != null ? user.getEmail() : null);
        }
        if (allBookings == null) {
            allBookings = new ArrayList<>();
        }

        // Attach refund & payment details and compute status counts
        int pendingCount = 0;
        int confirmedCount = 0;
        int cancelledCount = 0;
        int refundedCount = 0;
        int completedCount = 0;

        for (Booking booking : allBookings) {
            if (refundDAO != null) {
                Optional<Refund> refundOpt = refundDAO.findLatestByBookingId(booking.getId());
                refundOpt.ifPresent(booking::setRefund);
            }

            if (paymentDAO != null) {
                Payment payment = paymentDAO.findLatestByBookingId(booking.getId());
                if (payment != null) {
                    booking.setPayment(payment);
                }
            }

            String st = booking.getStatus() != null ? booking.getStatus().toUpperCase() : "";
            switch (st) {
                case "PENDING" -> pendingCount++;
                case "CONFIRMED" -> confirmedCount++;
                case "CANCELLED" -> cancelledCount++;
                case "REFUNDED" -> refundedCount++;
                case "COMPLETED" -> completedCount++;
            }
        }

        // Status tab filtering: ALL, PENDING, CONFIRMED, CANCELLED, REFUNDED, COMPLETED
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
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
        if (keyword != null && !keyword.trim().isEmpty()) {
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

        // Flash message from actions
        String msg = request.getParameter("msg");
        if ("refund_requested".equals(msg)) {
            request.setAttribute("successMessage", "Yêu cầu hủy phòng và hoàn tiền đã được gửi tới Host thành công!");
        } else if ("cancel_success".equals(msg)) {
            request.setAttribute("successMessage", "Đã hủy đơn đặt phòng thành công.");
        }

        request.setAttribute("bookings", displayBookings);
        request.setAttribute("totalCount", allBookings.size());
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("cancelledCount", cancelledCount);
        request.setAttribute("refundedCount", refundedCount);
        request.setAttribute("currentFilter", statusFilter);

        // Backwards compatibility attributes
        request.setAttribute("currentStatus", statusFilter);
        request.setAttribute("countAll", (long) allBookings.size());
        request.setAttribute("countConfirmed", (long) confirmedCount);
        request.setAttribute("countPending", (long) pendingCount);
        request.setAttribute("countCompleted", (long) completedCount);
        request.setAttribute("countCancelled", (long) cancelledCount);
        request.setAttribute("activePage", "my-bookings");

        request.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/my-bookings");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            handleCancel(request, response, userId, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/my-bookings");
        }
    }

    private void handleCancel(HttpServletRequest request, HttpServletResponse response, Integer userId, User user)
            throws IOException {
        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            bookingIdStr = request.getParameter("id");
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            String email = user != null ? user.getEmail() : null;
            boolean cancelled = bookingDAO.cancelBooking(bookingId, userId, email);
            if (cancelled) {
                request.getSession().setAttribute("messageSuccess", "Đã hủy đơn đặt phòng thành công.");
                response.sendRedirect(request.getContextPath() + "/my-bookings?msg=cancel_success");
                return;
            } else {
                request.getSession().setAttribute("messageError", "Không thể hủy đơn đặt phòng này (chỉ đơn Chờ xử lý hoặc Đã xác nhận mới có thể hủy).");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("messageError", "Mã đơn đặt phòng không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/my-bookings");
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
