package com.homestay.controller;

import com.homestay.dao.PasswordResetDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.PasswordReset;
import com.homestay.util.LoginUtil;
import com.homestay.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.sql.SQLException;
import java.util.regex.Pattern;

/**
 * Validates reset token and allows user to specify a new password.
 */
public class ResetPasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/reset-password.jsp";

    // Password rule: 8-128 chars, requires uppercase, lowercase, digit, and special char
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{}|;:',.<>?/\\\\`~])[A-Za-z\\d!@#$%^&*()_+\\-=\\[\\]{}|;:',.<>?/\\\\`~]{8,128}$");

    private final PasswordResetDAO resetDAO = new PasswordResetDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Verifies the reset token from the URL query parameter and renders the reset form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Read and validate the token parameter
        String token = request.getParameter("token");
        if (token == null || token.isBlank() || token.length() != 64) {
            request.setAttribute("invalidToken", true);
            request.setAttribute("messageError", "Liên kết đặt lại mật khẩu không hợp lệ.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        try {
            // Step 2: Check if token exists, is unused and unexpired in database
            PasswordReset reset = resetDAO.findValidToken(token.trim());
            if (reset == null) {
                request.setAttribute("invalidToken", true);
                request.setAttribute("messageError", "Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            // Step 3: Token is valid; provide CSRF token and forward to reset form
            request.setAttribute("token", token.trim());
            request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Lỗi hệ thống khi kiểm tra liên kết đặt lại mật khẩu.", e);
        }
    }

    /**
     * Validates new password input, updates account credentials, and marks token as used.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String csrfToken = request.getParameter("csrfToken");

        // Step 1: Validate CSRF token
        if (!LoginUtil.consumeCsrfToken(request, csrfToken)) {
            request.setAttribute("messageError", "Phiên thao tác đã hết hạn. Vui lòng tải lại trang.");
            request.setAttribute("token", token);
            request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        // Step 2: Validate token format
        if (token == null || token.isBlank() || token.length() != 64) {
            request.setAttribute("invalidToken", true);
            request.setAttribute("messageError", "Liên kết đặt lại mật khẩu không hợp lệ.");
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        try {
            // Step 3: Verify token state in database
            PasswordReset reset = resetDAO.findValidToken(token.trim());
            if (reset == null) {
                request.setAttribute("invalidToken", true);
                request.setAttribute("messageError", "Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            // Step 4: Validate password input criteria
            String validationError = validatePassword(password, confirmPassword);
            if (validationError != null) {
                request.setAttribute("messageError", validationError);
                request.setAttribute("token", token.trim());
                request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            // Step 5: Hash new password using PBKDF2
            String hashedPassword = PasswordUtil.hash(password);

            // Step 6: Update user password in DB
            if (!userDAO.updatePassword(reset.getUserId(), hashedPassword)) {
                request.setAttribute("messageError", "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
                request.setAttribute("token", token.trim());
                request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            // Step 7: Invalidate the used token
            resetDAO.markTokenUsed(reset.getId());

            // Step 8: Redirect to login with success indicator
            response.sendRedirect(request.getContextPath() + "/login?resetSuccess=1");
        } catch (SQLException | GeneralSecurityException e) {
            throw new ServletException("Lỗi hệ thống khi cập nhật mật khẩu mới.", e);
        }
    }

    /**
     * Validates new password rules.
     */
    private String validatePassword(String password, String confirmPassword) {
        if (password == null || password.length() < 8 || password.length() > 128) {
            return "Mật khẩu cần có từ 8 đến 128 ký tự.";
        }
        if (password.contains(" ")) {
            return "Mật khẩu không được chứa khoảng trắng.";
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            return "Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt (!@#$%^&*...).";
        }
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }
        return null;
    }
}
