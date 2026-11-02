package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * WalletTransaction - Represents a balance change record in a wallet.
 */
public class WalletTransaction implements Serializable {

    private static final long serialVersionUID = 1L;

    private long transactionId;
    private long walletAccountId;
    private long userId;
    private String transactionType; // CREDIT_BOOKING, DEBIT_REFUND, TOPUP, WITHDRAWAL
    private BigDecimal amount;
    private BigDecimal balanceBefore;
    private BigDecimal balanceAfter;
    private String referenceType; // BOOKING, REFUND, SYSTEM
    private Long referenceId;
    private String description;
    private Timestamp createdAt;

    public WalletTransaction() {
    }

    public WalletTransaction(long transactionId, long walletAccountId, long userId, String transactionType,
                             BigDecimal amount, BigDecimal balanceBefore, BigDecimal balanceAfter,
                             String referenceType, Long referenceId, String description, Timestamp createdAt) {
        this.transactionId = transactionId;
        this.walletAccountId = walletAccountId;
        this.userId = userId;
        this.transactionType = transactionType;
        this.amount = amount;
        this.balanceBefore = balanceBefore;
        this.balanceAfter = balanceAfter;
        this.referenceType = referenceType;
        this.referenceId = referenceId;
        this.description = description;
        this.createdAt = createdAt;
    }

    public long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(long transactionId) {
        this.transactionId = transactionId;
    }

    public long getWalletAccountId() {
        return walletAccountId;
    }

    public void setWalletAccountId(long walletAccountId) {
        this.walletAccountId = walletAccountId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public BigDecimal getBalanceBefore() {
        return balanceBefore;
    }

    public void setBalanceBefore(BigDecimal balanceBefore) {
        this.balanceBefore = balanceBefore;
    }

    public BigDecimal getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(BigDecimal balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public String getReferenceType() {
        return referenceType;
    }

    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }

    public Long getReferenceId() {
        return referenceId;
    }

    public void setReferenceId(Long referenceId) {
        this.referenceId = referenceId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

