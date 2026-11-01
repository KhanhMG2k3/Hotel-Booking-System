package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * WalletAccount - Represents an escrow / host wallet account.
 */
public class WalletAccount implements Serializable {

    private static final long serialVersionUID = 1L;

    private long walletAccountId;
    private String ownerType; // HOST, PLATFORM
    private String ownerKey;
    private Long ownerUserId;
    private String accountType; // AVAILABLE, PENDING, HOLD
    private String currency; // VND
    private String status; // ACTIVE, FROZEN, CLOSED
    private BigDecimal balance;
    private Timestamp createdAt;

    public WalletAccount() {
        this.balance = BigDecimal.ZERO;
        this.currency = "VND";
        this.status = "ACTIVE";
    }

    public WalletAccount(long walletAccountId, String ownerType, String ownerKey, Long ownerUserId,
                         String accountType, String currency, String status, BigDecimal balance, Timestamp createdAt) {
        this.walletAccountId = walletAccountId;
        this.ownerType = ownerType;
        this.ownerKey = ownerKey;
        this.ownerUserId = ownerUserId;
        this.accountType = accountType;
        this.currency = currency;
        this.status = status;
        this.balance = balance != null ? balance : BigDecimal.ZERO;
        this.createdAt = createdAt;
    }

    public long getWalletAccountId() {
        return walletAccountId;
    }

    public void setWalletAccountId(long walletAccountId) {
        this.walletAccountId = walletAccountId;
    }

    public String getOwnerType() {
        return ownerType;
    }

    public void setOwnerType(String ownerType) {
        this.ownerType = ownerType;
    }

    public String getOwnerKey() {
        return ownerKey;
    }

    public void setOwnerKey(String ownerKey) {
        this.ownerKey = ownerKey;
    }

    public Long getOwnerUserId() {
        return ownerUserId;
    }

    public void setOwnerUserId(Long ownerUserId) {
        this.ownerUserId = ownerUserId;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
