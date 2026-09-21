package com.homestay.dao;

import com.homestay.model.Room;
import com.homestay.model.RoomType;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

/**
 * RoomDAO - Data Access Object for Room entity in homestaybooking database.
 */
public class RoomDAO extends BaseDAO implements GenericDAO<Room, Integer> {

    private static final String BASE_SELECT =
            "SELECT r.id, r.type_id, r.room_number, r.room_name, r.location, " +
            "       r.price_per_night, r.capacity, r.image_url, r.description, " +
            "       r.status, r.is_featured, r.created_at, " +
            "       rt.type_name, rt.description AS type_description " +
            "FROM rooms r " +
            "JOIN room_types rt ON r.type_id = rt.id ";

    @Override
    public Optional<Room> findById(Integer id) {
        String sql = BASE_SELECT + "WHERE r.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                Room room = mapResultSetToRoom(rs);

                room.setImages(new ArrayList<>());
                if (room.getImageUrl() != null && !room.getImageUrl().trim().isEmpty()) {
                    room.getImages().add(room.getImageUrl());
                } else {
                    room.getImages().add("images/img_1.jpg");
                }

                room.setAmenities(getDefaultAmenities(room.getTypeId()));

                return Optional.of(room);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding room by id: " + id, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return Optional.empty();
    }

    @Override
    public List<Room> findAll() {
        List<Room> rooms = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY r.id ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting all rooms", e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return rooms;
    }

    /**
     * Feature #4 - Basic Search.
     *
     * Search by location, dates and number of guests.
     */
    public List<Room> searchRooms(
            String location,
            Date checkInDate,
            Date checkOutDate,
            Integer guests) {

        List<Room> rooms = new ArrayList<>();

        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append("WHERE r.status = 'AVAILABLE' ");

        List<Object> params = new ArrayList<>();

        if (guests != null) {
            sql.append("AND r.capacity >= ? ");
            params.add(guests);
        }

        if (location != null && !location.trim().isEmpty()) {
            sql.append("AND LOWER(COALESCE(r.location, '')) LIKE LOWER(?) ");
            params.add("%" + location.trim() + "%");
        }

        if (checkInDate != null && checkOutDate != null) {
            sql.append(
                    "AND NOT EXISTS (" +
                    "    SELECT 1 " +
                    "    FROM bookings b " +
                    "    WHERE b.room_id = r.id " +
                    "      AND b.status IN ('PENDING', 'CONFIRMED') " +
                    "      AND b.check_in_date < ? " +
                    "      AND b.check_out_date > ? " +
                    ") "
            );

            params.add(checkOutDate);
            params.add(checkInDate);
        }

        sql.append("ORDER BY r.price_per_night ASC, r.id ASC");

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

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error searching rooms", e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return rooms;
    }

    @Override
    public boolean insert(Room room) {
        String sql = "INSERT INTO rooms (type_id, room_number, status) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, room.getTypeId());
            ps.setString(2, room.getRoomNumber());
            ps.setString(3, room.getStatus() != null ? room.getStatus() : "AVAILABLE");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error inserting room: " + room.getRoomName(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean update(Room room) {
        String sql = "UPDATE rooms SET type_id = ?, room_number = ?, status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, room.getTypeId());
            ps.setString(2, room.getRoomNumber());
            ps.setString(3, room.getStatus());
            ps.setInt(4, room.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating room id: " + room.getId(), e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM rooms WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting room id: " + id, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();

        room.setId(rs.getInt("id"));
        room.setTypeId(rs.getInt("type_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomName(rs.getString("room_name"));
        room.setLocation(rs.getString("location"));
        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setCapacity(rs.getInt("capacity"));
        room.setImageUrl(rs.getString("image_url"));
        room.setDescription(rs.getString("description"));
        room.setStatus(rs.getString("status"));
        room.setFeatured(rs.getBoolean("is_featured"));
        room.setCreatedAt(rs.getTimestamp("created_at"));

        RoomType roomType = new RoomType();
        roomType.setId(rs.getInt("type_id"));
        roomType.setTypeName(rs.getString("type_name"));
        roomType.setDescription(rs.getString("type_description"));
        room.setRoomType(roomType);

        return room;
    }

    private List<String> getDefaultAmenities(int typeId) {
        List<String> amenities = new ArrayList<>(Arrays.asList(
                "Wifi tốc độ cao miễn phí",
                "Điều hòa không khí 2 chiều",
                "Smart TV 55 inch Full HD",
                "Tủ lạnh mini & Nước suối miễn phí",
                "Máy sấy tóc & Bình đun siêu tốc",
                "Phòng tắm riêng có nóng lạnh",
                "Khăn tắm & Bộ vệ sinh cá nhân cao cấp",
                "Dịch vụ dọn phòng hàng ngày"
        ));

        if (typeId == 2 || typeId == 6) {
            amenities.add("Bếp nấu gia đình & Bàn ăn riêng");
            amenities.add("Ban công thoáng mát view đồi/vườn");
        } else if (typeId == 3 || typeId == 4) {
            amenities.add("Bồn tắm nằm thư giãn");
            amenities.add("Ban công lớn view toàn cảnh biển");
        }

        return amenities;
    }
}
