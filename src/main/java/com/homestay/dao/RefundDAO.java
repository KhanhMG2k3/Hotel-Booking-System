package com.homestay.dao;

import com.homestay.model.Booking;
import com.homestay.model.Refund;
import com.homestay.model.RefundApprovalResult;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.logging.Level;

/**
 * RefundDAO - Data Access Object for handling customer refund requests
 * and host refund management actions.
 */
public class RefundDAO extends BaseDAO {

    /**
     * Creates a new refund request record for a customer booking.
     */
    public long createRefundRequest(Refund refund) {
        if (refund == null || refund.getBookingId() == null || refund.getAmount() == null) {
            throw new IllegalArgumentException("Refund booking ID and amount must not be null");
        }

        String idempotencyKey = refund.getIdempotencyKey();
        if (idempotencyKey == null || idempotencyKey.isBlank()) {
            idempotencyKey = "REF-" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
            refund.setIdempotencyKey(idempotencyKey);
        }

        String sql = """
                INSERT INTO refunds (
                    payment_id, booking_id, amount, currency, reason,
                    status, idempotency_key, gateway, requested_by,
                    customer_bank_info, host_note, created_at
                ) VALUES (?, ?, ?, ?, ?, 'REQUESTED', ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
                """;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            if (refund.getPaymentId() != null) {
                ps.setLong(1, refund.getPaymentId());
            } else {
                ps.setNull(1, Types.BIGINT);
            }
            ps.setLong(2, refund.getBookingId());
            ps.setBigDecimal(3, refund.getAmount());
            ps.setString(4, refund.getCurrency() != null ? refund.getCurrency() : "VND");
            ps.setString(5, refund.getReason());
            ps.setString(6, idempotencyKey);
            ps.setString(7, refund.getGateway() != null ? refund.getGateway() : "VIETQR");
            ps.setLong(8, refund.getRequestedBy());
            ps.setString(9, refund.getCustomerBankInfo());
            ps.setString(10, refund.getHostNote());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                conn.rollback();
                return -1;
            }

            rs = ps.getGeneratedKeys();
            long refundId = -1;
            if (rs.next()) {
                refundId = rs.getLong(1);
                refund.setRefundId(refundId);
            }

            // Also update booking cancellation reason
            String updateBookingSql = "UPDATE bookings SET cancellation_reason = ? WHERE booking_id = ?";
            try (PreparedStatement updatePs = conn.prepareStatement(updateBookingSql)) {
                updatePs.setString(1, refund.getReason());
                updatePs.setLong(2, refund.getBookingId());
                updatePs.executeUpdate();
            }

