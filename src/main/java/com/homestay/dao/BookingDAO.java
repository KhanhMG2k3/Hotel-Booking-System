package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.Booking;
import com.homestay.model.BookingRoomItem;
import com.homestay.model.Room;

import java.math.BigDecimal;
import java.time.LocalDate;
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
                     "WHERE p.host_id = ? AND b.status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = getConnection();
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
                     "WHERE p.host_id = ? AND YEAR(b.check_in_date) = ? AND b.status IN ('CONFIRMED', 'COMPLETED') " +
                     "GROUP BY MONTH(b.check_in_date)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, year);
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
        String sql = "SELECT b.*, r.room_name, r.room_number, p.property_name, " +
                     "       COALESCE(p.address, '') as property_address, " +
                     "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as room_image_url " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                     "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id " +
                     "WHERE p.host_id = ? " +
                     "ORDER BY b.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, limit);
            ps.setInt(3, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = mapResultSetToBooking(rs);
                    b.setRoomName(rs.getString("room_name"));
                    b.setRoomNumber(rs.getString("room_number"));
                    b.setPropertyName(rs.getString("property_name"));
                    b.setPropertyAddress(rs.getString("property_address"));
                    try {
                        b.setRoomImageUrl(rs.getString("room_image_url"));
                    } catch (SQLException ignored) {}
                    bookings.add(b);
                }
            }
        }

        // Attach multi-room items if any
        for (Booking b : bookings) {
            try {
                List<BookingRoomItem> rooms = getBookingRooms(b.getId());
                if (rooms != null && !rooms.isEmpty()) {
                    b.setBookingRooms(rooms);
                }
            } catch (Exception ignored) {}
        }

        return bookings;
    }

    public int countBookingsByHost(int hostId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "WHERE p.host_id = ?";
        try (Connection conn = getConnection();
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

    public int countTotalBookingsByHost(int hostId) throws SQLException {
        return countBookingsByHost(hostId);
    }

    public int countCompletedStaysByHost(int hostId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "WHERE p.host_id = ? AND b.status = 'COMPLETED'";
        try (Connection conn = getConnection();
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

    public List<Booking> findRecentBookingsByHost(int hostId, int limit) throws SQLException {
        return findBookingsByHost(hostId, limit, 0);
    }

    /**
     * Retrieves active bookings overlapping with a date range for a given host and optional property/room.
     */
    public List<Booking> findBookingsForCalendar(int hostId, int propertyId, int roomId, LocalDate startDate, LocalDate endDate) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT DISTINCT b.*, r.room_name, r.room_number, p.property_name, " +
                     "       COALESCE(p.address, '') as property_address, " +
                     "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as room_image_url, " +
                     "       COALESCE(br.room_id, b.room_id) as calendar_room_id " +
                     "FROM bookings b " +
                     "LEFT JOIN bookingrooms br ON b.id = br.booking_id " +
                     "JOIN rooms r ON r.room_id = COALESCE(br.room_id, b.room_id) " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                     "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id " +
                     "WHERE p.host_id = ? " +
                     "  AND (? = 0 OR p.property_id = ?) " +
                     "  AND (? = 0 OR r.room_id = ?) " +
                     "  AND b.status IN ('PENDING', 'CONFIRMED', 'COMPLETED') " +
                     "  AND (b.check_in_date < ? AND b.check_out_date > ?) " +
                     "ORDER BY b.check_in_date ASC, b.id ASC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hostId);
            ps.setInt(2, propertyId);
            ps.setInt(3, propertyId);
            ps.setInt(4, roomId);
            ps.setInt(5, roomId);
            ps.setDate(6, java.sql.Date.valueOf(endDate));
            ps.setDate(7, java.sql.Date.valueOf(startDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Booking b = mapResultSetToBooking(rs);
                    b.setRoomName(rs.getString("room_name"));
                    b.setRoomNumber(rs.getString("room_number"));
                    b.setPropertyName(rs.getString("property_name"));
                    b.setPropertyAddress(rs.getString("property_address"));
                    try {
                        b.setRoomImageUrl(rs.getString("room_image_url"));
                    } catch (SQLException ignored) {}
                    b.setRoomId(rs.getInt("calendar_room_id"));
                    bookings.add(b);
                }
            }
        }
        return bookings;
    }


    public int createBooking(Booking booking) throws SQLException {
        if (insert(booking)) {
            return booking.getId();
        }
        return 0;
    }

    /**
     * Checks if a room is available during the requested dates (no overlapping PENDING or CONFIRMED bookings).
     */
    public boolean isRoomAvailable(int roomId, Date checkIn, Date checkOut, Integer excludeBookingId) {
        String sql = "SELECT COUNT(*) FROM bookings b " +
                     "WHERE b.status IN ('PENDING', 'CONFIRMED') " +
                     "  AND (b.check_in_date < ? AND b.check_out_date > ?) " +
                     "  AND (b.room_id = ? OR EXISTS (SELECT 1 FROM bookingrooms br WHERE br.booking_id = b.id AND br.room_id = ?)) " +
                     (excludeBookingId != null ? " AND b.id <> ? " : "");
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, checkOut);
            ps.setDate(2, checkIn);
            ps.setInt(3, roomId);
            ps.setInt(4, roomId);
            if (excludeBookingId != null) {
                ps.setInt(5, excludeBookingId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking room availability for roomId=" + roomId, e);
            return false;
        } finally {
            closeResources(conn, ps, rs);
        }
        return true;
    }

    /**
     * Finds all available rooms for a given date range.
     */
    public List<Room> findAvailableRooms(Date checkIn, Date checkOut, Integer excludeRoomId) {
        List<Room> availableRooms = new ArrayList<>();
        String sql = "SELECT r.room_id as id, r.room_number, r.status, " +
                     "       COALESCE(r.room_name, rt.room_name) as room_name, " +
                     "       COALESCE(r.price_per_night, rt.base_price, 1000000) as price_per_night, " +
                     "       COALESCE(r.capacity, rt.max_guests, 2) as capacity, " +
                     "       COALESCE(ri.image_url, r.image_url, 'images/img_1.jpg') as image_url, " +
                     "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                     "       COALESCE(rt.room_name, 'Phòng Homestay') as room_type_name " +
                     "FROM rooms r " +
                     "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                     "LEFT JOIN properties prop ON r.property_id = prop.property_id " +
                     "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id " +
                     "WHERE r.status = 'AVAILABLE' " +
                     (excludeRoomId != null ? " AND r.room_id <> ? " : "") +
                     "  AND NOT EXISTS ( " +
                     "      SELECT 1 FROM bookings b " +
                     "      WHERE b.status IN ('PENDING', 'CONFIRMED') " +
                     "        AND (b.check_in_date < ? AND b.check_out_date > ?) " +
                     "        AND (b.room_id = r.room_id OR EXISTS (SELECT 1 FROM bookingrooms br WHERE br.booking_id = b.id AND br.room_id = r.room_id)) " +
                     "  ) " +
                     "ORDER BY r.sort_order ASC, r.room_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            int idx = 1;
            if (excludeRoomId != null) {
                ps.setInt(idx++, excludeRoomId);
            }
            ps.setDate(idx++, checkOut);
            ps.setDate(idx++, checkIn);
            rs = ps.executeQuery();
            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomName(rs.getString("room_name"));
                room.setPricePerNight(rs.getBigDecimal("price_per_night"));
                room.setCapacity(rs.getInt("capacity"));
                room.setImageUrl(rs.getString("image_url"));
                room.setPropertyName(rs.getString("property_name"));
                room.setRoomType(rs.getString("room_type_name"));
                availableRooms.add(room);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding available rooms", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return availableRooms;
    }

    /**
     * Inserts a multi-room booking transactionally into bookings and bookingrooms tables.
     */
    public boolean insertMultiRoomBooking(Booking booking, List<BookingRoomItem> rooms) {
        if (booking == null || rooms == null || rooms.isEmpty()) return false;

        String insertBookingSql = "INSERT INTO bookings (booking_code, user_id, customer_name, customer_email, customer_phone, " +
                                  "room_id, check_in_date, check_out_date, adults, children, guest_count, total_price, notes, special_requests, status) " +
                                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertRoomSql = "INSERT INTO bookingrooms (booking_id, room_id, price_per_night, number_of_nights, subtotal) " +
                               "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psBooking = null;
        PreparedStatement psRoom = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            if (booking.getBookingCode() == null || booking.getBookingCode().trim().isEmpty()) {
                booking.setBookingCode(generateBookingCode());
            }

            BookingRoomItem primaryRoom = rooms.get(0);
            booking.setRoomId(primaryRoom.getRoomId());
            booking.setCheckInDate(primaryRoom.getCheckInDate());
            booking.setCheckOutDate(primaryRoom.getCheckOutDate());

            psBooking = conn.prepareStatement(insertBookingSql, Statement.RETURN_GENERATED_KEYS);
            psBooking.setString(1, booking.getBookingCode());
            if (booking.getUserId() != null) {
                psBooking.setInt(2, booking.getUserId());
            } else {
                psBooking.setNull(2, Types.INTEGER);
            }
            psBooking.setString(3, booking.getCustomerName());
            psBooking.setString(4, booking.getCustomerEmail());
            psBooking.setString(5, booking.getCustomerPhone());
            psBooking.setInt(6, booking.getRoomId());
            psBooking.setDate(7, booking.getCheckInDate());
            psBooking.setDate(8, booking.getCheckOutDate());
            psBooking.setInt(9, booking.getAdults());
            psBooking.setInt(10, booking.getChildren());
            psBooking.setInt(11, booking.getGuestCount());
            psBooking.setBigDecimal(12, booking.getTotalPrice());
            psBooking.setString(13, booking.getNotes());
            psBooking.setString(14, booking.getSpecialRequests());
            psBooking.setString(15, booking.getStatus() != null ? booking.getStatus() : "CONFIRMED");

            int affected = psBooking.executeUpdate();
            if (affected == 0) {
                conn.rollback();
                return false;
            }

            int bookingId = 0;
            try (ResultSet keys = psBooking.getGeneratedKeys()) {
                if (keys.next()) {
                    bookingId = keys.getInt(1);
                    booking.setId(bookingId);
                }
            }
            if (bookingId == 0) {
                conn.rollback();
                return false;
            }

            psRoom = conn.prepareStatement(insertRoomSql);
            for (BookingRoomItem room : rooms) {
                psRoom.setInt(1, bookingId);
                psRoom.setInt(2, room.getRoomId());
                psRoom.setBigDecimal(3, room.getPricePerNight());
                psRoom.setInt(4, room.getNumberOfNights());
                psRoom.setBigDecimal(5, room.getSubtotal());
                psRoom.addBatch();
            }
            psRoom.executeBatch();

            conn.commit();
            return true;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting multi-room booking", e);
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Rollback failed", ex);
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignore) {}
            }
            closeResources(conn, psBooking, null);
            if (psRoom != null) {
                try { psRoom.close(); } catch (SQLException ignore) {}
            }
        }
    }

    /**
     * Finds a booking by unique booking code.
     */
    public Optional<Booking> findByBookingCode(String bookingCode) {
        if (bookingCode == null || bookingCode.trim().isEmpty()) return Optional.empty();
        String sql = "SELECT b.*, r.room_name, r.room_number, p.property_name, " +
                     "       COALESCE(p.address, '') as property_address, " +
                     "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as room_image_url " +
                     "FROM bookings b " +
                     "JOIN rooms r ON b.room_id = r.room_id " +
                     "JOIN properties p ON r.property_id = p.property_id " +
                     "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                     "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id " +
                     "WHERE b.booking_code = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, bookingCode.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                Booking booking = mapResultSetToBooking(rs);
                booking.setRoomName(rs.getString("room_name"));
                booking.setPropertyName(rs.getString("property_name"));
                booking.setBookingRooms(getBookingRooms(booking.getId()));
                return Optional.of(booking);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding booking by code: " + bookingCode, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return Optional.empty();
    }

    /**
     * Gets all rooms in a booking.
     */
    public List<BookingRoomItem> getBookingRooms(int bookingId) {
        List<BookingRoomItem> list = new ArrayList<>();
        String sql = "SELECT br.*, r.room_name, COALESCE(rt.room_name, 'Phòng Homestay') as type_name, " +
                     "       COALESCE(r.capacity, rt.max_guests, 2) as capacity, " +
                     "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as image_url, " +
                     "       COALESCE(p.property_name, 'Sogo Homestay') as property_name, " +
                     "       b.check_in_date, b.check_out_date, b.adults, b.children " +
                     "FROM bookingrooms br " +
                     "JOIN bookings b ON br.booking_id = b.id " +
                     "JOIN rooms r ON br.room_id = r.room_id " +
                     "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                     "LEFT JOIN properties p ON r.property_id = p.property_id " +
                     "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id " +
                     "WHERE br.booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            rs = ps.executeQuery();
            while (rs.next()) {
                BookingRoomItem item = new BookingRoomItem();
                item.setBookingRoomId(rs.getInt("booking_room_id"));
                item.setBookingId(rs.getInt("booking_id"));
                item.setRoomId(rs.getInt("room_id"));
                item.setPricePerNight(rs.getBigDecimal("price_per_night"));
                item.setNumberOfNights(rs.getInt("number_of_nights"));
                item.setSubtotal(rs.getBigDecimal("subtotal"));
                item.setRoomName(rs.getString("room_name"));
                item.setRoomTypeName(rs.getString("type_name"));
                item.setCapacity(rs.getInt("capacity"));
                item.setImageUrl(rs.getString("image_url"));
                item.setPropertyName(rs.getString("property_name"));
                item.setCheckInDate(rs.getDate("check_in_date"));
                item.setCheckOutDate(rs.getDate("check_out_date"));
                item.setAdults(rs.getInt("adults"));
                item.setChildren(rs.getInt("children"));
                list.add(item);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting booking rooms for bookingId=" + bookingId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    public static String generateBookingCode() {
        String datePart = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyMMdd"));
        int rand = 1000 + new java.util.Random().nextInt(9000);
        return "BK-" + datePart + "-" + rand;
    }

    private Booking mapResultSetToBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setId(rs.getInt("id"));
        try {
            booking.setBookingCode(rs.getString("booking_code"));
        } catch (SQLException ignored) {}
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

    /**
     * Finds all bookings for a user by user_id or customer_email, ordered newest first.
     */
    public List<Booking> findBookingsByUser(int userId, String email) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.*, " +
                     "       COALESCE(r.room_name, 'Phòng Homestay') as room_name, " +
                     "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                     "       COALESCE(ri.image_url, r.image_url, 'images/img_1.jpg') as room_image_url " +
                     "FROM bookings b " +
                     "LEFT JOIN rooms r ON b.room_id = r.room_id " +
                     "LEFT JOIN properties prop ON r.property_id = prop.property_id " +
                     "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                     "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id " +
                     "WHERE (b.user_id = ? OR (? IS NOT NULL AND ? <> '' AND b.customer_email = ?)) " +
                     "ORDER BY b.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, email);
            ps.setString(3, email);
            ps.setString(4, email);
            rs = ps.executeQuery();
            while (rs.next()) {
                Booking b = mapResultSetToBooking(rs);
                b.setRoomName(rs.getString("room_name"));
                b.setPropertyName(rs.getString("property_name"));
                try {
                    b.setRoomImageUrl(rs.getString("room_image_url"));
                } catch (SQLException ignored) {}
                bookings.add(b);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding bookings for user " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        // Attach multi-room items if any
        for (Booking b : bookings) {
            try {
                List<BookingRoomItem> rooms = getBookingRooms(b.getId());
                if (rooms != null && !rooms.isEmpty()) {
                    b.setBookingRooms(rooms);
                }
            } catch (Exception ignored) {}
        }
        return bookings;
    }

    /**
     * Cancels a booking if it belongs to the user and is in PENDING or CONFIRMED status.
     */
    public boolean cancelBooking(int bookingId, int userId, String email) {
        String sql = "UPDATE bookings SET status = 'CANCELLED' " +
                     "WHERE id = ? AND (user_id = ? OR (? IS NOT NULL AND ? <> '' AND customer_email = ?)) " +
                     "  AND status IN ('PENDING', 'CONFIRMED')";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, bookingId);
            ps.setInt(2, userId);
            ps.setString(3, email);
            ps.setString(4, email);
            ps.setString(5, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error cancelling booking " + bookingId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }
}
