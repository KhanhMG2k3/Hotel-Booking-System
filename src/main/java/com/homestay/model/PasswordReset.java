package com.homestay.model;

import java.sql.Timestamp;

/**
 * Model class representing a temporary password reset token.
 */
public class PasswordReset {
    private int id;
    private int userId;
    private String token;
    private Timestamp expiresAt;
    private boolean used;
    private Timestamp createdAt;

    public PasswordReset() {
    }

    public PasswordReset(int userId, String token, Timestamp expiresAt) {
        this.userId = userId;
        this.token = token;
        this.expiresAt = expiresAt;
        this.used = false;
    }

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

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
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

    /**
     * Checks if the reset token has expired compared to the current system time.
     */
    public boolean isExpired() {
        return expiresAt == null || expiresAt.before(new Timestamp(System.currentTimeMillis()));
    }
}
