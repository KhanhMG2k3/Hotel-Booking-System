package com.homestay.controller;

import com.homestay.dao.PasswordResetDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import com.homestay.util.EmailUtil;
import com.homestay.util.LoginUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.HexFormat;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Handles password reset requests and sends verification links by email.
 */
public class ForgotPasswordController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/forgot-password.jsp";
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final long TOKEN_VALIDITY_MS = 15 * 60 * 1000L; // 15 minutes

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();

    /**
     * Renders the forgot password request form.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Redirect already logged-in users to home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Step 2: Set CSRF token and forward to JSP view
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /**
     * Validates email submission, generates reset token, and triggers email sending.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Step 1: Validate CSRF token
        String csrfToken = request.getParameter("csrfToken");
        if (!LoginUtil.consumeCsrfToken(request, csrfToken)) {
            request.setAttribute("messageError", "Phiên yêu cầu đã hết hạn. Vui lòng thử lại.");
            request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        // Step 2: Validate email format
        String email = request.getParameter("email");
        if (email == null || email.isBlank() || email.length() > 254
                || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            request.setAttribute("messageError", "Vui lòng nhập định dạng email hợp lệ.");
            request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
            request.getRequestDispatcher(VIEW).forward(request, response);
            return;
        }

        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);

        try {
            // Step 3: Check if account exists and is active
            User user = userDAO.findByEmail(normalizedEmail).orElse(null);
            if (user != null && "ACTIVE".equals(user.getStatus())) {
                // Step 4: Generate cryptographically secure token
                byte[] randomBytes = new byte[32];
                SECURE_RANDOM.nextBytes(randomBytes);
                String token = HexFormat.of().formatHex(randomBytes);

                Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + TOKEN_VALIDITY_MS);

                // Step 5: Save token to database
                if (resetDAO.createResetToken(user.getId(), token, expiresAt)) {
                    // Step 6: Build reset URL
                    String baseUrl = request.getScheme() + "://" + request.getServerName();
                    int port = request.getServerPort();
                    if ((request.getScheme().equals("http") && port != 80)
                            || (request.getScheme().equals("https") && port != 443)) {
                        baseUrl += ":" + port;
                    }
                    String resetLink = baseUrl + request.getContextPath() + "/reset-password?token=" + token;

                    // Step 7: Send reset email
                    EmailUtil.sendResetPasswordEmail(user.getEmail(), user.getDisplayName(), resetLink);
                }
            }

            // Step 8: Always display generic success feedback to prevent account enumeration
            request.setAttribute("messageSuccess",
                    "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi liên kết đặt lại mật khẩu đến hộp thư của bạn. Vui lòng kiểm tra email.");
            request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Lỗi hệ thống khi xử lý yêu cầu đặt lại mật khẩu.", e);
        }
    }
}
