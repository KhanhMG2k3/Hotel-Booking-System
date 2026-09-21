package com.homestay.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * LogoutServlet - Handles user logout for both GET and POST requests.
 * Invalidates session, removes authentication cookies, sets no-cache headers,
 * and redirects safely to the home page with a logout notification status.
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

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
        // 1. Invalidate current session if active
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // 2. Clear JSESSIONID cookie
        Cookie jsessionCookie = new Cookie("JSESSIONID", "");
        jsessionCookie.setMaxAge(0);
        String contextPath = request.getContextPath();
        jsessionCookie.setPath(contextPath == null || contextPath.isEmpty() ? "/" : contextPath);
        response.addCookie(jsessionCookie);

        // 3. Prevent browser from serving cached authenticated pages
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // 4. Redirect to home page with logout success parameter
        response.sendRedirect(request.getContextPath() + "/home?logout=success");
    }

    @Override
    public String getServletInfo() {
        return "Sogo Homestay Logout Servlet";
    }
}
