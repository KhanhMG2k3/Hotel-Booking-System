package com.homestay.controller;

import com.homestay.dao.UserDAO;
import com.homestay.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

public class LoginController extends HttpServlet {

    private static final Logger LOGGER =
            Logger.getLogger(LoginController.class.getName());

    private static final String LOGIN_VIEW =
            "/WEB-INF/views/login.jsp";

    private static final String HOST_VOUCHERS =
            "/host/vouchers";

    private final UserDAO userDAO = new UserDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        HttpSession session = request.getSession(false);

        if (isAuthenticatedHost(session)) {
            response.sendRedirect(
                    request.getContextPath() + HOST_VOUCHERS);
            return;
        }

        // Create a session-bound CSRF token for the login form.
        if (session == null) {
            session = request.getSession(true);
        }

        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", generateCsrfToken());
        }

        request.setAttribute("pageTitle", "Đăng nhập Host - Sogo Homestay");
        request.getRequestDispatcher(LOGIN_VIEW)
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            handleLogout(request, response);
            return;
        }

        if (!"/login".equals(path)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        HttpSession session = request.getSession(false);

        if (session == null || !isValidCsrfToken(
                session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Yêu cầu không hợp lệ. Vui lòng tải lại trang.");
            return;
        }

        if (isAuthenticatedHost(session)) {
            response.sendRedirect(
                    request.getContextPath() + HOST_VOUCHERS);
            return;
        }

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            showLoginError(request, response,
                    "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            return;
        }

        Optional<User> authenticatedUser;

        try {
            authenticatedUser = userDAO.authenticateHost(
                    username.trim(), password);
        } catch (RuntimeException e) {
            LOGGER.log(Level.SEVERE, "Host authentication failed internally", e);
            showLoginError(request, response,
                    "Không thể đăng nhập lúc này. Vui lòng thử lại.");
            return;
        }

        if (authenticatedUser.isEmpty()) {
            showLoginError(request, response,
                    "Tên đăng nhập, mật khẩu không đúng hoặc tài khoản "
                    + "không có quyền Host đang hoạt động.");
            return;
        }

        User user = authenticatedUser.get();

        // Prevent session fixation by rotating the session ID after login.
        request.changeSessionId();

        // Store only the minimum identity and authorization information.
        session = request.getSession(false);
        session.setAttribute("hostUserId", user.getId());
        session.setAttribute("hostUsername", user.getUsername());
        session.setAttribute("hostRole", "ROLE_HOST");
        session.setAttribute("csrfToken", generateCsrfToken());

        response.sendRedirect(
                request.getContextPath() + HOST_VOUCHERS);
    }

    private void handleLogout(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || !isValidCsrfToken(
                session, request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Yêu cầu đăng xuất không hợp lệ.");
            return;
        }

        session.invalidate();

        response.sendRedirect(
                request.getContextPath() + "/login?loggedOut=1");
    }

    private void showLoginError(
            HttpServletRequest request,
            HttpServletResponse response,
            String message)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            session = request.getSession(true);
        }

        if (session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", generateCsrfToken());
        }

        request.setAttribute("loginError", message);
        request.setAttribute("pageTitle", "Đăng nhập Host - Sogo Homestay");

        request.getRequestDispatcher(LOGIN_VIEW)
                .forward(request, response);
    }

    private boolean isAuthenticatedHost(HttpSession session) {
        return session != null
                && session.getAttribute("hostUserId") instanceof Integer
                && "ROLE_HOST".equals(session.getAttribute("hostRole"));
    }

    private boolean isValidCsrfToken(
            HttpSession session, String submittedToken) {

        if (session == null || submittedToken == null) {
            return false;
        }

        Object savedToken = session.getAttribute("csrfToken");

        return savedToken instanceof String
                && java.security.MessageDigest.isEqual(
                        ((String) savedToken).getBytes(
                                java.nio.charset.StandardCharsets.UTF_8),
                        submittedToken.getBytes(
                                java.nio.charset.StandardCharsets.UTF_8));
    }

    private String generateCsrfToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);

        StringBuilder token = new StringBuilder(bytes.length * 2);

        for (byte b : bytes) {
            token.append(String.format("%02x", b & 0xff));
        }

        return token.toString();
    }
}
