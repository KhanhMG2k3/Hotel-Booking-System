package com.homestay.dao;

import com.homestay.model.Payment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * JDBC access for payments.
 *
 * Transaction-aware methods receive a Connection from the caller.
 * The caller owns commit, rollback and connection closure.
 */
public class PaymentDAO extends BaseDAO {

    /**
     * Finds a payment and locks its row until the caller's transaction ends.
     *
     * Must be called inside an explicit database transaction.
     */
    public Payment findByIdForUpdate(Connection conn, long paymentId)
            throws SQLException {

        if (conn == null || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    "findByIdForUpdate requires a connection with autoCommit=false");
        }

        String sql = """
                SELECT *
                FROM payments
                WHERE payment_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, paymentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPayment(rs) : null;
            }
        }
    }

    /**
     * Finds an existing pending payment for a room booking.
     *
     * Must be called inside an active transaction, after locking
     * the corresponding booking row with SELECT ... FOR UPDATE.
     *
     * The caller owns the Connection and transaction.
     */
    public Payment findPendingByBookingId(
            Connection conn,
            long bookingId) throws SQLException {

        if (conn == null || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    "An active transaction with autoCommit=false is required");
        }

        if (bookingId <= 0) {
            throw new IllegalArgumentException("Invalid booking ID");
        }

        String sql = """
                SELECT *
                FROM payments
                WHERE booking_id = ?
                  AND status = 'PENDING'
                ORDER BY payment_id ASC
                LIMIT 1
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPayment(rs) : null;
            }
        }
    }

    /**
     * Finds the latest payment for a booking (read-only).
     */
    public Payment findLatestByBookingId(long bookingId) {
        if (bookingId <= 0) {
            return null;
        }

        String sql = """
                SELECT *
                FROM payments
                WHERE booking_id = ?
                ORDER BY payment_id DESC
                LIMIT 1
                """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPayment(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Inserts a pending payment.
     *
     * The caller must validate booking ownership, amount and payment method.
     */
    public long insertPending(Connection conn, Payment payment)
            throws SQLException {

        if (conn == null || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    "insertPending requires a connection with autoCommit=false");
        }

        if (payment == null
                || payment.getPaymentCode() == null
                || payment.getUserId() == null
                || payment.getAmount() == null
                || payment.getAmount().signum() <= 0
                || payment.getPaymentMethod() == null) {
            throw new IllegalArgumentException("Invalid pending payment");
        }

        boolean roomBooking = payment.getBookingId() != null;
        boolean tourBooking = payment.getTourBookingId() != null;

        if (roomBooking == tourBooking) {
            throw new IllegalArgumentException(
                    "Payment must reference exactly one booking type");
        }

        String sql = """
                INSERT INTO payments (
                    payment_code,
                    user_id,
                    booking_id,
                    tour_booking_id,
                    amount,
                    payment_method,
                    status
                ) VALUES (?, ?, ?, ?, ?, ?, 'PENDING')
                """;

        try (PreparedStatement ps = conn.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, payment.getPaymentCode());
            ps.setLong(2, payment.getUserId());

            if (roomBooking) {
                ps.setLong(3, payment.getBookingId());
            } else {
                ps.setNull(3, java.sql.Types.BIGINT);
            }

            if (tourBooking) {
                ps.setLong(4, payment.getTourBookingId());
            } else {
                ps.setNull(4, java.sql.Types.BIGINT);
            }

            ps.setBigDecimal(5, payment.getAmount());
            ps.setString(6, payment.getPaymentMethod());

            int affected = ps.executeUpdate();

            if (affected != 1) {
                throw new SQLException("Failed to insert payment");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Missing generated payment ID");
                }

                long id = keys.getLong(1);
                payment.setPaymentId(id);
                payment.setStatus("PENDING");
                return id;
            }
        }
    }

    /**
     * Marks a payment as successful only if it is still pending.
     *
     * This method must be called only after trusted gateway verification.
     * It does not commit the transaction.
     */
    public boolean markSuccess(
            Connection conn,
            long paymentId,
            String transactionId) throws SQLException {

        if (conn == null || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    "markSuccess requires a connection with autoCommit=false");
        }

        if (transactionId == null || transactionId.isBlank()) {
            throw new IllegalArgumentException(
                    "Verified transaction ID is required");
        }

        String sql = """
                UPDATE payments
                SET status = 'SUCCESS',
                    transaction_id = ?,
                    paid_at = CURRENT_TIMESTAMP
                WHERE payment_id = ?
                  AND status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, transactionId);
            ps.setLong(2, paymentId);

            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Converts a database row into a Payment object.
     */
    private Payment mapPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();

        payment.setPaymentId(rs.getLong("payment_id"));
        payment.setPaymentCode(rs.getString("payment_code"));
        payment.setUserId(rs.getLong("user_id"));

        long bookingId = rs.getLong("booking_id");
        payment.setBookingId(rs.wasNull() ? null : bookingId);

        long tourBookingId = rs.getLong("tour_booking_id");
        payment.setTourBookingId(rs.wasNull() ? null : tourBookingId);

        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setTransactionId(rs.getString("transaction_id"));
        payment.setStatus(rs.getString("status"));

        payment.setQrCodeUrl(rs.getString("qr_code_url"));
        payment.setQrContent(rs.getString("qr_content"));
        payment.setBankCode(rs.getString("bank_code"));
        payment.setAccountNumber(rs.getString("account_number"));
        payment.setAccountHolder(rs.getString("account_holder"));
        payment.setTransferContent(rs.getString("transfer_content"));

        payment.setQrExpiredAt(rs.getTimestamp("qr_expired_at"));
        payment.setPaidAt(rs.getTimestamp("paid_at"));
        payment.setCreatedAt(rs.getTimestamp("created_at"));

        return payment;
    }
}
