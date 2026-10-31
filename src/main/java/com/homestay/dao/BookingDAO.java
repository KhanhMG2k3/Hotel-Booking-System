package com.homestay.dao;

import com.homestay.model.Booking;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.logging.Level;

/**
 * BookingDAO - Data Access Object for Booking entity.
 */
public class BookingDAO extends BaseDAO implements GenericDAO<Booking, Integer> {

    @Override
    public Optional<Booking> findById(Integer id) {
        String sql = "SELECT * FROM bookings WHERE booking_id = ?";

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

    public Optional<Booking> findByBookingCode(String bookingCode) {
        if (bookingCode == null || bookingCode.isBlank()) {
            return Optional.empty();
        }
        String sql = "SELECT * FROM bookings WHERE REPLACE(booking_code, '-', '') = REPLACE(?, '-', '')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, bookingCode.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                return Optional.of(mapResultSetToBooking(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding booking by code: " + bookingCode, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    public Booking findByBookingCodeForUpdate(Connection conn, String bookingCode)
            throws SQLException {
        requireTransaction(conn, "findByBookingCodeForUpdate");
        if (bookingCode == null || bookingCode.isBlank()) {
            throw new IllegalArgumentException("Booking code must not be null or blank");
        }
        String sql = """
                SELECT *
                FROM bookings
                WHERE REPLACE(booking_code, '-', '') = REPLACE(?, '-', '')
                FOR UPDATE
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bookingCode.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapResultSetToBooking(rs) : null;
            }
        }
    }

    /**
     * Locks a booking row inside a caller-managed transaction.
     */
    public Booking findByIdForUpdate(Connection conn, long bookingId)
            throws SQLException {

        requireTransaction(conn, "findByIdForUpdate");
        validateBookingId(bookingId);

        String sql = """
                SELECT *
                FROM bookings
                WHERE booking_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapResultSetToBooking(rs) : null;
            }
        }
    }

