package com.homestay.dao;

import com.homestay.model.Refund;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RefundDAOTest {

    private RefundDAO refundDAO;

    @BeforeEach
    void setUp() {
        refundDAO = new RefundDAO();
    }

    @Test
    @DisplayName("createRefundRequest throws IllegalArgumentException for null refund or missing fields")
    void testCreateRefundRequestValidation() {
        assertThrows(IllegalArgumentException.class, () -> {
            refundDAO.createRefundRequest(null);
        });

        Refund refundWithoutAmount = new Refund();
        refundWithoutAmount.setBookingId(1L);
        assertThrows(IllegalArgumentException.class, () -> {
            refundDAO.createRefundRequest(refundWithoutAmount);
        });

        Refund refundWithoutBookingId = new Refund();
        refundWithoutBookingId.setAmount(new BigDecimal("100000"));
        assertThrows(IllegalArgumentException.class, () -> {
            refundDAO.createRefundRequest(refundWithoutBookingId);
        });
    }

    @Test
    @DisplayName("findById with non-existent id returns empty Optional")
    void testFindByIdNotFound() {
        assertTrue(refundDAO.findById(-999999L).isEmpty());
    }

    @Test
    @DisplayName("findLatestByBookingId with non-existent booking id returns empty Optional")
    void testFindLatestByBookingIdNotFound() {
        assertTrue(refundDAO.findLatestByBookingId(-999999L).isEmpty());
    }

    @Test
    @DisplayName("getRefundStatsForHost returns valid map even for user with 0 properties")
    void testGetRefundStatsForHost() {
        var stats = refundDAO.getRefundStatsForHost(-999999L);
        assertNotNull(stats);
        assertTrue(stats.containsKey("totalCount"));
        assertTrue(stats.containsKey("pendingCount"));
        assertTrue(stats.containsKey("approvedCount"));
        assertTrue(stats.containsKey("rejectedCount"));
        assertTrue(stats.containsKey("totalRefundedAmount"));
    }

    @Test
    @DisplayName("rejectRefund returns false for non-existent refund ID")
    void testRejectRefundNonExistent() {
        boolean result = refundDAO.rejectRefund(-999999L, 1L, "Test reason");
        assertFalse(result);
    }
}

