package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostApplication;
import com.homestay.model.HostProfile;
import com.homestay.model.Property;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "AdminController", urlPatterns = {"/admin/dashboard"})
public class AdminController extends HttpServlet {

    private final HostApplicationDAO hostApplicationDAO = new HostApplicationDAO();
    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final UserDAO userDAO = new UserDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer roleId = (session != null) ? (Integer) session.getAttribute("roleId") : null;
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String roleName = (user != null && user.getRole() != null) ? user.getRole().getRoleName() : "";

        boolean isAdmin = (roleId != null && (roleId == 1 || roleId == 5))
                || "ROLE_ADMIN".equalsIgnoreCase(roleName)
                || "ADMIN".equalsIgnoreCase(roleName);

        if (!isAdmin) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return;
        }

        // Consume flash messages if present
        if (session != null) {
            if (session.getAttribute("messageSuccess") != null) {
                request.setAttribute("messageSuccess", session.getAttribute("messageSuccess"));
                session.removeAttribute("messageSuccess");
            }
            if (session.getAttribute("messageError") != null) {
                request.setAttribute("messageError", session.getAttribute("messageError"));
                session.removeAttribute("messageError");
            }
        }

        List<HostApplication> pendingHostApplications;
        try {
            pendingHostApplications = hostApplicationDAO.findPendingApplications();
        } catch (SQLException e) {
            pendingHostApplications = Collections.emptyList();
            e.printStackTrace();
        }

        List<HostProfile> pendingHostProfiles = hostProfileDAO.findPendingProfiles();
        List<User> allUsers = userDAO.findAll();
        List<Property> allProperties = propertyDAO.findAll();
        List<Booking> allBookings = bookingDAO.findAll();

        request.setAttribute("pendingHostApplications", pendingHostApplications);
        request.setAttribute("pendingHostProfiles", pendingHostProfiles);
        request.setAttribute("allUsers", allUsers);
        request.setAttribute("allProperties", allProperties);
        request.setAttribute("allBookings", allBookings);

        int totalPending = pendingHostApplications.size() + pendingHostProfiles.size();
        request.setAttribute("totalPendingHosts", totalPending);
        request.setAttribute("totalUsers", allUsers.size());
        request.setAttribute("totalProperties", allProperties.size());
        request.setAttribute("totalBookings", allBookings.size());

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin Dashboard Controller";
    }
}
