
package com.homestay.service;

import com.homestay.config.VNPayConfig;
import com.homestay.model.PaymentAttempt;
import com.homestay.security.VNPaySignatureUtils;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * VNPay payment gateway integration.
 *
 * Responsibilities:
 * - Build VNPay payment URLs.
 * - Generate HMAC-SHA512 signatures.
 * - Verify VNPay callback signatures.
 * - Validate gateway parameters.
 *
 * This service does not:
 * - Create payment attempts.
 * - Update payment status.
 * - Confirm bookings.
 * - Post financial ledger entries.
 */
public class VNPayService {

    private static final String GATEWAY = "VNPAY";
    private static final String VERSION = "2.1.0";
    private static final String COMMAND = "pay";
    private static final String CURRENCY = "VND";
    private static final String LOCALE = "vn";
    private static final String ORDER_TYPE = "other";

    private static final int EXPIRATION_MINUTES = 15;

    private static final ZoneId VIETNAM_ZONE =
            ZoneId.of("Asia/Ho_Chi_Minh");

    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    /**
     * Contains the generated gateway request.
     *
     * gatewayRequestId must be persisted in
     * payment_attempts.gateway_request_id
     * through PaymentAttemptService.markProcessing().
     */
    public record PaymentRequest(
            String gatewayRequestId,
            String paymentUrl
    ) {
    }

    /**
     * Creates a VNPay payment URL.
     *
     * The PaymentAttempt must already exist in the database.
     *
     * @param attempt existing payment attempt
     * @param clientIp actual client IP address
     * @param orderInfo payment description
     */
    public PaymentRequest createPaymentRequest(
            PaymentAttempt attempt,
            String clientIp,
            String orderInfo) {

        validateAttempt(attempt);
        validateClientIp(clientIp);
        validateOrderInfo(orderInfo);

        String tmnCode = VNPayConfig.getTmnCode();
        String hashSecret = VNPayConfig.getHashSecret();
        String returnUrl = VNPayConfig.getReturnUrl();
        String paymentUrl = VNPayConfig.getPaymentUrl();

        if (tmnCode.isBlank()
                || returnUrl.isBlank()
                || !returnUrl.startsWith("https://")
                || !paymentUrl.startsWith("https://")) {

            throw new IllegalStateException(
                    "Invalid VNPay configuration"
            );
        }

        long amount = convertAmount(
                attempt.getExpectedAmount()
        );

        /*
         * A stable reference derived from the unique
         * payment attempt ID.
         *
         * Reusing the same attempt keeps the same TxnRef.
         */
        String txnRef =
                "A" + attempt.getPaymentAttemptId();

        ZonedDateTime now =
                ZonedDateTime.now(VIETNAM_ZONE);

        String createDate =
                now.format(DATE_FORMAT);

        String expireDate =
                now.plusMinutes(EXPIRATION_MINUTES)
                        .format(DATE_FORMAT);

        Map<String, String> params =
                new LinkedHashMap<>();

        params.put("vnp_Version", VERSION);
        params.put("vnp_Command", COMMAND);
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(amount));
        params.put("vnp_CurrCode", CURRENCY);
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", orderInfo);
        params.put("vnp_OrderType", ORDER_TYPE);
        params.put("vnp_Locale", LOCALE);
        params.put("vnp_ReturnUrl", returnUrl);
        params.put("vnp_IpAddr", clientIp);
        params.put("vnp_CreateDate", createDate);
        params.put("vnp_ExpireDate", expireDate);

        /*
         * Reuse the existing VNPay signature implementation.
         */
        String canonicalData =
                VNPaySignatureUtils.buildCanonicalData(params);

        String secureHash =
                VNPaySignatureUtils.sign(
                        params,
                        hashSecret
                );

        String finalUrl =
                paymentUrl
                        + "?"
                        + canonicalData
                        + "&vnp_SecureHash="
                        + secureHash;

        return new PaymentRequest(
                txnRef,
                finalUrl
        );
    }

    /**
     * Verifies the signature returned by VNPay.
     *
     * This method only verifies data integrity.
     * It does NOT confirm payment success.
     */
    public boolean verifyCallbackSignature(
            Map<String, String> callbackParams) {

        if (callbackParams == null
                || callbackParams.isEmpty()) {
            return false;
        }

        String receivedTmnCode =
                callbackParams.get("vnp_TmnCode");

        String receivedSignature =
                callbackParams.get("vnp_SecureHash");

        if (receivedTmnCode == null
                || receivedSignature == null) {
            return false;
        }

        /*
         * Reject callbacks belonging to another merchant.
         */
        if (!VNPayConfig.getTmnCode().equals(
                receivedTmnCode)) {
            return false;
        }

        /*
         * VNPaySignatureUtils excludes signature fields
         * when building canonical data.
         */
        return VNPaySignatureUtils.verify(
                callbackParams,
                VNPayConfig.getHashSecret(),
                receivedSignature
        );
    }

    /**
     * Converts VND amount into VNPay amount format.
     *
     * VNPay requires the amount to be multiplied by 100.
     */
    private long convertAmount(BigDecimal amount) {

        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException(
                    "Payment amount must be positive"
            );
        }

        final long result;

        try {
            result = amount
                    .movePointRight(2)
                    .longValueExact();

        } catch (ArithmeticException e) {
            throw new IllegalArgumentException(
                    "Invalid VND payment precision or amount",
                    e
            );
        }

        if (result <= 0
                || result > 999_999_999_999L) {
            throw new IllegalArgumentException(
                    "VNPay amount exceeds supported range"
            );
        }

        return result;
    }

    /**
     * Validates payment attempt information.
     */
    private void validateAttempt(PaymentAttempt attempt) {

        if (attempt == null
                || attempt.getPaymentAttemptId() == null
                || attempt.getPaymentAttemptId() <= 0) {

            throw new IllegalArgumentException(
                    "Invalid payment attempt"
            );
        }

        if (!GATEWAY.equals(attempt.getGateway())) {
            throw new IllegalArgumentException(
                    "Payment attempt is not for VNPay"
            );
        }

        if (!CURRENCY.equals(attempt.getCurrency())) {
            throw new IllegalArgumentException(
                    "VNPay only supports VND"
            );
        }

        if (!"CREATED".equals(attempt.getStatus())) {
            throw new IllegalStateException(
                    "Payment attempt must be CREATED"
            );
        }
    }

    /**
     * Validates IPv4 or IPv6 address format.
     */
    private void validateClientIp(String clientIp) {

        if (clientIp == null
                || clientIp.isBlank()
                || clientIp.length() > 45
                || !clientIp.matches("[0-9a-fA-F:.]+")) {

            throw new IllegalArgumentException(
                    "Invalid client IP address"
            );
        }
    }

    /**
     * Validates payment description.
     */
    private void validateOrderInfo(String orderInfo) {

        if (orderInfo == null
                || orderInfo.isBlank()
                || orderInfo.length() > 255) {

            throw new IllegalArgumentException(
                    "Invalid VNPay order information"
            );
        }
    }
}
