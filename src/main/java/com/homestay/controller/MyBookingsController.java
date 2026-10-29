package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.model.Booking;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controller for managing customer's booking history (/my-bookings).
 */
@WebServlet(name = "MyBookingsController", urlPatterns = {"/my-bookings", "/my-bookings/*"})
public class MyBookingsController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final BookingDAO bookingDAO;

    public MyBookingsController() {
        this.bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/my-bookings");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo != null && pathInfo.equals("/cancel")) {
            handleCancel(request, response, user);
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.trim().isEmpty()) {
            statusFilter = "ALL";
        } else {
            statusFilter = statusFilter.trim().toUpperCase();
        }

        List<Booking> allBookings = bookingDAO.findBookingsByUser(user.getId(), user.getEmail());

        List<Booking> filteredBookings;
        if (!"ALL".equals(statusFilter)) {
            final String filter = statusFilter;
            filteredBookings = allBookings.stream()
                    .filter(b -> filter.equalsIgnoreCase(b.getStatus()))
                    .collect(Collectors.toList());
        } else {
            filteredBookings = allBookings;
        }

        long countAll = allBookings.size();
        long countConfirmed = allBookings.stream().filter(b -> "CONFIRMED".equalsIgnoreCase(b.getStatus())).count();
        long countPending = allBookings.stream().filter(b -> "PENDING".equalsIgnoreCase(b.getStatus())).count();
        long countCompleted = allBookings.stream().filter(b -> "COMPLETED".equalsIgnoreCase(b.getStatus())).count();
        long countCancelled = allBookings.stream().filter(b -> "CANCELLED".equalsIgnoreCase(b.getStatus())).count();

        request.setAttribute("bookings", filteredBookings);
        request.setAttribute("currentStatus", statusFilter);
        request.setAttribute("countAll", countAll);
        request.setAttribute("countConfirmed", countConfirmed);
        request.setAttribute("countPending", countPending);
        request.setAttribute("countCompleted", countCompleted);
        request.setAttribute("countCancelled", countCancelled);
        request.setAttribute("activePage", "my-bookings");

        request.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/my-bookings");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            handleCancel(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/my-bookings");
        }
    }

    private void handleCancel(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            bookingIdStr = request.getParameter("id");
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr.trim());
            boolean cancelled = bookingDAO.cancelBooking(bookingId, user.getId(), user.getEmail());
            if (cancelled) {
                request.getSession().setAttribute("messageSuccess", "Đã hủy đơn đặt phòng thành công.");
            } else {
                request.getSession().setAttribute("messageError", "Không thể hủy đơn đặt phòng này (chỉ đơn Chờ xử lý hoặc Đã xác nhận mới có thể hủy).");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("messageError", "Mã đơn đặt phòng không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/my-bookings");
    }
}
