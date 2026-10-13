package com.homestay.util;

import com.homestay.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/** Provides session, CSRF-token, and sign-in helpers for account flows. */
public final class LoginUtil {
    private static final String CSRF_SESSION_KEY = "loginCsrfToken";
    private static final String LOGOUT_CSRF_SESSION_KEY = "logoutCsrfToken";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private LoginUtil() {
    }

    /** Returns the session's login token, creating a random token when needed. */
    public static String getOrCreateCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String csrfToken = (String) session.getAttribute(CSRF_SESSION_KEY);
        if (csrfToken == null) {
            byte[] tokenBytes = new byte[32];
            SECURE_RANDOM.nextBytes(tokenBytes);
            csrfToken = Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
            session.setAttribute(CSRF_SESSION_KEY, csrfToken);
        }
        return csrfToken;
    }

    /**
     * Validates and consumes a one-time login token; returns whether it matched.
     */
    public static boolean consumeCsrfToken(HttpServletRequest request, String submittedToken) {
        HttpSession session = request.getSession(false);
        if (session == null || submittedToken == null) {
            return false;
        }

        String expectedToken = (String) session.getAttribute(CSRF_SESSION_KEY);
        // Consume the token to prevent replaying a login form submission.
        session.removeAttribute(CSRF_SESSION_KEY);
        return expectedToken != null && MessageDigest.isEqual(
                expectedToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                submittedToken.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    /**
     * Returns a stable logout token for the current session, or {@code null}
     * without one.
     */
    public static String getOrCreateLogoutCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        synchronized (session) {
            String csrfToken = (String) session.getAttribute(LOGOUT_CSRF_SESSION_KEY);
            if (csrfToken == null) {
                csrfToken = createCsrfToken();
                session.setAttribute(LOGOUT_CSRF_SESSION_KEY, csrfToken);
            }
            return csrfToken;
        }
    }

    /** Checks the submitted logout token against the current session token. */
    public static boolean isValidLogoutCsrfToken(HttpServletRequest request, String submittedToken) {
        HttpSession session = request.getSession(false);
        if (session == null || submittedToken == null || submittedToken.isBlank()) {
            return false;
        }

        String expectedToken = (String) session.getAttribute(LOGOUT_CSRF_SESSION_KEY);
        return expectedToken != null && MessageDigest.isEqual(
                expectedToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                submittedToken.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }

    /**
     * Rotates the session ID and stores authenticated account details in the
     * session.
     */
    public static void signIn(HttpServletRequest request, User user) {
        if (user.getRole() == null || user.getRole().getName() == null) {
            throw new IllegalArgumentException("The authenticated user has no assigned role.");
        }

        HttpSession session = request.getSession();
        request.changeSessionId();
        session.setAttribute("userId", user.getId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("displayName", getDisplayName(user));
        session.setAttribute("avatarUrl", user.getAvatarUrl());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("role", user.getRole().getName());
        getOrCreateLogoutCsrfToken(request);
    }

    /**
     * Chooses a display name from profile data, email, or username in that order.
     */
    public static String getDisplayName(User user) {
        String displayName = user.getDisplayName();
        if (displayName != null && !displayName.isBlank()) {
            return displayName;
        }

        String email = user.getEmail();
        if (email != null) {
            int atIndex = email.indexOf('@');
            if (atIndex > 0) {
                return email.substring(0, atIndex);
            }
        }
        return user.getUsername();
    }

    /** Creates a cryptographically random, URL-safe token for a session. */
    private static String createCsrfToken() {
        byte[] tokenBytes = new byte[32];
        SECURE_RANDOM.nextBytes(tokenBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }
}
