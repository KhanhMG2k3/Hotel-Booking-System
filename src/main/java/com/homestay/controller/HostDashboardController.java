package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostApplication;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/** Loads the signed-in Host's dashboard, owned property summaries, and dynamic revenue metrics. */
public class HostDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/host-dashboard.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final HostApplicationDAO applicationDAO = new HostApplicationDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    /** Authorizes the Host and forwards dashboard data to the JSP. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int userId = ((Number) session.getAttribute("userId")).intValue();
            // Check the persisted account and approval state before exposing Host data.
            User user = userDAO.findById(userId);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            if (user.getRole() == null || !"HOST".equals(user.getRole().getName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (!propertyDAO.isApprovedHost(userId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            session.setAttribute("role", "HOST");
            request.setAttribute("hostName", user.getDisplayName() == null
                    || user.getDisplayName().isBlank() ? user.getUsername() : user.getDisplayName());
            HostApplication application = applicationDAO.findLatestByUserId(userId);
            request.setAttribute("application", application);
            boolean isApproved = application != null && application.getStatus() == HostApplication.Status.APPROVED;
            request.setAttribute("applicationApproved", isApproved);

            // Fetch dynamic revenue statistics and recent reservations for approved Host
            if (isApproved) {
                int currentYear = LocalDate.now().getYear();
                BigDecimal totalRevenue = bookingDAO.getTotalRevenueByHost(userId);
                int totalBookings = bookingDAO.countTotalBookingsByHost(userId);
                int completedStays = bookingDAO.countCompletedStaysByHost(userId);
                Map<Integer, BigDecimal> monthlyData = bookingDAO.getMonthlyRevenueByHost(userId, currentYear);
                List<Booking> recentBookings = bookingDAO.findRecentBookingsByHost(userId, 10);

                // Build a JSON array of 12 monthly amounts for Chart.js
                StringBuilder sb = new StringBuilder("[");
                for (int m = 1; m <= 12; m++) {
                    BigDecimal amt = monthlyData.getOrDefault(m, BigDecimal.ZERO);
                    sb.append(amt.toPlainString());
                    if (m < 12) {
                        sb.append(",");
                    }
                }
                sb.append("]");

                request.setAttribute("totalRevenue", totalRevenue);
                request.setAttribute("totalBookings", totalBookings);
                request.setAttribute("completedStays", completedStays);
                request.setAttribute("currentYear", currentYear);
                request.setAttribute("monthlyRevenueJson", sb.toString());
                request.setAttribute("recentBookings", recentBookings);
            }

            request.setAttribute("properties", propertyDAO.findByOwnerId(userId));
            request.setAttribute("activePage", "host-dashboard");
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load the host dashboard.", e);
        }
    }
}
