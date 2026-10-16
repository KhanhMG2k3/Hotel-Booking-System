package com.homestay.util;

import org.mindrot.jbcrypt.BCrypt;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

/**
 * Hashes and verifies passwords supporting both PBKDF2-HMAC-SHA256 and BCrypt.
 */
public final class PasswordUtil {
    private static final int ITERATIONS = 210_000;
    private static final int SALT_LENGTH = 16;
    private static final int KEY_LENGTH = 256;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Password must not be empty.");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }
        try {
            return verify(plainPassword, hashedPassword);
        } catch (GeneralSecurityException e) {
            return false;
        }
    }

    /** Creates a salted password hash string from the supplied password using PBKDF2. */
    public static String hash(String password) throws GeneralSecurityException {
        byte[] salt = new byte[SALT_LENGTH];
        SECURE_RANDOM.nextBytes(salt);

        char[] passwordChars = password.toCharArray();
        PBEKeySpec keySpec = new PBEKeySpec(passwordChars, salt, ITERATIONS, KEY_LENGTH);
        try {
            byte[] hash = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
                    .generateSecret(keySpec)
                    .getEncoded();
            Base64.Encoder encoder = Base64.getUrlEncoder().withoutPadding();
            return "pbkdf2-sha256$" + ITERATIONS + "$"
                    + encoder.encodeToString(salt) + "$"
                    + encoder.encodeToString(hash);
        } finally {
            keySpec.clearPassword();
            Arrays.fill(passwordChars, '\0');
        }
    }

    /** Checks a password against its encoded hash and returns whether it matches. Supports BCrypt & PBKDF2. */
    public static boolean verify(String password, String encodedHash) throws GeneralSecurityException {
        if (password == null || encodedHash == null || encodedHash.isEmpty()) {
            return false;
        }

        // Support BCrypt format ($2a$, $2b$, $2y$)
        if (encodedHash.startsWith("$2a$") || encodedHash.startsWith("$2b$") || encodedHash.startsWith("$2y$")) {
            try {
                return BCrypt.checkpw(password, encodedHash);
            } catch (Exception e) {
                return false;
            }
        }

        // Parse PBKDF2 format
        String[] parts = encodedHash.split("\\$", -1);
        if (parts.length != 4 || !"pbkdf2-sha256".equals(parts[0])) {
            return false;
        }

        try {
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getUrlDecoder().decode(parts[2]);
            byte[] expectedHash = Base64.getUrlDecoder().decode(parts[3]);

            if (iterations < 100_000 || iterations > 1_000_000
                    || salt.length != SALT_LENGTH || expectedHash.length != KEY_LENGTH / 8) {
                return false;
            }

            char[] passwordChars = password.toCharArray();
            PBEKeySpec keySpec = new PBEKeySpec(passwordChars, salt, iterations, KEY_LENGTH);
            try {
                byte[] actualHash = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
                        .generateSecret(keySpec)
                        .getEncoded();
                return MessageDigest.isEqual(expectedHash, actualHash);
            } finally {
                keySpec.clearPassword();
                Arrays.fill(passwordChars, '\0');
            }
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
