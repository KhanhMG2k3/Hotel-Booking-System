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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Handles database operations for bookings and Host revenue calculations.
 */
public class BookingDAO {

    /**
     * Calculates the all-time total revenue for an approved Host.
     * Only completed and confirmed bookings are counted towards revenue.
     */
    public BigDecimal getTotalRevenueByHost(int hostId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(b.total_price), 0) " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.id " +
                     "JOIN properties p ON r.property_id = p.id " +
                     "WHERE p.owner_id = ? AND b.status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculates the monthly revenue breakdown for a Host in a given year.
     * Returns a map with keys 1..12 mapping to monthly revenue totals.
     */
    public Map<Integer, BigDecimal> getMonthlyRevenueByHost(int hostId, int year) throws SQLException {
        Map<Integer, BigDecimal> monthlyData = new HashMap<>();
        // Initialize all 12 months with 0
        for (int m = 1; m <= 12; m++) {
            monthlyData.put(m, BigDecimal.ZERO);
        }

        String sql = "SELECT MONTH(b.check_in_date) AS booking_month, COALESCE(SUM(b.total_price), 0) AS month_total " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.id " +
                     "JOIN properties p ON r.property_id = p.id " +
                     "WHERE p.owner_id = ? AND YEAR(b.check_in_date) = ? AND b.status IN ('CONFIRMED', 'COMPLETED') " +
                     "GROUP BY MONTH(b.check_in_date)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int month = rs.getInt("booking_month");
                    BigDecimal total = rs.getBigDecimal("month_total");
                    monthlyData.put(month, total);
                }
            }
        }
        return monthlyData;
    }

    /**
     * Counts the total number of bookings received by the Host's properties.
     */
    public int countTotalBookingsByHost(int hostId) throws SQLException {
        String sql = "SELECT COUNT(b.id) " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.id " +
                     "JOIN properties p ON r.property_id = p.id " +
                     "WHERE p.owner_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Counts the number of successfully completed stays for the Host.
     */
    public int countCompletedStaysByHost(int hostId) throws SQLException {
        String sql = "SELECT COUNT(b.id) " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.id " +
                     "JOIN properties p ON r.property_id = p.id " +
                     "WHERE p.owner_id = ? AND b.status = 'COMPLETED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * Retrieves recent bookings for a Host with attached customer and room info.
     */
    public List<Booking> findRecentBookingsByHost(int hostId, int limit) throws SQLException {
        String sql = "SELECT b.id, b.booking_code, b.room_id, b.user_id, b.check_in_date, b.check_out_date, " +
                     "b.guest_count, b.total_price, b.status, b.special_requests, b.created_at, " +
                     "r.room_name, p.property_name, u.username, u.display_name, u.email, u.phone " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.id " +
                     "JOIN properties p ON r.property_id = p.id " +
                     "JOIN users u ON b.user_id = u.id " +
                     "WHERE p.owner_id = ? " +
                     "ORDER BY b.created_at DESC, b.id DESC LIMIT ?";

        List<Booking> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, limit > 0 ? limit : 10);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = new Booking();
                    b.setId(rs.getInt("id"));
                    b.setBookingCode(rs.getString("booking_code"));
                    b.setRoomId(rs.getInt("room_id"));
                    b.setUserId(rs.getInt("user_id"));
                    b.setCheckInDate(rs.getDate("check_in_date"));
                    b.setCheckOutDate(rs.getDate("check_out_date"));
                    b.setGuestCount(rs.getInt("guest_count"));
                    b.setTotalPrice(rs.getBigDecimal("total_price"));
                    b.setStatus(Booking.Status.valueOf(rs.getString("status")));
                    b.setSpecialRequests(rs.getString("special_requests"));
                    b.setCreatedAt(rs.getTimestamp("created_at"));

                    b.setRoomName(rs.getString("room_name"));
                    b.setPropertyName(rs.getString("property_name"));
                    String displayName = rs.getString("display_name");
                    b.setCustomerName(displayName != null && !displayName.isBlank() ? displayName : rs.getString("username"));
                    b.setCustomerEmail(rs.getString("email"));
                    b.setCustomerPhone(rs.getString("phone"));

                    list.add(b);
                }
            }
        }
        return list;
    }

    /**
     * Inserts a new customer reservation into the database.
     */
    public int create(Booking booking) throws SQLException {
        String sql = "INSERT INTO bookings (booking_code, room_id, user_id, check_in_date, check_out_date, " +
                     "guest_count, total_price, status, special_requests) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, booking.getBookingCode());
            ps.setInt(2, booking.getRoomId());
            ps.setInt(3, booking.getUserId());
            ps.setDate(4, booking.getCheckInDate());
            ps.setDate(5, booking.getCheckOutDate());
            ps.setInt(6, booking.getGuestCount());
            ps.setBigDecimal(7, booking.getTotalPrice());
            ps.setString(8, booking.getStatus() != null ? booking.getStatus().name() : "CONFIRMED");
            ps.setString(9, booking.getSpecialRequests());

            if (ps.executeUpdate() != 1) {
                return 0;
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }
}
