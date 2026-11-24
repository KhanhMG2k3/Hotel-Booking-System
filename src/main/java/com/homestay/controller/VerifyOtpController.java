package com.homestay.controller;

import com.homestay.dao.EmailOtpDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.EmailOtp;
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
import java.util.regex.Pattern;

// --- START: VerifyOtpController Flow ---
/**
 * Purpose: Handles two-factor authentication (2FA) verification, resend cooldown, and rate limiting.
 * Flow: Receives submitted OTP -> enforces attempt limits -> validates expiration -> signs user in.
 */
public class VerifyOtpController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/verify-otp.jsp";
    private static final Pattern OTP_PATTERN = Pattern.compile("^[0-9]{6}$");
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private static final long OTP_VALIDITY_MS = 5 * 60 * 1000L; // 5 minutes
    private static final long COOLDOWN_MS = 60 * 1000L; // 60 seconds resend cooldown
    private static final int MAX_FAILED_ATTEMPTS = 5; // Max 5 wrong attempts before session invalidation

    private final UserDAO userDAO = new UserDAO();
    private final EmailOtpDAO otpDAO = new EmailOtpDAO();

    /**
     * Purpose: Renders the OTP verification form for pending 2FA login.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse)
     * Return value: None (Forwards to JSP or redirects to /login)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // --- START: Verification Authorization Flow ---
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("pending2faUserId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = ((Number) session.getAttribute("pending2faUserId")).intValue();
        try {
            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                cleanupOtpSession(session);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Populate view attributes including cooldown and attempt counters
            prepareView(request, session, user);
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Unable to prepare OTP verification view.", e);
        }
        // --- END: Verification Authorization Flow ---
    }

    /**
     * Purpose: Validates the submitted OTP or processes a resend request with rate limiting.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse)
     * Return value: None (Signs in user or returns error feedback)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // --- START: Session and CSRF Validation Flow ---
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("pending2faUserId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int userId = ((Number) session.getAttribute("pending2faUserId")).intValue();
            String csrfToken = request.getParameter("csrfToken");
            if (!LoginUtil.consumeCsrfToken(request, csrfToken)) {
                request.setAttribute("messageError", "Phiên xác thực đã hết hạn. Vui lòng thử lại.");
                prepareViewAndForward(request, response, userId, session);
                return;
            }

            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                cleanupOtpSession(session);
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            String action = request.getParameter("action");

            // --- Flow Branch 1: Resend OTP Code with 60s Cooldown ---
            if ("resend".equals(action)) {
                long remainingCooldown = getRemainingCooldownSeconds(session);
                if (remainingCooldown > 0) {
                    request.setAttribute("messageError",
                            "Vui lòng đợi " + remainingCooldown + " giây trước khi yêu cầu gửi lại mã OTP mới.");
                    prepareViewAndForward(request, response, userId, session);
                    return;
                }

                int codeNumber = 100000 + SECURE_RANDOM.nextInt(900000);
                String otpCode = String.valueOf(codeNumber);
                Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + OTP_VALIDITY_MS);

                // SQL Execution: save newly issued OTP
                otpDAO.createOtp(userId, otpCode, "LOGIN_2FA", expiresAt);
                EmailUtil.sendOtpEmail(user.getEmail(), user.getDisplayName(), otpCode);

                // Reset cooldown and failed attempts tracker upon new OTP issuance
                session.setAttribute("otpLastSentTime", System.currentTimeMillis());
                session.setAttribute("otpFailedAttempts", 0);

                request.setAttribute("messageSuccess", "Mã OTP mới đã được gửi đến email của bạn.");
                prepareViewAndForward(request, response, userId, session);
                return;
            }

            // --- Flow Branch 2: Verify Submitted OTP with Rate Limiting (Max 5 attempts) ---
            String otpCode = request.getParameter("otpCode");
            if (otpCode == null || !OTP_PATTERN.matcher(otpCode.trim()).matches()) {
                request.setAttribute("messageError", "Mã OTP phải gồm đúng 6 chữ số.");
                prepareViewAndForward(request, response, userId, session);
                return;
            }

            EmailOtp validOtp = otpDAO.findLatestValidOtp(userId, "LOGIN_2FA");
            if (validOtp == null || !validOtp.getOtpCode().equals(otpCode.trim())) {
                int failed = getFailedAttempts(session) + 1;
                session.setAttribute("otpFailedAttempts", failed);
                int remainingAttempts = MAX_FAILED_ATTEMPTS - failed;

                if (remainingAttempts <= 0) {
                    // Lockout: Invalidate pending 2FA state due to brute force attempts
                    cleanupOtpSession(session);
                    session.setAttribute("loginError",
                            "Bạn đã nhập sai mã OTP quá 5 lần. Vì lý do bảo mật, phiên xác thực đã bị hủy. Vui lòng đăng nhập lại.");
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }

                request.setAttribute("messageError",
                        "Mã OTP không chính xác hoặc đã hết hạn. Bạn còn " + remainingAttempts + " lần thử.");
                prepareViewAndForward(request, response, userId, session);
                return;
            }

            // Step 3: Consume OTP and complete sign-in
            otpDAO.markAsUsed(validOtp.getId());
            cleanupOtpSession(session);
            LoginUtil.signIn(request, user);
            if (user.getRole() != null && "ROLE_HOST".equalsIgnoreCase(user.getRole().getName())) {
                request.getSession().setAttribute("hostUserId", user.getId());
                request.getSession().setAttribute("hostRole", "ROLE_HOST");
            }
            String redirectPath = LoginUtil.getPostLoginRedirectPath(user);
            response.sendRedirect(request.getContextPath() + redirectPath);

        } catch (SQLException e) {
            throw new ServletException("Unable to process 2FA verification.", e);
        }
        // --- END: Session and CSRF Validation Flow ---
    }

    /**
     * Calculates remaining cooldown time in seconds before a resend is allowed.
     */
    private long getRemainingCooldownSeconds(HttpSession session) {
        Object lastSentObj = session.getAttribute("otpLastSentTime");
        if (lastSentObj instanceof Long) {
            long lastSent = (Long) lastSentObj;
            long elapsed = System.currentTimeMillis() - lastSent;
            if (elapsed < COOLDOWN_MS) {
                return (COOLDOWN_MS - elapsed + 999) / 1000L;
            }
        }
        return 0L;
    }

    /**
     * Retrieves current failed attempts counter from session.
     */
    private int getFailedAttempts(HttpSession session) {
        Object attemptsObj = session.getAttribute("otpFailedAttempts");
        return (attemptsObj instanceof Integer) ? (Integer) attemptsObj : 0;
    }

    /**
     * Cleans up all pending 2FA state from session.
     */
    private void cleanupOtpSession(HttpSession session) {
        session.removeAttribute("pending2faUserId");
        session.removeAttribute("otpLastSentTime");
        session.removeAttribute("otpFailedAttempts");
    }

    /**
     * Helper to mask email address for privacy.
     */
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "email của bạn";
        }
        int atIndex = email.indexOf('@');
        String name = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        if (name.length() <= 2) {
            return name.charAt(0) + "***" + domain;
        }
        return name.charAt(0) + "***" + name.charAt(name.length() - 1) + domain;
    }

    /**
     * Populates view attributes including CSRF, masked email, and cooldown data.
     */
    private void prepareView(HttpServletRequest request, HttpSession session, User user) {
        request.setAttribute("maskedEmail", maskEmail(user.getEmail()));
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.setAttribute("cooldownSeconds", getRemainingCooldownSeconds(session));
        int remainingAttempts = Math.max(0, MAX_FAILED_ATTEMPTS - getFailedAttempts(session));
        request.setAttribute("remainingAttempts", remainingAttempts);
    }

    /**
     * Restores view attributes and forwards back to the JSP after validation failure.
     */
    private void prepareViewAndForward(HttpServletRequest request, HttpServletResponse response,
                                       int userId, HttpSession session)
            throws SQLException, ServletException, IOException {
        User user = userDAO.findById(userId).orElse(null);
        if (user != null) {
            prepareView(request, session, user);
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }
}
// --- END: VerifyOtpController Flow ---

