package com.homestay.controller;

import com.homestay.util.LoginUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Ends an authenticated session after validating the logout request.
 * Supports both POST and GET methods to guarantee smooth sign-out experience.
 */
public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    private void processLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);

        // If no active session, simply redirect to home
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/?logout=success");
            return;
        }

        String submittedToken = request.getParameter("csrfToken");
        boolean validToken = LoginUtil.isValidLogoutCsrfToken(request, submittedToken);

        // Allow logout when CSRF token matches OR request is an explicit POST from same site
        String referer = request.getHeader("Referer");
        String origin = request.getHeader("Origin");
        String host = request.getHeader("Host");
        boolean isSameOrigin = (origin != null && host != null && origin.contains(host))
                || (referer != null && host != null && referer.contains(host));

        if (validToken || isSameOrigin || "POST".equalsIgnoreCase(request.getMethod())) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/?logout=success");
            return;
        }

        // Suspicious cross-origin GET requests without token will be denied
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid logout request.");
    }
}

