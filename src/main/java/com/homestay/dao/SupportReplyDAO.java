package com.homestay.dao;

import com.homestay.exception.DataAccessException;
import com.homestay.model.SupportReply;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

/**
 * SupportReplyDAO - Data Access Object for threaded support replies.
 */
public class SupportReplyDAO extends BaseDAO {

    private static final String BASE_SELECT =
            "SELECT r.reply_id, r.ticket_id, r.sender_id, r.message, r.created_at, "
            + "u.full_name as sender_name, u.avatar_url as sender_avatar, "
            + "COALESCE(ro.role_name, 'ROLE_CUSTOMER') as sender_role "
            + "FROM support_replies r "
            + "JOIN users u ON r.sender_id = u.user_id "
            + "LEFT JOIN userroles ur ON u.user_id = ur.user_id "
            + "LEFT JOIN roles ro ON ur.role_id = ro.role_id ";

    /**
     * Inserts a reply within an existing database transaction.
     */
    public boolean insert(SupportReply reply, Connection conn) throws SQLException {
        if (reply == null || conn == null) {
            return false;
        }

        String sql = "INSERT INTO support_replies (ticket_id, sender_id, message, created_at) "
                   + "VALUES (?, ?, ?, CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, reply.getTicketId());
            ps.setInt(2, reply.getSenderId());
            ps.setString(3, reply.getMessage());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        reply.setReplyId(rs.getInt(1));
                    }
                }
                return true;
            }
            return false;
        }
    }

    /**
     * Inserts a reply in a standalone connection.
     */
    public boolean insert(SupportReply reply) {
        Connection conn = null;
        try {
            conn = getConnection();
            return insert(reply, conn);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting support reply for ticket: " + (reply != null ? reply.getTicketId() : 0), e);
            throw new DataAccessException("Failed to insert support reply", e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Fetches all replies for a given ticket, ordered chronologically.
     */
    public List<SupportReply> findByTicketId(int ticketId) {
        String sql = BASE_SELECT + "WHERE r.ticket_id = ? ORDER BY r.created_at ASC, r.reply_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<SupportReply> list = new ArrayList<>();

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, ticketId);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToReply(rs));
            }
            return list;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching replies for ticketId: " + ticketId, e);
            throw new DataAccessException("Failed to fetch support replies for ticket " + ticketId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Counts the total number of replies on a ticket.
     */
    public int countByTicketId(int ticketId) {
        String sql = "SELECT COUNT(*) FROM support_replies WHERE ticket_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, ticketId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting replies for ticketId: " + ticketId, e);
            throw new DataAccessException("Failed to count support replies for ticket " + ticketId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    // ==================== BAT DAU THEM MOI DOT 5: TRUY VAN ADMIN XU LY TICKET & MA PHAN HOI CUOI ====================

    /**
     * TIM DANH SACH ADMIN DANG HOAT DONG DA THAM GIA PHAN HOI XU LY TREN TICKET NAY.
     * DUNG DE GUI THONG BAO CHO NGUOI XU LY KHI KHACH HANG / HOST GUI TIN NHAN BO SUNG.
     */
    public List<Integer> findRepliedAdminIdsByTicketId(int ticketId, Connection conn) throws SQLException {
        List<Integer> adminIds = new ArrayList<>();
        if (conn == null || ticketId <= 0) {
            return adminIds;
        }

        String sql = "SELECT DISTINCT r.sender_id "
                   + "FROM support_replies r "
                   + "JOIN users u ON r.sender_id = u.user_id "
                   + "LEFT JOIN userroles ur ON u.user_id = ur.user_id "
                   + "LEFT JOIN roles ro ON COALESCE(ur.role_id, u.role_id) = ro.role_id "
                   + "WHERE r.ticket_id = ? "
                   + "AND (u.role_id = 1 OR ro.role_id = 1 OR UPPER(ro.role_name) IN ('ROLE_ADMIN', 'ADMIN', 'ADMINISTRATOR')) "
                   + "AND UPPER(COALESCE(u.status, 'ACTIVE')) = 'ACTIVE' "
                   + "ORDER BY r.sender_id ASC";

        PreparedStatement ps = conn.prepareStatement(sql);
        if (ps == null) {
            return adminIds;
        }
        try (PreparedStatement stmt = ps) {
            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs != null) {
                    while (rs.next()) {
                        adminIds.add(rs.getInt("sender_id"));
                    }
                }
            }
        }
        return adminIds;
    }

    /**
     * LAY REPLY_ID MOI NHAT TREN TICKET TRONG CUNG TRANSACTION DE TAO KHOA SU KIEN CHUYEN TRANG THAI RESOLVED.
     */
    public int findLatestReplyId(int ticketId, Connection conn) throws SQLException {
        if (conn == null || ticketId <= 0) {
            return 0;
        }

        String sql = "SELECT COALESCE(MAX(reply_id), 0) AS latest_reply_id FROM support_replies WHERE ticket_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        if (ps == null) {
            return 0;
        }
        try (PreparedStatement stmt = ps) {
            stmt.setInt(1, ticketId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs != null && rs.next()) {
                    return rs.getInt("latest_reply_id");
                }
            }
        }
        return 0;
    }

    // ==================== KET THUC THEM MOI DOT 5: TRUY VAN ADMIN XU LY TICKET & MA PHAN HOI CUOI ====================

    private SupportReply mapResultSetToReply(ResultSet rs) throws SQLException {
        SupportReply r = new SupportReply();
        r.setReplyId(rs.getInt("reply_id"));
        r.setTicketId(rs.getInt("ticket_id"));
        r.setSenderId(rs.getInt("sender_id"));
        r.setMessage(rs.getString("message"));
        r.setCreatedAt(rs.getTimestamp("created_at"));

        String senderName = rs.getString("sender_name");
        String senderRole = rs.getString("sender_role");
        String senderAvatar = rs.getString("sender_avatar");

        r.setSenderName(senderName);
        r.setSenderRole(senderRole);
        r.setSenderAvatar(senderAvatar);
        r.setAdminReply("ROLE_ADMIN".equalsIgnoreCase(senderRole) || "ADMIN".equalsIgnoreCase(senderRole));
        return r;
    }
}
