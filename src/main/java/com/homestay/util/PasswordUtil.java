package com.homestay.util;

import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {

    private PasswordUtil() {
    }

    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException(
                    "Password must not be empty."
            );
        }

        return BCrypt.hashpw(
                plainPassword,
                BCrypt.gensalt(12)
        );
    }

    public static boolean verifyPassword(
            String plainPassword,
            String hashedPassword) {

        if (plainPassword == null
                || hashedPassword == null
                || hashedPassword.isEmpty()) {
            return false;
        }

        try {
            return BCrypt.checkpw(
                    plainPassword,
                    hashedPassword
            );
        } catch (IllegalArgumentException e) {
            // The stored value may not be a BCrypt hash.
            return false;
        }
    }
}
