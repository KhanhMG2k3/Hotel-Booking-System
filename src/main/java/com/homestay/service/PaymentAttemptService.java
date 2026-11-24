
package com.homestay.service;

import com.homestay.context.DBContext;
import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentAttemptDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.PaymentAttempt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Manages payment attempts before and during gateway processing.
 *
 * Responsibilities:
 * - Create or reuse payment attempts.
 * - Enforce payment ownership.
 * - Enforce idempotency.
 * - Manage CREATED -> PROCESSING transition.
 * - Validate payment amount and currency.
 *
 * This service does not:
 * - Call VNPay or MoMo.
 * - Confirm successful payments.
 * - Update wallet balances.
 * - Post ledger entries.
 */
public class PaymentAttemptService {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final PaymentAttemptDAO attemptDAO =
            new PaymentAttemptDAO();

    /**
     * Creates or reuses a payment attempt.
     *
     * Lock order:
     * 1. Booking
     * 2. Payment
     * 3. PaymentAttempt
     *
     * The idempotency key must identify one logical
     * payment request.
     */
    public PaymentAttempt createOrGetAttempt(
            long paymentId,
            long userId,
            String gateway,
            String idempotencyKey) throws SQLException {

        if (paymentId <= 0 || userId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment or user ID");
        }

        if (!"VNPAY".equals(gateway)
                && !"MOMO".equals(gateway)) {
            throw new IllegalArgumentException(
                    "Unsupported gateway");
        }

        if (idempotencyKey == null
                || idempotencyKey.isBlank()
                || idempotencyKey.length() > 191) {
            throw new IllegalArgumentException(
                    "Invalid idempotency key");
        }

        try (Connection conn = DBContext.getConnection()) {

            conn.setAutoCommit(false);

            try {
                // Discover booking ID before acquiring row locks.
                Long bookingId = findBookingId(conn, paymentId);

                if (bookingId == null || bookingId <= 0) {
                    throw new IllegalStateException(
                            "Payment does not reference a room booking");
                }

                // Lock 1: Booking.
                Booking booking = bookingDAO.findByIdForUpdate(
                        conn,
                        bookingId
                );

                if (booking == null) {
                    throw new IllegalArgumentException(
                            "Booking not found");
                }

                if (booking.getUserId() == null
                        || booking.getUserId().longValue() != userId) {
                    throw new SecurityException(
                            "Booking does not belong to the user");
                }

                if (!"PENDING".equals(booking.getStatus())) {
                    throw new IllegalStateException(
                            "Booking is not pending");
                }

                // Lock 2: Payment.
                Payment payment = paymentDAO.findByIdForUpdate(
                        conn,
                        paymentId
                );

                validatePayment(
                        payment,
                        booking,
                        paymentId,
                        userId,
                        bookingId,
                        gateway
                );

                // Lock 3: Existing attempt by idempotency key.
                PaymentAttempt existing =
                        attemptDAO.findByIdempotencyKeyForUpdate(
                                conn,
                                gateway,
                                idempotencyKey
                        );

                if (existing != null) {

                    if (existing.getPaymentId() == null
                            || existing.getPaymentId().longValue()
                                    != paymentId) {
                        throw new IllegalStateException(
                                "Idempotency key belongs to another payment");
                    }

                    if (existing.getExpectedAmount() == null
                            || existing.getExpectedAmount().compareTo(
                                    payment.getAmount()) != 0) {
                        throw new IllegalStateException(
                                "Idempotency key amount mismatch");
                    }

                    if (!"VND".equals(existing.getCurrency())) {
                        throw new IllegalStateException(
                                "Unexpected payment currency");
                    }

                    String status = existing.getStatus();

                    if ("FAILED".equals(status)
                            || "EXPIRED".equals(status)) {
                        throw new IllegalStateException(
                                "Previous attempt is terminal. "
                                        + "A new idempotency key is required.");
                    }

                    if ("SUCCEEDED".equals(status)) {
                        throw new IllegalStateException(
                                "Payment attempt already succeeded. "
                                        + "Payment state requires reconciliation.");
                    }

                    if (!"CREATED".equals(status)
                            && !"PROCESSING".equals(status)) {
                        throw new IllegalStateException(
                                "Unsupported payment attempt status");
                    }

                    conn.commit();
                    return existing;
                }

                // Prevent multiple active attempts for one payment.
                // The payment row is already locked.
                if (hasActiveAttempt(conn, paymentId)) {
                    throw new IllegalStateException(
                            "Payment already has an active attempt");
                }

                PaymentAttempt attempt = new PaymentAttempt();

                attempt.setPaymentId(paymentId);
                attempt.setGateway(gateway);
                attempt.setIdempotencyKey(idempotencyKey);
                attempt.setExpectedAmount(payment.getAmount());
                attempt.setCurrency("VND");

                attemptDAO.insert(conn, attempt);

                conn.commit();
                return attempt;

            } catch (SQLException | RuntimeException e) {

                rollback(conn, e);
                throw e;
            }
        }
    }

