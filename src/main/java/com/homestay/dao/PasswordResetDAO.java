package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.PasswordReset;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/**
 * Data Access Object for managing password reset tokens.
 */
public class PasswordResetDAO {

    /**
     * Inserts a new password reset token after invalidating any previous unused tokens for the user.
     * 
     * @param userId ID of the account requesting reset
     * @param token Cryptographically secure random token string
     * @param expiresAt Expiration timestamp
     * @return true if token was created successfully
     */
    public boolean createResetToken(int userId, String token, Timestamp expiresAt) throws SQLException {
        // Step 1: Invalidate existing unused tokens for this user
        String invalidateSql = "UPDATE password_resets SET used = TRUE WHERE user_id = ? AND used = FALSE";

        // Step 2: Insert new reset token record
        String insertSql = "INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, ?)";

        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try (PreparedStatement invalidateStmt = connection.prepareStatement(invalidateSql);
                 PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {

                // Invalidate prior tokens
                invalidateStmt.setInt(1, userId);
                invalidateStmt.executeUpdate();

                // Insert the new token
                insertStmt.setInt(1, userId);
                insertStmt.setString(2, token);
                insertStmt.setTimestamp(3, expiresAt);
                int rows = insertStmt.executeUpdate();

                connection.commit();
                return rows == 1;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    /**
     * Finds a valid, unused, unexpired reset token.
     * 
     * @param token Token string to search for
     * @return PasswordReset object if found and valid, null otherwise
     */
    public PasswordReset findValidToken(String token) throws SQLException {
        // Step 1: SQL to query active reset token by token string
        String sql = "SELECT id, user_id, token, expires_at, used, created_at "
                   + "FROM password_resets "
                   + "WHERE token = ? AND used = FALSE "
                   + "LIMIT 1";

        // Step 2: Execute query and map result with timezone-safe expiration check
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, token);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    PasswordReset reset = new PasswordReset();
                    reset.setId(resultSet.getInt("id"));
                    reset.setUserId(resultSet.getInt("user_id"));
                    reset.setToken(resultSet.getString("token"));
                    reset.setExpiresAt(resultSet.getTimestamp("expires_at"));
                    reset.setUsed(resultSet.getBoolean("used"));
                    reset.setCreatedAt(resultSet.getTimestamp("created_at"));

                    // Verify expiration using JVM clock for timezone consistency
                    if (reset.isExpired()) {
                        return null;
                    }
                    return reset;
                }
                return null;
            }
        }
    }

    /**
     * Marks the given password reset token as used.
     * 
     * @param resetId Primary key of the reset record
     * @return true if updated successfully
     */
    public boolean markTokenUsed(int resetId) throws SQLException {
        // Step 1: Prepare update statement
        String sql = "UPDATE password_resets SET used = TRUE WHERE id = ?";

        // Step 2: Execute statement
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, resetId);
            return statement.executeUpdate() == 1;
        }
    }
}
