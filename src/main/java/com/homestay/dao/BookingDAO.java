package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.Booking;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Level;

/**
 * BookingDAO - Data Access Object for Booking entity.
 * Supports public reservations, admin overview, and host revenue reporting.
 */
public class BookingDAO extends BaseDAO implements GenericDAO<Booking, Integer> {

    @Override
    public Optional<Booking> findById(Integer id) {
        if (id == null) return Optional.empty();
        String sql = "SELECT * FROM bookings WHERE id = ? LIMIT 1";
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
        String sql = "INSERT INTO bookings (booking_code, user_id, customer_name, customer_email, customer_phone, " +
                     "room_id, check_in_date, check_out_date, adults, children, guest_count, total_price, notes, special_requests, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, booking.getBookingCode());
            if (booking.getUserId() != null) {
                ps.setInt(2, booking.getUserId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, booking.getCustomerName());
            ps.setString(4, booking.getCustomerEmail());
            ps.setString(5, booking.getCustomerPhone());
            ps.setInt(6, booking.getRoomId());
            ps.setDate(7, booking.getCheckInDate());
            ps.setDate(8, booking.getCheckOutDate());
            ps.setInt(9, booking.getAdults());
            ps.setInt(10, booking.getChildren());
            ps.setInt(11, booking.getGuestCount());
            ps.setBigDecimal(12, booking.getTotalPrice());
            ps.setString(13, booking.getNotes());
            ps.setString(14, booking.getSpecialRequests());
            ps.setString(15, booking.getStatus() != null ? booking.getStatus() : "CONFIRMED");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        booking.setId(keys.getInt(1));
                    }
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting booking for: " + booking.getCustomerName(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean update(Booking booking) {
        String sql = "UPDATE bookings SET status = ?, notes = ?, special_requests = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, booking.getStatus());
            ps.setString(2, booking.getNotes());
            ps.setString(3, booking.getSpecialRequests());
            ps.setInt(4, booking.getId());

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
        if (id == null) return false;
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

    /**
     * Calculates the all-time total revenue for an approved Host.
     */
    public BigDecimal getTotalRevenueByHost(int hostId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(b.total_price), 0) " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "WHERE (p.host_id = ? OR p.owner_id = ?) AND b.status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, hostId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculates monthly revenue for a Host in a given year.
     */
    public Map<Integer, BigDecimal> getMonthlyRevenueByHost(int hostId, int year) throws SQLException {
        Map<Integer, BigDecimal> monthlyData = new HashMap<>();
        for (int m = 1; m <= 12; m++) {
            monthlyData.put(m, BigDecimal.ZERO);
        }

        String sql = "SELECT MONTH(b.check_in_date) AS booking_month, COALESCE(SUM(b.total_price), 0) AS month_total " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "WHERE (p.host_id = ? OR p.owner_id = ?) AND YEAR(b.check_in_date) = ? AND b.status IN ('CONFIRMED', 'COMPLETED') " +
                     "GROUP BY MONTH(b.check_in_date)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, hostId);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    monthlyData.put(rs.getInt("booking_month"), rs.getBigDecimal("month_total"));
                }
            }
        }
        return monthlyData;
    }

    public List<Booking> findBookingsByHost(int hostId, int limit, int offset) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, r.room_name, p.property_name " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "WHERE (p.host_id = ? OR p.owner_id = ?) " +
                     "ORDER BY b.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, hostId);
            ps.setInt(3, limit);
            ps.setInt(4, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = mapResultSetToBooking(rs);
                    b.setRoomName(rs.getString("room_name"));
                    b.setPropertyName(rs.getString("property_name"));
                    bookings.add(b);
                }
            }
        }
        return bookings;
    }

    public int countBookingsByHost(int hostId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "WHERE (p.host_id = ? OR p.owner_id = ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, hostId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<Booking> findRecentBookingsByHost(int hostId, int limit) throws SQLException {
        return findBookingsByHost(hostId, limit, 0);
    }

    public int createBooking(Booking booking) throws SQLException {
        if (insert(booking)) {
            return booking.getId();
        }
        return 0;
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
        booking.setGuestCount(rs.getInt("guest_count"));
        booking.setTotalPrice(rs.getBigDecimal("total_price"));
        booking.setNotes(rs.getString("notes"));
        booking.setSpecialRequests(rs.getString("special_requests"));
        booking.setStatus(rs.getString("status"));
        booking.setCreatedAt(rs.getTimestamp("created_at"));
        return booking;
    }
}