    @Override
    public List<Booking> findAll() {
        List<Booking> bookings = new ArrayList<>();

        String sql = "SELECT * FROM bookings ORDER BY booking_id DESC";

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
        String sql =
                "INSERT INTO bookings (" +
                "booking_code, user_id, property_id, room_id, " +
                "customer_name, customer_email, customer_phone, " +
                "check_in, check_out, check_in_date, check_out_date, " +
                "adults, children, rooms_count, " +
                "subtotal, discount_amount, total_amount, total_price, " +
                "notes, booking_status, status" +
                ") VALUES (" +
                "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?" +
                ")";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet generatedKeys = null;

        try {
            if (booking == null || booking.getPropertyId() == null) {
                return false;
            }

            if (booking.getCheckInDate() == null ||
                    booking.getCheckOutDate() == null ||
                    !booking.getCheckOutDate().after(booking.getCheckInDate())) {
                return false;
            }

            if (booking.getRoomId() <= 0) {
                return false;
            }

            BigDecimal subtotal = booking.getSubtotal();

            if (subtotal == null) {
                subtotal = booking.getTotalPrice();
            }

            if (subtotal == null ||
                    subtotal.compareTo(BigDecimal.ZERO) < 0) {
                return false;
            }

            BigDecimal discount = booking.getDiscountAmount();

            if (discount == null) {
                discount = BigDecimal.ZERO;
            }

            if (discount.compareTo(BigDecimal.ZERO) < 0 ||
                    discount.compareTo(subtotal) > 0) {
                return false;
            }

            BigDecimal totalAmount = subtotal.subtract(discount);

            String bookingCode = booking.getBookingCode();

            if (bookingCode == null || bookingCode.trim().isEmpty()) {
                bookingCode = generateBookingCode();
            }

            String bookingStatus = booking.getStatus();

            if (bookingStatus == null || bookingStatus.trim().isEmpty()) {
                bookingStatus = "PENDING";
            }

            if (!"PENDING".equalsIgnoreCase(bookingStatus)) {
                logger.warning(
                        "Cannot insert booking: initial status must be PENDING."
                );
                return false;
            }

            conn = getConnection();

            ps = conn.prepareStatement(
                    sql,
                    Statement.RETURN_GENERATED_KEYS
            );

            ps.setString(1, bookingCode);

            if (booking.getUserId() != null) {
                ps.setInt(2, booking.getUserId());
            } else {
                ps.setNull(2, Types.BIGINT);
            }

            ps.setLong(3, booking.getPropertyId());
            ps.setInt(4, booking.getRoomId());
            ps.setString(5, booking.getCustomerName());
            ps.setString(6, booking.getCustomerEmail());
            ps.setString(7, booking.getCustomerPhone());
            ps.setDate(8, booking.getCheckInDate());
            ps.setDate(9, booking.getCheckOutDate());
            ps.setDate(10, booking.getCheckInDate());
            ps.setDate(11, booking.getCheckOutDate());
            ps.setInt(12, booking.getAdults());
            ps.setInt(13, booking.getChildren());
            ps.setInt(14, 1);
            ps.setBigDecimal(15, subtotal);
            ps.setBigDecimal(16, discount);
            ps.setBigDecimal(17, totalAmount);
            ps.setBigDecimal(18, totalAmount);
            ps.setString(19, booking.getNotes());
            ps.setString(20, "PENDING");
            ps.setString(21, "PENDING");

            if (ps.executeUpdate() <= 0) {
                return false;
            }

            generatedKeys = ps.getGeneratedKeys();

            if (!generatedKeys.next()) {
                return false;
            }

            long generatedId = generatedKeys.getLong(1);

            if (generatedId > Integer.MAX_VALUE) {
                logger.severe(
                        "Generated booking ID exceeds Integer range: " + generatedId
                );
                return false;
            }

            booking.setId((int) generatedId);
            booking.setBookingCode(bookingCode);
            booking.setSubtotal(subtotal);
            booking.setDiscountAmount(discount);
            booking.setTotalAmount(totalAmount);
            booking.setTotalPrice(totalAmount);
            booking.setStatus("PENDING");

            return true;

        } catch (SQLException e) {
            logger.log(
                    Level.SEVERE,
                    "Error inserting booking",
                    e
            );
            return false;
        } finally {
            if (generatedKeys != null) {
                try {
                    generatedKeys.close();
                } catch (SQLException ignored) {
                }
            }

            closeResources(conn, ps, null);
        }
    }

    /**
     * Confirms a pending booking after trusted payment verification.
     * The caller owns the transaction.
     */
    public boolean confirmPendingBooking(
            Connection conn,
            long bookingId) throws SQLException {

        requireTransaction(conn, "confirmPendingBooking");
        validateBookingId(bookingId);

        String sql = """
                UPDATE bookings
                SET booking_status = 'CONFIRMED',
                    status = 'CONFIRMED'
                WHERE booking_id = ?
                  AND booking_status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            return ps.executeUpdate() == 1;
        }
    }

    /**
     * Cancels a PENDING booking and records the reason.
     *
     * Locks the booking before updating it.
     * Does not commit, rollback, or close the supplied connection.
     *
     * The caller must verify payment and QR state before invoking this method.
     */
    public boolean cancelPendingBooking(
            Connection conn,
            long bookingId,
            String cancellationReason) throws SQLException {

        requireTransaction(conn, "cancelPendingBooking");
        validateBookingId(bookingId);

        if (cancellationReason == null ||
                cancellationReason.trim().isEmpty() ||
                cancellationReason.length() > 500) {
            throw new IllegalArgumentException(
                    "Cancellation reason must contain 1-500 characters."
            );
        }

        Booking booking = findByIdForUpdate(conn, bookingId);

        if (booking == null ||
                !"PENDING".equalsIgnoreCase(booking.getStatus())) {
            return false;
        }

        String sql = """
                UPDATE bookings
                SET booking_status = 'CANCELLED',
                    status = 'CANCELLED',
                    cancellation_reason = ?
                WHERE booking_id = ?
                  AND booking_status = 'PENDING'
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cancellationReason.trim());
            ps.setLong(2, bookingId);

            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public boolean update(Booking booking) {
        String sql =
                "UPDATE bookings " +
                "SET booking_status = ?, status = ?, notes = ? " +
                "WHERE booking_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            if (booking == null || booking.getId() <= 0) {
                return false;
            }

