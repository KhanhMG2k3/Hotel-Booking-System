package com.homestay.dao;

import com.homestay.model.Role;
import com.homestay.model.User;
import com.homestay.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
        if (id == null || id <= 0) {
            return Optional.empty();
        }

        String sql = "SELECT u.*, r.role_name, r.description AS role_desc "
                   + "FROM users u "
                   + "JOIN roles r ON u.role_id = r.id "
                   + "WHERE u.id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding user by id: " + id, e);
        }

        return Optional.empty();
    }

    public Optional<User> findByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return Optional.empty();
        }

        String sql = "SELECT u.*, r.role_name, r.description AS role_desc "
                   + "FROM users u "
                   + "JOIN roles r ON u.role_id = r.id "
                   + "WHERE u.username = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding user by username", e);
        }

        return Optional.empty();
    }

    /**
     * Authenticates an ACTIVE Host account using a BCrypt password hash.
     *
     * Returns an empty Optional if the account does not exist, is inactive,
     * has another role, or the password is invalid.
     *
     * The password field is cleared before returning the authenticated user.
     */
    public Optional<User> authenticateHost(
            String username, String plainPassword) {

        if (username == null || username.trim().isEmpty()
                || plainPassword == null || plainPassword.isEmpty()) {
            return Optional.empty();
        }

        Optional<User> optionalUser = findByUsername(username.trim());

        if (optionalUser.isEmpty()) {
            return Optional.empty();
        }

        User user = optionalUser.get();

        if (!"ACTIVE".equals(user.getStatus())
                || user.getRole() == null
                || !"ROLE_HOST".equals(user.getRole().getRoleName())) {
            return Optional.empty();
        }

        if (!PasswordUtil.verifyPassword(
                plainPassword, user.getPassword())) {
            return Optional.empty();
        }

        // Do not expose the stored password hash to the caller.
        user.setPassword(null);

        return Optional.of(user);
    }

    @Override
    public List<User> findAll() {
        List<User> users = new ArrayList<>();

        String sql = "SELECT u.*, r.role_name, r.description AS role_desc "
                   + "FROM users u "
                   + "JOIN roles r ON u.role_id = r.id "
                   + "ORDER BY u.id ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all users", e);
        }

        return users;
    }

    @Override
    public boolean insert(User user) {
        if (user == null) {
            return false;
        }

        String sql = "INSERT INTO users "
                   + "(role_id, username, password, full_name, email, phone, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, user.getRoleId() > 0 ? user.getRoleId() : 2);
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getEmail());
            ps.setString(6, user.getPhone());
            ps.setString(7,
                    user.getStatus() != null ? user.getStatus() : "ACTIVE");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting user", e);
            return false;
        }
    }

    @Override
    public boolean update(User user) {
        if (user == null || user.getId() <= 0) {
            return false;
        }

        String sql = "UPDATE users "
                   + "SET role_id = ?, full_name = ?, email = ?, "
                   + "phone = ?, status = ? "
                   + "WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, user.getRoleId());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getStatus());
            ps.setInt(6, user.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error updating user id: " + user.getId(), e);
            return false;
        }
    }

    @Override
    public boolean delete(Integer id) {
        if (id == null || id <= 0) {
            return false;
        }

        String sql = "DELETE FROM users WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting user", e);
            return false;
        }
    }

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

        return user;
    }
}
