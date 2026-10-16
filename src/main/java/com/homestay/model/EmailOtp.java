package com.homestay.model;

import java.sql.Timestamp;

// --- START: EmailOtp Model Flow ---
/**
 * Purpose: Represents an email one-time password (OTP) record for two-factor authentication (2FA).
 * Attributes: id, userId, otpCode, purpose, expiresAt, used, createdAt.
 */
public class EmailOtp {
    // --- Step 1: Attribute definitions ---
    private int id;
    private int userId;
    private String otpCode;
    private String purpose;
    private Timestamp expiresAt;
    private boolean used;
    private Timestamp createdAt;

    // --- Step 2: Constructors ---
    public EmailOtp() {
    }

    public EmailOtp(int id, int userId, String otpCode, String purpose, Timestamp expiresAt, boolean used, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.otpCode = otpCode;
        this.purpose = purpose;
        this.expiresAt = expiresAt;
        this.used = used;
        this.createdAt = createdAt;
    }

    // --- Step 3: Expiration evaluation helper ---
    /**
     * Checks if the OTP has expired based on current system time.
     * @return true if current time is after the expiration timestamp.
     */
    public boolean isExpired() {
        if (expiresAt == null) {
            return true;
        }
        return System.currentTimeMillis() > expiresAt.getTime();
    }

    // --- Step 4: Getters and Setters ---
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isUsed() {
        return used;
    }

    public void setUsed(boolean used) {
        this.used = used;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
// --- END: EmailOtp Model Flow ---
