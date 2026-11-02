package com.homestay.dao;

import com.homestay.model.PaymentQrCode;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

/**
 * JDBC access for payment QR codes.
 *
 * Transaction-aware methods receive a Connection from the caller.
 * The caller owns commit, rollback and connection closure.
 */
public class PaymentQrCodeDAO extends BaseDAO {

    /**
     * Inserts a pending QR code.
     *
     * The caller must validate the payment, booking, beneficiary
     * account and QR payload before calling this method.
     */
    public long insertPending(
            Connection conn,
            PaymentQrCode qrCode) throws SQLException {

        requireTransaction(conn);
        validateQrCode(qrCode);

        String sql = """
                INSERT INTO payment_qr_codes (
                    payment_id,
                    booking_id,
                    bank_code,
                    account_number,
                    account_holder,
                    amount,
                    transfer_content,
                    qr_data_url,
                    qr_raw_string,
                    status,
                    expires_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)
                """;

        try (PreparedStatement ps = conn.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, qrCode.getPaymentId());

            if (qrCode.getBookingId() == null) {
                ps.setNull(2, Types.BIGINT);
            } else {
                ps.setLong(2, qrCode.getBookingId());
            }

            ps.setString(3, qrCode.getBankCode());
            ps.setString(4, qrCode.getAccountNumber());
            ps.setString(5, qrCode.getAccountHolder());
            ps.setBigDecimal(6, qrCode.getAmount());
            ps.setString(7, qrCode.getTransferContent());
            ps.setString(8, qrCode.getQrDataUrl());
            ps.setString(9, qrCode.getQrRawString());
            ps.setTimestamp(10, qrCode.getExpiresAt());

            int affected = ps.executeUpdate();

            if (affected != 1) {
                throw new SQLException("Failed to insert payment QR code");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Missing generated QR ID");
                }

                long qrId = keys.getLong(1);
                qrCode.setQrId(qrId);
                qrCode.setStatus("PENDING");

                return qrId;
            }
        }
    }

    /**
     * Finds the latest pending QR code for a payment and locks its row.
     *
     * Must be called inside an active transaction.
     */
    public PaymentQrCode findPendingByPaymentIdForUpdate(
            Connection conn,
            long paymentId) throws SQLException {

        requireTransaction(conn);

        if (paymentId <= 0) {
            throw new IllegalArgumentException("Invalid payment ID");
        }

        String sql = """
                SELECT *
                FROM payment_qr_codes
                WHERE payment_id = ?
                  AND status = 'PENDING'
                ORDER BY qr_id DESC
                LIMIT 1
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, paymentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPaymentQrCode(rs) : null;
            }
        }
    }

    /**
     * Finds the latest pending QR code for a payment (read-only).
     */
    public PaymentQrCode findLatestByPaymentId(long paymentId) {
        if (paymentId <= 0) {
            return null;
        }

        String sql = """
                SELECT *
                FROM payment_qr_codes
                WHERE payment_id = ?
                ORDER BY qr_id DESC
                LIMIT 1
                """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, paymentId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPaymentQrCode(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Finds the latest QR code for a booking (read-only).
     */
    public PaymentQrCode findLatestByBookingId(long bookingId) {
        if (bookingId <= 0) {
            return null;
        }

        String sql = """
                SELECT *
                FROM payment_qr_codes
                WHERE booking_id = ?
                ORDER BY qr_id DESC
                LIMIT 1
                """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPaymentQrCode(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Marks pending QR code as PAID by payment ID.
     */
    public boolean markPaidByPaymentId(Connection conn, long paymentId) throws SQLException {
        requireTransaction(conn);

        String sql = """
                UPDATE payment_qr_codes
                SET status = 'PAID',
                    paid_at = CURRENT_TIMESTAMP
                WHERE payment_id = ?
                  AND status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, paymentId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Finds a QR code by ID and locks its row.
     *
     * Must be called inside an active transaction.
     */
    public PaymentQrCode findByIdForUpdate(
            Connection conn,
            long qrId) throws SQLException {

        requireTransaction(conn);

        if (qrId <= 0) {
            throw new IllegalArgumentException("Invalid QR ID");
        }

        String sql = """
                SELECT *
                FROM payment_qr_codes
                WHERE qr_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, qrId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPaymentQrCode(rs) : null;
            }
        }
    }

    /**
     * Maps a database row to PaymentQrCode.
     */
    private PaymentQrCode mapPaymentQrCode(ResultSet rs)
            throws SQLException {

        PaymentQrCode qrCode = new PaymentQrCode();

        qrCode.setQrId(rs.getLong("qr_id"));
        qrCode.setPaymentId(rs.getLong("payment_id"));

        long bookingId = rs.getLong("booking_id");
        qrCode.setBookingId(rs.wasNull() ? null : bookingId);

        qrCode.setBankCode(rs.getString("bank_code"));
        qrCode.setAccountNumber(rs.getString("account_number"));
        qrCode.setAccountHolder(rs.getString("account_holder"));
        qrCode.setAmount(rs.getBigDecimal("amount"));
        qrCode.setTransferContent(rs.getString("transfer_content"));
        qrCode.setQrDataUrl(rs.getString("qr_data_url"));
        qrCode.setQrRawString(rs.getString("qr_raw_string"));
        qrCode.setStatus(rs.getString("status"));

        qrCode.setExpiresAt(rs.getTimestamp("expires_at"));
        qrCode.setCreatedAt(rs.getTimestamp("created_at"));
        qrCode.setPaidAt(rs.getTimestamp("paid_at"));

        return qrCode;
    }

    private void requireTransaction(Connection conn) {
        if (conn == null) {
            throw new IllegalArgumentException("Connection is required");
        }

        try {
            if (conn.isClosed() || conn.getAutoCommit()) {
                throw new IllegalArgumentException(
                        "An active transaction with autoCommit=false is required");
            }
        } catch (SQLException e) {
            throw new IllegalArgumentException(
                    "Unable to validate database connection", e);
        }
    }

    private void validateQrCode(PaymentQrCode qrCode) {
        if (qrCode == null
                || qrCode.getPaymentId() == null
                || qrCode.getPaymentId() <= 0
                || qrCode.getBankCode() == null
                || qrCode.getBankCode().isBlank()
                || qrCode.getAccountNumber() == null
                || qrCode.getAccountNumber().isBlank()
                || qrCode.getAccountHolder() == null
                || qrCode.getAccountHolder().isBlank()
                || qrCode.getAmount() == null
                || qrCode.getAmount().signum() <= 0
                || qrCode.getTransferContent() == null
                || qrCode.getTransferContent().isBlank()
                || qrCode.getQrDataUrl() == null
                || qrCode.getQrDataUrl().isBlank()
                || qrCode.getExpiresAt() == null) {

            throw new IllegalArgumentException(
                    "Invalid payment QR code data");
        }
    }
}
