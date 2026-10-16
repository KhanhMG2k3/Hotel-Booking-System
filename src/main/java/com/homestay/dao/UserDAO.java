package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.Role;
import com.homestay.model.User;
import com.homestay.model.UserRole;
import com.homestay.util.PasswordUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

/**
 * UserDAO - Comprehensive Data Access Object for User accounts.
 * Supports authentication, OAuth, profile management, and 2FA.
 */
public class UserDAO extends BaseDAO implements GenericDAO<User, Integer> {

    private static final String BASE_SELECT =
            "SELECT u.user_id as id, u.username, u.full_name, u.display_name, u.email, "
            + "u.password_hash as password, u.phone, u.avatar_url, u.status, "
            + "COALESCE(u.two_factor_enabled, 0) as two_factor_enabled, "
            + "u.google_id, u.auth_provider, u.created_at, "
            + "u.date_of_birth, u.gender, u.address, "
            + "COALESCE(r.role_id, 2) as role_id, "
            + "COALESCE(r.role_name, 'ROLE_CUSTOMER') as role_name, "
            + "COALESCE(r.description, 'Khách hàng') as role_desc "
            + "FROM users u "
            + "LEFT JOIN userroles ur ON u.user_id = ur.user_id "
            + "LEFT JOIN roles r ON ur.role_id = r.role_id ";

