package com.homestay.security;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TreeMap;

/**
 * Builds canonical VNPay parameter strings and HMAC signatures.
 *
 * This utility does not communicate with VNPay.
 */
public final class VNPaySignatureUtils {

    private VNPaySignatureUtils() {
    }

    /**
     * Creates the canonical parameter string.
     *
     * Parameters are sorted by key.
     * Empty values and signature fields are excluded.
     */
    public static String buildCanonicalData(
            Map<String, String> parameters) {

        if (parameters == null) {
            throw new IllegalArgumentException(
                    "Parameters must not be null"
            );
        }

        Map<String, String> sorted = new TreeMap<>();

        for (Map.Entry<String, String> entry
                : parameters.entrySet()) {

            String key = entry.getKey();
            String value = entry.getValue();

            if (key == null || key.isBlank()
                    || value == null || value.isEmpty()) {
                continue;
            }

            if ("vnp_SecureHash".equals(key)
                    || "vnp_SecureHashType".equals(key)) {
                continue;
            }

            sorted.put(key, value);
        }

        StringBuilder result = new StringBuilder();

        for (Map.Entry<String, String> entry
                : sorted.entrySet()) {

            if (result.length() > 0) {
                result.append('&');
            }

            result.append(encode(entry.getKey()));
            result.append('=');
            result.append(encode(entry.getValue()));
        }

        return result.toString();
    }

    /**
     * Signs the canonical data with HMAC-SHA512.
     */
    public static String sign(
            Map<String, String> parameters,
            String hashSecret) {

        String canonicalData =
                buildCanonicalData(parameters);

        return HmacUtils.hmacSha512(
                hashSecret,
                canonicalData
        );
    }

    /**
     * Compares a received signature against the
     * locally calculated signature.
     *
     * IMPORTANT:
     * The caller must supply the original parameters
     * according to the gateway's callback format.
     */
    public static boolean verify(
            Map<String, String> parameters,
            String hashSecret,
            String receivedSignature) {

        if (receivedSignature == null
                || receivedSignature.isBlank()) {
            return false;
        }

        String expectedSignature = sign(
                parameters,
                hashSecret
        );

        return HmacUtils.constantTimeHexEquals(
                expectedSignature,
                receivedSignature
        );
    }

    private static String encode(String value) {
        return URLEncoder.encode(
                value,
                StandardCharsets.UTF_8
        );
    }
}