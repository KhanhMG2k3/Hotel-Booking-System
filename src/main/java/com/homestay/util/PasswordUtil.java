package com.homestay.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

/** Hashes and verifies passwords with PBKDF2-HMAC-SHA256. */
public final class PasswordUtil {
    private static final int ITERATIONS = 210_000;
    private static final int SALT_LENGTH = 16;
    private static final int KEY_LENGTH = 256;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private PasswordUtil() {
    }

    /** Creates a salted password hash string from the supplied password. */
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

    /** Checks a password against its encoded hash and returns whether it matches. */
    public static boolean verify(String password, String encodedHash) throws GeneralSecurityException {
        if (password == null || encodedHash == null) {
            return false;
        }

        // Reject unknown formats before decoding attacker-controlled hash parameters.
        String[] parts = encodedHash.split("\\$", -1);
        if (parts.length != 4 || !"pbkdf2-sha256".equals(parts[0])) {
            return false;
        }

        try {
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getUrlDecoder().decode(parts[2]);
            byte[] expectedHash = Base64.getUrlDecoder().decode(parts[3]);
            // Bound work and encoded lengths before invoking the expensive PBKDF2 operation.
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
