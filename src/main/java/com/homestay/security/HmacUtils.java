package com.homestay.security;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.GeneralSecurityException;
import java.util.HexFormat;

/**
 * Cryptographic utilities for payment gateway integrations.
 *
 * This class provides HMAC primitives only.
 * Each gateway must define its own canonical message format
 * and signature verification rules.
 */
public final class HmacUtils {

    private HmacUtils() {
    }

    /**
     * Calculates HMAC-SHA256 and returns lowercase hexadecimal output.
     */
    public static String hmacSha256(
            String secret,
            String message) {

        return hmacHex("HmacSHA256", secret, message);
    }

    /**
     * Calculates HMAC-SHA512 and returns lowercase hexadecimal output.
     */
    public static String hmacSha512(
            String secret,
            String message) {

        return hmacHex("HmacSHA512", secret, message);
    }

    private static String hmacHex(
            String algorithm,
            String secret,
            String message) {

        if (secret == null || secret.isBlank()) {
            throw new IllegalArgumentException(
                    "HMAC secret must not be empty"
            );
        }

        if (message == null) {
            throw new IllegalArgumentException(
                    "HMAC message must not be null"
            );
        }

        try {
            Mac mac = Mac.getInstance(algorithm);

            SecretKeySpec key = new SecretKeySpec(
                    secret.getBytes(StandardCharsets.UTF_8),
                    algorithm
            );

            mac.init(key);

            byte[] result = mac.doFinal(
                    message.getBytes(StandardCharsets.UTF_8)
            );

            return HexFormat.of().formatHex(result);

        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(
                    "Unable to calculate HMAC",
                    e
            );
        }
    }

    /**
     * Compares two hexadecimal signatures without
     * using a regular String.equals comparison.
     *
     * Both signatures must be valid hexadecimal strings.
     */
    public static boolean constantTimeHexEquals(
            String expectedHex,
            String receivedHex) {

        if (expectedHex == null || receivedHex == null) {
            return false;
        }

        try {
            byte[] expected = HexFormat.of().parseHex(
                    expectedHex
            );

            byte[] received = HexFormat.of().parseHex(
                    receivedHex
            );

            return MessageDigest.isEqual(
                    expected,
                    received
            );

        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}