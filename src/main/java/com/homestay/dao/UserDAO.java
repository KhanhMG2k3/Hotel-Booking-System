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
 */
public class UserDAO extends BaseDAO implements GenericDAO<User, Integer> {

    @Override
    public Optional<User> findById(Integer id) {
        String sql = "SELECT u.*, r.role_name, r.description as role_desc "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.id "
                + "WHERE u.id = ?";
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
        String sql = "SELECT u.*, r.role_name, r.description as role_desc "
                + "FROM users u "
                + "LEFT JOIN roles r ON u.role_id = r.id "
                + "WHERE u.username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
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

    // c) Thêm 2 method mới (đặt sau findByUsername):
    public Optional<User> findByEmail(String email) {
        String sql = "SELECT u.*, r.role_name, r.description as role_desc "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.id "
                + "WHERE u.email = ?";
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
        String sql = "SELECT u.*, r.role_name, r.description as role_desc "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.id "
                + "WHERE u.google_id = ?";
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

    /**
     * Liên kết Google vào tài khoản local đã có sẵn (cùng email).
     */
    public boolean linkGoogleAccount(int userId, String googleId, String avatarUrl) {
        String sql = "UPDATE users SET google_id = ?, avatar_url = ? WHERE id = ?";
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
        String sql = "SELECT u.*, r.role_name, r.description as role_desc "
                + "FROM users u "
                + "JOIN roles r ON u.role_id = r.id "
                + "ORDER BY u.id ASC";
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

    // b) Sửa insert() — thêm 3 cột mới vào câu SQL để hỗ trợ cả đăng ký local lẫn
    // Google:
    @Override
    public boolean insert(User user) {
        String sql = "INSERT INTO users (role_id, username, password, full_name, email, phone, status, google_id, auth_provider, avatar_url) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, user.getRoleId() > 0 ? user.getRoleId() : 2);
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getPassword()); // NULL nếu là tài khoản Google
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getEmail());
            ps.setString(6, user.getPhone());
            ps.setString(7, user.getStatus() != null ? user.getStatus() : "ACTIVE");
            ps.setString(8, user.getGoogleId());
            ps.setString(9, user.getAuthProvider() != null ? user.getAuthProvider() : "local");
            ps.setString(10, user.getAvatarUrl());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting user: " + user.getUsername(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean update(User user) {
        String sql = "UPDATE users SET role_id = ?, full_name = ?, email = ?, phone = ?, status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, user.getRoleId());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getStatus());
            ps.setInt(6, user.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating user id: " + user.getId(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM users WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting user id: " + id, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // Sửa mapResultSetToUser() — thêm 3 dòng đọc cột mới (thêm ngay trước return
    // user;):
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setRoleId(rs.getInt("role_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));

        Role role = new Role();
        role.setId(rs.getInt("role_id"));
        role.setRoleName(rs.getString("role_name"));
        role.setDescription(rs.getString("role_desc"));
        user.setRole(role);

        user.setGoogleId(rs.getString("google_id"));
        user.setAuthProvider(rs.getString("auth_provider"));
        user.setAvatarUrl(rs.getString("avatar_url"));

        return user;
    }

    /**
     * Tạo tài khoản đăng ký thường (email + mật khẩu). Trả về id user mới, -1
     * nếu lỗi.
     */
    public int createLocalUser(String email, String fullName, String phone, String hashedPassword) {
        String username = generateUsernameFromEmail(email);
        String sql = "INSERT INTO users (role_id, username, password, full_name, email, phone, status) "
                + "VALUES (2, ?, ?, ?, ?, ?, 'ACTIVE')"; // role_id = 2 -> ROLE_CUSTOMER
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            ps.setString(3, fullName);
            ps.setString(4, email);
            ps.setString(5, phone);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Tạo tài khoản mới từ đăng nhập Google lần đầu.
     */
    public int createGoogleUser(String email, String fullName, String googleId, String avatarUrl) {
        String username = generateUsernameFromEmail(email);
        String sql = "INSERT INTO users (role_id, username, password, full_name, email, status, google_id, auth_provider, avatar_url) "
                + "VALUES (2, ?, NULL, ?, ?, 'ACTIVE', ?, 'google', ?)";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, googleId);
            ps.setString(5, avatarUrl);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    private String generateUsernameFromEmail(String email) {
        // username là NOT NULL UNIQUE trong schema thật -> tự sinh để không lỗi ràng
        // buộc
        String base = email.split("@")[0];
        return base + "_" + (System.currentTimeMillis() % 100000);
    }
}