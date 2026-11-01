package com.homestay.dao;

import com.homestay.exception.DataAccessException;
import com.homestay.model.ContactMessage;
import com.homestay.model.TicketCategory;
import com.homestay.model.TicketStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Level;

/**
 * ContactMessageDAO - Data Access Object for contact and support tickets.
 * Handles ticket creation, parameterized filtering, pagination, and optimistic state updates.
 */
public class ContactMessageDAO extends BaseDAO {

    private static final Set<String> ALLOWED_SORT_COLUMNS = Set.of(
            "created_at", "updated_at", "status", "category", "subject", "message_id"
    );

    private static final Set<String> ALLOWED_SORT_ORDERS = Set.of(
            "ASC", "DESC"
    );

    private static final String BASE_SELECT =
            "SELECT c.message_id, c.user_id, c.ticket_code, c.category, c.booking_id, "
            + "c.full_name, c.email, c.phone, c.subject, c.message, c.status, "
            + "c.created_at, c.updated_at, "
            + "b.booking_code, "
            + "COALESCE(ro.role_name, 'GUEST') as sender_role, "
            + "(SELECT COUNT(*) FROM support_replies sr WHERE sr.ticket_id = c.message_id) as reply_count "
            + "FROM contactmessages c "
            + "LEFT JOIN users u ON c.user_id = u.user_id "
            + "LEFT JOIN userroles ur ON u.user_id = ur.user_id "
            + "LEFT JOIN roles ro ON ur.role_id = ro.role_id "
            + "LEFT JOIN bookings b ON c.booking_id = b.id ";

