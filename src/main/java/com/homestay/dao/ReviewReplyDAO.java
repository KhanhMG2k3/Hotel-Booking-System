package com.homestay.dao;

import com.homestay.model.Review;
import com.homestay.model.ReviewReply;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Level;

/**
 * ReviewReplyDAO - Data Access Object for Host replies, plus the Host-side
 * review list (reviews of the properties owned by one Host).
 */
public class ReviewReplyDAO extends BaseDAO implements GenericDAO<ReviewReply, Integer> {

    // Filter keys accepted by the Host review list
    public static final String FILTER_ALL = "all";
    public static final String FILTER_UNREPLIED = "unreplied";
    public static final String FILTER_REPLIED = "replied";
    public static final String FILTER_LOW = "low";

    // Reviews -> rooms -> roomtypes -> properties: the Host owns a review through its property.
    private static final String HOST_FROM =
            "FROM reviews rv "
            + "JOIN rooms r ON rv.room_id = r.room_id "
            + "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id "
            + "JOIN properties p ON rt.property_id = p.property_id "
            + "JOIN users u ON rv.user_id = u.user_id "
            + "LEFT JOIN bookings b ON rv.booking_id = b.id "
            + "LEFT JOIN review_replies rp ON rp.review_id = rv.id "
            + "WHERE p.host_id = ? AND rv.status = 'APPROVED' ";

    @Override
    public Optional<ReviewReply> findById(Integer id) {
        if (id == null) return Optional.empty();
        return queryOne("SELECT * FROM review_replies WHERE id = ? LIMIT 1", id);
    }

