package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.WalletAccount;
import com.homestay.model.WalletTransaction;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * WalletDAO - Data Access Object for Host Wallet and Ledger Transactions (Model 2).
 */
public class WalletDAO {

    private static final Logger logger = Logger.getLogger(WalletDAO.class.getName());

    protected Connection getConnection() throws SQLException {
        return DBContext.getConnection();
    }

    protected void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing Statement", e);
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                logger.log(Level.WARNING, "Error closing Connection", e);
            }
        }
    }

    /**
     * Gets or automatically creates the available wallet account for a host.
     * Default initial balance for new host wallets is 0 VND.
     */
    public WalletAccount getOrCreateHostWallet(long hostUserId) {
        Connection conn = null;
        PreparedStatement selectPs = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String selectSql = """
                    SELECT * FROM wallet_accounts
                    WHERE owner_type = 'HOST' AND owner_user_id = ? AND account_type = 'AVAILABLE'
                    LIMIT 1
                    """;
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setLong(1, hostUserId);
            rs = selectPs.executeQuery();

            if (rs.next()) {
                return mapResultSetToWalletAccount(rs);
            }

            // Create new wallet account with initial balance = 0.00
            closeResources(null, selectPs, rs);

            String insertSql = """
                    INSERT INTO wallet_accounts (
                        owner_type, owner_key, owner_user_id, account_type,
                        currency, status, balance, created_at
                    ) VALUES ('HOST', ?, ?, 'AVAILABLE', 'VND', 'ACTIVE', 0.00, CURRENT_TIMESTAMP)
                    """;
            PreparedStatement insertPs = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
            insertPs.setString(1, "host_" + hostUserId);
            insertPs.setLong(2, hostUserId);
            insertPs.executeUpdate();

            ResultSet genKeys = insertPs.getGeneratedKeys();
            long newWalletId = 0;
            if (genKeys.next()) {
                newWalletId = genKeys.getLong(1);
            }
            genKeys.close();
            insertPs.close();

            WalletAccount wallet = new WalletAccount();
            wallet.setWalletAccountId(newWalletId);
            wallet.setOwnerType("HOST");
            wallet.setOwnerKey("host_" + hostUserId);
            wallet.setOwnerUserId(hostUserId);
            wallet.setAccountType("AVAILABLE");
            wallet.setCurrency("VND");
            wallet.setStatus("ACTIVE");
            wallet.setBalance(BigDecimal.ZERO);
            return wallet;

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting or creating wallet for host user: " + hostUserId, e);
            throw new RuntimeException("Database error accessing host wallet", e);
        } finally {
            closeResources(conn, selectPs, rs);
        }
    }

    /**
     * Gets current balance of host wallet.
     */
    public BigDecimal getHostBalance(long hostUserId) {
        WalletAccount wallet = getOrCreateHostWallet(hostUserId);
        return wallet != null && wallet.getBalance() != null ? wallet.getBalance() : BigDecimal.ZERO;
    }

    /**
     * Retrieves recent transactions for a host user's wallet.
     */
    public List<WalletTransaction> getTransactionsByUserId(long hostUserId, int limit) {
        List<WalletTransaction> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql = """
                    SELECT * FROM wallet_transactions
                    WHERE user_id = ?
                    ORDER BY transaction_id DESC
                    LIMIT ?
                    """;
            ps = conn.prepareStatement(sql);
            ps.setLong(1, hostUserId);
            ps.setInt(2, limit > 0 ? limit : 50);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToWalletTransaction(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error loading wallet transactions for user: " + hostUserId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Tops up wallet balance for a host (used for testing or host self-deposit).
     */
    public boolean topUpWallet(long hostUserId, BigDecimal amount, String note) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Top-up amount must be positive");
        }

        Connection conn = null;
        PreparedStatement selectPs = null;
        PreparedStatement updatePs = null;
        PreparedStatement txPs = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            WalletAccount wallet = getOrCreateHostWallet(hostUserId);

            String selectSql = "SELECT wallet_account_id, balance FROM wallet_accounts WHERE wallet_account_id = ? FOR UPDATE";
            selectPs = conn.prepareStatement(selectSql);
            selectPs.setLong(1, wallet.getWalletAccountId());
            rs = selectPs.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return false;
            }

            BigDecimal currentBal = rs.getBigDecimal("balance");
            BigDecimal newBal = currentBal.add(amount);

            String updateSql = "UPDATE wallet_accounts SET balance = ? WHERE wallet_account_id = ?";
            updatePs = conn.prepareStatement(updateSql);
            updatePs.setBigDecimal(1, newBal);
            updatePs.setLong(2, wallet.getWalletAccountId());
            updatePs.executeUpdate();

            String txSql = """
                    INSERT INTO wallet_transactions (
                        wallet_account_id, user_id, transaction_type, amount,
                        balance_before, balance_after, reference_type, description, created_at
                    ) VALUES (?, ?, 'TOPUP', ?, ?, ?, 'SYSTEM', ?, CURRENT_TIMESTAMP)
                    """;
            txPs = conn.prepareStatement(txSql);
            txPs.setLong(1, wallet.getWalletAccountId());
            txPs.setLong(2, hostUserId);
            txPs.setBigDecimal(3, amount);
            txPs.setBigDecimal(4, currentBal);
            txPs.setBigDecimal(5, newBal);
            txPs.setString(6, note != null && !note.isBlank() ? note.trim() : "Nạp tiền vào Ví Host");
            txPs.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error topping up wallet for user: " + hostUserId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return false;
        } finally {
            closeResources(null, txPs, null);
            closeResources(null, updatePs, null);
            closeResources(conn, selectPs, rs);
        }
    }

    /**
     * Withdraws revenue of a specific booking to host's bank account.
     * Deducts host wallet balance, marks booking payout_status = WITHDRAWN,
     * logs DEBIT_WITHDRAWAL transaction and records into host_payouts table.
     */
    public boolean withdrawBookingRevenue(long hostUserId, long bookingId, String bankCode,
                                           String accountNumber, String accountHolder, String notes) {
        Connection conn = null;
        PreparedStatement selectBookingPs = null;
        PreparedStatement selectHostProfilePs = null;
        PreparedStatement selectWalletPs = null;
        PreparedStatement updateWalletPs = null;
        PreparedStatement insertTxPs = null;
        PreparedStatement insertPayoutPs = null;
        PreparedStatement updateBookingPs = null;
        ResultSet bookingRs = null;
        ResultSet hostProfileRs = null;
        ResultSet walletRs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Lock and verify booking
            String selectBookingSql = """
                    SELECT b.booking_id, b.booking_code, b.total_amount, b.booking_status, b.payout_status,
                           p.owner_id, p.host_id
                    FROM bookings b
                    JOIN properties p ON b.property_id = p.property_id
                    WHERE b.booking_id = ?
                    FOR UPDATE
                    """;
            selectBookingPs = conn.prepareStatement(selectBookingSql);
            selectBookingPs.setLong(1, bookingId);
            bookingRs = selectBookingPs.executeQuery();

            if (!bookingRs.next()) {
                conn.rollback();
                throw new IllegalArgumentException("Không tìm thấy đơn đặt phòng #" + bookingId);
            }

            long ownerId = bookingRs.getLong("owner_id");
            long propertyHostId = bookingRs.getLong("host_id");
            String bookingCode = bookingRs.getString("booking_code");
            BigDecimal totalAmount = bookingRs.getBigDecimal("total_amount");
            String bookingStatus = bookingRs.getString("booking_status");
            String payoutStatus = bookingRs.getString("payout_status");

            // Verify host ownership
            boolean isOwner = (ownerId == hostUserId);
            long hostProfileId = 0;

            String selectHostProfileSql = "SELECT id FROM host_profiles WHERE user_id = ?";
            selectHostProfilePs = conn.prepareStatement(selectHostProfileSql);
            selectHostProfilePs.setLong(1, hostUserId);
            hostProfileRs = selectHostProfilePs.executeQuery();
            if (hostProfileRs.next()) {
                hostProfileId = hostProfileRs.getLong("id");
                if (propertyHostId == hostProfileId) {
                    isOwner = true;
                }
            }

            if (!isOwner) {
                conn.rollback();
                throw new SecurityException("Bạn không có quyền rút tiền cho đơn đặt phòng này.");
            }

            if (!"CONFIRMED".equalsIgnoreCase(bookingStatus) && !"COMPLETED".equalsIgnoreCase(bookingStatus)) {
                conn.rollback();
                throw new IllegalStateException("Chỉ có thể rút tiền cho đơn đặt phòng đã thanh toán thành công (CONFIRMED). Trạng thái hiện tại: " + bookingStatus);
            }

            if ("WITHDRAWN".equalsIgnoreCase(payoutStatus)) {
                conn.rollback();
                throw new IllegalStateException("Đơn đặt phòng này đã được rút tiền về tài khoản ngân hàng trước đó.");
            }

            if (totalAmount == null || totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
                conn.rollback();
                throw new IllegalStateException("Số tiền doanh thu đơn phòng không hợp lệ.");
            }

            // 2. Lock and verify host wallet balance
            String selectWalletSql = """
                    SELECT wallet_account_id, balance
                    FROM wallet_accounts
                    WHERE owner_type = 'HOST' AND owner_user_id = ? AND account_type = 'AVAILABLE'
                    FOR UPDATE
                    """;
            selectWalletPs = conn.prepareStatement(selectWalletSql);
            selectWalletPs.setLong(1, hostUserId);
            walletRs = selectWalletPs.executeQuery();

            if (!walletRs.next()) {
                conn.rollback();
                throw new IllegalStateException("Không tìm thấy ví Host của bạn.");
            }

            long walletAccountId = walletRs.getLong("wallet_account_id");
            BigDecimal currentBal = walletRs.getBigDecimal("balance");
            if (currentBal == null) {
                currentBal = BigDecimal.ZERO;
            }

            if (currentBal.compareTo(totalAmount) < 0) {
                conn.rollback();
                throw new IllegalStateException(String.format("Số dư ví hiện tại (%,.0f VNĐ) không đủ để rút số tiền đơn phòng (%,.0f VNĐ).",
                        currentBal, totalAmount));
            }

            // 3. Deduct from wallet balance
            BigDecimal newBal = currentBal.subtract(totalAmount);
            String updateWalletSql = "UPDATE wallet_accounts SET balance = ? WHERE wallet_account_id = ?";
            updateWalletPs = conn.prepareStatement(updateWalletSql);
            updateWalletPs.setBigDecimal(1, newBal);
            updateWalletPs.setLong(2, walletAccountId);
            updateWalletPs.executeUpdate();

            // 4. Record wallet transaction
            String cleanBank = (bankCode != null && !bankCode.isBlank()) ? bankCode.trim().toUpperCase() : "BANK";
            String cleanAcc = (accountNumber != null && !accountNumber.isBlank()) ? accountNumber.trim() : "";
            String cleanHolder = (accountHolder != null && !accountHolder.isBlank()) ? accountHolder.trim().toUpperCase() : "";

            String txSql = """
                    INSERT INTO wallet_transactions (
                        wallet_account_id, user_id, transaction_type, amount,
                        balance_before, balance_after, reference_type, reference_id, description, created_at
                    ) VALUES (?, ?, 'DEBIT_WITHDRAWAL', ?, ?, ?, 'BOOKING', ?, ?, CURRENT_TIMESTAMP)
                    """;
            insertTxPs = conn.prepareStatement(txSql);
            insertTxPs.setLong(1, walletAccountId);
            insertTxPs.setLong(2, hostUserId);
            insertTxPs.setBigDecimal(3, totalAmount);
            insertTxPs.setBigDecimal(4, currentBal);
            insertTxPs.setBigDecimal(5, newBal);
            insertTxPs.setLong(6, bookingId);
            insertTxPs.setString(7, "Rút tiền doanh thu phòng đơn #" + bookingCode + " về ngân hàng " + cleanBank + " (" + cleanAcc + " - " + cleanHolder + ")");
            insertTxPs.executeUpdate();

            // 5. Record into host_payouts if hostProfile exists
            if (hostProfileId > 0) {
                String payoutCode = "PO-" + bookingCode + "-" + (System.currentTimeMillis() % 100000);
                String payoutSql = """
                        INSERT INTO host_payouts (
                            payout_code, host_id, amount, bank_code, account_number, account_holder,
                            status, notes, requested_at, processed_at, processed_by
                        ) VALUES (?, ?, ?, ?, ?, ?, 'COMPLETED', ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ?)
                        """;
                insertPayoutPs = conn.prepareStatement(payoutSql);
                insertPayoutPs.setString(1, payoutCode);
                insertPayoutPs.setLong(2, hostProfileId);
                insertPayoutPs.setBigDecimal(3, totalAmount);
                insertPayoutPs.setString(4, cleanBank);
                insertPayoutPs.setString(5, cleanAcc);
                insertPayoutPs.setString(6, cleanHolder);
                insertPayoutPs.setString(7, (notes != null && !notes.isBlank()) ? notes.trim() : ("Rút tiền doanh thu đơn phòng #" + bookingCode));
                insertPayoutPs.setLong(8, hostUserId);
                insertPayoutPs.executeUpdate();
            }

            // 6. Update booking payout_status
            String updateBookingSql = "UPDATE bookings SET payout_status = 'WITHDRAWN' WHERE booking_id = ?";
            updateBookingPs = conn.prepareStatement(updateBookingSql);
            updateBookingPs.setLong(1, bookingId);
            updateBookingPs.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error processing booking withdrawal: " + bookingId, e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            closeResources(null, selectBookingPs, bookingRs);
            closeResources(null, selectHostProfilePs, hostProfileRs);
            closeResources(null, selectWalletPs, walletRs);
            closeResources(null, updateWalletPs, null);
            closeResources(null, insertTxPs, null);
            closeResources(null, insertPayoutPs, null);
            closeResources(conn, updateBookingPs, null);
        }
    }

    /**
     * Credits booking revenue to host wallet (used upon booking payment confirmation).
     */
    public boolean creditBookingRevenue(Connection conn, long hostUserId, BigDecimal amount,
                                        long bookingId, String bookingCode) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        WalletAccount wallet = getOrCreateHostWallet(hostUserId);

        String selectSql = "SELECT wallet_account_id, balance FROM wallet_accounts WHERE wallet_account_id = ? FOR UPDATE";
        try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
            selectPs.setLong(1, wallet.getWalletAccountId());
            try (ResultSet rs = selectPs.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                BigDecimal currentBal = rs.getBigDecimal("balance");
                BigDecimal newBal = currentBal.add(amount);

                String updateSql = "UPDATE wallet_accounts SET balance = ? WHERE wallet_account_id = ?";
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setBigDecimal(1, newBal);
                    updatePs.setLong(2, wallet.getWalletAccountId());
                    updatePs.executeUpdate();
                }

                String txSql = """
                        INSERT INTO wallet_transactions (
                            wallet_account_id, user_id, transaction_type, amount,
                            balance_before, balance_after, reference_type, reference_id, description, created_at
                        ) VALUES (?, ?, 'CREDIT_BOOKING', ?, ?, ?, 'BOOKING', ?, ?, CURRENT_TIMESTAMP)
                        """;
                try (PreparedStatement txPs = conn.prepareStatement(txSql)) {
                    txPs.setLong(1, wallet.getWalletAccountId());
                    txPs.setLong(2, hostUserId);
                    txPs.setBigDecimal(3, amount);
                    txPs.setBigDecimal(4, currentBal);
                    txPs.setBigDecimal(5, newBal);
                    txPs.setLong(6, bookingId);
                    txPs.setString(7, "Doanh thu phòng từ đơn #" + (bookingCode != null ? bookingCode : String.valueOf(bookingId)));
                    txPs.executeUpdate();
                }
                return true;
            }
        }
    }

    /**
     * Finds property owner and credits booking revenue to their host wallet.
     * Non-fatal: failures are logged so booking confirmation is not rolled back.
     */
    public void creditBookingToHost(Connection conn, long propertyId, BigDecimal amount,
                                    long bookingId, String bookingCode) {
        if (conn == null || amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        try {
            long hostUserId = 0;
            String sql = "SELECT owner_id FROM properties WHERE property_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, propertyId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hostUserId = rs.getLong("owner_id");
                    }
                }
            }
            if (hostUserId > 0) {
                creditBookingRevenue(conn, hostUserId, amount, bookingId, bookingCode);
            }
        } catch (Exception e) {
            logger.log(Level.WARNING, "Could not credit wallet for booking " + bookingCode, e);
        }
    }

    private WalletAccount mapResultSetToWalletAccount(ResultSet rs) throws SQLException {
        WalletAccount w = new WalletAccount();
        w.setWalletAccountId(rs.getLong("wallet_account_id"));
        w.setOwnerType(rs.getString("owner_type"));
        w.setOwnerKey(rs.getString("owner_key"));
        long userId = rs.getLong("owner_user_id");
        if (!rs.wasNull()) {
            w.setOwnerUserId(userId);
        }
        w.setAccountType(rs.getString("account_type"));
        w.setCurrency(rs.getString("currency"));
        w.setStatus(rs.getString("status"));
        w.setBalance(rs.getBigDecimal("balance"));
        w.setCreatedAt(rs.getTimestamp("created_at"));
        return w;
    }

    private WalletTransaction mapResultSetToWalletTransaction(ResultSet rs) throws SQLException {
        WalletTransaction t = new WalletTransaction();
        t.setTransactionId(rs.getLong("transaction_id"));
        t.setWalletAccountId(rs.getLong("wallet_account_id"));
        t.setUserId(rs.getLong("user_id"));
        t.setTransactionType(rs.getString("transaction_type"));
        t.setAmount(rs.getBigDecimal("amount"));
        t.setBalanceBefore(rs.getBigDecimal("balance_before"));
        t.setBalanceAfter(rs.getBigDecimal("balance_after"));
        t.setReferenceType(rs.getString("reference_type"));
        long refId = rs.getLong("reference_id");
        if (!rs.wasNull()) {
            t.setReferenceId(refId);
        }
        t.setDescription(rs.getString("description"));
        t.setCreatedAt(rs.getTimestamp("created_at"));
        return t;
    }
}