    /**
     * Changes CREATED to PROCESSING.
     *
     * Must be called after the gateway request has been prepared
     * and before redirecting the customer to the gateway.
     *
     * Lock order:
     * 1. Booking
     * 2. Payment
     * 3. PaymentAttempt
     *
     * The caller owns no Connection.
     * This method owns its transaction.
     *
     * @return true if transitioned successfully or the same
     *         request was already marked PROCESSING.
     */
    public boolean markProcessing(
            long paymentId,
            long userId,
            long attemptId,
            String gatewayRequestId) throws SQLException {

        if (paymentId <= 0
                || userId <= 0
                || attemptId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment, user or attempt ID");
        }

        if (gatewayRequestId == null
                || gatewayRequestId.isBlank()
                || gatewayRequestId.length() > 191) {
            throw new IllegalArgumentException(
                    "Invalid gateway request ID");
        }

        try (Connection conn = DBContext.getConnection()) {

            conn.setAutoCommit(false);

            try {
                // Discover booking ID.
                Long bookingId = findBookingId(conn, paymentId);

                if (bookingId == null || bookingId <= 0) {
                    throw new IllegalStateException(
                            "Payment does not reference a room booking");
                }

                // Lock 1: Booking.
                Booking booking = bookingDAO.findByIdForUpdate(
                        conn,
                        bookingId
                );

                if (booking == null
                        || booking.getUserId() == null
                        || booking.getUserId().longValue() != userId
                        || !"PENDING".equals(booking.getStatus())) {
                    throw new SecurityException(
                            "Invalid or inaccessible booking");
                }

                // Lock 2: Payment.
                Payment payment = paymentDAO.findByIdForUpdate(
                        conn,
                        paymentId
                );

                validatePayment(
                        payment,
                        booking,
                        paymentId,
                        userId,
                        bookingId,
                        payment == null
                                ? null
                                : payment.getPaymentMethod()
                );

                // Lock 3: PaymentAttempt.
                PaymentAttempt attempt =
                        attemptDAO.findByIdForUpdate(
                                conn,
                                attemptId
                        );

                if (attempt == null
                        || attempt.getPaymentId() == null
                        || attempt.getPaymentId().longValue()
                                != paymentId) {
                    throw new IllegalStateException(
                            "Payment attempt does not match payment");
                }

                if (!payment.getPaymentMethod().equals(
                        attempt.getGateway())) {
                    throw new IllegalStateException(
                            "Payment gateway mismatch");
                }

                if (attempt.getExpectedAmount() == null
                        || attempt.getExpectedAmount().compareTo(
                                payment.getAmount()) != 0
                        || !"VND".equals(attempt.getCurrency())) {
                    throw new IllegalStateException(
                            "Payment attempt amount or currency mismatch");
                }

                // Idempotent retry using the same gateway request ID.
                if ("PROCESSING".equals(attempt.getStatus())) {

                    boolean sameRequest = gatewayRequestId.equals(
                            attempt.getGatewayRequestId());

                    conn.commit();
                    return sameRequest;
                }

                if (!"CREATED".equals(attempt.getStatus())) {
                    throw new IllegalStateException(
                            "Attempt cannot transition to PROCESSING");
                }

                boolean updated = attemptDAO.markProcessing(
                        conn,
                        attemptId,
                        gatewayRequestId
                );

                if (!updated) {
                    throw new SQLException(
                            "Failed to mark attempt as PROCESSING");
                }

                conn.commit();
                return true;

            } catch (SQLException | RuntimeException e) {

                rollback(conn, e);
                throw e;
            }
        }
    }

    /**
     * Validates payment ownership, status, gateway and amount.
     */
    private void validatePayment(
            Payment payment,
            Booking booking,
            long paymentId,
            long userId,
            long bookingId,
            String gateway) {

        if (payment == null) {
            throw new IllegalArgumentException(
                    "Payment not found");
        }

        if (payment.getUserId() == null
                || payment.getUserId().longValue() != userId) {
            throw new SecurityException(
                    "Payment does not belong to the user");
        }

        if (!"PENDING".equals(payment.getStatus())) {
            throw new IllegalStateException(
                    "Payment is not pending");
        }

        if (payment.getBookingId() == null
                || payment.getBookingId().longValue() != bookingId) {
            throw new IllegalStateException(
                    "Payment booking reference mismatch");
        }

        if (payment.getPaymentMethod() == null
                || !payment.getPaymentMethod().equals(gateway)) {
            throw new IllegalArgumentException(
                    "Gateway does not match payment method");
        }

        if (payment.getAmount() == null
                || booking.getTotalAmount() == null
                || payment.getAmount().signum() <= 0
                || payment.getAmount().compareTo(
                        booking.getTotalAmount()) != 0) {
            throw new IllegalStateException(
                    "Payment amount does not match booking");
        }
    }

    /**
     * Reads the booking ID associated with a payment.
     *
     * The payment will be locked and validated later.
     */
    private Long findBookingId(
            Connection conn,
            long paymentId) throws SQLException {

        String sql = """
                SELECT booking_id
                FROM payments
                WHERE payment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, paymentId);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    return null;
                }

                long bookingId = rs.getLong("booking_id");

                return rs.wasNull() ? null : bookingId;
            }
        }
    }

    /**
     * Checks whether a payment already has an active attempt.
     */
    private boolean hasActiveAttempt(
            Connection conn,
            long paymentId) throws SQLException {

        String sql = """
                SELECT payment_attempt_id
                FROM payment_attempts
                WHERE payment_id = ?
                  AND status IN ('CREATED', 'PROCESSING')
                LIMIT 1
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, paymentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Rolls back the transaction and preserves rollback errors.
     */
    private void rollback(
            Connection conn,
            Exception originalError) {

        try {
            conn.rollback();
        } catch (SQLException rollbackError) {
            originalError.addSuppressed(rollbackError);
        }
    }
}

