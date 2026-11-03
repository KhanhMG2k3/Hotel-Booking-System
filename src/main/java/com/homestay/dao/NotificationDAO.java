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
     * Retrieves notifications for a given user with optional filters and
     * pagination.
     */
    public List<Notification> findByUserId(int userId, String filterType, Boolean unreadOnly, int limit, int offset) {
        List<Notification> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, user_id, title, message, type, target_url, is_read, created_at "
                + "FROM notifications WHERE user_id = ? ");

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
        String sql = "INSERT INTO notifications (user_id, title, message, type, target_url, is_read, created_at) "
                + "VALUES (?, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP)";
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

    // ==================== BAT DAU THEM MOI DOT 5: TICH HOP NOTIFICATION CHO CONTACT & SUPPORT ====================
    /**
     * KIEM TRA CHONG TRUNG THONG BAO THEO CAP (USER_ID, TARGET_URL) TRONG CUNG
     * TRANSACTION NGHIEP VU.
     */
    public boolean existsByUserAndTargetUrl(int userId, String targetUrl, Connection conn) throws SQLException {
        if (conn == null || userId <= 0 || targetUrl == null || targetUrl.isBlank()) {
            return false;
        }
        String sql = "SELECT 1 FROM notifications WHERE user_id = ? AND target_url = ? LIMIT 1";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (ps == null) {
            return false;
        }
        try (PreparedStatement stmt = ps) {
            stmt.setInt(1, userId);
            stmt.setString(2, targetUrl.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                return rs != null && rs.next();
            }
        }
    }

    /**
     * TAO THONG BAO NHAT QUAN TRONG CUNG TRANSACTION NGHIEP VU VA CHONG TRUNG
     * THEO SU KIEN. NEU TRANSACTION CHA ROLLBACK THI THONG BAO CUNG DUOC
     * ROLLBACK, KHONG SINH THONG BAO SAI.
     */
    public boolean createNotificationIfAbsent(int userId, String title, String message,
            String type, String targetUrl, Connection conn) throws SQLException {
        if (conn == null || userId <= 0 || title == null || title.isBlank() || message == null || message.isBlank()) {
            return false;
        }

        // CHONG TRUNG THEO TUNG SU KIEN QUA KHOA TARGET_URL CHUA MA SU KIEN (TICKET_ID / REPLY_ID / TRANSITION_ID)
        String normalizedTargetUrl = (targetUrl != null && !targetUrl.isBlank()) ? targetUrl.trim() : null;
        if (normalizedTargetUrl != null && existsByUserAndTargetUrl(userId, normalizedTargetUrl, conn)) {
            return false;
        }

        // DAM BAO GIA TRI TYPE HOP LE VOI ENUM('BOOKING','PROMOTION','REVIEW','SYSTEM') TRONG BANG NOTIFICATIONS
        String safeType = normalizeNotificationType(type);

        String sql = "INSERT INTO notifications (user_id, title, message, type, target_url, is_read, created_at) "
                + "VALUES (?, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP)";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (ps == null) {
            return false;
        }
        try (PreparedStatement stmt = ps) {
            stmt.setInt(1, userId);
            stmt.setString(2, title.trim());
            stmt.setString(3, message.trim());
            stmt.setString(4, safeType);
            stmt.setString(5, normalizedTargetUrl);
            int affected = stmt.executeUpdate();
            if (affected <= 0) {
                throw new SQLException("Khong the ghi nhan thong bao cho userId=" + userId);
            }
            return true;
        }
    }

    /**
     * TRUY VAN DANH SACH ADMIN DANG HOAT DONG TU DATABASE (KHONG HARD-CODE
     * ADMIN ID, KHONG LAY TU INPUT).
     */
    public List<Integer> findActiveAdminIds(Connection conn) throws SQLException {
        List<Integer> adminIds = new ArrayList<>();
        if (conn == null) {
            return adminIds;
        }

        String sql = "SELECT DISTINCT u.user_id "
                + "FROM users u "
                + "LEFT JOIN userroles ur ON u.user_id = ur.user_id "
                + "LEFT JOIN roles r ON COALESCE(ur.role_id, u.role_id) = r.role_id "
                + "WHERE (u.role_id = 1 OR r.role_id = 1 OR UPPER(r.role_name) IN ('ROLE_ADMIN', 'ADMIN', 'ADMINISTRATOR')) "
                + "AND UPPER(COALESCE(u.status, 'ACTIVE')) = 'ACTIVE' "
                + "ORDER BY u.user_id ASC";

        PreparedStatement ps = conn.prepareStatement(sql);
        if (ps == null) {
            return adminIds;
        }
        try (PreparedStatement stmt = ps; ResultSet rs = stmt.executeQuery()) {
            if (rs != null) {
                while (rs.next()) {
                    adminIds.add(rs.getInt("user_id"));
                }
            }
        }
        return adminIds;
    }

    /**
     * CHUAN HOA LOAI THONG BAO DE KHOP CHINH XAC ENUM TRONG DATABASE.
     */
    private String normalizeNotificationType(String type) {
        if (type == null || type.isBlank()) {
            return "SYSTEM";
        }
        String upper = type.trim().toUpperCase();
        switch (upper) {
            case "BOOKING":
            case "PROMOTION":
            case "REVIEW":
            case "SYSTEM":
                return upper;
            default:
                return "SYSTEM";
        }
    }

    // ==================== KET THUC THEM MOI DOT 5: TICH HOP NOTIFICATION CHO CONTACT & SUPPORT ====================
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

    /**
     * TỰ ĐỘNG QUÉT VÀ TẠO THÔNG BÁO MỜI ĐÁNH GIÁ: Quét các đơn phòng của khách
     * đã hoàn thành lưu trú (COMPLETED hoặc đã qua ngày check-out) mà chưa từng
     * gửi thông báo mời đánh giá.
     */
    public void autoGenerateCompletedStayReviewNotifications(int userId) {
        String queryBookings
                = "SELECT b.id, b.booking_code, b.room_id, COALESCE(r.room_name, 'homestay') AS room_name "
                + "FROM bookings b "
                + "LEFT JOIN rooms r ON b.room_id = r.room_id "
                + "WHERE b.user_id = ? "
                + "  AND (b.status = 'COMPLETED' OR (b.status = 'CONFIRMED' AND b.check_out_date <= CURRENT_DATE())) "
                + "  AND NOT EXISTS (SELECT 1 FROM reviews rv WHERE rv.booking_id = b.id) "
                + "  AND NOT EXISTS (SELECT 1 FROM notifications n WHERE n.user_id = b.user_id AND n.target_url = CONCAT('/write-review?bookingId=', b.id))";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(queryBookings);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                int bookingId = rs.getInt("id");
                String bookingCode = rs.getString("booking_code");
                if (bookingCode == null || bookingCode.isBlank()) {
                    bookingCode = "BK-" + bookingId;
                }
                String roomName = rs.getString("room_name");

                String notifTitle = "Mời bạn đánh giá kỳ nghỉ tại " + roomName;
                String notifMsg = "Kỳ nghỉ của bạn (Mã #" + bookingCode + ") đã hoàn thành! Hãy chia sẻ cảm nhận và hình ảnh trải nghiệm để nhận ưu đãi cho các chuyến đi tới nhé.";
                String targetUrl = "/write-review?bookingId=" + bookingId;

                // Tự động tạo thông báo mời review vào bảng notifications
                createNotification(userId, notifTitle, notifMsg, "REVIEW", targetUrl);
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Lỗi khi tự động tạo thông báo review cho user: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }
}
