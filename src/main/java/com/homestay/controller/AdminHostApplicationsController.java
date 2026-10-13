package com.homestay.controller;

import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

// --- START: AdminHostApplicationsController Flow ---
/**
 * Purpose: Authorizes administrators and renders the Host application management page.
 * Flow: Receives request -> validates session & admin role -> forwards to JSP.
 */
public class AdminHostApplicationsController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/admin/host-applications.jsp";

    private final UserDAO userDAO = new UserDAO();

    /**
     * Purpose: Loads the admin page after validating the signed-in administrator.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse)
     * Return value: None (Forwards to JSP)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // --- START: Authentication and Authorization Flow ---
        // Step 1: Validate session presence
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Step 2: Reload the account from DB so authorization uses current role and status.
            int userId = ((Number) session.getAttribute("userId")).intValue();
            User admin = userDAO.findById(userId); // SQL Execution via DAO
            
            // Step 3: Check if account exists and is ACTIVE
            if (admin == null || !"ACTIVE".equals(admin.getStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            
            // Step 4: Verify Admin role permissions
            if (admin.getRole() == null || !"ADMIN".equals(admin.getRole().getName())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            // --- END: Authentication and Authorization Flow ---

            // --- START: Page Rendering Flow ---
            // Step 5: Set UI state and forward request to the View
            session.setAttribute("role", "ADMIN");
            request.setAttribute("activePage", "admin-host-applications");
            request.getRequestDispatcher(VIEW).forward(request, response);
            // --- END: Page Rendering Flow ---
        } catch (SQLException e) {
            throw new ServletException("Unable to authorize the Host Applications page.", e);
        }
    }

    /**
     * Purpose: Rejects unsupported form submissions for this read-only page.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse)
     * Return value: None
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
// --- END: AdminHostApplicationsController Flow ---
