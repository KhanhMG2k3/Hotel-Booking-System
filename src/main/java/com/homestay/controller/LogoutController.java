package com.homestay.controller;

import com.homestay.util.LoginUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Ends an authenticated session after validating the logout CSRF token. */
public class LogoutController extends HttpServlet {
    /** Invalidates the current session and redirects to the public home page. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!LoginUtil.isValidLogoutCsrfToken(request, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid logout request.");
            return;
        }

        // Invalidate only an existing session, then return the browser to the home page.
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/");
    }
}
