package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.UserRole;
import com.homestay.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/** Reads and updates account records using parameterized JDBC statements. */
public class UserDAO {
    private static final String USER_COLUMNS =
            "SELECT u.id, u.username, u.display_name, u.avatar_url, u.phone, u.email, " +
                    "u.password, u.google_id, u.role_id, r.name AS role_name, " +
                    "u.status, u.two_factor_enabled, u.created_at ";

    /** Loads a user and assigned role by ID, or returns {@code null} when absent. */
    public User findById(int userId) throws SQLException {
        String sql = USER_COLUMNS +
                "FROM users u JOIN roles r ON r.id = u.role_id WHERE u.id = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUser(resultSet) : null;
            }
        }
    }

    /** Finds an account by normalized email or username for local sign-in. */
    public User findByLoginIdentifier(String loginIdentifier) throws SQLException {
        String sql = USER_COLUMNS +
                "FROM users u JOIN roles r ON r.id = u.role_id " +
                "WHERE u.email = ? OR u.username = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, loginIdentifier);
            statement.setString(2, loginIdentifier);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUser(resultSet) : null;
            }
        }
    }

    /** Finds the account linked to a Google subject ID, if one exists. */
    public User findByGoogleId(String googleId) throws SQLException {
        String sql = USER_COLUMNS +
                "FROM users u JOIN roles r ON r.id = u.role_id WHERE u.google_id = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, googleId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUser(resultSet) : null;
            }
        }
    }

    /** Finds an account by email for verified OAuth account linking. */
    public User findByEmail(String email) throws SQLException {
        String sql = USER_COLUMNS +
                "FROM users u JOIN roles r ON r.id = u.role_id WHERE u.email = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapUser(resultSet) : null;
            }
        }
    }

    /** Checks whether an account with the specified email already exists. */
    public boolean existsByEmail(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Checks whether an account with the specified phone number already exists. */
    public boolean existsByPhone(String phone) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE phone = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, phone);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Checks whether an account with the specified username already exists. */
    public boolean existsByUsername(String username) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Checks whether another user account already has the specified username. */
    public boolean existsByUsernameExceptUser(String username, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ? AND id != ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Checks whether another user account already has the specified phone number. */
    public boolean existsByPhoneExceptUser(String phone, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE phone = ? AND id != ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, phone);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Inserts a local account and sets its generated ID; returns whether one row was added. */
    public boolean insert(User user) throws SQLException {
        String sql = "INSERT INTO users (username, display_name, phone, email, password) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, user.getUsername());
            statement.setString(2, user.getDisplayName());
            statement.setString(3, user.getPhone());
            statement.setString(4, user.getEmail());
            statement.setString(5, user.getPassword());
            // Persist the new account, then capture its generated key for the model.
            if (statement.executeUpdate() != 1) {
                return false;
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (!generatedKeys.next()) {
                    throw new SQLException("The database did not return the new user ID.");
                }
                user.setId(generatedKeys.getInt(1));
                return true;
            }
        }
    }

    /** Updates the username and phone for the identified account. */
    public boolean updateProfile(int userId, String username, String phone) throws SQLException {
        String sql = "UPDATE users SET username = ?, phone = ? WHERE id = ?";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, username);
            statement.setString(2, phone);
            statement.setInt(3, userId);
            return statement.executeUpdate() == 1;
        }
    }

    /**
     * Updates the password hash for the specified user account.
     * 
     * @param userId The ID of the user to update
     * @param password The newly hashed password
     * @return true if one record was updated, false otherwise
     */
    public boolean updatePassword(int userId, String password) throws SQLException {
        // Step 1: Prepare SQL query to update user's password
        String sql = "UPDATE users SET password = ? WHERE id = ?";

        // Step 2: Execute update with DB connection
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, password);
            statement.setInt(2, userId);
            return statement.executeUpdate() == 1;
        }
    }

    /** Inserts a Google-backed account without a local password. */
    public boolean insertGoogleUser(User user) throws SQLException {
        String sql = "INSERT INTO users (username, email, google_id, display_name, avatar_url) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, user.getUsername());
            statement.setString(2, user.getEmail());
            statement.setString(3, user.getGoogleId());
            statement.setString(4, user.getDisplayName());
            statement.setString(5, user.getAvatarUrl());
            return statement.executeUpdate() == 1;
        }
    }

    /** Updates OAuth profile fields and confirms the account remains Google-linked. */
    public boolean updateGoogleProfile(int userId, String displayName, String avatarUrl)
            throws SQLException {
        String sql = "UPDATE users SET display_name = COALESCE(NULLIF(?, ''), display_name), " +
                "avatar_url = COALESCE(?, avatar_url) WHERE id = ? AND google_id IS NOT NULL";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, displayName);
            statement.setString(2, avatarUrl);
            statement.setInt(3, userId);
            if (statement.executeUpdate() == 1) {
                return true;
            }

            try (PreparedStatement checkStatement = connection.prepareStatement(
                    "SELECT 1 FROM users WHERE id = ? AND google_id IS NOT NULL LIMIT 1")) {
                checkStatement.setInt(1, userId);
                try (ResultSet resultSet = checkStatement.executeQuery()) {
                    return resultSet.next();
                }
            }
        }
    }

    /** Links a Google subject only when the account email still matches and is unlinked. */
    public boolean linkGoogleId(int userId, String email, String googleId) throws SQLException {
        String sql = "UPDATE users SET google_id = ? " +
                "WHERE id = ? AND email = ? AND google_id IS NULL";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, googleId);
            statement.setInt(2, userId);
            statement.setString(3, email);
            return statement.executeUpdate() == 1;
        }
    }

    /** Maps an account row and its joined role columns into a user model. */
    private User mapUser(ResultSet resultSet) throws SQLException {
        User user = new User();
        user.setId(resultSet.getInt("id"));
        user.setUsername(resultSet.getString("username"));
        user.setDisplayName(resultSet.getString("display_name"));
        user.setAvatarUrl(resultSet.getString("avatar_url"));
        user.setPhone(resultSet.getString("phone"));
        user.setEmail(resultSet.getString("email"));
        user.setPassword(resultSet.getString("password"));
        user.setGoogleId(resultSet.getString("google_id"));
        UserRole role = new UserRole();
        role.setId(resultSet.getInt("role_id"));
        role.setName(resultSet.getString("role_name"));
        user.setRole(role);
        user.setStatus(resultSet.getString("status"));
        user.setTwoFactorEnabled(resultSet.getBoolean("two_factor_enabled"));
        user.setCreatedAt(resultSet.getTimestamp("created_at"));
        return user;
    }

    /** Updates the two-factor authentication (2FA) preference for an account. */
    public boolean updateTwoFactor(int userId, boolean enabled) throws SQLException {
        // --- START: Update 2FA Flow ---
        String sql = "UPDATE users SET two_factor_enabled = ? WHERE id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setBoolean(1, enabled);
            statement.setInt(2, userId);
            return statement.executeUpdate() == 1;
        }
        // --- END: Update 2FA Flow ---
    }
}
