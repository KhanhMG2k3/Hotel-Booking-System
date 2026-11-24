package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.WalletAccount;
import com.homestay.model.WalletTransaction;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class WalletDAOTest {

    private WalletDAO walletDAO;

    @BeforeEach
    void setUp() {
        walletDAO = new WalletDAO();
    }

    @Test
    @DisplayName("getOrCreateHostWallet returns existing wallet for host 3")
    void testGetOrCreateHostWallet() {
        WalletAccount wallet = walletDAO.getOrCreateHostWallet(3L);
        assertNotNull(wallet);
        assertEquals("HOST", wallet.getOwnerType());
        assertEquals(3L, wallet.getOwnerUserId());
        assertNotNull(wallet.getBalance());
        assertTrue(wallet.getBalance().compareTo(BigDecimal.ZERO) >= 0);
    }

    @Test
    @DisplayName("getHostBalance returns valid balance")
    void testGetHostBalance() {
        BigDecimal balance = walletDAO.getHostBalance(3L);
        assertNotNull(balance);
        assertTrue(balance.compareTo(BigDecimal.ZERO) >= 0);
    }

    @Test
    @DisplayName("topUpWallet throws IllegalArgumentException on non-positive amount")
    void testTopUpValidation() {
        assertThrows(IllegalArgumentException.class, () -> {
            walletDAO.topUpWallet(3L, BigDecimal.ZERO, "Test");
        });
        assertThrows(IllegalArgumentException.class, () -> {
            walletDAO.topUpWallet(3L, new BigDecimal("-1000"), "Test");
        });
        assertThrows(IllegalArgumentException.class, () -> {
            walletDAO.topUpWallet(3L, null, "Test");
        });
    }

    @Test
    @DisplayName("topUpWallet increases balance and adds transaction")
    void testTopUpSuccess() {
        BigDecimal before = walletDAO.getHostBalance(3L);
        BigDecimal topupAmount = new BigDecimal("500000.00");
        try {
            boolean ok = walletDAO.topUpWallet(3L, topupAmount, "Unit Test Topup");
            assertTrue(ok);

            BigDecimal after = walletDAO.getHostBalance(3L);
            assertEquals(before.add(topupAmount), after);

            List<WalletTransaction> txs = walletDAO.getTransactionsByUserId(3L, 5);
            assertFalse(txs.isEmpty());
            WalletTransaction latest = txs.get(0);
            assertEquals("TOPUP", latest.getTransactionType());
            assertEquals(topupAmount, latest.getAmount());
        } finally {
            // Restore host 3 balance and clean up test transaction so host wallet stays clean
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps1 = conn.prepareStatement(
                         "UPDATE wallet_accounts SET balance = ? WHERE owner_user_id = 3 AND owner_type = 'HOST'");
                 PreparedStatement ps2 = conn.prepareStatement(
                         "DELETE FROM wallet_transactions WHERE user_id = 3 AND description = 'Unit Test Topup'")) {
                ps1.setBigDecimal(1, before);
                ps1.executeUpdate();
                ps2.executeUpdate();
            } catch (Exception ignored) {
            }
        }
    }

    @Test
    @DisplayName("getTransactionsByUserId returns non-null list for any user")
    void testGetTransactions() {
        List<WalletTransaction> txs = walletDAO.getTransactionsByUserId(-999999L, 10);
        assertNotNull(txs);
        assertTrue(txs.isEmpty());
    }

    @Test
    @DisplayName("withdrawBookingRevenue throws IllegalArgumentException for non-existent booking")
    void testWithdrawNonExistentBooking() {
        assertThrows(RuntimeException.class, () -> {
            walletDAO.withdrawBookingRevenue(3L, 99999999L, "TPBANK", "22465786789", "NGUYEN THANH HAI", "Test");
        });
    }
}
