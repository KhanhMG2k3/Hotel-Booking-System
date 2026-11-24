package com.homestay.controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.homestay.context.AppConfig;
import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import com.homestay.util.LoginUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.Locale;

/** Verifies Google sign-in credentials and links or creates local accounts. */
public class GoogleLoginController extends HttpServlet {
    private static final int MAX_CREDENTIAL_LENGTH = 8192;

    private final UserDAO userDAO = new UserDAO();

    /** Verifies the Google credential, signs in the matching account, and returns JSON. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        // Consume the one-time token before validating or processing the credential.
        if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN, "Phiên đăng nhập hết hạn. Vui lòng thử lại.");
            return;
        }

        String clientId = AppConfig.getGoogleClientId();
        String credential = request.getParameter("credential");
        if (clientId == null || clientId.isBlank()
                || credential == null || credential.length() > MAX_CREDENTIAL_LENGTH) {
            writeError(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Đăng nhập Google chưa được cấu hình hoặc yêu cầu không hợp lệ.");
            return;
        }

        try {
            // Verify the signature and audience before trusting Google claims.
            // Verify the signature and audience before trusting any identity claims.
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(clientId))
                    .build();
            GoogleIdToken idToken = verifier.verify(credential);
            if (idToken == null || !isValidGooglePayload(idToken.getPayload())) {
                writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "Không thể xác minh tài khoản Google.");
                return;
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String googleId = payload.getSubject();
            String email = payload.getEmail().trim().toLowerCase(Locale.ROOT);
            String displayName = getDisplayName(payload, email);
            String avatarUrl = getAvatarUrl(payload);
            User googleUser = userDAO.findByGoogleId(googleId).orElse(null);
            HttpSession session = request.getSession(false);
            Object sessionUserId = session == null ? null : session.getAttribute("userId");
            User user;

            if (sessionUserId instanceof Number) {
                user = linkGoogleToUser(
                        ((Number) sessionUserId).intValue(), email, googleId, googleUser, response);
                if (user == null) {
                    return;
                }
            } else if (googleUser != null) {
                if (!googleUser.getEmail().equalsIgnoreCase(email)) {
                    writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                            "Tài khoản Google không khớp với thông tin đã liên kết.");
                    return;
                }
                user = googleUser;
            } else {
                User emailUser = userDAO.findByEmail(email).orElse(null);
                if (emailUser != null) {
                    // Google confirmed this email, so reuse the existing account.
                    user = linkGoogleToUser(emailUser.getId(), email, googleId, googleUser, response);
                    if (user == null) {
                        return;
                    }
                } else {
                    user = createGoogleUser(email, googleId, displayName, avatarUrl, response);
                    if (user == null) {
                        return;
                    }
                }
            }

            // Inactive accounts must not establish a session, even with a valid Google token.
            if (!"ACTIVE".equals(user.getStatus())) {
                writeError(response, HttpServletResponse.SC_FORBIDDEN,
                        "Tài khoản hiện không thể đăng nhập.");
                return;
            }

            if (!userDAO.updateGoogleProfile(user.getId(), displayName, avatarUrl)) {
                writeError(response, HttpServletResponse.SC_CONFLICT,
                        "Không thể cập nhật thông tin tài khoản Google.");
                return;
            }
            user = userDAO.findById(user.getId()).orElse(null);
            if (user == null) {
                writeError(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "Không thể tải thông tin tài khoản.");
                return;
            }

            // Refresh the account snapshot before publishing authenticated session data.
            LoginUtil.signIn(request, user);
            if (user.getRole() != null && "ROLE_HOST".equalsIgnoreCase(user.getRole().getName())) {
                request.getSession().setAttribute("hostUserId", user.getId());
                request.getSession().setAttribute("hostRole", "ROLE_HOST");
            }
            String redirectPath = LoginUtil.getPostLoginRedirectPath(user);
            response.setStatus(HttpServletResponse.SC_OK);
            response.setContentType("application/json");
            response.setCharacterEncoding(StandardCharsets.UTF_8.name());
            response.getWriter().write("{\"success\":true,\"redirectUrl\":\"" + request.getContextPath() + redirectPath + "\"}");
        } catch (GeneralSecurityException | SQLException e) {
            throw new ServletException("Unable to authenticate the Google account.", e);
        }
    }

    /** Links an identity only when ownership and email checks match the account. */
    private User linkGoogleToUser(int userId, String email, String googleId, User googleUser,
                                  HttpServletResponse response)
            throws SQLException, IOException {
        User signedInUser = userDAO.findById(userId).orElse(null);
        if (signedInUser == null || !"ACTIVE".equals(signedInUser.getStatus())) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN,
                    "Tài khoản hiện không thể liên kết Google.");
            return null;
        }
        if (!signedInUser.getEmail().equalsIgnoreCase(email)) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Email Google phải khớp với email của tài khoản đang đăng nhập.");
            return null;
        }
        if (googleUser != null && googleUser.getId() != signedInUser.getId()) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Tài khoản Google này đã được liên kết với một tài khoản khác.");
            return null;
        }
        if (signedInUser.getGoogleId() != null && !signedInUser.getGoogleId().equals(googleId)) {
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Tài khoản này đã liên kết với một tài khoản Google khác.");
            return null;
        }

        // Link conditionally in the DAO so a concurrent account-link attempt cannot overwrite it.
        if (signedInUser.getGoogleId() == null
                && !userDAO.linkGoogleId(signedInUser.getId(), signedInUser.getEmail(), googleId)) {
            User linkedUser = userDAO.findByGoogleId(googleId).orElse(null);
            if (linkedUser == null || linkedUser.getId() != signedInUser.getId()) {
                writeError(response, HttpServletResponse.SC_CONFLICT,
                        "Không thể liên kết tài khoản Google. Vui lòng thử lại.");
                return null;
            }
        }
        return signedInUser;
    }

    /** Creates a local account for a verified Google identity, handling duplicate races. */
    private User createGoogleUser(String email, String googleId, String displayName, String avatarUrl,
                                  HttpServletResponse response)
            throws GeneralSecurityException, SQLException, IOException {
        User googleUser = new User();
        googleUser.setUsername(generateUsernameFromEmail(email));
        googleUser.setEmail(email);
        googleUser.setGoogleId(googleId);
        googleUser.setDisplayName(displayName);
        googleUser.setAvatarUrl(avatarUrl);

        try {
            if (userDAO.insertGoogleUser(googleUser)) {
                return userDAO.findByGoogleId(googleId).orElse(null);
            }
            writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể tạo tài khoản Google.");
            return null;
        } catch (SQLException e) {
            if (e.getSQLState() == null || !e.getSQLState().startsWith("23")) {
                throw e;
            }
            User existingGoogleUser = userDAO.findByGoogleId(googleId).orElse(null);
            if (existingGoogleUser != null
                    && existingGoogleUser.getEmail().equalsIgnoreCase(email)) {
                return existingGoogleUser;
            }
            writeError(response, HttpServletResponse.SC_CONFLICT,
                    "Tài khoản Google hoặc email đã được sử dụng.");
            return null;
        }
    }

    /** Checks required verified claims before account lookup or creation. */
    private boolean isValidGooglePayload(GoogleIdToken.Payload payload) {
        return payload != null
                && payload.getSubject() != null
                && !payload.getSubject().isBlank()
                && payload.getEmail() != null
                && payload.getEmail().length() <= 100
                && Boolean.TRUE.equals(payload.getEmailVerified());
    }

    /** Returns a bounded Google display name or a name derived from the email. */
    private String getDisplayName(GoogleIdToken.Payload payload, String email) {
        Object claim = payload.get("name");
        if (claim instanceof String) {
            String displayName = ((String) claim).trim();
            if (!displayName.isEmpty() && displayName.length() <= 100) {
                return displayName;
            }
        }

        int atIndex = email.indexOf('@');
        return atIndex > 0 ? email.substring(0, atIndex) : email;
    }

    /** Returns only a valid HTTPS avatar URL from the verified token claims. */
    private String getAvatarUrl(GoogleIdToken.Payload payload) {
        Object claim = payload.get("picture");
        if (!(claim instanceof String)) {
            return null;
        }

        String avatarUrl = ((String) claim).trim();
        if (avatarUrl.isEmpty() || avatarUrl.length() > 500) {
            return null;
        }

        try {
            URI uri = URI.create(avatarUrl);
            return "https".equalsIgnoreCase(uri.getScheme()) && uri.getHost() != null
                    ? avatarUrl : null;
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /** Derives a clean, unique username from the email prefix (e.g. hungjohn2004@gmail.com -> hungjohn2004). */
    private String generateUsernameFromEmail(String email) throws SQLException {
        int atIndex = email.indexOf('@');
        String base = atIndex > 0 ? email.substring(0, atIndex).trim().toLowerCase(Locale.ROOT) : email.trim().toLowerCase(Locale.ROOT);

        // Sanitize: keep only letters, numbers, dots, underscores, and hyphens
        base = base.replaceAll("[^a-z0-9._-]", "");
        if (base.isEmpty()) {
            base = "user";
        }
        if (base.length() > 40) {
            base = base.substring(0, 40);
        }

        String candidate = base;
        int counter = 1;
        while (userDAO.existsByUsername(candidate)) {
            candidate = base + "_" + counter;
            counter++;
            if (candidate.length() > 50) {
                candidate = base.substring(0, 35) + "_" + counter;
            }
        }
        return candidate;
    }

    /** Writes a JSON error body with the supplied HTTP status and message. */
    private void writeError(HttpServletResponse response, int status, String message)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        String safeMessage = message.replace("\\", "\\\\").replace("\"", "\\\"");
        response.getWriter().write("{\"message\":\"" + safeMessage + "\"}");
    }
}
