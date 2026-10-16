package com.homestay.controller;

import com.homestay.context.AppConfig;
import com.homestay.dao.EmailOtpDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import com.homestay.util.EmailUtil;
import com.homestay.util.LoginUtil;
import com.homestay.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Locale;

/**
 * Handles local account sign-in, two-factor authentication, and prepares the login view.
 */
public class LoginController extends HttpServlet {
    private static final String LOGIN_VIEW = "/WEB-INF/views/login.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final EmailOtpDAO otpDAO = new EmailOtpDAO();
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private static final int MAX_FAILED_LOGINS = 5;
    private static final long LOCKOUT_DURATION_MS = 15 * 60 * 1000L; // 15 minutes lockout
    private static final java.util.concurrent.ConcurrentHashMap<String, LoginAttemptTracker> ATTEMPTS =
            new java.util.concurrent.ConcurrentHashMap<>();

    /** Inner helper class tracking failed login attempts and temporary lockout state per user identifier. */
    private static final class LoginAttemptTracker {
        private int failedCount;
        private long lockedUntil;

        synchronized boolean isLocked() {
            if (lockedUntil > System.currentTimeMillis()) {
                return true;
            }
            if (lockedUntil != 0L) {
                failedCount = 0;
                lockedUntil = 0L;
            }
            return false;
        }

        synchronized long getRemainingLockoutMinutes() {
            long diff = lockedUntil - System.currentTimeMillis();
            if (diff <= 0) return 0;
            return (diff + 59_999L) / 60_000L;
        }

        synchronized int recordFailure() {
            long now = System.currentTimeMillis();
            if (lockedUntil > now) {
                return failedCount;
            }
            failedCount++;
            if (failedCount >= MAX_FAILED_LOGINS) {
                lockedUntil = now + LOCKOUT_DURATION_MS;
            }
            return failedCount;
        }

        synchronized void reset() {
            failedCount = 0;
            lockedUntil = 0L;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loginError") != null) {
            request.setAttribute("messageError", session.getAttribute("loginError"));
            session.removeAttribute("loginError");
        }
        prepareLoginView(request);
        request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String loginIdentifier = valueOrEmpty(request.getParameter("loginIdentifier"))
                .trim().toLowerCase(Locale.ROOT);
        String password = valueOrEmpty(request.getParameter("password"));
        request.setAttribute("loginIdentifier", loginIdentifier);

        if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            request.setAttribute("messageError", "Phiên đăng nhập hết hạn. Vui lòng thử lại.");
            forwardToLogin(request, response);
            return;
        }
        if (loginIdentifier.isEmpty() || loginIdentifier.length() > 254
                || password.isEmpty() || password.length() > 128) {
            request.setAttribute("messageError", "Vui lòng nhập đầy đủ email/tên đăng nhập và mật khẩu hợp lệ.");
            forwardToLogin(request, response);
            return;
        }

        LoginAttemptTracker tracker = ATTEMPTS.computeIfAbsent(loginIdentifier, k -> new LoginAttemptTracker());
        if (tracker.isLocked()) {
            long remainingMinutes = tracker.getRemainingLockoutMinutes();
            request.setAttribute("messageError",
                    "Tài khoản đang bị tạm khóa 15 phút do nhập sai mật khẩu quá 5 lần. Vui lòng thử lại sau "
                    + remainingMinutes + " phút hoặc sử dụng 'Quên mật khẩu'.");
            forwardToLogin(request, response);
            return;
        }

        try {
            User user = userDAO.findByLoginIdentifier(loginIdentifier);
            if (user == null || user.getPassword() == null
                    || !PasswordUtil.verify(password, user.getPassword())) {
                int failed = tracker.recordFailure();
                int remainingAttempts = MAX_FAILED_LOGINS - failed;

                if (remainingAttempts <= 0) {
                    request.setAttribute("messageError",
                            "Bạn đã nhập sai mật khẩu 5 lần liên tiếp. Tài khoản đã bị tạm khóa trong 15 phút để đảm bảo an toàn.");
                } else {
                    request.setAttribute("messageError",
                            "Email/tên đăng nhập hoặc mật khẩu không đúng. Bạn còn " + remainingAttempts + " lần thử trước khi bị khóa tạm 15 phút.");
                }
                forwardToLogin(request, response);
                return;
            }

            if (!"ACTIVE".equals(user.getStatus())) {
                request.setAttribute("messageError", "Tài khoản của bạn đã bị khóa hoặc chưa được kích hoạt.");
                forwardToLogin(request, response);
                return;
            }

            tracker.reset();

            if (user.isTwoFactorEnabled()) {
                int codeNumber = 100000 + SECURE_RANDOM.nextInt(900000);
                String otpCode = String.valueOf(codeNumber);
                Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + 5 * 60 * 1000L);

                otpDAO.createOtp(user.getId(), otpCode, "LOGIN_2FA", expiresAt);
                EmailUtil.sendOtpEmail(user.getEmail(), user.getDisplayName(), otpCode);

                request.getSession().setAttribute("pending2faUserId", user.getId());
                request.getSession().setAttribute("otpLastSentTime", System.currentTimeMillis());
                request.getSession().setAttribute("otpFailedAttempts", 0);
                response.sendRedirect(request.getContextPath() + "/verify-otp");
                return;
            }

            LoginUtil.signIn(request, user);
            // If host, set host attributes for voucher management
            if (user.getRole() != null && "ROLE_HOST".equalsIgnoreCase(user.getRole().getName())) {
                request.getSession().setAttribute("hostUserId", user.getId());
                request.getSession().setAttribute("hostRole", "ROLE_HOST");
            }

            response.sendRedirect(request.getContextPath() + "/");
        } catch (SQLException e) {
            throw new ServletException("Unable to authenticate the local account.", e);
        } catch (GeneralSecurityException e) {
            throw new ServletException("Unable to verify the account password.", e);
        }
    }

    private void forwardToLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepareLoginView(request);
        request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
    }

    private void prepareLoginView(HttpServletRequest request) {
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.setAttribute("googleClientId", AppConfig.getGoogleClientId());
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value;
    }
}
