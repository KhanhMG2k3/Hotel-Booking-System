package com.homestay.dao;

import com.homestay.model.Province;
import com.homestay.model.Recommendation;
import com.homestay.model.Room;
import com.homestay.model.RoomType;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;

/**
 * RecommendationDAO - Data Access Object for AI-driven personalized room recommendations.
 * Powers the "Recommended for You" section on Catalog & Discovery (Actor: Customer).
 */
public class RecommendationDAO extends BaseDAO {

    private static final String ROOM_IMAGE_JOIN =
            "LEFT JOIN (SELECT room_type_id, image_url FROM (" +
            "    SELECT room_type_id, image_url, " +
            "           ROW_NUMBER() OVER (PARTITION BY room_type_id ORDER BY is_primary DESC, display_order ASC, image_id ASC) as rn " +
            "    FROM roomimages " +
            "    WHERE (media_type = 'IMAGE' OR media_type IS NULL)" +
            ") ranked_ri WHERE ranked_ri.rn = 1) ri ON rt.room_type_id = ri.room_type_id ";

    private static final String BASE_RECOMMENDATION_SELECT =
            "SELECT rec.recommendation_id, rec.user_id, rec.room_id, rec.recommendation_type, rec.score, rec.reason, rec.is_displayed, rec.created_at, " +
            "       r.room_id as r_id, r.room_number, r.status, " +
            "       rt.room_type_id, rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
            "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.8) as rating, COALESCE(rt.review_count, 12) as review_count, " +
            "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
            "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
            "       COALESCE(prop.address, '') as address, " +
            "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
            "FROM recommendations rec " +
            "JOIN rooms r ON rec.room_id = r.room_id " +
            "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
            "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
            "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
            "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
            ROOM_IMAGE_JOIN;

    /**
     * Get personalized recommendations for a given customer.
     * If user has existing recommendation records, returns them.
     * If not, generates dynamic AI recommendations based on booking history, wishlist, and popular homestays,
     * and saves them to the recommendations table.
     *
     * @param userId Logged in user ID, or null for guests
     * @param limit Maximum number of recommended rooms (e.g., 3 or 4)
     * @return List of Recommendation objects with attached Room models
     */
    public List<Recommendation> getPersonalizedRecommendations(Integer userId, int limit) {
        if (limit <= 0) limit = 4;

        if (userId == null) {
            return getPopularRecommendations(limit);
        }

        // 1. Try to load saved recommendations for this user
        List<Recommendation> userRecs = getSavedRecommendationsForUser(userId, limit);
        if (userRecs.size() >= Math.min(3, limit)) {
            return userRecs;
        }

        // 2. Generate personalized recommendations dynamically
        List<Recommendation> generatedRecs = generateAndSaveRecommendations(userId, limit);
        if (!generatedRecs.isEmpty()) {
            return generatedRecs;
        }

        // 3. Fallback to popular recommendations
        return getPopularRecommendations(limit);
    }

