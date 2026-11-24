package com.homestay.config;

/**
 * VNPay Sandbox configuration.
 *
 * Sensitive values are loaded from environment variables.
 * Never commit gateway secrets to source control.
 */
public final class VNPayConfig {

    private static final String DEFAULT_SANDBOX_URL =
            "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

    private VNPayConfig() {
    }

    public static String getPaymentUrl() {
        return getOptionalEnv(
                "VNPAY_PAYMENT_URL",
                DEFAULT_SANDBOX_URL
        );
    }

    public static String getTmnCode() {
        return getRequiredEnv("VNPAY_TMN_CODE");
    }

    public static String getHashSecret() {
        return getRequiredEnv("VNPAY_HASH_SECRET");
    }

    public static String getReturnUrl() {
        return getRequiredEnv("VNPAY_RETURN_URL");
    }

    public static String getIpnUrl() {
        return getRequiredEnv("VNPAY_IPN_URL");
    }

    private static String getRequiredEnv(String name) {
        String value = System.getenv(name);

        if (value == null || value.isBlank()) {
            throw new IllegalStateException(
                    "Missing required environment variable: " + name
            );
        }

        return value.trim();
    }

    private static String getOptionalEnv(
            String name,
            String defaultValue) {

        String value = System.getenv(name);

        if (value == null || value.isBlank()) {
            return defaultValue;
        }

        return value.trim();
    }
}