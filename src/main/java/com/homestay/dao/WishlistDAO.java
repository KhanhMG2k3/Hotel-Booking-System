package com.homestay.dao;

import com.homestay.model.Property;
import com.homestay.model.Room;
import com.homestay.model.RoomType;
import com.homestay.model.Wishlist;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;

/**
 * WishlistDAO - Data access object for managing user wishlist items.
 */
public class WishlistDAO extends BaseDAO {

    /**
     * Retrieves all wishlisted items for a given user, with full room details joined.
     */
    public List<Wishlist> findByUserId(int userId) {
        List<Wishlist> list = new ArrayList<>();
        String sql = "SELECT " +
                "w.wishlist_id, w.user_id, w.room_id, w.property_id, w.tour_id, w.notes, w.created_at, " +
                "r.room_id as r_room_id, r.room_number, r.room_name, r.price_per_night, r.capacity, " +
                "r.description as room_description, r.status as room_status, r.is_featured, " +
                "rt.room_type_id, rt.room_name as type_name, rt.size_m2, rt.bed_type, rt.rating, rt.review_count, " +
                "COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
                "prop.property_id as p_property_id, prop.property_name, prop.address, prop.city, " +
                "prov.province_id, prov.province_name " +
                "FROM wishlists w " +
                "LEFT JOIN rooms r ON w.room_id = r.room_id " +
                "LEFT JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                "LEFT JOIN (SELECT room_type_id, image_url FROM (SELECT room_type_id, image_url, ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn FROM roomimages WHERE (media_type = 'IMAGE' OR media_type IS NULL)) ranked_ri WHERE ranked_ri.rn = 1) ri " +
                "ON rt.room_type_id = ri.room_type_id " +
                "WHERE w.user_id = ? " +
                "ORDER BY w.created_at DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Wishlist item = new Wishlist();
                item.setWishlistId(rs.getLong("wishlist_id"));
                item.setUserId(rs.getInt("user_id"));
                int roomId = rs.getInt("room_id");
                item.setRoomId(rs.wasNull() ? null : roomId);
                int propId = rs.getInt("property_id");
                item.setPropertyId(rs.wasNull() ? null : propId);
                int tourId = rs.getInt("tour_id");
                item.setTourId(rs.wasNull() ? null : tourId);
                item.setNotes(rs.getString("notes"));
                item.setCreatedAt(rs.getTimestamp("created_at"));

                // Map Room if available
                if (item.getRoomId() != null && rs.getInt("r_room_id") > 0) {
                    Room room = new Room();
                    room.setId(rs.getInt("r_room_id"));
                    room.setTypeId(rs.getInt("room_type_id"));
                    room.setRoomNumber(rs.getString("room_number"));
                    room.setRoomName(rs.getString("room_name"));
                    room.setPricePerNight(rs.getBigDecimal("price_per_night"));
                    room.setCapacity(rs.getInt("capacity"));
                    room.setSize(rs.getDouble("size_m2"));
                    room.setBedType(rs.getString("bed_type"));
                    room.setImageUrl(rs.getString("display_image_url"));
                    room.setDescription(rs.getString("room_description"));
                    room.setStatus(rs.getString("room_status"));
                    room.setFeatured(rs.getBoolean("is_featured"));
                    room.setRating(rs.getDouble("rating"));
                    room.setReviewCount(rs.getInt("review_count"));
                    room.setProvinceId(rs.getInt("province_id"));
                    room.setProvinceName(rs.getString("province_name"));
                    room.setPropertyName(rs.getString("property_name"));
                    room.setAddress(rs.getString("address"));

                    RoomType rt = new RoomType();
                    rt.setId(rs.getInt("room_type_id"));
                    rt.setTypeName(rs.getString("type_name"));
                    room.setRoomType(rt);

                    item.setRoom(room);
                }

                list.add(item);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding wishlists for user: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return list;
    }

    /**
     * Returns a set of all room IDs that this user has saved in their wishlist.
     */
    public Set<Integer> getWishlistRoomIds(int userId) {
        Set<Integer> roomIds = new HashSet<>();
        String sql = "SELECT room_id FROM wishlists WHERE user_id = ? AND room_id IS NOT NULL";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                roomIds.add(rs.getInt("room_id"));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error getting wishlist room ids for user: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return roomIds;
    }

    /**
     * Checks if a specific room is in the user's wishlist.
     */
    public boolean isRoomInWishlist(int userId, int roomId) {
        String sql = "SELECT 1 FROM wishlists WHERE user_id = ? AND room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, roomId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking room in wishlist", e);
            return false;
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Adds a room to the user's wishlist.
     */
    public boolean addRoom(int userId, int roomId) {
        String sql = "INSERT INTO wishlists (user_id, room_id) VALUES (?, ?) " +
                "ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, roomId);
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                recordBehavior(conn, userId, "WISHLIST_ADD", roomId);
            }
            return success;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding room to wishlist: user=" + userId + ", room=" + roomId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Removes a room from the user's wishlist.
     */
    public boolean removeRoom(int userId, int roomId) {
        String sql = "DELETE FROM wishlists WHERE user_id = ? AND room_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, roomId);
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                recordBehavior(conn, userId, "REMOVE_WISHLIST", roomId);
            }
            return success;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error removing room from wishlist: user=" + userId + ", room=" + roomId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Toggles a room's wishlist state (adds if not present, removes if already present).
     * @return true if room was added, false if room was removed.
     */
    public boolean toggleRoomWishlist(int userId, int roomId) {
        if (isRoomInWishlist(userId, roomId)) {
            removeRoom(userId, roomId);
            return false;
        } else {
            addRoom(userId, roomId);
            return true;
        }
    }

    /**
     * Returns total count of wishlisted items for a user.
     */
    public int getWishlistCount(int userId) {
        String sql = "SELECT COUNT(*) FROM wishlists WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error counting wishlist for user: " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Removes all items from a user's wishlist.
     */
    public boolean clearAll(int userId) {
        String sql = "DELETE FROM wishlists WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error clearing wishlist for user: " + userId, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Optional helper to record user behavior analytics.
     */
    private void recordBehavior(Connection conn, int userId, String behaviorType, int roomId) {
        String sql = "INSERT INTO userbehaviors (user_id, behavior_type, room_type_id, property_id) " +
                "SELECT ?, ?, r.room_type_id, rt.property_id FROM rooms r " +
                "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                "WHERE r.room_id = ? LIMIT 1";
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, behaviorType);
            ps.setInt(3, roomId);
            ps.executeUpdate();
        } catch (SQLException ignored) {
            // Non-critical background telemetry
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException ignored) {}
            }
        }
    }
}
