package com.homestay.controller;

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
import java.sql.SQLException;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

// --- START: ProfileController Flow ---
/**
 * Purpose: Displays and updates the signed-in user's profile details and password.
 * Flow: Handles profile view (GET) and updates for profile details or password change (POST).
 */
public class ProfileController extends HttpServlet {
    private static final String PROFILE_VIEW = "/WEB-INF/views/profile.jsp";

    private static final Pattern USERNAME_PATTERN =
            Pattern.compile("^(?!.*[_.-]{2})[a-zA-Z][a-zA-Z0-9._-]{1,18}[a-zA-Z0-9]$");
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^(0|\\+84)[35789]\\d{8}$");

    // Password rule: 8-128 chars, requires uppercase, lowercase, digit, and special char
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{}|;:',.<>?/\\\\`~])[A-Za-z\\d!@#$%^&*()_+\\-=\\[\\]{}|;:',.<>?/\\\\`~]{8,128}$");

    private static final Set<String> COMMON_WEAK_PASSWORDS = Set.of(
            "12345678", "123456789", "1234567890", "password", "password123",
            "admin123", "qwertyuiop", "12345678a", "12345678a!", "password123!",
            "admin123!", "qwerty123!", "welcome123!", "letmein123!"
    );

    private static final Set<String> RESERVED_USERNAMES = Set.of(
            "admin", "administrator", "root", "system", "api", "support",
            "help", "login", "register", "auth", "superuser", "moderator",
            "mod", "null", "undefined", "user", "guest", "owner", "host",
            "homestay", "sogo", "official", "info", "security"
    );

    private final UserDAO userDAO = new UserDAO();

    /**
     * Purpose: Loads the active account profile and forwards it to the JSP.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse)
     * Return value: None (Forwards to profile view)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // --- START: Load Profile Flow ---
        Integer userId = getSignedInUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Step 1: Fetch active user record from database
            User user = userDAO.findById(userId);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Step 2: Handle success notifications from redirect query parameters
            if ("1".equals(request.getParameter("success"))) {
                request.setAttribute("messageSuccess", "Hồ sơ đã được cập nhật thành công.");
            }
            if ("1".equals(request.getParameter("passwordSuccess"))) {
                request.setAttribute("messagePasswordSuccess", "Mật khẩu của bạn đã được thay đổi thành công.");
            }

            // Step 3: Populate request attributes and forward to JSP
            prepareProfileView(request, user);
            request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load the customer profile.", e);
        }
        // --- END: Load Profile Flow ---
    }

    /**
     * Purpose: Dispatches POST requests to either profile update or password change flow.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse)
     * Return value: None
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Integer userId = getSignedInUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("changePassword".equals(action)) {
            handleChangePassword(request, response, userId);
        } else {
            handleUpdateProfile(request, response, userId);
        }
    }

    /**
     * Purpose: Validates password change input, verifies current credentials, and updates hash in database.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse), userId (int)
     * Return value: None
     */
    private void handleChangePassword(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        // --- START: Change Password Flow ---
        String currentPassword = valueOrEmpty(request.getParameter("currentPassword"));
        String newPassword = valueOrEmpty(request.getParameter("newPassword"));
        String confirmPassword = valueOrEmpty(request.getParameter("confirmPassword"));

        // Step 1: CSRF validation
        if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            request.setAttribute("messagePasswordError", "Phiên thao tác đã hết hạn. Vui lòng thử lại.");
            forwardWithLoadedProfile(request, response, userId);
            return;
        }

        try {
            // Step 2: Fetch current user from database
            User user = userDAO.findById(userId);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Step 3: Verify if user has a local password (not Google-only)
            if (user.getPassword() == null || user.getPassword().isEmpty()) {
                request.setAttribute("messagePasswordError",
                        "Tài khoản của bạn được liên kết qua Google và chưa thiết lập mật khẩu. Vui lòng sử dụng chức năng 'Quên mật khẩu' để tạo mật khẩu lần đầu.");
                forwardWithLoadedProfile(request, response, userId);
                return;
            }

            // Step 4: Validate current password with PBKDF2
            boolean currentMatches = PasswordUtil.verify(currentPassword, user.getPassword());
            if (!currentMatches) {
                request.setAttribute("messagePasswordError", "Mật khẩu hiện tại không chính xác. Vui lòng kiểm tra lại.");
                forwardWithLoadedProfile(request, response, userId);
                return;
            }

            // Step 5: Validate new password criteria
            String validationError = validateNewPassword(newPassword, confirmPassword, user);
            if (validationError != null) {
                request.setAttribute("messagePasswordError", validationError);
                forwardWithLoadedProfile(request, response, userId);
                return;
            }

            // Step 6: Hash new password using PBKDF2-HMAC-SHA256
            String hashedPassword = PasswordUtil.hash(newPassword);

            // Step 7: Update password in database
            if (!userDAO.updatePassword(userId, hashedPassword)) {
                request.setAttribute("messagePasswordError", "Không thể cập nhật mật khẩu. Vui lòng thử lại sau.");
                forwardWithLoadedProfile(request, response, userId);
                return;
            }

            // Send security alert email
            EmailUtil.sendSecurityAlertEmail(user.getEmail(), user.getDisplayName(),
                    "Mật khẩu tài khoản của bạn vừa được thay đổi thành công.");

            // Step 8: Invalidate current session for security and redirect to login
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/login?passwordChanged=1");
        } catch (SQLException e) {
            throw new ServletException("Unable to update password in database.", e);
        } catch (GeneralSecurityException e) {
            throw new ServletException("Unable to hash new password.", e);
        }
        // --- END: Change Password Flow ---
    }

    /**
     * Purpose: Validates and saves profile details (username, phone, 2FA) for the user.
     * Parameters: request (HttpServletRequest), response (HttpServletResponse), userId (int)
     * Return value: None
     */
    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        // --- START: Update Profile Details Flow ---
        String username = valueOrEmpty(request.getParameter("username")).trim().toLowerCase(Locale.ROOT);
        String phone = valueOrEmpty(request.getParameter("phone")).trim();
        boolean twoFactorEnabled = "on".equalsIgnoreCase(request.getParameter("twoFactorEnabled"))
                || "true".equalsIgnoreCase(request.getParameter("twoFactorEnabled"));

        // Step 1: CSRF validation
        if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            request.setAttribute("messageError", "Phiên chỉnh sửa đã hết hạn. Vui lòng thử lại.");
            forwardWithCurrentProfile(request, response, userId, username, phone, twoFactorEnabled);
            return;
        }

        // Step 2: Validate profile fields
        String validationError = validateProfile(username, phone);
        if (validationError != null) {
            request.setAttribute("messageError", validationError);
            forwardWithCurrentProfile(request, response, userId, username, phone, twoFactorEnabled);
            return;
        }

        try {
            // Step 3: Check for duplicate username or phone number
            if (userDAO.existsByUsernameExceptUser(username, userId)) {
                request.setAttribute("messageError", "Tên đăng nhập đã được sử dụng bởi tài khoản khác.");
                forwardWithCurrentProfile(request, response, userId, username, phone, twoFactorEnabled);
                return;
            }
            if (!phone.isEmpty() && userDAO.existsByPhoneExceptUser(phone, userId)) {
                request.setAttribute("messageError", "Số điện thoại đã được sử dụng bởi tài khoản khác.");
                forwardWithCurrentProfile(request, response, userId, username, phone, twoFactorEnabled);
                return;
            }

            // Step 4: Execute database update
            if (!userDAO.updateProfile(userId, username, phone.isEmpty() ? null : phone)) {
                request.setAttribute("messageError", "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
                forwardWithCurrentProfile(request, response, userId, username, phone, twoFactorEnabled);
                return;
            }

            User currentUser = userDAO.findById(userId);
            boolean oldTwoFactor = currentUser != null && currentUser.isTwoFactorEnabled();

            // Step 5: Update two-factor authentication setting
            userDAO.updateTwoFactor(userId, twoFactorEnabled);

            // Send security alert email if 2FA status changed
            if (currentUser != null && oldTwoFactor != twoFactorEnabled) {
                String alertDescription = twoFactorEnabled
                        ? "Xác thực hai bước (Email OTP) vừa được BẬT trên tài khoản của bạn."
                        : "Xác thực hai bước (Email OTP) vừa bị TẮT trên tài khoản của bạn.";
                EmailUtil.sendSecurityAlertEmail(currentUser.getEmail(), currentUser.getDisplayName(), alertDescription);
            }

            // Step 6: Update session attributes
            HttpSession session = request.getSession();
            String previousUsername = (String) session.getAttribute("username");
            session.setAttribute("username", username);
            if (session.getAttribute("displayName") == null
                    || session.getAttribute("displayName").equals(previousUsername)) {
                session.setAttribute("displayName", username);
            }
            response.sendRedirect(request.getContextPath() + "/profile?success=1");
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                request.setAttribute("messageError", "Tên đăng nhập hoặc số điện thoại đã được sử dụng.");
                forwardWithCurrentProfile(request, response, userId, username, phone, twoFactorEnabled);
                return;
            }
            throw new ServletException("Unable to update the customer profile.", e);
        }
        // --- END: Update Profile Details Flow ---
    }

    /**
     * Purpose: Validates new password rules and compares with current credentials.
     * Parameters: newPassword (String), confirmPassword (String), user (User)
     * Return value: String error message or null if valid
     */
    private String validateNewPassword(String newPassword, String confirmPassword, User user)
            throws GeneralSecurityException {
        if (newPassword.length() < 8 || newPassword.length() > 128) {
            return "Mật khẩu mới cần có từ 8 đến 128 ký tự.";
        }
        if (newPassword.contains(" ")) {
            return "Mật khẩu mới không được chứa khoảng trắng.";
        }
        if (!PASSWORD_PATTERN.matcher(newPassword).matches()) {
            return "Mật khẩu mới phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt (!@#$%^&*...).";
        }

        String lowerPassword = newPassword.toLowerCase(Locale.ROOT);
        if (lowerPassword.contains(user.getUsername().toLowerCase(Locale.ROOT))) {
            return "Mật khẩu mới không được chứa tên đăng nhập.";
        }

        String email = user.getEmail();
        if (email != null && email.contains("@")) {
            String localPart = email.substring(0, email.indexOf('@')).toLowerCase(Locale.ROOT);
            if (localPart.length() >= 3 && lowerPassword.contains(localPart)) {
                return "Mật khẩu mới không được chứa phần tên email của bạn.";
            }
        }

        if (COMMON_WEAK_PASSWORDS.contains(lowerPassword)) {
            return "Mật khẩu quá đơn giản và dễ đoán. Vui lòng chọn mật khẩu mạnh hơn.";
        }

        // Check if new password is the same as current password
        if (user.getPassword() != null && PasswordUtil.verify(newPassword, user.getPassword())) {
            return "Mật khẩu mới không được trùng với mật khẩu hiện tại.";
        }

        if (!newPassword.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp với mật khẩu mới.";
        }

        return null;
    }

    /**
     * Purpose: Reloads current profile data from DB and forwards to JSP with preserved error states.
     */
    private void forwardWithLoadedProfile(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            User user = userDAO.findById(userId);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            prepareProfileView(request, user);
            request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to reload the customer profile.", e);
        }
    }

    /**
     * Purpose: Reloads the account and forwards the submitted values after a failed update.
     */
    private void forwardWithCurrentProfile(HttpServletRequest request, HttpServletResponse response,
                                           int userId, String username, String phone, boolean twoFactorEnabled)
            throws ServletException, IOException {
        try {
            User user = userDAO.findById(userId);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            user.setUsername(username);
            user.setPhone(phone.isEmpty() ? null : phone);
            user.setTwoFactorEnabled(twoFactorEnabled);
            prepareProfileView(request, user);
            request.getRequestDispatcher(PROFILE_VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to reload the customer profile.", e);
        }
    }

    /**
     * Purpose: Removes sensitive credentials and adds display metadata required by the JSP.
     */
    private void prepareProfileView(HttpServletRequest request, User user) {
        String loginMethod;
        boolean hasPassword = user.getPassword() != null && !user.getPassword().isEmpty();

        if (hasPassword && user.getGoogleId() != null) {
            loginMethod = "Local and Google";
        } else if (user.getGoogleId() != null) {
            loginMethod = "Google";
        } else {
            loginMethod = "Local";
        }

        user.setPassword(null);
        user.setGoogleId(null);
        request.setAttribute("profile", user);
        request.setAttribute("hasPassword", hasPassword);
        request.setAttribute("accountRole", request.getSession().getAttribute("role"));
        request.setAttribute("loginMethod", loginMethod);
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.setAttribute("activePage", "profile");
    }

    /**
     * Purpose: Returns the session user ID, or {@code null} when the visitor is signed out.
     */
    private Integer getSignedInUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            return null;
        }
        return ((Number) session.getAttribute("userId")).intValue();
    }

    /**
     * Purpose: Returns the first profile validation error, or {@code null} when valid.
     */
    private String validateProfile(String username, String phone) {
        if (username.length() < 3 || username.length() > 20) {
            return "Tên đăng nhập phải có từ 3 đến 20 ký tự.";
        }
        if (RESERVED_USERNAMES.contains(username)) {
            return "Tên đăng nhập này thuộc từ khóa hệ thống, vui lòng chọn tên khác.";
        }
        if (!USERNAME_PATTERN.matcher(username).matches()) {
            return "Tên đăng nhập phải bắt đầu bằng chữ cái, kết thúc bằng chữ cái hoặc số, không chứa khoảng trắng hay hai ký tự đặc biệt liên tiếp.";
        }
        if (!phone.isEmpty() && !PHONE_PATTERN.matcher(phone).matches()) {
            return "Số điện thoại không hợp lệ (gồm 10 chữ số Việt Nam, ví dụ: 0912345678 hoặc +84912345678).";
        }
        return null;
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value;
    }
}
// --- END: ProfileController Flow ---