    /**
     * Inserts a new support ticket within a database transaction.
     */
    public boolean insert(ContactMessage ticket, Connection conn) throws SQLException {
        if (ticket == null || conn == null) {
            return false;
        }

        String sql = "INSERT INTO contactmessages "
                + "(user_id, ticket_code, category, booking_id, full_name, email, phone, subject, message, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (ticket.getUserId() != null) {
                ps.setInt(1, ticket.getUserId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }

            ps.setString(2, ticket.getTicketCode());
            ps.setString(3, ticket.getCategory() != null ? ticket.getCategory().name() : TicketCategory.GENERAL_FEEDBACK.name());

            if (ticket.getBookingId() != null) {
                ps.setInt(4, ticket.getBookingId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }

            ps.setString(5, ticket.getFullName());
            ps.setString(6, ticket.getEmail());
            ps.setString(7, ticket.getPhone());
            ps.setString(8, ticket.getSubject());
            ps.setString(9, ticket.getMessage());
            ps.setString(10, ticket.getStatus() != null ? ticket.getStatus().name() : TicketStatus.NEW.name());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        ticket.setMessageId(rs.getInt(1));
                    }
                }
                return true;
            }
            return false;
        }
    }

    /**
     * Inserts a ticket with an independent connection.
     */
    public boolean insert(ContactMessage ticket) {
        Connection conn = null;
        try {
            conn = getConnection();
            return insert(ticket, conn);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting contact message ticket", e);
            throw new DataAccessException("Failed to insert contact message ticket", e);
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
     * Finds a ticket by primary key (message_id).
     */
    public Optional<ContactMessage> findById(int messageId) {
        String sql = BASE_SELECT + "WHERE c.message_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, messageId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToMessage(rs));
            }
            return Optional.empty();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding ticket by id: " + messageId, e);
            throw new DataAccessException("Failed to find ticket with id: " + messageId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Finds a ticket by unique ticket_code.
     */
    public Optional<ContactMessage> findByTicketCode(String ticketCode) {
        if (ticketCode == null || ticketCode.isBlank()) {
            return Optional.empty();
        }

        String sql = BASE_SELECT + "WHERE c.ticket_code = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, ticketCode.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToMessage(rs));
            }
            return Optional.empty();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding ticket by code: " + ticketCode, e);
            throw new DataAccessException("Failed to find ticket with code: " + ticketCode, e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Finds a ticket ensuring it belongs to the given user (strict authorization boundary).
     */
    public Optional<ContactMessage> findByIdAndUserId(int messageId, int userId) {
        String sql = BASE_SELECT + "WHERE c.message_id = ? AND c.user_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, messageId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToMessage(rs));
            }
            return Optional.empty();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding ticket by id " + messageId + " and userId " + userId, e);
            throw new DataAccessException("Failed to find ticket for user", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Retrieves tickets sent by a specific user with pagination and optional status filter.
     */
    public List<ContactMessage> findByUserId(int userId, String statusFilter, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(BASE_SELECT).append("WHERE c.user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        TicketStatus status = TicketStatus.fromCode(statusFilter);
        if (status != null) {
            sql.append("AND c.status = ? ");
            params.add(status.name());
        }

        sql.append("ORDER BY c.updated_at DESC, c.created_at DESC LIMIT ? OFFSET ?");
        int safePage = Math.max(page, 1);
        int safeSize = pageSize > 0 ? pageSize : 10;
        int offset = (safePage - 1) * safeSize;
        params.add(safeSize);
        params.add(offset);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<ContactMessage> list = new ArrayList<>();

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToMessage(rs));
            }
            return list;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error querying tickets for user: " + userId, e);
            throw new DataAccessException("Failed to query user tickets", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Counts tickets sent by a specific user for pagination.
     */
    public int countByUserId(int userId, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM contactmessages WHERE user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        TicketStatus status = TicketStatus.fromCode(statusFilter);
        if (status != null) {
            sql.append("AND status = ? ");
            params.add(status.name());
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting tickets for user: " + userId, e);
            throw new DataAccessException("Failed to count user tickets", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Admin query: finds all tickets with multiple filters, keyword search, allowlist sorting, and pagination.
     */
    public List<ContactMessage> findAllForAdmin(String statusFilter, String categoryFilter, String keyword,
                                                String sortBy, String sortOrder, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(BASE_SELECT).append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        TicketStatus status = TicketStatus.fromCode(statusFilter);
        if (status != null) {
            sql.append("AND c.status = ? ");
            params.add(status.name());
        }

        TicketCategory category = TicketCategory.fromCode(categoryFilter);
        if (category != null) {
            sql.append("AND c.category = ? ");
            params.add(category.name());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (c.ticket_code LIKE ? OR c.full_name LIKE ? OR c.email LIKE ? OR c.subject LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Enforce sort column allowlist
        String validSortBy = "updated_at";
        if (sortBy != null && ALLOWED_SORT_COLUMNS.contains(sortBy.trim().toLowerCase())) {
            validSortBy = sortBy.trim().toLowerCase();
        }

        // Enforce sort order allowlist
        String validOrder = "DESC";
        if (sortOrder != null && ALLOWED_SORT_ORDERS.contains(sortOrder.trim().toUpperCase())) {
            validOrder = sortOrder.trim().toUpperCase();
        }

        sql.append("ORDER BY c.").append(validSortBy).append(" ").append(validOrder).append(", c.message_id DESC ");
        sql.append("LIMIT ? OFFSET ?");

        int safePage = Math.max(page, 1);
        int safeSize = pageSize > 0 ? pageSize : 10;
        int offset = (safePage - 1) * safeSize;
        params.add(safeSize);
        params.add(offset);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<ContactMessage> list = new ArrayList<>();

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToMessage(rs));
            }
            return list;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error querying tickets for admin", e);
            throw new DataAccessException("Failed to query admin tickets", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Admin query: counts tickets matching admin filter criteria.
     */
    public int countAllForAdmin(String statusFilter, String categoryFilter, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM contactmessages c WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        TicketStatus status = TicketStatus.fromCode(statusFilter);
        if (status != null) {
            sql.append("AND c.status = ? ");
            params.add(status.name());
        }

        TicketCategory category = TicketCategory.fromCode(categoryFilter);
        if (category != null) {
            sql.append("AND c.category = ? ");
            params.add(category.name());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (c.ticket_code LIKE ? OR c.full_name LIKE ? OR c.email LIKE ? OR c.subject LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting tickets for admin", e);
            throw new DataAccessException("Failed to count admin tickets", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Optimistically updates ticket status if and only if the current status matches expectedCurrentStatus.
     */
    public boolean updateStatus(int messageId, TicketStatus newStatus, TicketStatus expectedCurrentStatus, Connection conn) throws SQLException {
        if (newStatus == null || conn == null) {
            return false;
        }

        String sql;
        if (expectedCurrentStatus != null) {
            sql = "UPDATE contactmessages SET status = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE message_id = ? AND status = ?";
        } else {
            sql = "UPDATE contactmessages SET status = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE message_id = ?";
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus.name());
            ps.setInt(2, messageId);
            if (expectedCurrentStatus != null) {
                ps.setString(3, expectedCurrentStatus.name());
            }
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Standalone status update.
     */
    public boolean updateStatus(int messageId, TicketStatus newStatus, TicketStatus expectedCurrentStatus) {
        Connection conn = null;
        try {
            conn = getConnection();
            return updateStatus(messageId, newStatus, expectedCurrentStatus, conn);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating status for ticket: " + messageId, e);
            throw new DataAccessException("Failed to update ticket status", e);
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
     * Updates the updated_at timestamp when a reply is added without changing status.
     */
    public boolean touchUpdatedAt(int messageId, Connection conn) throws SQLException {
        if (conn == null) {
            return false;
        }
        String sql = "UPDATE contactmessages SET updated_at = CURRENT_TIMESTAMP WHERE message_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Retrieves KPI ticket counts grouped by status in a single aggregation query.
     */
    public Map<String, Integer> getTicketKpiStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("NEW", 0);
        stats.put("PROCESSING", 0);
        stats.put("RESOLVED", 0);
        stats.put("TOTAL", 0);

        String sql = "SELECT status, COUNT(*) as cnt FROM contactmessages GROUP BY status";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            int total = 0;
            while (rs.next()) {
                String st = rs.getString("status");
                int count = rs.getInt("cnt");
                if (st != null) {
                    stats.put(st.toUpperCase(), count);
                }
                total += count;
            }
            stats.put("TOTAL", total);
            return stats;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error querying ticket KPI stats", e);
            throw new DataAccessException("Failed to query ticket KPI stats", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    private ContactMessage mapResultSetToMessage(ResultSet rs) throws SQLException {
        ContactMessage m = new ContactMessage();
        m.setMessageId(rs.getInt("message_id"));

        int userId = rs.getInt("user_id");
        if (!rs.wasNull()) {
            m.setUserId(userId);
        }

        m.setTicketCode(rs.getString("ticket_code"));
        m.setCategoryCode(rs.getString("category"));

        int bookingId = rs.getInt("booking_id");
        if (!rs.wasNull()) {
            m.setBookingId(bookingId);
        }

        m.setFullName(rs.getString("full_name"));
        m.setEmail(rs.getString("email"));
        m.setPhone(rs.getString("phone"));
        m.setSubject(rs.getString("subject"));
        m.setMessage(rs.getString("message"));
        m.setStatusCode(rs.getString("status"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setUpdatedAt(rs.getTimestamp("updated_at"));

        m.setBookingCode(rs.getString("booking_code"));
        m.setSenderRole(rs.getString("sender_role"));
        m.setReplyCount(rs.getInt("reply_count"));

        return m;
    }
}
