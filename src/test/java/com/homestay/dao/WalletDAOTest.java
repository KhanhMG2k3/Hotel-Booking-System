package com.homestay.dao;

import com.homestay.model.WalletAccount;
import com.homestay.model.WalletTransaction;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
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
        boolean ok = walletDAO.topUpWallet(3L, topupAmount, "Unit Test Topup");
        assertTrue(ok);

        BigDecimal after = walletDAO.getHostBalance(3L);
        assertEquals(before.add(topupAmount), after);

        List<WalletTransaction> txs = walletDAO.getTransactionsByUserId(3L, 5);
        assertFalse(txs.isEmpty());
        WalletTransaction latest = txs.get(0);
        assertEquals("TOPUP", latest.getTransactionType());
        assertEquals(topupAmount, latest.getAmount());
    }

    @Test
    @DisplayName("getTransactionsByUserId returns non-null list for any user")
    void testGetTransactions() {
        List<WalletTransaction> txs = walletDAO.getTransactionsByUserId(-999999L, 10);
        assertNotNull(txs);
        assertTrue(txs.isEmpty());
    }
}

