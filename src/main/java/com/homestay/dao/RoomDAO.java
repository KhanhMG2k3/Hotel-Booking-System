package com.homestay.dao;

import com.homestay.model.Room;
import com.homestay.model.RoomType;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

public class RoomDAO extends BaseDAO implements GenericDAO<Room, Integer> {

    /**
     * SQL dùng chung cho Listing Page và Detail Page.
     *
     * Database hiện tại:
     * rooms
     * room_types
     */
    private static final String BASE_SELECT =
            "SELECT " +
            "r.id, " +
            "r.type_id, " +
            "r.room_number, " +
            "r.room_name, " +
            "r.price_per_night, " +
            "r.capacity, " +
            "r.image_url, " +
            "r.description, " +
            "r.status, " +
            "r.is_featured, " +
            "r.created_at, " +
            "rt.type_name, " +
            "rt.description AS type_description " +
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

                // Database hiện tại chỉ có một image_url
                // nên dùng image đó làm ảnh chính.
                room.setImages(
                        new ArrayList<>(
                                List.of(room.getImageUrl())
                        )
                );

                // Tiện nghi mặc định.
                room.setAmenities(
                        getDefaultAmenities(room.getTypeId())
                );

                return Optional.of(room);
            }

        } catch (SQLException e) {

            logger.log(
                    Level.SEVERE,
                    "Error finding room by id: " + id,
                    e
            );

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

                Room room = mapResultSetToRoom(rs);

                rooms.add(room);
            }

        } catch (SQLException e) {

            logger.log(
                    Level.SEVERE,
                    "Error getting all rooms",
                    e
            );

        } finally {

            closeResources(conn, ps, rs);
        }

        return rooms;
    }

    /**
     * Thêm phòng.
     */
    @Override
    public boolean insert(Room room) {

        String sql =
                "INSERT INTO rooms " +
                "(type_id, room_number, room_name, price_per_night, " +
                "capacity, image_url, description, status, is_featured) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;

        try {

            conn = getConnection();

            ps = conn.prepareStatement(sql);

            ps.setInt(1, room.getTypeId());
            ps.setString(2, room.getRoomNumber());
            ps.setString(3, room.getRoomName());
            ps.setBigDecimal(4, room.getPricePerNight());
            ps.setInt(5, room.getCapacity());
            ps.setString(6, room.getImageUrl());
            ps.setString(7, room.getDescription());

            ps.setString(
                    8,
                    room.getStatus() != null
                            ? room.getStatus()
                            : "AVAILABLE"
            );

            ps.setBoolean(9, room.isFeatured());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            logger.log(
                    Level.SEVERE,
                    "Error inserting room: " + room.getRoomName(),
                    e
            );

            return false;

        } finally {

            closeResources(conn, ps, null);
        }
    }

    /**
     * Cập nhật phòng.
     */
    @Override
    public boolean update(Room room) {

        String sql =
                "UPDATE rooms SET " +
                "type_id = ?, " +
                "room_number = ?, " +
                "room_name = ?, " +
                "price_per_night = ?, " +
                "capacity = ?, " +
                "image_url = ?, " +
                "description = ?, " +
                "status = ?, " +
                "is_featured = ? " +
                "WHERE id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {

            conn = getConnection();

            ps = conn.prepareStatement(sql);

            ps.setInt(1, room.getTypeId());
            ps.setString(2, room.getRoomNumber());
            ps.setString(3, room.getRoomName());
            ps.setBigDecimal(4, room.getPricePerNight());
            ps.setInt(5, room.getCapacity());
            ps.setString(6, room.getImageUrl());
            ps.setString(7, room.getDescription());
            ps.setString(8, room.getStatus());
            ps.setBoolean(9, room.isFeatured());
            ps.setInt(10, room.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {

            logger.log(
                    Level.SEVERE,
                    "Error updating room id: " + room.getId(),
                    e
            );

            return false;

        } finally {

            closeResources(conn, ps, null);
        }
    }

    /**
     * Xóa phòng.
     */
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

            logger.log(
                    Level.SEVERE,
                    "Error deleting room id: " + id,
                    e
            );

            return false;

        } finally {

            closeResources(conn, ps, null);
        }
    }

    /**
     * Chuyển ResultSet thành Room object.
     */
    private Room mapResultSetToRoom(ResultSet rs)
            throws SQLException {

        Room room = new Room();

        room.setId(
                rs.getInt("id")
        );

        room.setTypeId(
                rs.getInt("type_id")
        );

        room.setRoomNumber(
                rs.getString("room_number")
        );

        room.setRoomName(
                rs.getString("room_name")
        );

        room.setPricePerNight(
                rs.getBigDecimal("price_per_night")
        );

        room.setCapacity(
                rs.getInt("capacity")
        );

        room.setImageUrl(
                rs.getString("image_url")
        );

        room.setDescription(
                rs.getString("description")
        );

        room.setStatus(
                rs.getString("status")
        );

        room.setFeatured(
                rs.getBoolean("is_featured")
        );

        room.setCreatedAt(
                rs.getTimestamp("created_at")
        );

        /*
         * Database hiện tại chưa có:
         * size_m2
         * bed_type
         *
         * nên không set hai field này.
         */

        RoomType roomType = new RoomType();

        roomType.setId(
                rs.getInt("type_id")
        );

        roomType.setTypeName(
                rs.getString("type_name")
        );

        roomType.setDescription(
                rs.getString("type_description")
        );

        room.setRoomType(roomType);

        return room;
    }

    /**
     * Tiện nghi mặc định.
     */
    private List<String> getDefaultAmenities(int typeId) {

        List<String> amenities =
                new ArrayList<>(
                        Arrays.asList(
                                "Wifi tốc độ cao miễn phí",
                                "Điều hòa không khí",
                                "Smart TV",
                                "Tủ lạnh mini",
                                "Nước suối miễn phí",
                                "Máy sấy tóc",
                                "Phòng tắm riêng",
                                "Khăn tắm & đồ vệ sinh cá nhân",
                                "Dịch vụ dọn phòng hàng ngày"
                        )
                );

        if (typeId == 2) {

            amenities.add(
                    "Không gian phù hợp cho gia đình"
            );

            amenities.add(
                    "Ban công thoáng mát"
            );

        } else if (typeId == 3 || typeId == 4) {

            amenities.add(
                    "Không gian cao cấp"
            );

            amenities.add(
                    "View đẹp"
            );
        }

        return amenities;
    }
}