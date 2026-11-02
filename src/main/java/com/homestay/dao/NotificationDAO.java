package com.homestay.dao;

import com.homestay.model.Notification;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

/**
 * Data Access Object for handling user In-App Notifications.
 */
public class NotificationDAO extends BaseDAO {

    /**
     * Retrieves notifications for a given user with optional filters and pagination.
     */
    public List<Notification> findByUserId(int userId, String filterType, Boolean unreadOnly, int limit, int offset) {
        List<Notification> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, user_id, title, message, type, target_url, is_read, created_at " +
                "FROM notifications WHERE user_id = ? ");

        if (filterType != null && !filterType.isBlank() && !"ALL".equalsIgnoreCase(filterType)) {
            sql.append("AND type = ? ");
        }
        if (unreadOnly != null && unreadOnly) {
            sql.append("AND is_read = 0 ");
        }
        sql.append("ORDER BY created_at DESC LIMIT ? OFFSET ?");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);

            if (filterType != null && !filterType.isBlank() && !"ALL".equalsIgnoreCase(filterType)) {
                ps.setString(paramIndex++, filterType.toUpperCase());
            }

            ps.setInt(paramIndex++, limit > 0 ? limit : 20);
            ps.setInt(paramIndex++, Math.max(offset, 0));

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapNotification(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching notifications for userId: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Counts total notifications matching criteria (for pagination).
     */
    public int countByUserId(int userId, String filterType, Boolean unreadOnly) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM notifications WHERE user_id = ? ");
        if (filterType != null && !filterType.isBlank() && !"ALL".equalsIgnoreCase(filterType)) {
            sql.append("AND type = ? ");
        }
        if (unreadOnly != null && unreadOnly) {
            sql.append("AND is_read = 0 ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            if (filterType != null && !filterType.isBlank() && !"ALL".equalsIgnoreCase(filterType)) {
                ps.setString(paramIndex++, filterType.toUpperCase());
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting notifications for userId: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Quick count of unread notifications for badge display.
     */
    public int countUnreadByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting unread notifications for userId: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Retrieves the top most recent notifications (e.g. for header dropdown).
     */
    public List<Notification> findTopRecentByUserId(int userId, int limit) {
        return findByUserId(userId, null, null, limit, 0);
    }

    /**
     * Marks a specific notification as read.
     */
    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error marking notification as read. ID: " + notificationId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Marks all unread notifications of a user as read.
     */
    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error marking all notifications as read for userId: " + userId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Inserts a new notification into the database.
     */
    public boolean createNotification(int userId, String title, String message, String type, String targetUrl) {
        String sql = "INSERT INTO notifications (user_id, title, message, type, target_url, is_read, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.setString(4, (type != null && !type.isBlank()) ? type.toUpperCase() : "SYSTEM");
            ps.setString(5, targetUrl);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating notification for userId: " + userId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Deletes a notification by ID and User ID.
     */
    public boolean deleteNotification(int notificationId, int userId) {
        String sql = "DELETE FROM notifications WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting notification ID: " + notificationId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private Notification mapNotification(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setTargetUrl(rs.getString("target_url"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}