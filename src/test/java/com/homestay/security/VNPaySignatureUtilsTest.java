package com.homestay.security;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class VNPaySignatureUtilsTest {

    @Test
    @DisplayName("Sorts keys alphabetically, encodes and excludes signature fields in canonical data")
    void testBuildCanonicalData() {
        Map<String, String> params = new HashMap<>();
        params.put("vnp_Amount", "10000000");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", "DEMOTMN1");
        params.put("vnp_TxnRef", "BK123456");
        params.put("vnp_SecureHash", "SHOULD_BE_EXCLUDED");
        params.put("vnp_SecureHashType", "SHA512");
        params.put("empty_param", "");

        String canonical = VNPaySignatureUtils.buildCanonicalData(params);

        assertNotNull(canonical);
        assertFalse(canonical.contains("vnp_SecureHash"));
        assertFalse(canonical.contains("vnp_SecureHashType"));
        assertFalse(canonical.contains("empty_param"));
        assertEquals("vnp_Amount=10000000&vnp_Command=pay&vnp_TmnCode=DEMOTMN1&vnp_TxnRef=BK123456", canonical);
    }

    @Test
    @DisplayName("Calculates valid HMAC-SHA512 signature with sign()")
    void testSignWithHmacSha512() {
        String secret = "MYSECRETKEY12345";
        Map<String, String> params = new HashMap<>();
        params.put("vnp_Amount", "10000000");
        params.put("vnp_Command", "pay");

        String signature = VNPaySignatureUtils.sign(params, secret);

        assertNotNull(signature);
        assertEquals(128, signature.length(), "HMAC-SHA512 hex length must be 128 characters");
    }

    @Test
    @DisplayName("Verifies valid signature and detects invalid signature")
    void testVerifySignature() {
        String secret = "MYSECRETKEY12345";
        Map<String, String> params = new HashMap<>();
        params.put("vnp_Amount", "10000000");
        params.put("vnp_Command", "pay");

        String validSignature = VNPaySignatureUtils.sign(params, secret);

        assertTrue(VNPaySignatureUtils.verify(params, secret, validSignature));
        assertFalse(VNPaySignatureUtils.verify(params, secret, "invalidsignature123"));
        assertFalse(VNPaySignatureUtils.verify(params, "WRONG_SECRET", validSignature));
        assertFalse(VNPaySignatureUtils.verify(params, secret, null));
        assertFalse(VNPaySignatureUtils.verify(params, secret, "   "));
    }

    @Test
    @DisplayName("Throws IllegalArgumentException when null arguments provided")
    void testNullArgumentsThrowException() {
        assertThrows(IllegalArgumentException.class, () -> VNPaySignatureUtils.buildCanonicalData(null));
        assertThrows(IllegalArgumentException.class, () -> VNPaySignatureUtils.sign(null, "secret"));
        assertThrows(IllegalArgumentException.class, () -> VNPaySignatureUtils.sign(new HashMap<>(), null));
    }
}
