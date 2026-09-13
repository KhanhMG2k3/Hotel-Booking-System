package com.homestay.dao;

import com.homestay.model.Booking;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

/**
 * BookingDAO - Data Access Object for Booking entity.
 */
public class BookingDAO extends BaseDAO implements GenericDAO<Booking, Integer> {

    @Override
    public Optional<Booking> findById(Integer id) {
        String sql = "SELECT * FROM bookings WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return Optional.of(mapResultSetToBooking(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding booking by id: " + id, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    @Override
    public List<Booking> findAll() {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                bookings.add(mapResultSetToBooking(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all bookings", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return bookings;
    }

    @Override
    public boolean insert(Booking booking) {
        String sql = "INSERT INTO bookings (user_id, customer_name, customer_email, customer_phone, " +
                     "room_id, check_in_date, check_out_date, adults, children, total_price, notes, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            if (booking.getUserId() != null) {
                ps.setInt(1, booking.getUserId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, booking.getCustomerName());
            ps.setString(3, booking.getCustomerEmail());
            ps.setString(4, booking.getCustomerPhone());
            ps.setInt(5, booking.getRoomId());
            ps.setDate(6, booking.getCheckInDate());
            ps.setDate(7, booking.getCheckOutDate());
            ps.setInt(8, booking.getAdults());
            ps.setInt(9, booking.getChildren());
            ps.setBigDecimal(10, booking.getTotalPrice());
            ps.setString(11, booking.getNotes());
            ps.setString(12, booking.getStatus() != null ? booking.getStatus() : "PENDING");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting booking for: " + booking.getCustomerName(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean update(Booking booking) {
        String sql = "UPDATE bookings SET status = ?, notes = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, booking.getStatus());
            ps.setString(2, booking.getNotes());
            ps.setInt(3, booking.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating booking id: " + booking.getId(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM bookings WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting booking id: " + id, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private Booking mapResultSetToBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setId(rs.getInt("id"));
        int userId = rs.getInt("user_id");
        if (!rs.wasNull()) {
            booking.setUserId(userId);
        }
        booking.setCustomerName(rs.getString("customer_name"));
        booking.setEmail(rs.getString("customer_email"));
        booking.setCustomerPhone(rs.getString("customer_phone"));
        booking.setRoomId(rs.getInt("room_id"));
        booking.setCheckInDate(rs.getDate("check_in_date"));
        booking.setCheckOutDate(rs.getDate("check_out_date"));
        booking.setAdults(rs.getInt("adults"));
        booking.setChildren(rs.getInt("children"));
        booking.setTotalPrice(rs.getBigDecimal("total_price"));
        booking.setNotes(rs.getString("notes"));
        booking.setStatus(rs.getString("status"));
        booking.setCreatedAt(rs.getTimestamp("created_at"));
        return booking;
    }
}