            conn.commit();
            return refundId;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating refund request", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return -1;
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Finds a refund by refund ID.
     */
    public Optional<Refund> findById(long refundId) {
        String sql = """
                SELECT r.*,
                       b.booking_code, b.customer_name, b.customer_email, b.customer_phone,
                       COALESCE(p.property_name, p.name, 'Sogo Homestay') AS property_name,
                       COALESCE(rm.room_name, 'Phòng tiêu chuẩn') AS room_name
                FROM refunds r
                JOIN bookings b ON r.booking_id = b.booking_id
                LEFT JOIN properties p ON b.property_id = p.property_id
                LEFT JOIN rooms rm ON b.room_id = rm.room_id
                WHERE r.refund_id = ?
                """;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, refundId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToRefund(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding refund by id: " + refundId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return Optional.empty();
    }

    /**
     * Finds the latest refund request for a booking.
     */
    public Optional<Refund> findLatestByBookingId(long bookingId) {
        String sql = """
                SELECT r.*,
                       b.booking_code, b.customer_name, b.customer_email, b.customer_phone,
                       COALESCE(p.property_name, p.name, 'Sogo Homestay') AS property_name,
                       COALESCE(rm.room_name, 'Phòng tiêu chuẩn') AS room_name
                FROM refunds r
                JOIN bookings b ON r.booking_id = b.booking_id
                LEFT JOIN properties p ON b.property_id = p.property_id
                LEFT JOIN rooms rm ON b.room_id = rm.room_id
                WHERE r.booking_id = ?
                ORDER BY r.refund_id DESC
                LIMIT 1
                """;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToRefund(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding refund for booking: " + bookingId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return Optional.empty();
    }

    /**
     * Finds all refund requests made by a specific customer.
     */
    public List<Refund> findByUserId(long userId) {
        List<Refund> refunds = new ArrayList<>();
        String sql = """
                SELECT r.*,
                       b.booking_code, b.customer_name, b.customer_email, b.customer_phone,
                       COALESCE(p.property_name, p.name, 'Sogo Homestay') AS property_name,
                       COALESCE(rm.room_name, 'Phòng tiêu chuẩn') AS room_name
                FROM refunds r
                JOIN bookings b ON r.booking_id = b.booking_id
                LEFT JOIN properties p ON b.property_id = p.property_id
                LEFT JOIN rooms rm ON b.room_id = rm.room_id
                WHERE r.requested_by = ?
                ORDER BY r.refund_id DESC
                """;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                refunds.add(mapResultSetToRefund(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding refunds for user: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return refunds;
    }

    /**
     * Finds all refund requests for homestay properties owned by a host.
     */
    public List<Refund> findByHostUserId(long hostUserId) {
        List<Refund> refunds = new ArrayList<>();
        String sql = """
                SELECT r.*,
                       b.booking_code, b.customer_name, b.customer_email, b.customer_phone,
                       COALESCE(p.property_name, p.name, 'Sogo Homestay') AS property_name,
                       COALESCE(rm.room_name, 'Phòng tiêu chuẩn') AS room_name
                FROM refunds r
                JOIN bookings b ON r.booking_id = b.booking_id
                JOIN properties p ON b.property_id = p.property_id
                LEFT JOIN rooms rm ON b.room_id = rm.room_id
                WHERE p.owner_id = ? OR p.host_id IN (SELECT id FROM host_profiles WHERE user_id = ?)
                ORDER BY r.refund_id DESC
                """;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, hostUserId);
            ps.setLong(2, hostUserId);
            rs = ps.executeQuery();

            while (rs.next()) {
                refunds.add(mapResultSetToRefund(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding refunds for host: " + hostUserId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return refunds;
    }

    /**
     * Approves a refund request with Model 2 Host Wallet deduction.
     * Performs an atomic transaction:
     * 1. Verifies refund exists and is in REQUESTED status.
     * 2. Checks Host wallet balance with FOR UPDATE lock.
     * 3. If balance < refund amount, rolls back and returns insufficientBalance result.
     * 4. Deducts refund amount from wallet and logs DEBIT_REFUND transaction.
     * 5. Updates refunds, bookings, and payments tables.
     */
    public RefundApprovalResult approveRefundWithWallet(long refundId, long hostUserId, String hostNote) {
        Connection conn = null;
        PreparedStatement selectPs = null;
        PreparedStatement walletSelectPs = null;
        PreparedStatement walletUpdatePs = null;
        PreparedStatement txPs = null;
        PreparedStatement updateRefundPs = null;
        PreparedStatement updateBookingPs = null;
        PreparedStatement updatePaymentPs = null;
        ResultSet rs = null;
        ResultSet walletRs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Verify current status is REQUESTED and retrieve refund details
            String selectSql = """
                    SELECT r.booking_id, r.payment_id, r.amount, r.status, b.booking_code
                    FROM refunds r
                    JOIN bookings b ON r.booking_id = b.booking_id
                    WHERE r.refund_id = ?
                    FOR UPDATE
                    """;
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setLong(1, refundId);
            rs = selectPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return RefundApprovalResult.failure("Không tìm thấy yêu cầu hoàn tiền.");
            }

            String currentStatus = rs.getString("status");
            if (!"REQUESTED".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return RefundApprovalResult.failure("Yêu cầu này đã được xử lý trước đó (Trạng thái: " + currentStatus + ").");
            }

            long bookingId = rs.getLong("booking_id");
            long paymentId = rs.getLong("payment_id");
            BigDecimal refundAmount = rs.getBigDecimal("amount");
            String bookingCode = rs.getString("booking_code");

            if (refundAmount == null) {
                refundAmount = BigDecimal.ZERO;
            }

            // 2. Lock & check Host's wallet balance
            String walletSelectSql = """
                    SELECT wallet_account_id, balance
                    FROM wallet_accounts
                    WHERE owner_type = 'HOST' AND owner_user_id = ? AND account_type = 'AVAILABLE'
                    FOR UPDATE
                    """;
            walletSelectPs = conn.prepareStatement(walletSelectSql);
            walletSelectPs.setLong(1, hostUserId);
            walletRs = walletSelectPs.executeQuery();

            long walletAccountId;
            BigDecimal currentBalance;

            if (walletRs.next()) {
                walletAccountId = walletRs.getLong("wallet_account_id");
                currentBalance = walletRs.getBigDecimal("balance");
                if (currentBalance == null) {
                    currentBalance = BigDecimal.ZERO;
                }
            } else {
                // Initialize wallet for host if not found
                closeResources(null, walletSelectPs, walletRs);
                String initWalletSql = """
                        INSERT INTO wallet_accounts (
                            owner_type, owner_key, owner_user_id, account_type,
                            currency, status, balance, created_at
                        ) VALUES ('HOST', ?, ?, 'AVAILABLE', 'VND', 'ACTIVE', 0.00, CURRENT_TIMESTAMP)
                        """;
                PreparedStatement initPs = conn.prepareStatement(initWalletSql, Statement.RETURN_GENERATED_KEYS);
                initPs.setString(1, "host_" + hostUserId);
                initPs.setLong(2, hostUserId);
                initPs.executeUpdate();
                ResultSet gk = initPs.getGeneratedKeys();
                walletAccountId = gk.next() ? gk.getLong(1) : 0;
                currentBalance = BigDecimal.ZERO;
                gk.close();
                initPs.close();
            }

            // 3. Balance verification
            if (currentBalance.compareTo(refundAmount) < 0) {
                conn.rollback();
                return RefundApprovalResult.insufficientBalance(currentBalance, refundAmount);
            }

            // 4. Deduct refund amount from Host's wallet
            BigDecimal newBalance = currentBalance.subtract(refundAmount);
            String walletUpdateSql = "UPDATE wallet_accounts SET balance = ? WHERE wallet_account_id = ?";
            walletUpdatePs = conn.prepareStatement(walletUpdateSql);
            walletUpdatePs.setBigDecimal(1, newBalance);
            walletUpdatePs.setLong(2, walletAccountId);
            walletUpdatePs.executeUpdate();

            // 5. Insert wallet transaction ledger record
            String txSql = """
                    INSERT INTO wallet_transactions (
                        wallet_account_id, user_id, transaction_type, amount,
                        balance_before, balance_after, reference_type, reference_id, description, created_at
                    ) VALUES (?, ?, 'DEBIT_REFUND', ?, ?, ?, 'REFUND', ?, ?, CURRENT_TIMESTAMP)
                    """;
            txPs = conn.prepareStatement(txSql);
            txPs.setLong(1, walletAccountId);
            txPs.setLong(2, hostUserId);
            txPs.setBigDecimal(3, refundAmount);
            txPs.setBigDecimal(4, currentBalance);
            txPs.setBigDecimal(5, newBalance);
            txPs.setLong(6, refundId);
            txPs.setString(7, "Hoàn tiền cho khách hủy đơn phòng #" + bookingCode);
            txPs.executeUpdate();

            // 6. Update refunds table
            String updateRefundSql = """
                    UPDATE refunds
                    SET status = 'APPROVED',
                        approved_by = ?,
                        host_note = ?,
                        completed_at = CURRENT_TIMESTAMP
                    WHERE refund_id = ?
                    """;
            updateRefundPs = conn.prepareStatement(updateRefundSql);
            updateRefundPs.setLong(1, hostUserId);
            updateRefundPs.setString(2, hostNote);
            updateRefundPs.setLong(3, refundId);
            updateRefundPs.executeUpdate();

            // 7. Update bookings table
            if (bookingId > 0) {
                String updateBookingSql = "UPDATE bookings SET booking_status = 'REFUNDED', status = 'REFUNDED' WHERE booking_id = ?";
                updateBookingPs = conn.prepareStatement(updateBookingSql);
                updateBookingPs.setLong(1, bookingId);
                updateBookingPs.executeUpdate();
            }

            // 8. Update payments table if exists
            if (paymentId > 0) {
                String updatePaymentSql = "UPDATE payments SET status = 'REFUNDED' WHERE payment_id = ?";
                updatePaymentPs = conn.prepareStatement(updatePaymentSql);
                updatePaymentPs.setLong(1, paymentId);
                updatePaymentPs.executeUpdate();
            }

            conn.commit();
            return RefundApprovalResult.success("Đã phê duyệt và hoàn tiền thành công. Tiền đã được trừ từ Ví Host.", newBalance);

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error approving refund: " + refundId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return RefundApprovalResult.failure("Lỗi hệ thống trong quá trình hoàn tiền: " + e.getMessage());
        } finally {
            closeResources(null, walletSelectPs, walletRs);
            closeStatement(walletUpdatePs);
            closeStatement(txPs);
            closeStatement(updateRefundPs);
            closeStatement(updateBookingPs);
            closeStatement(updatePaymentPs);
            closeResources(conn, selectPs, rs);
        }
    }

    /**
     * Approves a refund request using the traditional VietQR flow (no wallet deduction / guard).
     */
    public boolean approveRefundTraditional(long refundId, long hostUserId, String hostNote) {
        Connection conn = null;
        PreparedStatement selectPs = null;
        PreparedStatement updateRefundPs = null;
        PreparedStatement updateBookingPs = null;
        PreparedStatement updatePaymentPs = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Verify current status is REQUESTED
            String selectSql = """
                    SELECT r.booking_id, r.payment_id, r.amount, r.status
                    FROM refunds r
                    WHERE r.refund_id = ?
                    FOR UPDATE
                    """;
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setLong(1, refundId);
            rs = selectPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            String currentStatus = rs.getString("status");
            if (!"REQUESTED".equalsIgnoreCase(currentStatus)) {
                conn.rollback();
                return false;
            }

            long bookingId = rs.getLong("booking_id");
            long paymentId = rs.getLong("payment_id");

            // 2. Update refunds table: status = 'APPROVED'
            String updateRefundSql = """
                    UPDATE refunds
                    SET status = 'APPROVED',
                        approved_by = ?,
                        host_note = ?,
                        completed_at = CURRENT_TIMESTAMP
                    WHERE refund_id = ?
                    """;
            updateRefundPs = conn.prepareStatement(updateRefundSql);
            updateRefundPs.setLong(1, hostUserId);
            updateRefundPs.setString(2, hostNote);
            updateRefundPs.setLong(3, refundId);
            updateRefundPs.executeUpdate();

            // 3. Update bookings table: status = 'REFUNDED'
            String updateBookingSql = """
                    UPDATE bookings
                    SET status = 'REFUNDED',
                        payout_status = 'REFUNDED'
                    WHERE id = ? OR booking_id = ?
                    """;
            updateBookingPs = conn.prepareStatement(updateBookingSql);
            updateBookingPs.setLong(1, bookingId);
            updateBookingPs.setLong(2, bookingId);
            updateBookingPs.executeUpdate();

            // 4. Update payments table if payment_id exists
            if (paymentId > 0) {
                String updatePaymentSql = """
                        UPDATE payments
                        SET status = 'REFUNDED'
                        WHERE payment_id = ?
                        """;
                updatePaymentPs = conn.prepareStatement(updatePaymentSql);
                updatePaymentPs.setLong(1, paymentId);
                updatePaymentPs.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.WARNING, "Rollback failed", ex);
                }
            }
            logger.log(Level.SEVERE, "Error in approveRefundTraditional: " + refundId, e);
            return false;
        } finally {
            closeStatement(selectPs);
            closeStatement(updateRefundPs);
            closeStatement(updateBookingPs);
            closeStatement(updatePaymentPs);
            closeResources(conn, null, rs);
        }
    }

    /**
     * Approves a refund request in an atomic transaction (backward compatibility wrapper).
     */
    public boolean approveRefund(long refundId, long hostUserId, String hostNote) {
        return approveRefundTraditional(refundId, hostUserId, hostNote);
    }

    /**
     * Rejects a refund request with host explanation.
     */
    public boolean rejectRefund(long refundId, long hostUserId, String hostNote) {
        String sql = """
                UPDATE refunds
                SET status = 'REJECTED',
                    approved_by = ?,
                    host_note = ?,
                    completed_at = CURRENT_TIMESTAMP
                WHERE refund_id = ? AND status = 'REQUESTED'
                """;

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, hostUserId);
            ps.setString(2, hostNote);
            ps.setLong(3, refundId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error rejecting refund: " + refundId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Retrieves KPI summary statistics for a host's refund management.
     */
    public Map<String, Object> getRefundStatsForHost(long hostUserId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalCount", 0);
        stats.put("pendingCount", 0);
        stats.put("approvedCount", 0);
        stats.put("rejectedCount", 0);
        stats.put("totalRefundedAmount", BigDecimal.ZERO);

        String sql = """
                SELECT
                    COUNT(*) as total_count,
                    SUM(CASE WHEN r.status = 'REQUESTED' THEN 1 ELSE 0 END) as pending_count,
                    SUM(CASE WHEN r.status IN ('APPROVED', 'SUCCEEDED') THEN 1 ELSE 0 END) as approved_count,
                    SUM(CASE WHEN r.status = 'REJECTED' THEN 1 ELSE 0 END) as rejected_count,
                    COALESCE(SUM(CASE WHEN r.status IN ('APPROVED', 'SUCCEEDED') THEN r.amount ELSE 0 END), 0) as total_refunded_amount
                FROM refunds r
                JOIN bookings b ON r.booking_id = b.booking_id
                JOIN properties p ON b.property_id = p.property_id
                WHERE p.owner_id = ? OR p.host_id IN (SELECT id FROM host_profiles WHERE user_id = ?)
                """;

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, hostUserId);
            ps.setLong(2, hostUserId);
            rs = ps.executeQuery();

            if (rs.next()) {
                stats.put("totalCount", rs.getInt("total_count"));
                stats.put("pendingCount", rs.getInt("pending_count"));
                stats.put("approvedCount", rs.getInt("approved_count"));
                stats.put("rejectedCount", rs.getInt("rejected_count"));
                stats.put("totalRefundedAmount", rs.getBigDecimal("total_refunded_amount"));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching refund stats for host: " + hostUserId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return stats;
    }

    private Refund mapResultSetToRefund(ResultSet rs) throws SQLException {
        Refund refund = new Refund();
        refund.setRefundId(rs.getLong("refund_id"));
        refund.setPaymentId(rs.getLong("payment_id"));
        refund.setBookingId(rs.getLong("booking_id"));
        refund.setAmount(rs.getBigDecimal("amount"));
        refund.setCurrency(rs.getString("currency"));
        refund.setReason(rs.getString("reason"));
        refund.setStatus(rs.getString("status"));
        refund.setIdempotencyKey(rs.getString("idempotency_key"));
        refund.setGateway(rs.getString("gateway"));
        refund.setGatewayRefundId(rs.getString("gateway_refund_id"));
        refund.setRequestedBy(rs.getLong("requested_by"));
        refund.setApprovedBy(rs.getLong("approved_by"));
        refund.setCreatedAt(rs.getTimestamp("created_at"));
        refund.setCompletedAt(rs.getTimestamp("completed_at"));

        try {
            refund.setCustomerBankInfo(rs.getString("customer_bank_info"));
        } catch (SQLException ignored) {
        }

        try {
            refund.setHostNote(rs.getString("host_note"));
        } catch (SQLException ignored) {
        }

        // Joined presentation attributes
        try {
            refund.setBookingCode(rs.getString("booking_code"));
        } catch (SQLException ignored) {
        }

        try {
            refund.setCustomerName(rs.getString("customer_name"));
        } catch (SQLException ignored) {
        }

        try {
            refund.setCustomerEmail(rs.getString("customer_email"));
        } catch (SQLException ignored) {
        }

        try {
            refund.setCustomerPhone(rs.getString("customer_phone"));
        } catch (SQLException ignored) {
        }

        try {
            refund.setPropertyName(rs.getString("property_name"));
        } catch (SQLException ignored) {
        }

        try {
            refund.setRoomName(rs.getString("room_name"));
        } catch (SQLException ignored) {
        }

        return refund;
    }

    private void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing statement", e);
            }
        }
    }
}

