package com.homestay.dao;

import com.homestay.model.Province;
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

/**
 * RoomDAO - Data Access Object for Room entity in homestaybooking database.
 */
public class RoomDAO extends BaseDAO implements GenericDAO<Room, Integer> {

    private static final String BASE_SELECT = 
            "SELECT r.room_id as id, r.room_type_id as type_id, r.room_number, r.status, " +
            "       rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
            "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.5) as rating, COALESCE(rt.review_count, 10) as review_count, " +
            "       COALESCE(ri.image_url, 'images/img_1.jpg') as image_url, " +
            "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
            "       COALESCE(prop.address, '') as address, " +
            "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
            "FROM rooms r " +
            "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
            "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
            "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
            "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
            "LEFT JOIN (SELECT room_type_id, MIN(image_url) as image_url FROM roomimages GROUP BY room_type_id) ri " +
            "ON rt.room_type_id = ri.room_type_id ";

    @Override
    public Optional<Room> findById(Integer id) {
        String sql = BASE_SELECT + "WHERE r.room_id = ?";
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
                // Load all images for this room type
                room.setImages(getRoomImages(conn, room.getTypeId()));
                // Set standard homestay amenities
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
        String sql = BASE_SELECT + "ORDER BY r.room_id ASC";
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
            logger.log(Level.SEVERE, "Error getting all rooms", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return rooms;
    }

    /**
     * Retrieves all gallery images for a room type.
     */
    public List<String> getRoomImages(Connection conn, int roomTypeId) {
        List<String> images = new ArrayList<>();
        String sql = "SELECT image_url FROM roomimages WHERE room_type_id = ? ORDER BY display_order ASC";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roomTypeId);
            rs = ps.executeQuery();

            while (rs.next()) {
                images.add(rs.getString("image_url"));
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Error loading room images for type: " + roomTypeId, e);
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        }

        if (images.isEmpty()) {
            images.add("images/img_1.jpg");
        }
        return images;
    }

    @Override
    public boolean insert(Room room) {
        String sql = "INSERT INTO rooms (room_type_id, room_number, status) VALUES (?, ?, ?)";
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
        String sql = "UPDATE rooms SET room_type_id = ?, room_number = ?, status = ? WHERE room_id = ?";
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
        String sql = "DELETE FROM rooms WHERE room_id = ?";
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
        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setCapacity(rs.getInt("capacity"));
        room.setSize(rs.getDouble("size_m2"));
        room.setBedType(rs.getString("bed_type"));
        room.setImageUrl(rs.getString("image_url"));
        room.setDescription(rs.getString("description"));
        room.setStatus(rs.getString("status"));
        room.setFeatured(true);
        room.setRating(rs.getDouble("rating"));
        room.setReviewCount(rs.getInt("review_count"));
        int provId = rs.getInt("province_id");
        room.setProvinceId(provId != 0 ? provId : null);
        room.setProvinceName(rs.getString("province_name"));
        room.setPropertyName(rs.getString("property_name"));
        room.setAddress(rs.getString("address"));

        RoomType roomType = new RoomType();
        roomType.setId(rs.getInt("type_id"));
        roomType.setTypeName(rs.getString("room_name"));
        roomType.setDescription(rs.getString("description"));
        room.setRoomType(roomType);

        return room;
    }

    /**
     * Search rooms with dynamic filters: keyword, price range, capacity, room type, province/city, star rating range (min-max), and sort.
     */
    public List<Room> searchRooms(String keyword, java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice,
                                  Integer capacity, Integer typeId, Integer provinceId, Double minRating, Double maxRating, String sortBy) {
        List<Room> rooms = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        sql.append("WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (LOWER(rt.room_name) LIKE ? OR LOWER(rt.description) LIKE ? OR LOWER(r.room_number) LIKE ? OR LOWER(prov.province_name) LIKE ? OR LOWER(prop.address) LIKE ? OR LOWER(prop.property_name) LIKE ?) ");
            String kw = "%" + keyword.trim().toLowerCase() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (typeId != null && typeId > 0) {
            sql.append("AND r.room_type_id = ? ");
            params.add(typeId);
        }

        if (provinceId != null && provinceId > 0) {
            sql.append("AND dest.province_id = ? ");
            params.add(provinceId);
        }

        if (capacity != null && capacity > 0) {
            sql.append("AND rt.max_guests >= ? ");
            params.add(capacity);
        }

        if (minPrice != null && minPrice.compareTo(java.math.BigDecimal.ZERO) > 0) {
            sql.append("AND rt.base_price >= ? ");
            params.add(minPrice);
        }

        if (maxPrice != null && maxPrice.compareTo(java.math.BigDecimal.ZERO) > 0) {
            sql.append("AND rt.base_price <= ? ");
            params.add(maxPrice);
        }

        if (minRating != null && minRating > 0) {
            sql.append("AND COALESCE(rt.rating, 4.5) >= ? ");
            params.add(minRating);
        }

        if (maxRating != null && maxRating > 0) {
            sql.append("AND COALESCE(rt.rating, 4.5) <= ? ");
            params.add(maxRating);
        }

        if ("price_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY rt.base_price ASC ");
        } else if ("price_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY rt.base_price DESC ");
        } else if ("rating_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY rt.rating DESC ");
        } else if ("capacity_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY rt.max_guests DESC ");
        } else {
            sql.append("ORDER BY r.room_id ASC ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else if (p instanceof Double) {
                    ps.setDouble(i + 1, (Double) p);
                } else if (p instanceof java.math.BigDecimal) {
                    ps.setBigDecimal(i + 1, (java.math.BigDecimal) p);
                } else {
                    ps.setString(i + 1, p.toString());
                }
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Room room = mapResultSetToRoom(rs);
                rooms.add(room);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error searching rooms", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return rooms;
    }

    public List<Room> searchRooms(String keyword, java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice,
                                  Integer capacity, Integer typeId, Double minRating, Double maxRating, String sortBy) {
        return searchRooms(keyword, minPrice, maxPrice, capacity, typeId, null, minRating, maxRating, sortBy);
    }

    public List<Room> searchRooms(String keyword, java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice,
                                  Integer capacity, Integer typeId, Double minRating, String sortBy) {
        return searchRooms(keyword, minPrice, maxPrice, capacity, typeId, null, minRating, null, sortBy);
    }

    /**
     * Retrieves all available provinces for filter dropdown.
     */
    public List<Province> getAllProvinces() {
        List<Province> provinces = new ArrayList<>();
        String sql = "SELECT province_id, country_id, province_name FROM provinces ORDER BY province_name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Province p = new Province();
                p.setId(rs.getInt("province_id"));
                p.setCountryId(rs.getInt("country_id"));
                p.setProvinceName(rs.getString("province_name"));
                provinces.add(p);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting provinces", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return provinces;
    }

    /**
     * Retrieves all available room types for filter dropdown.
     */
    public List<RoomType> getAllRoomTypes() {
        List<RoomType> types = new ArrayList<>();
        String sql = "SELECT room_type_id as id, room_name as type_name, description FROM roomtypes ORDER BY room_type_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                RoomType type = new RoomType();
                type.setId(rs.getInt("id"));
                type.setTypeName(rs.getString("type_name"));
                type.setDescription(rs.getString("description"));
                types.add(type);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting room types", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return types;
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
