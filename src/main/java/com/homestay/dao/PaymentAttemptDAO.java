package com.homestay.dao;

import com.homestay.model.PaymentAttempt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * JDBC access for payment attempts.
 *
 * The caller owns the Connection, transaction, commit and rollback.
 */
public class PaymentAttemptDAO extends BaseDAO {

    private void requireTransaction(Connection conn) throws SQLException {
        if (conn == null || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    "An active transaction with autoCommit=false is required");
        }
    }

    /**
     * Creates a payment attempt.
     *
     * The database enforces uniqueness of gateway + idempotency key.
     * A duplicate key is propagated to the Service for handling.
     */
    public long insert(Connection conn, PaymentAttempt attempt)
            throws SQLException {

        requireTransaction(conn);

        if (attempt == null
                || attempt.getPaymentId() == null
                || attempt.getGateway() == null
                || attempt.getGateway().isBlank()
                || attempt.getIdempotencyKey() == null
                || attempt.getIdempotencyKey().isBlank()
                || attempt.getExpectedAmount() == null
                || attempt.getExpectedAmount().signum() <= 0
                || attempt.getCurrency() == null
                || attempt.getCurrency().isBlank()) {
            throw new IllegalArgumentException("Invalid payment attempt");
        }

        String sql = """
                INSERT INTO payment_attempts (
                    payment_id,
                    gateway,
                    idempotency_key,
                    expected_amount,
                    currency,
                    status
                ) VALUES (?, ?, ?, ?, ?, 'CREATED')
                """;

        try (PreparedStatement ps = conn.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, attempt.getPaymentId());
            ps.setString(2, attempt.getGateway());
            ps.setString(3, attempt.getIdempotencyKey());
            ps.setBigDecimal(4, attempt.getExpectedAmount());
            ps.setString(5, attempt.getCurrency());

            if (ps.executeUpdate() != 1) {
                throw new SQLException("Failed to create payment attempt");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException(
                            "Missing generated payment attempt ID");
                }

                long id = keys.getLong(1);
                attempt.setPaymentAttemptId(id);
                attempt.setStatus("CREATED");
                return id;
            }
        }
    }

    /**
     * Finds an attempt by gateway and idempotency key.
     * Locks the row for transaction-safe processing.
     */
    public PaymentAttempt findByIdempotencyKeyForUpdate(
            Connection conn,
            String gateway,
            String idempotencyKey) throws SQLException {

        requireTransaction(conn);

        String sql = """
                SELECT *
                FROM payment_attempts
                WHERE gateway = ?
                  AND idempotency_key = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, gateway);
            ps.setString(2, idempotencyKey);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapAttempt(rs) : null;
            }
        }
    }

    /**
     * Locks an attempt by its primary key.
     */
    public PaymentAttempt findByIdForUpdate(
            Connection conn,
            long attemptId) throws SQLException {

        requireTransaction(conn);

        String sql = """
                SELECT *
                FROM payment_attempts
                WHERE payment_attempt_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, attemptId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapAttempt(rs) : null;
            }
        }
    }

    /**
     * Changes CREATED to PROCESSING.
     *
     * Does not commit the transaction.
     */
    public boolean markProcessing(
            Connection conn,
            long attemptId,
            String gatewayRequestId) throws SQLException {

        requireTransaction(conn);

        if (gatewayRequestId == null || gatewayRequestId.isBlank()) {
            throw new IllegalArgumentException(
                    "Gateway request ID is required");
        }

        String sql = """
                UPDATE payment_attempts
                SET status = 'PROCESSING',
                    gateway_request_id = ?
                WHERE payment_attempt_id = ?
                  AND status = 'CREATED'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, gatewayRequestId);
            ps.setLong(2, attemptId);

            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Marks a verified gateway attempt as successful.
     *
     * Must only be called by Service after trusted gateway verification.
     */
    public boolean markSucceeded(
            Connection conn,
            long attemptId,
            String gatewayTransactionId) throws SQLException {

        requireTransaction(conn);

        if (gatewayTransactionId == null
                || gatewayTransactionId.isBlank()) {
            throw new IllegalArgumentException(
                    "Verified gateway transaction ID is required");
        }

        String sql = """
                UPDATE payment_attempts
                SET status = 'SUCCEEDED',
                    gateway_transaction_id = ?
                WHERE payment_attempt_id = ?
                  AND status = 'PROCESSING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, gatewayTransactionId);
            ps.setLong(2, attemptId);

            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Marks an unsuccessful attempt as FAILED or EXPIRED.
     */
    public boolean markUnsuccessful(
            Connection conn,
            long attemptId,
            String newStatus) throws SQLException {

        requireTransaction(conn);

        if (!"FAILED".equals(newStatus)
                && !"EXPIRED".equals(newStatus)) {
            throw new IllegalArgumentException(
                    "Only FAILED or EXPIRED is allowed");
        }

        String sql = """
                UPDATE payment_attempts
                SET status = ?
                WHERE payment_attempt_id = ?
                  AND status IN ('CREATED', 'PROCESSING')
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setLong(2, attemptId);

            return ps.executeUpdate() == 1;
        }
    }

    private PaymentAttempt mapAttempt(ResultSet rs)
            throws SQLException {

        PaymentAttempt attempt = new PaymentAttempt();

        attempt.setPaymentAttemptId(
                rs.getLong("payment_attempt_id"));
        attempt.setPaymentId(rs.getLong("payment_id"));
        attempt.setGateway(rs.getString("gateway"));
        attempt.setIdempotencyKey(
                rs.getString("idempotency_key"));
        attempt.setGatewayRequestId(
                rs.getString("gateway_request_id"));
        attempt.setGatewayTransactionId(
                rs.getString("gateway_transaction_id"));
        attempt.setExpectedAmount(
                rs.getBigDecimal("expected_amount"));
        attempt.setCurrency(rs.getString("currency"));
        attempt.setStatus(rs.getString("status"));
        attempt.setCreatedAt(rs.getTimestamp("created_at"));
        attempt.setUpdatedAt(rs.getTimestamp("updated_at"));

        return attempt;
    }
}