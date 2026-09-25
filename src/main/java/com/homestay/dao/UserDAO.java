package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.Role;
import com.homestay.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

/**
 * UserDAO - Data Access Object for User accounts.
 * Compatible with homestaybooking database (users, userroles, roles).
 */
public class UserDAO extends BaseDAO implements GenericDAO<User, Integer> {

    private static final String BASE_SELECT =
            "SELECT u.user_id as id, u.full_name, u.email, u.password_hash as password, u.phone, "
            + "u.avatar_url, u.status, u.google_id, u.auth_provider, u.created_at, "
            + "u.date_of_birth, u.gender, u.address, "
            + "COALESCE(r.role_id, 1) as role_id, "
            + "COALESCE(r.role_name, 'CUSTOMER') as role_name, "
            + "COALESCE(r.description, 'Khách hàng') as role_desc "
            + "FROM users u "
            + "LEFT JOIN userroles ur ON u.user_id = ur.user_id "
            + "LEFT JOIN roles r ON ur.role_id = r.role_id ";

    @Override
    public Optional<User> findById(Integer id) {
        String sql = BASE_SELECT + "WHERE u.user_id = ?";
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

    public Optional<User> findByUsername(String username) {
        return findByEmail(username);
    }

    public Optional<User> findByEmail(String email) {
        String sql = BASE_SELECT + "WHERE u.email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
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

    public Optional<User> findByGoogleId(String googleId) {
        String sql = BASE_SELECT + "WHERE u.google_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, googleId);
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

    public boolean linkGoogleAccount(int userId, String googleId, String avatarUrl) {
        String sql = "UPDATE users SET google_id = ?, avatar_url = COALESCE(avatar_url, ?), auth_provider = 'google' WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, googleId);
            ps.setString(2, avatarUrl);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error linking google account for user id: " + userId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
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
        String sqlUser = "INSERT INTO users (full_name, email, password_hash, phone, status, google_id, auth_provider, avatar_url, email_verified) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
        String sqlRole = "INSERT INTO userroles (user_id, role_id) VALUES (?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement psRole = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getStatus() != null ? user.getStatus() : "ACTIVE");
            ps.setString(6, user.getGoogleId());
            ps.setString(7, user.getAuthProvider() != null ? user.getAuthProvider() : "local");
            ps.setString(8, user.getAvatarUrl());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int newUserId = rs.getInt(1);
                    user.setId(newUserId);

                    int roleId = user.getRoleId() > 0 ? user.getRoleId() : 1;
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

    @Override
    public boolean update(User user) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, status = ?, avatar_url = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getStatus());
            ps.setString(4, user.getAvatarUrl());
            ps.setInt(5, user.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating user id: " + user.getId(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Cập nhật thông tin profile (họ tên, sđt, avatar, ngày sinh, giới tính, địa chỉ).
     */
    public boolean updateProfile(int userId, String fullName, String phone, String avatarUrl,
                                 java.sql.Date dateOfBirth, String gender, String address) {
        String sql = "UPDATE users SET full_name = ?, phone = ?, avatar_url = ?, date_of_birth = ?, gender = ?, address = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, avatarUrl);
            ps.setDate(4, dateOfBirth);
            ps.setString(5, gender);
            ps.setString(6, address);
            ps.setInt(7, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating profile for user id: " + userId, e);
            return false;
        }
    }

    public boolean updateProfile(int userId, String fullName, String phone, String avatarUrl) {
        return updateProfile(userId, fullName, phone, avatarUrl, null, null, null);
    }

    /**
     * Đổi mật khẩu (password đã hash sẵn).
     */
    public boolean updatePassword(int userId, String hashedPassword) {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating password for user id: " + userId, e);
            return false;
        }
    }

    @Override
    public boolean delete(Integer id) {
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
        u.setPhone(phone);
        u.setPassword(hashedPassword);
        u.setRoleId(1); // 1 = CUSTOMER
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
        u.setPassword(null);
        u.setGoogleId(googleId);
        u.setAvatarUrl(avatarUrl);
        u.setRoleId(1); // 1 = CUSTOMER
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

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        int roleId = rs.getInt("role_id");
        user.setRoleId(roleId);
        user.setUsername(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setStatus(rs.getString("status"));
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

    private User mapRow(ResultSet rs) throws SQLException {
        return mapResultSetToUser(rs);
    }
}
