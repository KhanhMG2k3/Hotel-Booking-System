package com.homestay.dao;

import com.homestay.model.Review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

/**
 * ReviewDAO - Data Access Object for customer reviews and ratings.
 */
public class ReviewDAO extends BaseDAO implements GenericDAO<Review, Integer> {

    @Override
    public Optional<Review> findById(Integer id) {
        if (id == null) {
            return Optional.empty();
        }
        String sql = "SELECT * FROM reviews WHERE id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return Optional.of(mapResultSetToReview(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding review by id: " + id, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    @Override
    public List<Review> findAll() {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT * FROM reviews ORDER BY created_at DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToReview(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding all reviews", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    @Override
    public boolean insert(Review review) {
        String sql = "INSERT INTO reviews (booking_id, user_id, room_id, property_id, rating, title, comment, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, review.getBookingId());
            ps.setInt(2, review.getUserId());
            ps.setInt(3, review.getRoomId());
            ps.setInt(4, review.getPropertyId());
            ps.setInt(5, review.getRating());
            ps.setString(6, review.getTitle());
            ps.setString(7, review.getComment());
            ps.setString(8, review.getStatus() != null ? review.getStatus() : "APPROVED");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting review", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean update(Review review) {
        String sql = "UPDATE reviews SET rating = ?, title = ?, comment = ?, status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, review.getRating());
            ps.setString(2, review.getTitle());
            ps.setString(3, review.getComment());
            ps.setString(4, review.getStatus());
            ps.setInt(5, review.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating review", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM reviews WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting review", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Checks if a booking has already been reviewed.
     */
    public boolean hasReviewed(int bookingId) {
        String sql = "SELECT COUNT(*) FROM reviews WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking if booking was reviewed: " + bookingId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Validates if a booking is eligible for writing a review: 1. Booking
     * belongs to this user. 2. Status is COMPLETED (or CONFIRMED with
     * check_out_date <= TODAY). 3. No review exists yet.
     */
    public boolean isBookingEligibleForReview(int bookingId, int userId) {
        if (hasReviewed(bookingId)) {
            return false;
        }
        String sql = "SELECT id FROM bookings "
                + "WHERE id = ? AND user_id = ? "
                + "  AND (status = 'COMPLETED' OR (status = 'CONFIRMED' AND check_out_date <= CURRENT_DATE())) "
                + "LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking review eligibility for booking " + bookingId, e);
            return false;
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Retrieves all approved reviews for a specific room with reviewer info.
     */
    public List<Review> findApprovedReviewsByRoomId(int roomId, int offset, int limit) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.*, u.full_name, u.display_name, u.avatar_url "
                + "FROM reviews r "
                + "JOIN users u ON r.user_id = u.user_id "
                + "WHERE r.room_id = ? AND r.status = 'APPROVED' "
                + "ORDER BY r.created_at DESC LIMIT ? OFFSET ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roomId);
            ps.setInt(2, limit);
            ps.setInt(3, offset);
            rs = ps.executeQuery();
            while (rs.next()) {
                Review rev = mapResultSetToReview(rs);
                rev.setUserDisplayName(rs.getString("display_name") != null ? rs.getString("display_name") : rs.getString("full_name"));
                rev.setUserAvatar(rs.getString("avatar_url"));
                list.add(rev);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding reviews by room id: " + roomId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Counts approved reviews for a room.
     */
    public int countApprovedReviewsByRoomId(int roomId) {
        String sql = "SELECT COUNT(*) FROM reviews WHERE room_id = ? AND status = 'APPROVED'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roomId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting reviews for room: " + roomId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Calculates the average rating of a room.
     */
    public double calculateAverageRating(int roomId) {
        String sql = "SELECT ROUND(AVG(rating), 1) FROM reviews WHERE room_id = ? AND status = 'APPROVED'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roomId);
            rs = ps.executeQuery();
            if (rs.next() && rs.getObject(1) != null) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating average rating", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return 5.0; // Default fallback rating
    }

    /**
     * Synchronizes room average rating and count in roomtypes table.
     */
    public void syncRoomRatingAndCount(int roomId) {
        double avg = calculateAverageRating(roomId);
        int count = countApprovedReviewsByRoomId(roomId);
        String sql = "UPDATE roomtypes rt "
                + "JOIN rooms r ON rt.room_type_id = r.room_type_id "
                + "SET rt.rating = ?, rt.review_count = ? WHERE r.room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDouble(1, avg);
            ps.setInt(2, count);
            ps.setInt(3, roomId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error syncing room rating for room: " + roomId, e);
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private Review mapResultSetToReview(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setId(rs.getInt("id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRoomId(rs.getInt("room_id"));
        r.setPropertyId(rs.getInt("property_id"));
        r.setRating(rs.getInt("rating"));
        r.setTitle(rs.getString("title"));
        r.setComment(rs.getString("comment"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        return r;
    }

    /**
     * Finds the most recent completed booking of a user that hasn't been
     * reviewed yet.
     */
    public Optional<Integer> findLatestPendingReviewBookingId(int userId) {
        String sql = "SELECT b.id FROM bookings b "
                + "WHERE b.user_id = ? "
                + "  AND (b.status = 'COMPLETED' OR (b.status = 'CONFIRMED' AND b.check_out_date <= CURRENT_DATE())) "
                + "  AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.booking_id = b.id) "
                + "ORDER BY b.check_out_date DESC LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return Optional.of(rs.getInt("id"));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding pending review booking for user: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }
}
