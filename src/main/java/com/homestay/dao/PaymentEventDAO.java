package com.homestay.dao;

import com.homestay.model.PaymentEvent;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.Locale;

/**
 * JDBC access for payment gateway events.
 *
 * All database operations use a caller-managed transaction.
 * This DAO does not verify gateway signatures or confirm payments.
 */
public class PaymentEventDAO extends BaseDAO {

    private void requireTransaction(Connection conn)
            throws SQLException {

        if (conn == null || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    "An active transaction with autoCommit=false is required"
            );
        }
    }

    /**
     * Records a newly received gateway event.
     *
     * Initial state:
     * verification_status = RECEIVED
     * processing_status = PENDING
     *
     * Duplicate gateway event IDs are rejected by the database.
     */
    public long insertReceived(
            Connection conn,
            PaymentEvent event) throws SQLException {

        requireTransaction(conn);

        if (event == null) {
            throw new IllegalArgumentException(
                    "Payment event is required"
            );
        }

        if (event.getGateway() == null
                || event.getGateway().isBlank()
                || event.getGateway().length() > 40) {

            throw new IllegalArgumentException(
                    "Invalid gateway"
            );
        }

        if (event.getGatewayEventId() == null
                || event.getGatewayEventId().isBlank()
                || event.getGatewayEventId().length() > 191) {

            throw new IllegalArgumentException(
                    "Invalid gateway event ID"
            );
        }

        if (event.getEventType() == null
                || event.getEventType().isBlank()
                || event.getEventType().length() > 80) {

            throw new IllegalArgumentException(
                    "Invalid event type"
            );
        }

        if (event.getPaymentId() != null
                && event.getPaymentId() <= 0) {

            throw new IllegalArgumentException(
                    "Invalid payment ID"
            );
        }

        if (event.getPayloadSha256() == null
                || !event.getPayloadSha256()
                        .matches("[0-9a-fA-F]{64}")) {

            throw new IllegalArgumentException(
                    "Payload SHA-256 must contain 64 hexadecimal characters"
            );
        }

        String sql = """
                INSERT INTO payment_events (
                    payment_id,
                    gateway,
                    gateway_event_id,
                    event_type,
                    verification_status,
                    processing_status,
                    payload_sha256
                )
                VALUES (?, ?, ?, ?, 'RECEIVED', 'PENDING', ?)
                """;

        try (PreparedStatement ps = conn.prepareStatement(
                sql,
                Statement.RETURN_GENERATED_KEYS)) {

            if (event.getPaymentId() != null) {
                ps.setLong(1, event.getPaymentId());
            } else {
                ps.setNull(1, Types.BIGINT);
            }

            ps.setString(2, event.getGateway());
            ps.setString(3, event.getGatewayEventId());
            ps.setString(4, event.getEventType());

            ps.setString(
                    5,
                    event.getPayloadSha256().toLowerCase(Locale.ROOT)
            );

            if (ps.executeUpdate() != 1) {
                throw new SQLException(
                        "Failed to insert payment event"
                );
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException(
                            "Missing generated payment event ID"
                    );
                }

                long id = keys.getLong(1);

                event.setPaymentEventId(id);
                event.setVerificationStatus("RECEIVED");
                event.setProcessingStatus("PENDING");

                return id;
            }
        }
    }

    /**
     * Finds and locks an event by its primary key.
     */
    public PaymentEvent findByIdForUpdate(
            Connection conn,
            long eventId) throws SQLException {

        requireTransaction(conn);

        if (eventId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment event ID"
            );
        }

        String sql = """
                SELECT *
                FROM payment_events
                WHERE payment_event_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? mapPaymentEvent(rs)
                        : null;
            }
        }
    }

    /**
     * Finds and locks an event by gateway and gateway event ID.
     *
     * The caller must compare the payload hash to detect
     * conflicting retries.
     */
    public PaymentEvent findByGatewayEventIdForUpdate(
            Connection conn,
            String gateway,
            String gatewayEventId) throws SQLException {

        requireTransaction(conn);

        if (gateway == null || gateway.isBlank()
                || gatewayEventId == null
                || gatewayEventId.isBlank()) {

            throw new IllegalArgumentException(
                    "Gateway and gateway event ID are required"
            );
        }

        String sql = """
                SELECT *
                FROM payment_events
                WHERE gateway = ?
                  AND gateway_event_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, gateway);
            ps.setString(2, gatewayEventId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? mapPaymentEvent(rs)
                        : null;
            }
        }
    }

    /**
     * Marks an event as verified.
     *
     * IMPORTANT:
     * Only call this after successful gateway signature
     * and payload verification.
     *
     * This method does not perform verification itself.
     */
    public boolean markVerified(
            Connection conn,
            long eventId) throws SQLException {

        requireTransaction(conn);

        if (eventId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment event ID"
            );
        }

        String sql = """
                UPDATE payment_events
                SET verification_status = 'VERIFIED'
                WHERE payment_event_id = ?
                  AND verification_status = 'RECEIVED'
                  AND processing_status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, eventId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Marks an event as rejected after failed verification.
     *
     * A rejected event is also marked IGNORED so that
     * it cannot be processed as a valid payment event.
     */
    public boolean markRejected(
            Connection conn,
            long eventId) throws SQLException {

        requireTransaction(conn);

        if (eventId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment event ID"
            );
        }

        String sql = """
                UPDATE payment_events
                SET verification_status = 'REJECTED',
                    processing_status = 'IGNORED',
                    processed_at = CURRENT_TIMESTAMP
                WHERE payment_event_id = ?
                  AND verification_status = 'RECEIVED'
                  AND processing_status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, eventId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Marks a verified event as processed.
     *
     * Must be called in the same transaction as the
     * corresponding payment and ledger updates.
     */
    public boolean markProcessed(
            Connection conn,
            long eventId) throws SQLException {

        requireTransaction(conn);

        if (eventId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment event ID"
            );
        }

        String sql = """
                UPDATE payment_events
                SET processing_status = 'PROCESSED',
                    processed_at = CURRENT_TIMESTAMP
                WHERE payment_event_id = ?
                  AND verification_status = 'VERIFIED'
                  AND processing_status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, eventId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Marks a verified event as failed during processing.
     *
     * Does not change the payment status.
     */
    public boolean markProcessingFailed(
            Connection conn,
            long eventId) throws SQLException {

        requireTransaction(conn);

        if (eventId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid payment event ID"
            );
        }

        String sql = """
                UPDATE payment_events
                SET processing_status = 'FAILED',
                    processed_at = CURRENT_TIMESTAMP
                WHERE payment_event_id = ?
                  AND verification_status = 'VERIFIED'
                  AND processing_status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, eventId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Maps a ResultSet row to PaymentEvent.
     */
    private PaymentEvent mapPaymentEvent(ResultSet rs)
            throws SQLException {

        PaymentEvent event = new PaymentEvent();

        event.setPaymentEventId(
                rs.getLong("payment_event_id")
        );

        long paymentId = rs.getLong("payment_id");

        event.setPaymentId(
                rs.wasNull() ? null : paymentId
        );

        event.setGateway(
                rs.getString("gateway")
        );

        event.setGatewayEventId(
                rs.getString("gateway_event_id")
        );

        event.setEventType(
                rs.getString("event_type")
        );

        event.setVerificationStatus(
                rs.getString("verification_status")
        );

        event.setProcessingStatus(
                rs.getString("processing_status")
        );

        event.setPayloadSha256(
                rs.getString("payload_sha256")
        );

        event.setReceivedAt(
                rs.getTimestamp("received_at")
        );

        event.setProcessedAt(
                rs.getTimestamp("processed_at")
        );

        return event;
    }
}