    @Override
    public Optional<User> findById(Integer id) {
        if (id == null) return Optional.empty();
        String sql = BASE_SELECT + "WHERE u.user_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding user by id: " + id, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    public Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        String sql = BASE_SELECT + "WHERE LOWER(u.email) = LOWER(?) LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding user by email: " + email, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    public Optional<User> findByUsername(String username) {
        if (username == null) return Optional.empty();
        String sql = BASE_SELECT + "WHERE LOWER(u.username) = LOWER(?) OR LOWER(u.email) = LOWER(?) LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username.trim());
            ps.setString(2, username.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding user by username: " + username, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    public Optional<User> findByGoogleId(String googleId) {
        if (googleId == null) return Optional.empty();
        String sql = BASE_SELECT + "WHERE u.google_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, googleId.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding user by googleId: " + googleId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    public User findByLoginIdentifier(String loginIdentifier) throws SQLException {
        if (loginIdentifier == null || loginIdentifier.trim().isEmpty()) {
            return null;
        }
        return findByEmail(loginIdentifier)
                .or(() -> findByUsername(loginIdentifier))
                .orElse(null);
    }

    public boolean existsByEmail(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsByPhone(String phone) throws SQLException {
        if (phone == null || phone.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM users WHERE phone = ? LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsByUsername(String username) throws SQLException {
        if (username == null || username.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM users WHERE LOWER(username) = LOWER(?) LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsByUsernameExceptUser(String username, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE LOWER(username) = LOWER(?) AND user_id != ? LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsByPhoneExceptUser(String phone, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE phone = ? AND user_id != ? LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public List<User> findAll() {
        List<User> users = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY u.user_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all users", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return users;
    }

    @Override
    public boolean insert(User user) {
        String sqlUser = "INSERT INTO users (username, full_name, display_name, email, password_hash, password, phone, status, google_id, auth_provider, avatar_url, email_verified) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        String sqlRole = "INSERT INTO userroles (user_id, role_id) VALUES (?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement psRole = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            String username = user.getUsername() != null && !user.getUsername().isBlank()
                    ? user.getUsername() : user.getEmail();
            ps.setString(1, username);
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getDisplayName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPassword());
            ps.setString(6, user.getPassword());
            ps.setString(7, user.getPhone());
            ps.setString(8, user.getStatus() != null ? user.getStatus() : "ACTIVE");
            ps.setString(9, user.getGoogleId());
            ps.setString(10, user.getAuthProvider() != null ? user.getAuthProvider() : "local");
            ps.setString(11, user.getAvatarUrl());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int newUserId = rs.getInt(1);
                    user.setId(newUserId);

                    int roleId = user.getRoleId() > 0 ? user.getRoleId() : 2; // 2 = ROLE_CUSTOMER
                    psRole = conn.prepareStatement(sqlRole);
                    psRole.setInt(1, newUserId);
                    psRole.setInt(2, roleId);
                    psRole.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            logger.log(Level.SEVERE, "Error inserting user: " + user.getEmail(), e);
            return false;
        } finally {
            closeResources(null, psRole, null);
            closeResources(conn, ps, rs);
        }
    }

    public boolean insertGoogleUser(User user) throws SQLException {
        return insert(user);
    }

    @Override
    public boolean update(User user) {
        String sql = "UPDATE users SET full_name = ?, display_name = ?, phone = ?, status = ?, avatar_url = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getDisplayName());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getStatus());
            ps.setString(5, user.getAvatarUrl());
            ps.setInt(6, user.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating user id: " + user.getId(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    public boolean updateProfile(int userId, String fullName, String phone, String avatarUrl,
                                 Date dateOfBirth, String gender, String address) {
        String sql = "UPDATE users SET full_name = ?, display_name = ?, phone = ?, avatar_url = ?, date_of_birth = ?, gender = ?, address = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            ps.setString(4, avatarUrl);
            ps.setDate(5, dateOfBirth);
            ps.setString(6, gender);
            ps.setString(7, address);
            ps.setInt(8, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating profile for user id: " + userId, e);
            return false;
        }
    }

    public boolean updateProfile(int userId, String fullName, String phone, String avatarUrl) {
        return updateProfile(userId, fullName, phone, avatarUrl, null, null, null);
    }

    public boolean updateProfile(int userId, String username, String phone) throws SQLException {
        String sql = "UPDATE users SET username = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, phone);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePassword(int userId, String hashedPassword) {
        String sql = "UPDATE users SET password_hash = ?, password = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setString(2, hashedPassword);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating password for user id: " + userId, e);
            return false;
        }
    }

    public boolean updateTwoFactor(int userId, boolean enabled) throws SQLException {
        String sql = "UPDATE users SET two_factor_enabled = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, enabled);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateGoogleProfile(int userId, String displayName, String avatarUrl) throws SQLException {
        String sql = "UPDATE users SET display_name = COALESCE(NULLIF(?, ''), display_name), "
                + "avatar_url = COALESCE(?, avatar_url) WHERE user_id = ? AND google_id IS NOT NULL";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, displayName);
            ps.setString(2, avatarUrl);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean linkGoogleId(int userId, String email, String googleId) throws SQLException {
        String sql = "UPDATE users SET google_id = ?, auth_provider = 'google' "
                + "WHERE user_id = ? AND LOWER(email) = LOWER(?) AND google_id IS NULL";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleId);
            ps.setInt(2, userId);
            ps.setString(3, email);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean linkGoogleAccount(int userId, String googleId, String avatarUrl) {
        String sql = "UPDATE users SET google_id = ?, avatar_url = COALESCE(avatar_url, ?), auth_provider = 'google' WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleId);
            ps.setString(2, avatarUrl);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error linking google account for user id: " + userId, e);
            return false;
        }
    }

    @Override
    public boolean delete(Integer id) {
        if (id == null) return false;
        String sqlRole = "DELETE FROM userroles WHERE user_id = ?";
        String sql = "DELETE FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement psRole = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psRole = conn.prepareStatement(sqlRole);
            psRole.setInt(1, id);
            psRole.executeUpdate();

            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            boolean ok = ps.executeUpdate() > 0;

            conn.commit();
            return ok;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) {}
            }
            logger.log(Level.SEVERE, "Error deleting user id: " + id, e);
            return false;
        } finally {
            closeResources(null, psRole, null);
            closeResources(conn, ps, null);
        }
    }

    public int createLocalUser(String email, String fullName, String phone, String hashedPassword) {
        User u = new User();
        u.setEmail(email);
        u.setUsername(email);
        u.setFullName(fullName);
        u.setDisplayName(fullName);
        u.setPhone(phone);
        u.setPassword(hashedPassword);
        u.setRoleId(2); // 2 = ROLE_CUSTOMER
        u.setStatus("ACTIVE");
        u.setAuthProvider("local");

        if (insert(u)) {
            return u.getId();
        }
        return -1;
    }

    public int createGoogleUser(String email, String fullName, String googleId, String avatarUrl) {
        User u = new User();
        u.setEmail(email);
        u.setUsername(email);
        u.setFullName(fullName);
        u.setDisplayName(fullName);
        u.setPassword(null);
        u.setGoogleId(googleId);
        u.setAvatarUrl(avatarUrl);
        u.setRoleId(2); // 2 = ROLE_CUSTOMER
        u.setStatus("ACTIVE");
        u.setAuthProvider("google");

        if (insert(u)) {
            return u.getId();
        }
        return -1;
    }

    public String generateUsernameFromEmail(String email) {
        String base = email.split("@")[0];
        return base + "_" + (System.currentTimeMillis() % 100000);
    }

    public Optional<User> authenticateHost(String email, String plainPassword) {
        if (email == null || email.trim().isEmpty() || plainPassword == null || plainPassword.isEmpty()) {
            return Optional.empty();
        }

        String sql = BASE_SELECT + "WHERE LOWER(u.email) = LOWER(?) AND r.role_name = 'ROLE_HOST'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return Optional.empty();
                }

                User user = mapResultSetToUser(rs);
                if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
                    return Optional.empty();
                }

                if (!PasswordUtil.verifyPassword(plainPassword, user.getPassword())) {
                    return Optional.empty();
                }

                user.setPassword(null);
                return Optional.of(user);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error authenticating Host", e);
            return Optional.empty();
        }
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        int roleId = rs.getInt("role_id");
        user.setRoleId(roleId);
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setDisplayName(rs.getString("display_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setStatus(rs.getString("status"));
        user.setTwoFactorEnabled(rs.getBoolean("two_factor_enabled"));
        user.setGoogleId(rs.getString("google_id"));
        user.setAuthProvider(rs.getString("auth_provider"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setDateOfBirth(rs.getDate("date_of_birth"));
        user.setGender(rs.getString("gender"));
        user.setAddress(rs.getString("address"));

        Role role = new Role();
        role.setId(roleId);
        role.setRoleName(rs.getString("role_name"));
        role.setDescription(rs.getString("role_desc"));
        user.setRole(role);

        return user;
    }
}