            String status = booking.getStatus();

            if (status == null || status.trim().isEmpty()) {
                return false;
            }

            if ("CONFIRMED".equalsIgnoreCase(status) ||
                    "PAID".equalsIgnoreCase(status)) {
                logger.warning(
                        "Use verified payment flow to confirm a booking."
                );
                return false;
            }

            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setString(3, booking.getNotes());
            ps.setInt(4, booking.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(
                    Level.SEVERE,
                    "Error updating booking id: " +
                            (booking == null ? null : booking.getId()),
                    e
            );
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM bookings WHERE booking_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(
                    Level.SEVERE,
                    "Error deleting booking id: " + id,
                    e
            );
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private Booking mapResultSetToBooking(ResultSet rs)
            throws SQLException {

        Booking booking = new Booking();

        long bookingId = rs.getLong("booking_id");

        if (bookingId > Integer.MAX_VALUE) {
            throw new SQLException(
                    "Booking ID exceeds Integer range: " + bookingId
            );
        }

        booking.setId((int) bookingId);
        booking.setBookingCode(rs.getString("booking_code"));

        long userId = rs.getLong("user_id");

        if (!rs.wasNull()) {
            if (userId > Integer.MAX_VALUE) {
                throw new SQLException(
                        "User ID exceeds Integer range: " + userId
                );
            }

            booking.setUserId((int) userId);
        }

        long propertyId = rs.getLong("property_id");

        if (!rs.wasNull()) {
            booking.setPropertyId(propertyId);
        }

        booking.setCustomerName(rs.getString("customer_name"));
        booking.setCustomerEmail(rs.getString("customer_email"));
        booking.setCustomerPhone(rs.getString("customer_phone"));

        long roomId = rs.getLong("room_id");

        if (!rs.wasNull()) {
            if (roomId > Integer.MAX_VALUE) {
                throw new SQLException(
                        "Room ID exceeds Integer range: " + roomId
                );
            }

            booking.setRoomId((int) roomId);
        }

        booking.setCheckInDate(rs.getDate("check_in"));
        booking.setCheckOutDate(rs.getDate("check_out"));
        booking.setAdults(rs.getInt("adults"));
        booking.setChildren(rs.getInt("children"));
        booking.setSubtotal(rs.getBigDecimal("subtotal"));
        booking.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        booking.setTotalAmount(rs.getBigDecimal("total_amount"));
        booking.setTotalPrice(rs.getBigDecimal("total_amount"));
        booking.setNotes(rs.getString("notes"));
        booking.setStatus(rs.getString("booking_status"));
        booking.setCancellationReason(rs.getString("cancellation_reason"));
        booking.setCreatedAt(rs.getTimestamp("created_at"));

        return booking;
    }

    private void requireTransaction(Connection conn, String method)
            throws SQLException {

        if (conn == null || conn.isClosed() || conn.getAutoCommit()) {
            throw new IllegalArgumentException(
                    method + " requires an open connection with autoCommit=false."
            );
        }
    }

    private void validateBookingId(long bookingId) {
        if (bookingId <= 0 || bookingId > Integer.MAX_VALUE) {
            throw new IllegalArgumentException(
                    "Invalid booking ID: " + bookingId
            );
        }
    }

    private String generateBookingCode() {
        return "BK-" +
                UUID.randomUUID()
                        .toString()
                        .replace("-", "")
                        .substring(0, 12)
                        .toUpperCase();
    }
}