    @Override
    public List<ReviewReply> findAll() {
        List<ReviewReply> list = new ArrayList<>();
        String sql = "SELECT * FROM review_replies ORDER BY created_at DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapReply(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding all review replies", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    @Override
    public boolean insert(ReviewReply reply) {
        String sql = "INSERT INTO review_replies (review_id, host_id, reply_content) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, reply.getReviewId());
            ps.setInt(2, reply.getHostId());
            ps.setString(3, reply.getReplyContent());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // A duplicate review_id (UNIQUE) means the review was already answered.
            logger.log(Level.WARNING, "Error inserting review reply for review " + reply.getReviewId(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Updates the reply text; only the Host who wrote it can change it. */
    @Override
    public boolean update(ReviewReply reply) {
        String sql = "UPDATE review_replies SET reply_content = ? WHERE id = ? AND host_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, reply.getReplyContent());
            ps.setInt(2, reply.getId());
            ps.setInt(3, reply.getHostId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating review reply", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM review_replies WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting review reply", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /** Finds the reply of one review, if the Host already answered it. */
    public Optional<ReviewReply> findByReviewId(int reviewId) {
        return queryOne("SELECT * FROM review_replies WHERE review_id = ? LIMIT 1", reviewId);
    }

    /** Checks that the review belongs to a property owned by this Host. */
    public boolean isReviewOwnedByHost(int reviewId, int hostId) {
        String sql = "SELECT 1 FROM reviews rv "
                + "JOIN rooms r ON rv.room_id = r.room_id "
                + "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id "
                + "JOIN properties p ON rt.property_id = p.property_id "
                + "WHERE rv.id = ? AND p.host_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, reviewId);
            ps.setInt(2, hostId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking review ownership: " + reviewId, e);
            return false;
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /** Lists one page of this Host's reviews (unreplied first), with the reply attached. */
    public List<Review> findReviewsForHost(int hostId, String filter, int offset, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT rv.*, COALESCE(u.display_name, u.full_name) AS reviewer_name, "
                + "COALESCE(r.room_name, rt.room_name) AS room_name, r.room_number, p.property_name, "
                + "b.booking_code, rp.id AS reply_id, rp.host_id AS reply_host_id, rp.reply_content, "
                + "rp.created_at AS reply_created_at, rp.updated_at AS reply_updated_at "
                + HOST_FROM + filterClause(filter)
                + "ORDER BY (rp.id IS NULL) DESC, rv.created_at DESC LIMIT ? OFFSET ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, hostId);
            ps.setInt(2, limit);
            ps.setInt(3, offset);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapHostReview(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding reviews for host: " + hostId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /** Counts this Host's reviews for the given filter. */
    public int countReviewsForHost(int hostId, String filter) {
        String sql = "SELECT COUNT(*) " + HOST_FROM + filterClause(filter);
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, hostId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting reviews for host: " + hostId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /** Loads the Host reply (if any) into each review, using one query for the whole list. */
    public void attachReplies(List<Review> reviews) {
        if (reviews == null || reviews.isEmpty()) return;

        // Build "?,?,?" - only placeholders are concatenated, values are bound below.
        StringBuilder marks = new StringBuilder();
        for (int i = 0; i < reviews.size(); i++) {
            marks.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT rp.*, COALESCE(u.display_name, u.full_name) AS host_name "
                + "FROM review_replies rp JOIN users u ON rp.host_id = u.user_id "
                + "WHERE rp.review_id IN (" + marks + ")";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < reviews.size(); i++) {
                ps.setInt(i + 1, reviews.get(i).getId());
            }
            rs = ps.executeQuery();
            Map<Integer, ReviewReply> byReview = new HashMap<>();
            while (rs.next()) {
                ReviewReply reply = mapReply(rs);
                reply.setHostName(rs.getString("host_name"));
                byReview.put(reply.getReviewId(), reply);
            }
            for (Review review : reviews) {
                review.setReply(byReview.get(review.getId()));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error attaching replies to reviews", e);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /** Maps a filter key to a fixed SQL fragment (whitelist, never user text). */
    private String filterClause(String filter) {
        return switch (filter == null ? FILTER_ALL : filter) {
            case FILTER_UNREPLIED -> "AND rp.id IS NULL ";
            case FILTER_REPLIED -> "AND rp.id IS NOT NULL ";
            case FILTER_LOW -> "AND rv.rating <= 3 ";
            default -> "";
        };
    }

    private Optional<ReviewReply> queryOne(String sql, int param) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, param);
            rs = ps.executeQuery();
            if (rs.next()) {
                return Optional.of(mapReply(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error querying review reply: " + param, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    private ReviewReply mapReply(ResultSet rs) throws SQLException {
        ReviewReply reply = new ReviewReply();
        reply.setId(rs.getInt("id"));
        reply.setReviewId(rs.getInt("review_id"));
        reply.setHostId(rs.getInt("host_id"));
        reply.setReplyContent(rs.getString("reply_content"));
        reply.setCreatedAt(rs.getTimestamp("created_at"));
        reply.setUpdatedAt(rs.getTimestamp("updated_at"));
        return reply;
    }

    private Review mapHostReview(ResultSet rs) throws SQLException {
        Review review = new Review();
        review.setId(rs.getInt("id"));
        review.setBookingId(rs.getInt("booking_id"));
        review.setUserId(rs.getInt("user_id"));
        review.setRoomId(rs.getInt("room_id"));
        review.setPropertyId(rs.getInt("property_id"));
        review.setRating(rs.getInt("rating"));
        review.setTitle(rs.getString("title"));
        review.setComment(rs.getString("comment"));
        review.setStatus(rs.getString("status"));
        review.setCreatedAt(rs.getTimestamp("created_at"));
        review.setUpdatedAt(rs.getTimestamp("updated_at"));
        review.setUserDisplayName(rs.getString("reviewer_name"));
        review.setRoomName(rs.getString("room_name"));
        review.setRoomNumber(rs.getString("room_number"));
        review.setPropertyName(rs.getString("property_name"));
        review.setBookingCode(rs.getString("booking_code"));

        // The LEFT JOIN returns a reply_id only when the Host already answered.
        if (rs.getObject("reply_id") != null) {
            ReviewReply reply = new ReviewReply();
            reply.setId(rs.getInt("reply_id"));
            reply.setReviewId(review.getId());
            reply.setHostId(rs.getInt("reply_host_id"));
            reply.setReplyContent(rs.getString("reply_content"));
            reply.setCreatedAt(rs.getTimestamp("reply_created_at"));
            reply.setUpdatedAt(rs.getTimestamp("reply_updated_at"));
            review.setReply(reply);
        }
        return review;
    }
}