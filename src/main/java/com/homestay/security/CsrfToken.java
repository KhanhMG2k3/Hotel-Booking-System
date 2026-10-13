package com.homestay.security;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public final class CsrfToken {

    public static final String SESSION_ATTRIBUTE = "googleLoginCsrfToken";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32;

    private CsrfToken() {
    }

    public static String generate() {
        byte[] token = new byte[TOKEN_BYTES];
        SECURE_RANDOM.nextBytes(token);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(token);
    }

    public static boolean matches(String expected, String actual) {
        if (expected == null || actual == null) {
            return false;
        }
        return MessageDigest.isEqual(
                expected.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                actual.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }
}