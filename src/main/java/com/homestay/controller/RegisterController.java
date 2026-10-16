package com.homestay.controller;

import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import com.homestay.util.LoginUtil;
import com.homestay.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.sql.SQLException;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;

/** Handles customer registration, input validation, and automatic sign-in. */
public class RegisterController extends HttpServlet {
    // 3-20 chars, starts with letter, ends with letter or digit, no consecutive special chars [_.-]
    private static final Pattern USERNAME_PATTERN =
            Pattern.compile("^(?!.*[_.-]{2})[a-zA-Z][a-zA-Z0-9._-]{1,18}[a-zA-Z0-9]$");

    // Client/Server RFC-compliant basic email regex
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");

    // Vietnamese 10-digit phone format (03/05/07/08/09 or +84...)
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^(0|\\+84)[35789]\\d{8}$");

    // Password: 8-128 chars, requiring uppercase, lowercase, digit, and special char
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{}|;:',.<>?/\\\\`~])[A-Za-z\\d!@#$%^&*()_+\\-=\\[\\]{}|;:',.<>?/\\\\`~]{8,128}$");

    private static final Set<String> RESERVED_USERNAMES = Set.of(
            "admin", "administrator", "root", "system", "api", "support",
            "help", "login", "register", "auth", "superuser", "moderator",
            "mod", "null", "undefined", "user", "guest", "owner", "host",
            "homestay", "sogo", "official", "info", "security"
    );

    private static final Set<String> COMMON_WEAK_PASSWORDS = Set.of(
            "12345678", "123456789", "1234567890", "password", "password123",
            "admin123", "qwertyuiop", "12345678a", "12345678a!", "password123!",
            "admin123!", "qwerty123!", "welcome123!", "letmein123!"
    );

    private static final Set<String> DISPOSABLE_EMAIL_DOMAINS = Set.of(
            "tempmail.com", "mailinator.com", "10minutemail.com", "yopmail.com",
            "trashmail.com", "guerrillamail.com", "sharklasers.com", "dispostable.com"
    );

    private final UserDAO userDAO = new UserDAO();

    /** Displays the registration form and its one-time form token. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("1".equals(request.getParameter("success"))) {
            request.setAttribute("messageSuccess", "Tài khoản đã được tạo thành công.");
        }
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    /** Validates registration fields, creates the account, and signs it in. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Normalize username and email to lowercase for consistent case handling.
        String username = valueOrEmpty(request.getParameter("username")).trim().toLowerCase(Locale.ROOT);
        String phone = valueOrEmpty(request.getParameter("phone")).trim();
        String email = valueOrEmpty(request.getParameter("email")).trim().toLowerCase(Locale.ROOT);
        String password = valueOrEmpty(request.getParameter("password"));
        String confirmPassword = valueOrEmpty(request.getParameter("confirmPassword"));

        request.setAttribute("username", username);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);

        if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("messageError", "Phiên đăng ký hết hạn. Vui lòng thử lại.");
            forwardToRegister(request, response);
            return;
        }

        // Validate all submitted fields before hashing the password or writing to the database.
        String validationError = validate(username, phone, email, password, confirmPassword);
        if (validationError != null) {
            request.setAttribute("messageError", validationError);
            forwardToRegister(request, response);
            return;
        }

        try {
            // Check for existing duplicate username, phone, or email.
            String duplicateError = checkDuplicate(username, phone, email);
            if (duplicateError != null) {
                request.setAttribute("messageError", duplicateError);
                forwardToRegister(request, response);
                return;
            }

            // Hash the password before storing a new local account.
            User user = new User();
            user.setUsername(username);
            user.setDisplayName(email.substring(0, email.indexOf('@')));
            user.setPhone(phone);
            user.setEmail(email);
            user.setPassword(PasswordUtil.hash(password));

            if (!userDAO.insert(user)) {
                request.setAttribute("messageError", "Không thể tạo tài khoản. Vui lòng thử lại.");
                forwardToRegister(request, response);
                return;
            }

            User registeredUser = userDAO.findById(user.getId());
            if (registeredUser == null) {
                throw new SQLException("The newly created account could not be loaded.");
            }
            LoginUtil.signIn(request, registeredUser);
            response.sendRedirect(request.getContextPath() + "/");
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                request.setAttribute("messageError", "Tên đăng nhập, email hoặc số điện thoại đã được sử dụng.");
                forwardToRegister(request, response);
                return;
            }
            throw new ServletException("Không thể lưu tài khoản đăng ký.", e);
        } catch (GeneralSecurityException e) {
            throw new ServletException("Không thể mã hóa mật khẩu.", e);
        }
    }

    /** Restores the form token and forwards validation errors to the registration JSP. */
    private void forwardToRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    /** Returns the first registration validation error, or {@code null} when valid. */
    private String validate(String username, String phone, String email,
                            String password, String confirmPassword) {
        // --- 1. USERNAME VALIDATION ---
        if (username.length() < 3 || username.length() > 20) {
            return "Tên đăng nhập phải có từ 3 đến 20 ký tự.";
        }
        if (RESERVED_USERNAMES.contains(username)) {
            return "Tên đăng nhập này thuộc từ khóa hệ thống, vui lòng chọn tên khác.";
        }
        if (!USERNAME_PATTERN.matcher(username).matches()) {
            return "Tên đăng nhập phải bắt đầu bằng chữ cái, kết thúc bằng chữ cái hoặc số, không chứa khoảng trắng hay hai ký tự đặc biệt liên tiếp.";
        }

        // --- 2. PHONE VALIDATION ---
        if (phone.isEmpty() || !PHONE_PATTERN.matcher(phone).matches()) {
            return "Số điện thoại không hợp lệ (gồm 10 chữ số Việt Nam, ví dụ: 0912345678 hoặc +84912345678).";
        }

        // --- 3. EMAIL VALIDATION ---
        if (email.isEmpty() || email.length() > 254 || !EMAIL_PATTERN.matcher(email).matches()) {
            return "Định dạng email không hợp lệ (tối đa 254 ký tự).";
        }
        int atIndex = email.indexOf('@');
        if (atIndex <= 0 || atIndex > 64) {
            return "Phần tên email (trước @) không hợp lệ (tối đa 64 ký tự).";
        }
        String localPart = email.substring(0, atIndex);
        String domainPart = email.substring(atIndex + 1);

        if (localPart.startsWith(".") || localPart.endsWith(".") || localPart.contains("..")) {
            return "Phần tên email không được bắt đầu, kết thúc hoặc chứa hai dấu chấm liên tiếp.";
        }
        if (domainPart.startsWith(".") || domainPart.endsWith(".")
                || domainPart.startsWith("-") || domainPart.endsWith("-")) {
            return "Tên miền email không hợp lệ.";
        }
        if (DISPOSABLE_EMAIL_DOMAINS.contains(domainPart)) {
            return "Vui lòng không sử dụng email tạm thời (disposable email).";
        }

        // --- 4. PASSWORD VALIDATION ---
        if (password.length() < 8 || password.length() > 128) {
            return "Mật khẩu cần có từ 8 đến 128 ký tự.";
        }
        if (password.contains(" ")) {
            return "Mật khẩu không được chứa khoảng trắng.";
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            return "Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt (!@#$%^&*...).";
        }
        String lowerPassword = password.toLowerCase(Locale.ROOT);
        if (lowerPassword.contains(username)) {
            return "Mật khẩu không được chứa tên đăng nhập.";
        }
        if (localPart.length() >= 3 && lowerPassword.contains(localPart)) {
            return "Mật khẩu không được chứa phần tên email.";
        }
        if (COMMON_WEAK_PASSWORDS.contains(lowerPassword)) {
            return "Mật khẩu quá đơn giản và dễ đoán. Vui lòng chọn mật khẩu mạnh hơn.";
        }
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }

        return null;
    }

    /** Checks whether the specified email is already registered in the system. */
    public boolean checkDuplicateEmail(String email) throws SQLException {
        return userDAO.existsByEmail(email);
    }

    /** Checks whether the specified phone number is already registered in the system. */
    public boolean checkDuplicatePhone(String phone) throws SQLException {
        return userDAO.existsByPhone(phone);
    }

    /** Checks whether the specified username is already registered in the system. */
    public boolean checkDuplicateUsername(String username) throws SQLException {
        return userDAO.existsByUsername(username);
    }

    /** Checks for duplicate registration credentials and returns an error message, or null if clear. */
    public String checkDuplicate(String username, String phone, String email) throws SQLException {
        if (checkDuplicateUsername(username)) {
            return "Tên đăng nhập đã tồn tại trong hệ thống.";
        }
        if (checkDuplicatePhone(phone)) {
            return "Số điện thoại đã được sử dụng.";
        }
        if (checkDuplicateEmail(email)) {
            return "Email đã được sử dụng.";
        }
        return null;
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value;
    }
}