    /**
     * Retrieves saved recommendations for a specific user from recommendations table.
     */
    private List<Recommendation> getSavedRecommendationsForUser(int userId, int limit) {
        List<Recommendation> list = new ArrayList<>();
        String sql = BASE_RECOMMENDATION_SELECT +
                     "WHERE rec.user_id = ? AND rec.is_displayed = 1 " +
                     "ORDER BY rec.score DESC, rec.recommendation_id DESC LIMIT ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToRecommendation(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error loading saved recommendations for user " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Generates personalized recommendations for a user by analyzing:
     * 1. Previous bookings (budget range, preferred province, room type)
     * 2. Saved wishlist items
     * 3. Highest rated popular homestays
     * Then persists the generated recommendations in the database.
     */
    public List<Recommendation> generateAndSaveRecommendations(int userId, int limit) {
        List<Recommendation> recommendations = new ArrayList<>();
        Set<Integer> excludedRoomIds = new HashSet<>();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        double avgBudget = 0.0;
        int budgetSampleCount = 0;
        Integer favProvinceId = null;
        String favProvinceName = null;
        Integer favTypeId = null;

        Map<Integer, Integer> provinceFreq = new HashMap<>();
        Map<Integer, String> provinceNameMap = new HashMap<>();
        Map<Integer, Integer> typeFreq = new HashMap<>();

        try {
            conn = getConnection();

            // 1. Inspect past bookings
            String bookingHistorySql = 
                    "SELECT b.room_id, rt.base_price, rt.room_type_id, prov.province_id, prov.province_name " +
                    "FROM bookings b " +
                    "JOIN rooms r ON b.room_id = r.room_id " +
                    "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                    "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                    "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                    "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                    "WHERE b.user_id = ? ORDER BY b.id DESC LIMIT 10";

            ps = conn.prepareStatement(bookingHistorySql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                int rId = rs.getInt("room_id");
                excludedRoomIds.add(rId);

                BigDecimal basePrice = rs.getBigDecimal("base_price");
                if (basePrice != null) {
                    avgBudget += basePrice.doubleValue();
                    budgetSampleCount++;
                }

                int provId = rs.getInt("province_id");
                if (provId > 0) {
                    provinceFreq.put(provId, provinceFreq.getOrDefault(provId, 0) + 2);
                    provinceNameMap.put(provId, rs.getString("province_name"));
                }

                int tId = rs.getInt("room_type_id");
                if (tId > 0) {
                    typeFreq.put(tId, typeFreq.getOrDefault(tId, 0) + 2);
                }
            }
            rs.close();
            ps.close();

            // 2. Inspect wishlists
            String wishlistSql = 
                    "SELECT w.room_id, rt.base_price, rt.room_type_id, prov.province_id, prov.province_name " +
                    "FROM wishlists w " +
                    "JOIN rooms r ON w.room_id = r.room_id " +
                    "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                    "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                    "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                    "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                    "WHERE w.user_id = ? ORDER BY w.wishlist_id DESC LIMIT 10";

            ps = conn.prepareStatement(wishlistSql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            List<Integer> wishlistRoomIds = new ArrayList<>();
            while (rs.next()) {
                int rId = rs.getInt("room_id");
                wishlistRoomIds.add(rId);

                BigDecimal basePrice = rs.getBigDecimal("base_price");
                if (basePrice != null) {
                    avgBudget += basePrice.doubleValue();
                    budgetSampleCount++;
                }

                int provId = rs.getInt("province_id");
                if (provId > 0) {
                    provinceFreq.put(provId, provinceFreq.getOrDefault(provId, 0) + 1);
                    provinceNameMap.put(provId, rs.getString("province_name"));
                }

                int tId = rs.getInt("room_type_id");
                if (tId > 0) {
                    typeFreq.put(tId, typeFreq.getOrDefault(tId, 0) + 1);
                }
            }
            rs.close();
            ps.close();

            // Calculate preferences
            if (budgetSampleCount > 0) {
                avgBudget /= budgetSampleCount;
            }

            int maxProvCount = 0;
            for (Map.Entry<Integer, Integer> entry : provinceFreq.entrySet()) {
                if (entry.getValue() > maxProvCount) {
                    maxProvCount = entry.getValue();
                    favProvinceId = entry.getKey();
                    favProvinceName = provinceNameMap.get(entry.getKey());
                }
            }

            int maxTypeCount = 0;
            for (Map.Entry<Integer, Integer> entry : typeFreq.entrySet()) {
                if (entry.getValue() > maxTypeCount) {
                    maxTypeCount = entry.getValue();
                    favTypeId = entry.getKey();
                }
            }

            Locale vnLocale = new Locale("vi", "VN");
            NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(vnLocale);

            // A. BUDGET_MATCH Recommendation (if user has budget history)
            if (avgBudget > 0 && recommendations.size() < limit) {
                double minRange = avgBudget * 0.70;
                double maxRange = avgBudget * 1.35;

                String budgetSql = 
                        "SELECT r.room_id as r_id, r.room_number, r.status, " +
                        "       rt.room_type_id, rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
                        "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.8) as rating, COALESCE(rt.review_count, 12) as review_count, " +
                        "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
                        "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                        "       COALESCE(prop.address, '') as address, " +
                        "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
                        "FROM rooms r " +
                        "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                        "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                        "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                        ROOM_IMAGE_JOIN +
                        "WHERE rt.base_price BETWEEN ? AND ? " +
                        "ORDER BY rt.rating DESC, rt.review_count DESC LIMIT 2";

                ps = conn.prepareStatement(budgetSql);
                ps.setDouble(1, minRange);
                ps.setDouble(2, maxRange);
                rs = ps.executeQuery();

                while (rs.next() && recommendations.size() < limit) {
                    int rId = rs.getInt("r_id");
                    if (!excludedRoomIds.contains(rId)) {
                        Room room = mapResultSetToRoom(rs);
                        Recommendation rec = new Recommendation();
                        rec.setUserId(userId);
                        rec.setRoomId(rId);
                        rec.setRecommendationType("BUDGET_MATCH");
                        rec.setScore(0.96);
                        rec.setReason("Phù hợp với tầm giá ~" + currencyFormat.format(avgBudget) + " bạn hay lựa chọn");
                        rec.setDisplayed(true);
                        rec.setRoom(room);

                        recommendations.add(rec);
                        excludedRoomIds.add(rId);
                    }
                }
                rs.close();
                ps.close();
            }

            // B. CONTENT_BASED Recommendation (Preferred location or room type)
            if (favProvinceId != null && recommendations.size() < limit) {
                String contentSql = 
                        "SELECT r.room_id as r_id, r.room_number, r.status, " +
                        "       rt.room_type_id, rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
                        "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.8) as rating, COALESCE(rt.review_count, 12) as review_count, " +
                        "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
                        "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                        "       COALESCE(prop.address, '') as address, " +
                        "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
                        "FROM rooms r " +
                        "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                        "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                        "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                        ROOM_IMAGE_JOIN +
                        "WHERE dest.province_id = ? " +
                        "ORDER BY rt.rating DESC LIMIT 2";

                ps = conn.prepareStatement(contentSql);
                ps.setInt(1, favProvinceId);
                rs = ps.executeQuery();

                while (rs.next() && recommendations.size() < limit) {
                    int rId = rs.getInt("r_id");
                    if (!excludedRoomIds.contains(rId)) {
                        Room room = mapResultSetToRoom(rs);
                        Recommendation rec = new Recommendation();
                        rec.setUserId(userId);
                        rec.setRoomId(rId);
                        rec.setRecommendationType("CONTENT_BASED");
                        rec.setScore(0.93);
                        rec.setReason("Nằm tại điểm đến yêu thích " + (favProvinceName != null ? favProvinceName : "của bạn") + " với đánh giá hàng đầu");
                        rec.setDisplayed(true);
                        rec.setRoom(room);

                        recommendations.add(rec);
                        excludedRoomIds.add(rId);
                    }
                }
                rs.close();
                ps.close();
            }

            // C. BEHAVIOR_BASED Recommendation (Wishlist matching)
            if (!wishlistRoomIds.isEmpty() && recommendations.size() < limit) {
                for (int wRoomId : wishlistRoomIds) {
                    if (recommendations.size() >= limit) break;
                    String wishMatchSql = 
                            "SELECT r.room_id as r_id, r.room_number, r.status, " +
                            "       rt.room_type_id, rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
                            "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.8) as rating, COALESCE(rt.review_count, 12) as review_count, " +
                            "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
                            "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                            "       COALESCE(prop.address, '') as address, " +
                            "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
                            "FROM rooms r " +
                            "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                            "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                            "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                            "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                            ROOM_IMAGE_JOIN +
                            "WHERE r.room_id = ? LIMIT 1";

                    ps = conn.prepareStatement(wishMatchSql);
                    ps.setInt(1, wRoomId);
                    rs = ps.executeQuery();

                    if (rs.next()) {
                        int rId = rs.getInt("r_id");
                        if (!excludedRoomIds.contains(rId)) {
                            Room room = mapResultSetToRoom(rs);
                            Recommendation rec = new Recommendation();
                            rec.setUserId(userId);
                            rec.setRoomId(rId);
                            rec.setRecommendationType("BEHAVIOR_BASED");
                            rec.setScore(0.91);
                            rec.setReason("Homestay trong danh sách quan tâm của bạn với dịch vụ tiện nghi");
                            rec.setDisplayed(true);
                            rec.setRoom(room);

                            recommendations.add(rec);
                            excludedRoomIds.add(rId);
                        }
                    }
                    rs.close();
                    ps.close();
                }
            }

            // D. POPULAR fallback to fill up to limit
            if (recommendations.size() < limit) {
                String popularSql = 
                        "SELECT r.room_id as r_id, r.room_number, r.status, " +
                        "       rt.room_type_id, rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
                        "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.8) as rating, COALESCE(rt.review_count, 12) as review_count, " +
                        "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
                        "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                        "       COALESCE(prop.address, '') as address, " +
                        "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
                        "FROM rooms r " +
                        "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                        "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                        "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                        ROOM_IMAGE_JOIN +
                        "ORDER BY rt.rating DESC, rt.review_count DESC LIMIT 10";

                ps = conn.prepareStatement(popularSql);
                rs = ps.executeQuery();

                while (rs.next() && recommendations.size() < limit) {
                    int rId = rs.getInt("r_id");
                    if (!excludedRoomIds.contains(rId)) {
                        Room room = mapResultSetToRoom(rs);
                        Recommendation rec = new Recommendation();
                        rec.setUserId(userId);
                        rec.setRoomId(rId);
                        rec.setRecommendationType("POPULAR");
                        rec.setScore(0.89);
                        rec.setReason("Homestay được đánh giá xuất sắc nhất từ cộng đồng du khách");
                        rec.setDisplayed(true);
                        rec.setRoom(room);

                        recommendations.add(rec);
                        excludedRoomIds.add(rId);
                    }
                }
                rs.close();
                ps.close();
            }

            // Persist newly generated recommendations into DB
            if (!recommendations.isEmpty()) {
                String insertSql = 
                        "INSERT INTO recommendations (user_id, room_id, recommendation_type, score, reason, is_displayed) " +
                        "VALUES (?, ?, ?, ?, ?, 1)";
                ps = conn.prepareStatement(insertSql);

                for (Recommendation rec : recommendations) {
                    ps.setInt(1, userId);
                    ps.setInt(2, rec.getRoomId());
                    ps.setString(3, rec.getRecommendationType());
                    ps.setDouble(4, rec.getScore());
                    ps.setString(5, rec.getReason());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error generating AI recommendations for user " + userId, e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return recommendations;
    }

    /**
     * Retrieves top popular recommendations for guests (unauthenticated users).
     */
    public List<Recommendation> getPopularRecommendations(int limit) {
        List<Recommendation> list = new ArrayList<>();
        // Check if there are default seeded recommendations
        String seededSql = BASE_RECOMMENDATION_SELECT +
                           "WHERE rec.user_id IS NULL AND rec.is_displayed = 1 " +
                           "ORDER BY rec.score DESC LIMIT ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(seededSql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapResultSetToRecommendation(rs));
            }

            // If no seeded popular recs or less than limit, fetch top-rated rooms directly
            if (list.size() < limit) {
                Set<Integer> existingRoomIds = new HashSet<>();
                for (Recommendation r : list) {
                    if (r.getRoomId() != null) existingRoomIds.add(r.getRoomId());
                }

                rs.close();
                ps.close();

                String topRatedSql = 
                        "SELECT r.room_id as r_id, r.room_number, r.status, " +
                        "       rt.room_type_id, rt.room_name, rt.description, rt.max_guests as capacity, rt.base_price as price_per_night, " +
                        "       rt.size_m2, rt.bed_type, COALESCE(rt.rating, 4.8) as rating, COALESCE(rt.review_count, 12) as review_count, " +
                        "       COALESCE(r.image_url, ri.image_url, 'images/img_1.jpg') as display_image_url, " +
                        "       COALESCE(prop.property_name, 'Sogo Homestay') as property_name, " +
                        "       COALESCE(prop.address, '') as address, " +
                        "       prov.province_id, COALESCE(prov.province_name, 'Đà Nẵng') as province_name " +
                        "FROM rooms r " +
                        "JOIN roomtypes rt ON r.room_type_id = rt.room_type_id " +
                        "LEFT JOIN properties prop ON rt.property_id = prop.property_id " +
                        "LEFT JOIN destinations dest ON prop.destination_id = dest.destination_id " +
                        "LEFT JOIN provinces prov ON dest.province_id = prov.province_id " +
                        ROOM_IMAGE_JOIN +
                        "ORDER BY rt.rating DESC, rt.review_count DESC LIMIT ?";

                ps = conn.prepareStatement(topRatedSql);
                ps.setInt(1, limit + 2);
                rs = ps.executeQuery();

                while (rs.next() && list.size() < limit) {
                    int rId = rs.getInt("r_id");
                    if (!existingRoomIds.contains(rId)) {
                        Room room = mapResultSetToRoom(rs);
                        Recommendation rec = new Recommendation();
                        rec.setRoomId(rId);
                        rec.setRecommendationType("POPULAR");
                        rec.setScore(0.95);
                        rec.setReason("Homestay được đánh giá cao nhất và được nhiều du khách yêu thích");
                        rec.setDisplayed(true);
                        rec.setRoom(room);

                        list.add(rec);
                        existingRoomIds.add(rId);
                    }
                }
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error loading popular recommendations", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Map ResultSet to a full Recommendation object with joined Room.
     */
    private Recommendation mapResultSetToRecommendation(ResultSet rs) throws SQLException {
        Recommendation rec = new Recommendation();
        rec.setRecommendationId(rs.getLong("recommendation_id"));
        int uId = rs.getInt("user_id");
        rec.setUserId(rs.wasNull() ? null : uId);
        int rId = rs.getInt("room_id");
        rec.setRoomId(rs.wasNull() ? null : rId);
        rec.setRecommendationType(rs.getString("recommendation_type"));
        rec.setScore(rs.getDouble("score"));
        rec.setReason(rs.getString("reason"));
        rec.setDisplayed(rs.getBoolean("is_displayed"));
        rec.setCreatedAt(rs.getTimestamp("created_at"));

        Room room = mapResultSetToRoom(rs);
        rec.setRoom(room);
        return rec;
    }

    /**
     * Map ResultSet to Room entity.
     */
    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        int roomId = 0;
        try {
            roomId = rs.getInt("r_id");
        } catch (SQLException e) {
            roomId = rs.getInt("room_id");
        }
        room.setId(roomId);
        room.setTypeId(rs.getInt("room_type_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomName(rs.getString("room_name"));
        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setCapacity(rs.getInt("capacity"));
        room.setSize(rs.getDouble("size_m2"));
        room.setBedType(rs.getString("bed_type"));
        room.setImageUrl(rs.getString("display_image_url"));
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
        roomType.setId(rs.getInt("room_type_id"));
        roomType.setTypeName(rs.getString("room_name"));
        roomType.setDescription(rs.getString("description"));
        room.setRoomType(roomType);

        return room;
    }
}
