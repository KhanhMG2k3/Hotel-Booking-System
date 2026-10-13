package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.EmailOtp;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

// --- START: EmailOtpDAO Flow ---
/**
 * Purpose: Manages database persistence, validation, and status updates for Email OTP records.
 * Flow: Receives request from controllers -> executes parameterized JDBC queries -> returns result/model.
 */
public class EmailOtpDAO {

    /**
     * Purpose: Invalidates any existing unused OTPs for a user and purpose.
     * Parameters: userId (int), purpose (String)
     * Return value: int (number of invalidated rows)
     */
    public int invalidatePreviousOtps(int userId, String purpose) throws SQLException {
        // --- START: Invalidate Old OTPs Flow ---
        String sql = "UPDATE email_otps SET used = TRUE WHERE user_id = ? AND purpose = ? AND used = FALSE";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setString(2, purpose);
            return statement.executeUpdate();
        }
        // --- END: Invalidate Old OTPs Flow ---
    }

    /**
     * Purpose: Inserts a newly generated OTP code into the database.
     * Parameters: userId (int), otpCode (String), purpose (String), expiresAt (Timestamp)
     * Return value: boolean (true if insertion succeeded)
     */
    public boolean createOtp(int userId, String otpCode, String purpose, Timestamp expiresAt) throws SQLException {
        // --- START: Create OTP Flow ---
        // Step 1: Invalidate previous unused codes first
        invalidatePreviousOtps(userId, purpose);

        // Step 2: Insert new OTP record
        String sql = "INSERT INTO email_otps (user_id, otp_code, purpose, expires_at, used) VALUES (?, ?, ?, ?, FALSE)";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setString(2, otpCode);
            statement.setString(3, purpose);
            statement.setTimestamp(4, expiresAt);
            return statement.executeUpdate() == 1;
        }
        // --- END: Create OTP Flow ---
    }

    /**
     * Purpose: Finds the latest unused and unexpired OTP code for a user and purpose.
     * Parameters: userId (int), purpose (String)
     * Return value: EmailOtp or null if none found
     */
    public EmailOtp findLatestValidOtp(int userId, String purpose) throws SQLException {
        // --- START: Find Latest Valid OTP Flow ---
        String sql = "SELECT id, user_id, otp_code, purpose, expires_at, used, created_at "
                + "FROM email_otps "
                + "WHERE user_id = ? AND purpose = ? AND used = FALSE "
                + "ORDER BY id DESC LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.setString(2, purpose);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    EmailOtp otp = mapOtp(rs);
                    // Double check in-memory expiration against JVM clock
                    if (!otp.isExpired()) {
                        return otp;
                    }
                }
                return null;
            }
        }
        // --- END: Find Latest Valid OTP Flow ---
    }

    /**
     * Purpose: Marks an OTP code as consumed to prevent replay attacks.
     * Parameters: otpId (int)
     * Return value: boolean (true if marked successfully)
     */
    public boolean markAsUsed(int otpId) throws SQLException {
        // --- START: Mark OTP Used Flow ---
        String sql = "UPDATE email_otps SET used = TRUE WHERE id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, otpId);
            return statement.executeUpdate() == 1;
        }
        // --- END: Mark OTP Used Flow ---
    }

    /**
     * Purpose: Maps a SQL ResultSet row to an EmailOtp entity.
     * Parameters: rs (ResultSet)
     * Return value: EmailOtp
     */
    private EmailOtp mapOtp(ResultSet rs) throws SQLException {
        return new EmailOtp(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("otp_code"),
                rs.getString("purpose"),
                rs.getTimestamp("expires_at"),
                rs.getBoolean("used"),
                rs.getTimestamp("created_at")
        );
    }
}
// --- END: EmailOtpDAO Flow ---
