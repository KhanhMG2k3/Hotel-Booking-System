package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.PartnerApplicationMedia;
import com.homestay.model.PartnerApplicationRoom;
import com.homestay.model.PartnerApplicationRoom.RoomImage;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/** Persists application rooms, amenities, images, and staged media references. */
public class PartnerApplicationRoomDAO {

    /** Copies a source application's rooms and child data using the caller's transaction. */
    public void copyRooms(Connection connection, int sourceApplicationId,
                          int targetApplicationId) throws SQLException {
        String selectSql = "SELECT id, room_name, room_type, price_per_night, max_guests, " +
                "bed_count, bathroom_count, sort_order FROM partner_application_rooms " +
                "WHERE application_id = ? ORDER BY sort_order, id";
        String insertSql = "INSERT INTO partner_application_rooms " +
                "(application_id, room_name, room_type, price_per_night, max_guests, " +
                "bed_count, bathroom_count, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement select = connection.prepareStatement(selectSql);
             PreparedStatement insert = connection.prepareStatement(
                     insertSql, Statement.RETURN_GENERATED_KEYS)) {
            select.setInt(1, sourceApplicationId);
            try (ResultSet rooms = select.executeQuery()) {
                while (rooms.next()) {
                    insert.setInt(1, targetApplicationId);
                    insert.setString(2, rooms.getString("room_name"));
                    insert.setString(3, rooms.getString("room_type"));
                    insert.setBigDecimal(4, rooms.getBigDecimal("price_per_night"));
                    insert.setInt(5, rooms.getInt("max_guests"));
                    insert.setInt(6, rooms.getInt("bed_count"));
                    insert.setInt(7, rooms.getInt("bathroom_count"));
                    insert.setInt(8, rooms.getInt("sort_order"));
                    insert.executeUpdate();
                    int newRoomId;
                    try (ResultSet keys = insert.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("The database did not return a copied room ID.");
                        }
                        newRoomId = keys.getInt(1);
                    }
                    copyRoomChildren(connection, rooms.getInt("id"), newRoomId);
                }
            }
        }
        updateApplicationCapacity(connection, targetApplicationId);
    }

    /** Loads an application's rooms only when the specified user owns the application. */
    public List<PartnerApplicationRoom> findByApplication(int applicationId, int userId)
            throws SQLException {
        String sql = "SELECT r.id, r.application_id, r.room_name, r.room_type, r.price_per_night, " +
                "r.max_guests, r.bed_count, r.bathroom_count, r.sort_order " +
                "FROM partner_application_rooms r JOIN host_applications a ON a.id = r.application_id " +
                "WHERE r.application_id = ? AND a.user_id = ? ORDER BY r.sort_order, r.id";
        List<PartnerApplicationRoom> rooms = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    PartnerApplicationRoom room = mapRoom(resultSet);
                    room.setAmenities(findAmenities(connection, room.getId()));
                    room.setImages(findImages(connection, room.getId()));
                    rooms.add(room);
                }
            }
        }
        return rooms;
    }

    /** Loads all rooms for an administrator's application view. */
    public List<PartnerApplicationRoom> findByApplicationForAdmin(int applicationId)
            throws SQLException {
        String sql = "SELECT id, application_id, room_name, room_type, price_per_night, " +
                "max_guests, bed_count, bathroom_count, sort_order " +
                "FROM partner_application_rooms WHERE application_id = ? ORDER BY sort_order, id";
        List<PartnerApplicationRoom> rooms = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    PartnerApplicationRoom room = mapRoom(resultSet);
                    room.setAmenities(findAmenities(connection, room.getId()));
                    room.setImages(findImages(connection, room.getId()));
                    rooms.add(room);
                }
            }
        }
        return rooms;
    }

    /** Loads a draft room only for its owning active customer. */
    public PartnerApplicationRoom findById(int roomId, int userId) throws SQLException {
        String sql = "SELECT r.id, r.application_id, r.room_name, r.room_type, r.price_per_night, " +
                "r.max_guests, r.bed_count, r.bathroom_count, r.sort_order " +
                "FROM partner_application_rooms r JOIN host_applications a ON a.id = r.application_id " +
                "JOIN users u ON u.id = a.user_id JOIN roles role ON role.id = u.role_id " +
                "WHERE r.id = ? AND a.user_id = ? AND a.status = 'DRAFT' " +
                "AND u.status = 'ACTIVE' AND role.name = 'CUSTOMER' LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, roomId);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                PartnerApplicationRoom room = mapRoom(resultSet);
                room.setAmenities(findAmenities(connection, roomId));
                room.setImages(findImages(connection, roomId));
                return room;
            }
        }
    }

    /** Loads a room for its owning account, regardless of application state. */
    public PartnerApplicationRoom findByIdForOwner(int roomId, int userId) throws SQLException {
        String sql = "SELECT r.id, r.application_id, r.room_name, r.room_type, r.price_per_night, " +
                "r.max_guests, r.bed_count, r.bathroom_count, r.sort_order " +
                "FROM partner_application_rooms r JOIN host_applications a ON a.id = r.application_id " +
                "WHERE r.id = ? AND a.user_id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, roomId);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                PartnerApplicationRoom room = mapRoom(resultSet);
                room.setAmenities(findAmenities(connection, roomId));
                room.setImages(findImages(connection, roomId));
                return room;
            }
        }
    }

    /** Loads a room by ID for an authorized administrator workflow. */
    public PartnerApplicationRoom findByIdForAdmin(int roomId) throws SQLException {
        String sql = "SELECT id, application_id, room_name, room_type, price_per_night, " +
                "max_guests, bed_count, bathroom_count, sort_order " +
                "FROM partner_application_rooms WHERE id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, roomId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                PartnerApplicationRoom room = mapRoom(resultSet);
                room.setAmenities(findAmenities(connection, roomId));
                room.setImages(findImages(connection, roomId));
                return room;
            }
        }
    }

    /** Saves a validated room, its amenities, and staged media as one transaction. */
    public boolean save(int applicationId, int userId, PartnerApplicationRoom room)
            throws SQLException {
        if (getValidationError(room) != null) {
            return false;
        }
        // Keep room changes, staged media attachment, and capacity totals consistent.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEditableApplication(connection, applicationId, userId)) {
                    connection.rollback();
                    return false;
                }

                if (room.getId() > 0) {
                    String updateSql = "UPDATE partner_application_rooms SET room_name = ?, " +
                            "room_type = ?, price_per_night = ?, max_guests = ?, bed_count = ?, " +
                            "bathroom_count = ?, sort_order = ? WHERE id = ? AND application_id = ?";
                    try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                        bindRoom(statement, room);
                        statement.setInt(8, room.getId());
                        statement.setInt(9, applicationId);
                        int updatedRows = statement.executeUpdate();
                        if (updatedRows != 1 && (updatedRows != 0
                                || !roomExists(connection, applicationId, room.getId()))) {
                            connection.rollback();
                            return false;
                        }
                    }
                    try (PreparedStatement statement = connection.prepareStatement(
                            "DELETE FROM partner_application_room_amenities WHERE room_id = ?")) {
                        statement.setInt(1, room.getId());
                        statement.executeUpdate();
                    }
                } else {
                    try (PreparedStatement statement = connection.prepareStatement(
                            "SELECT COUNT(*) FROM partner_application_rooms " +
                                    "WHERE application_id = ?")) {
                        statement.setInt(1, applicationId);
                        try (ResultSet resultSet = statement.executeQuery()) {
                            resultSet.next();
                            if (resultSet.getInt(1) >= 20) {
                                connection.rollback();
                                return false;
                            }
                        }
                    }
                    String insertSql = "INSERT INTO partner_application_rooms " +
                            "(application_id, room_name, room_type, price_per_night, max_guests, " +
                            "bed_count, bathroom_count, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement statement = connection.prepareStatement(
                            insertSql, Statement.RETURN_GENERATED_KEYS)) {
                        statement.setInt(1, applicationId);
                        bindRoom(statement, room, 2);
                        if (statement.executeUpdate() != 1) {
                            throw new SQLException("The partner room was not inserted.");
                        }
                        try (ResultSet keys = statement.getGeneratedKeys()) {
                            if (!keys.next()) {
                                throw new SQLException("The database did not return a room ID.");
                            }
                            room.setId(keys.getInt(1));
                        }
                    }
                }

                // Attach pending uploads atomically with the room save.
                if (!attachStagedMedia(connection, applicationId, room.getId(),
                        room.getClientRoomKey())) {
                    connection.rollback();
                    return false;
                }
                insertAmenities(connection, room.getId(), room.getAmenities());
                updateApplicationCapacity(connection, applicationId);
                connection.commit();
                room.setApplicationId(applicationId);
                return true;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Returns a room input error, or {@code null} when all fields meet the limits. */
    public String getValidationError(PartnerApplicationRoom room) {
        if (room == null) {
            return "Room details were not received. Please try again.";
        }
        if (room.getRoomName() == null || room.getRoomName().isBlank()
                || room.getRoomName().trim().length() > 120) {
            return "Enter a room name between 1 and 120 characters.";
        }
        if (room.getRoomType() == null
                || !room.getRoomType().matches("SINGLE|DOUBLE|TWIN|FAMILY|SUITE|OTHER")) {
            return "Choose a valid room type.";
        }
        if (room.getPricePerNight() == null
                || room.getPricePerNight().compareTo(BigDecimal.ZERO) <= 0
                || room.getPricePerNight().scale() > 2
                || room.getPricePerNight().compareTo(new BigDecimal("99999999.99")) > 0) {
            return "Enter a nightly price greater than 0, with no more than 2 decimal places.";
        }
        if (room.getMaxGuests() < 1 || room.getMaxGuests() > 65535) {
            return "Maximum guests must be between 1 and 65,535.";
        }
        if (room.getBedCount() < 1 || room.getBedCount() > 65535) {
            return "Number of beds must be between 1 and 65,535.";
        }
        if (room.getBathroomCount() < 1 || room.getBathroomCount() > 65535) {
            return "Bathrooms must be between 1 and 65,535.";
        }
        if (room.getSortOrder() < 0 || room.getSortOrder() > 65535) {
            return "The room order is invalid. Reload the application and try again.";
        }
        if (room.getAmenities() == null || room.getAmenities().size() > 30
                || room.getAmenities().stream().anyMatch(
                        amenity -> amenity == null || amenity.trim().length() > 80)) {
            return "Room amenities must be 80 characters or fewer, with at most 30 selections.";
        }
        return null;
    }

    private boolean roomExists(Connection connection, int applicationId, int roomId)
            throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT 1 FROM partner_application_rooms WHERE id = ? AND application_id = ?")) {
            statement.setInt(1, roomId);
            statement.setInt(2, applicationId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Deletes an owned room and updates application capacity in one transaction. */
    public boolean delete(int applicationId, int userId, int roomId) throws SQLException {
        String sql = "DELETE r FROM partner_application_rooms r " +
                "JOIN host_applications a ON a.id = r.application_id " +
                "JOIN users u ON u.id = a.user_id JOIN roles role ON role.id = u.role_id " +
                "WHERE r.id = ? AND r.application_id = ? AND a.user_id = ? " +
                "AND a.status = 'DRAFT' AND u.status = 'ACTIVE' AND role.name = 'CUSTOMER'";
        // Delete the owned room and recalculate its parent application capacity atomically.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEditableApplication(connection, applicationId, userId)) {
                    connection.rollback();
                    return false;
                }
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setInt(1, roomId);
                    statement.setInt(2, applicationId);
                    statement.setInt(3, userId);
                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }
                updateApplicationCapacity(connection, applicationId);
                connection.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Adds validated media metadata to an owned room's editable application. */
    public boolean addImage(int applicationId, int userId, int roomId,
                            String storedName, String mediaType, String contentType)
            throws SQLException {
        if (!isValidMedia(storedName, mediaType, contentType)) {
            return false;
        }
        String checkSql = "SELECT COUNT(*) FROM partner_application_room_images i " +
                "JOIN partner_application_rooms r ON r.id = i.room_id " +
                "JOIN host_applications a ON a.id = r.application_id " +
                "WHERE r.id = ? AND a.id = ? AND a.user_id = ? AND a.status = 'DRAFT'";
        String insertSql = "INSERT INTO partner_application_room_images " +
                "(room_id, stored_name, media_type, content_type, sort_order) " +
                "SELECT ?, ?, ?, ?, COALESCE(MAX(sort_order), -1) + 1 " +
                "FROM partner_application_room_images WHERE room_id = ?";
        // Check the current media limit and insert under a locked draft in one transaction.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEditableApplication(connection, applicationId, userId)) {
                    connection.rollback();
                    return false;
                }
                try (PreparedStatement statement = connection.prepareStatement(checkSql)) {
                    statement.setInt(1, roomId);
                    statement.setInt(2, applicationId);
                    statement.setInt(3, userId);
                    try (ResultSet resultSet = statement.executeQuery()) {
                        resultSet.next();
                        if (resultSet.getInt(1) >= 10) {
                            connection.rollback();
                            return false;
                        }
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(insertSql)) {
                    statement.setInt(1, roomId);
                    statement.setString(2, storedName);
                    statement.setString(3, mediaType);
                    statement.setString(4, contentType);
                    statement.setInt(5, roomId);
                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }
                connection.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Saves media metadata before a room exists and returns the generated media model. */
    public PartnerApplicationMedia addStagedMedia(int applicationId, int userId,
                                                   String clientRoomKey, String storedName,
                                                   String mediaType, String contentType)
            throws SQLException {
        if (!isValidClientRoomKey(clientRoomKey) || !isValidMedia(storedName, mediaType, contentType)) {
            return null;
        }
        // Lock the draft while enforcing its media limit and saving the staged reference.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEditableApplication(connection, applicationId, userId)) {
                    connection.rollback();
                    return null;
                }
                String countSql = "SELECT COUNT(*) FROM partner_application_staged_media " +
                        "WHERE application_id = ? AND client_room_key = ?";
                int mediaCount;
                try (PreparedStatement statement = connection.prepareStatement(countSql)) {
                    statement.setInt(1, applicationId);
                    statement.setString(2, clientRoomKey);
                    try (ResultSet resultSet = statement.executeQuery()) {
                        resultSet.next();
                        mediaCount = resultSet.getInt(1);
                    }
                }
                if (mediaCount >= 10) {
                    connection.rollback();
                    return null;
                }

                String insertSql = "INSERT INTO partner_application_staged_media " +
                        "(application_id, client_room_key, stored_name, media_type, " +
                        "content_type, sort_order) VALUES (?, ?, ?, ?, ?, ?)";
                int mediaId;
                try (PreparedStatement statement = connection.prepareStatement(
                        insertSql, Statement.RETURN_GENERATED_KEYS)) {
                    statement.setInt(1, applicationId);
                    statement.setString(2, clientRoomKey);
                    statement.setString(3, storedName);
                    statement.setString(4, mediaType);
                    statement.setString(5, contentType);
                    statement.setInt(6, mediaCount);
                    statement.executeUpdate();
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("The database did not return a staged media ID.");
                        }
                        mediaId = keys.getInt(1);
                    }
                }
                connection.commit();
                PartnerApplicationMedia media = new PartnerApplicationMedia();
                media.setId(mediaId);
                media.setApplicationId(applicationId);
                media.setClientRoomKey(clientRoomKey);
                media.setStoredName(storedName);
                media.setMediaType(mediaType);
                media.setContentType(contentType);
                media.setSortOrder(mediaCount);
                return media;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Lists staged media for an application and client room key owned by the user. */
    public List<PartnerApplicationMedia> findStagedMedia(int applicationId, int userId,
                                                           String clientRoomKey)
            throws SQLException {
        String sql = "SELECT m.id, m.application_id, m.client_room_key, m.stored_name, " +
                "m.media_type, m.content_type, m.sort_order, m.created_at " +
                "FROM partner_application_staged_media m " +
                "JOIN host_applications a ON a.id = m.application_id " +
                "WHERE m.application_id = ? AND a.user_id = ? AND m.client_room_key = ? " +
                "ORDER BY m.sort_order, m.id";
        List<PartnerApplicationMedia> media = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            statement.setInt(2, userId);
            statement.setString(3, clientRoomKey);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    media.add(mapStagedMedia(resultSet));
                }
            }
        }
        return media;
    }

    /** Lists all staged media for an application owned by the specified user. */
    public List<PartnerApplicationMedia> findAllStagedMedia(int applicationId, int userId)
            throws SQLException {
        String sql = "SELECT m.id, m.application_id, m.client_room_key, m.stored_name, " +
                "m.media_type, m.content_type, m.sort_order, m.created_at " +
                "FROM partner_application_staged_media m " +
                "JOIN host_applications a ON a.id = m.application_id " +
                "WHERE m.application_id = ? AND a.user_id = ? " +
                "ORDER BY m.client_room_key, m.sort_order, m.id";
        List<PartnerApplicationMedia> media = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    media.add(mapStagedMedia(resultSet));
                }
            }
        }
        return media;
    }

    /** Finds one staged media row only when the application belongs to the user. */
    public PartnerApplicationMedia findStagedMedia(int applicationId, int userId, int mediaId)
            throws SQLException {
        String sql = "SELECT m.id, m.application_id, m.client_room_key, m.stored_name, " +
                "m.media_type, m.content_type, m.sort_order, m.created_at " +
                "FROM partner_application_staged_media m " +
                "JOIN host_applications a ON a.id = m.application_id " +
                "WHERE m.id = ? AND m.application_id = ? AND a.user_id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, mediaId);
            statement.setInt(2, applicationId);
            statement.setInt(3, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapStagedMedia(resultSet) : null;
            }
        }
    }

    /** Deletes owned staged media and returns its stored filename after commit. */
    public String deleteStagedMedia(int applicationId, int userId, String clientRoomKey,
                                    int mediaId) throws SQLException {
        String selectSql = "SELECT m.stored_name FROM partner_application_staged_media m " +
                "JOIN host_applications a ON a.id = m.application_id " +
                "WHERE m.id = ? AND m.application_id = ? AND m.client_room_key = ? " +
                "AND a.user_id = ? AND a.status = 'DRAFT' FOR UPDATE";
        // Lock the draft, read the file reference, and delete its row atomically.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEditableApplication(connection, applicationId, userId)) {
                    connection.rollback();
                    return null;
                }
                String storedName;
                try (PreparedStatement statement = connection.prepareStatement(selectSql)) {
                    statement.setInt(1, mediaId);
                    statement.setInt(2, applicationId);
                    statement.setString(3, clientRoomKey);
                    statement.setInt(4, userId);
                    try (ResultSet resultSet = statement.executeQuery()) {
                        if (!resultSet.next()) {
                            connection.rollback();
                            return null;
                        }
                        storedName = resultSet.getString(1);
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(
                        "DELETE FROM partner_application_staged_media WHERE id = ?")) {
                    statement.setInt(1, mediaId);
                    statement.executeUpdate();
                }
                connection.commit();
                return storedName;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Returns a staged file reference for the owner, or {@code null} when not found. */
    public String findStagedMediaPath(int applicationId, int userId, int mediaId)
            throws SQLException {
        PartnerApplicationMedia media = findStagedMedia(applicationId, userId, mediaId);
        return media == null ? null : media.getStoredName();
    }

    /** Attaches eligible staged files to a room using the caller's transaction. */
    public boolean attachStagedMedia(Connection connection, int applicationId, int roomId,
                                     String clientRoomKey) throws SQLException {
        if (!isValidClientRoomKey(clientRoomKey)) {
            return true;
        }
        String existingCountSql = "SELECT COUNT(*) FROM partner_application_room_images " +
                "WHERE room_id = ?";
        int existingMediaCount;
        try (PreparedStatement statement = connection.prepareStatement(existingCountSql)) {
            statement.setInt(1, roomId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                existingMediaCount = resultSet.getInt(1);
            }
        }
        String stagedCountSql = "SELECT COUNT(*) FROM partner_application_staged_media " +
                "WHERE application_id = ? AND client_room_key = ?";
        int stagedMediaCount;
        try (PreparedStatement statement = connection.prepareStatement(stagedCountSql)) {
            statement.setInt(1, applicationId);
            statement.setString(2, clientRoomKey);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                stagedMediaCount = resultSet.getInt(1);
            }
        }
        if (existingMediaCount + stagedMediaCount > 10) {
            return false;
        }
        // Copy staged file references to the room, then remove their staging rows together.
        String insertSql = "INSERT INTO partner_application_room_images " +
                "(room_id, stored_name, media_type, content_type, sort_order) " +
                "SELECT ?, stored_name, media_type, content_type, " +
                "COALESCE((SELECT MAX(sort_order) + 1 FROM partner_application_room_images " +
                "WHERE room_id = ?), 0) + staged.sort_order FROM partner_application_staged_media staged " +
                "WHERE staged.application_id = ? AND staged.client_room_key = ? " +
                "ORDER BY staged.sort_order, staged.id";
        try (PreparedStatement statement = connection.prepareStatement(insertSql)) {
            statement.setInt(1, roomId);
            statement.setInt(2, roomId);
            statement.setInt(3, applicationId);
            statement.setString(4, clientRoomKey);
            statement.executeUpdate();
        }
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM partner_application_staged_media " +
                        "WHERE application_id = ? AND client_room_key = ?")) {
            statement.setInt(1, applicationId);
            statement.setString(2, clientRoomKey);
            statement.executeUpdate();
        }
        return true;
    }

    /** Returns an image filename only when its room belongs to the specified user. */
    public String findImagePath(int roomId, int imageId, int userId) throws SQLException {
        String sql = "SELECT i.stored_name FROM partner_application_room_images i " +
                "JOIN partner_application_rooms r ON r.id = i.room_id " +
                "JOIN host_applications a ON a.id = r.application_id " +
                "WHERE i.id = ? AND r.id = ? AND a.user_id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, imageId);
            statement.setInt(2, roomId);
            statement.setInt(3, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getString(1) : null;
            }
        }
    }

    /** Returns a room image filename for an authorized administrator workflow. */
    public String findImagePathForAdmin(int roomId, int imageId) throws SQLException {
        String sql = "SELECT stored_name FROM partner_application_room_images " +
                "WHERE id = ? AND room_id = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, imageId);
            statement.setInt(2, roomId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getString(1) : null;
            }
        }
    }

    /** Checks whether any application media row still references a stored filename. */
    public boolean isStoredNameInUse(String storedName) throws SQLException {
        String sql = "SELECT EXISTS (" +
                "SELECT 1 FROM host_applications WHERE identity_document_url = ? " +
                "OR ownership_document_url = ? OR business_document_url = ? " +
                "UNION ALL SELECT 1 FROM partner_application_room_images WHERE stored_name = ? " +
                "UNION ALL SELECT 1 FROM room_images WHERE stored_name = ? " +
                "UNION ALL SELECT 1 FROM partner_application_staged_media WHERE stored_name = ?)";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, storedName);
            statement.setString(2, storedName);
            statement.setString(3, storedName);
            statement.setString(4, storedName);
            statement.setString(5, storedName);
            statement.setString(6, storedName);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getBoolean(1);
            }
        }
    }

    /** Deletes an owned room-image row and returns its filename after successful commit. */
    public String deleteImage(int applicationId, int userId, int roomId, int imageId)
            throws SQLException {
        String sql = "DELETE i FROM partner_application_room_images i " +
                "JOIN partner_application_rooms r ON r.id = i.room_id " +
                "JOIN host_applications a ON a.id = r.application_id " +
                "JOIN users u ON u.id = a.user_id JOIN roles role ON role.id = u.role_id " +
                "WHERE i.id = ? AND r.id = ? AND a.id = ? AND a.user_id = ? " +
                "AND a.status = 'DRAFT' AND u.status = 'ACTIVE' AND role.name = 'CUSTOMER'";
        String[] storedName = new String[1];
        // Capture the file reference and remove its row in one transaction before cleanup.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEditableApplication(connection, applicationId, userId)) {
                    connection.rollback();
                    return null;
                }
                try (PreparedStatement select = connection.prepareStatement(
                        "SELECT stored_name FROM partner_application_room_images " +
                                "WHERE id = ? AND room_id = ? FOR UPDATE")) {
                    select.setInt(1, imageId);
                    select.setInt(2, roomId);
                    try (ResultSet resultSet = select.executeQuery()) {
                        if (!resultSet.next()) {
                            connection.rollback();
                            return null;
                        }
                        storedName[0] = resultSet.getString(1);
                    }
                }
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setInt(1, imageId);
                    statement.setInt(2, roomId);
                    statement.setInt(3, applicationId);
                    statement.setInt(4, userId);
                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return null;
                    }
                }
                connection.commit();
                return storedName[0];
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Locks and validates the owner's editable draft within the caller's transaction. */
    private boolean lockEditableApplication(Connection connection, int applicationId, int userId)
            throws SQLException {
        String sql = "SELECT a.id FROM host_applications a " +
                "JOIN users u ON u.id = a.user_id JOIN roles role ON role.id = u.role_id " +
                "WHERE a.id = ? AND a.user_id = ? AND a.status = 'DRAFT' " +
                "AND u.status = 'ACTIVE' AND role.name = 'CUSTOMER' FOR UPDATE";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Recalculates room count and guest capacity from persisted rooms. */
    private void updateApplicationCapacity(Connection connection, int applicationId)
            throws SQLException {
        String sql = "UPDATE host_applications SET " +
                "room_count = (SELECT COUNT(*) FROM partner_application_rooms WHERE application_id = ?), " +
                "max_guests = (SELECT COALESCE(SUM(max_guests), 0) " +
                "FROM partner_application_rooms WHERE application_id = ?) WHERE id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            statement.setInt(2, applicationId);
            statement.setInt(3, applicationId);
            statement.executeUpdate();
        }
    }

    private void insertAmenities(Connection connection, int roomId, List<String> amenities)
            throws SQLException {
        String sql = "INSERT INTO partner_application_room_amenities (room_id, amenity_name) " +
                "VALUES (?, ?)";
        Set<String> uniqueAmenities = new LinkedHashSet<>();
        for (String amenity : amenities) {
            if (amenity != null && !amenity.isBlank()) {
                uniqueAmenities.add(amenity.trim());
            }
        }
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            for (String amenity : uniqueAmenities) {
                statement.setInt(1, roomId);
                statement.setString(2, amenity);
                statement.addBatch();
            }
            statement.executeBatch();
        }
    }

    private void copyRoomChildren(Connection connection, int sourceRoomId, int targetRoomId)
            throws SQLException {
        try (PreparedStatement amenities = connection.prepareStatement(
                "INSERT INTO partner_application_room_amenities (room_id, amenity_name) " +
                        "SELECT ?, amenity_name FROM partner_application_room_amenities " +
                        "WHERE room_id = ?");
             PreparedStatement images = connection.prepareStatement(
                     "INSERT INTO partner_application_room_images " +
                             "(room_id, stored_name, media_type, content_type, sort_order) " +
                             "SELECT ?, stored_name, media_type, content_type, sort_order " +
                             "FROM partner_application_room_images WHERE room_id = ?")) {
            amenities.setInt(1, targetRoomId);
            amenities.setInt(2, sourceRoomId);
            amenities.executeUpdate();
            images.setInt(1, targetRoomId);
            images.setInt(2, sourceRoomId);
            images.executeUpdate();
        }
    }

    /** Loads room amenities and returns them in stable database order. */
    private List<String> findAmenities(Connection connection, int roomId) throws SQLException {
        List<String> amenities = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT amenity_name FROM partner_application_room_amenities " +
                        "WHERE room_id = ? ORDER BY amenity_name")) {
            statement.setInt(1, roomId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    amenities.add(resultSet.getString(1));
                }
            }
        }
        return amenities;
    }

    /** Loads room image metadata and returns it in display order. */
    private List<RoomImage> findImages(Connection connection, int roomId) throws SQLException {
        List<RoomImage> images = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT id, media_type, content_type, sort_order " +
                        "FROM partner_application_room_images " +
                        "WHERE room_id = ? ORDER BY sort_order, id")) {
            statement.setInt(1, roomId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    RoomImage image = new RoomImage();
                    image.setId(resultSet.getInt("id"));
                    image.setMediaType(resultSet.getString("media_type"));
                    image.setContentType(resultSet.getString("content_type"));
                    image.setSortOrder(resultSet.getInt("sort_order"));
                    images.add(image);
                }
            }
        }
        return images;
    }

    /** Maps one staged-media row into its model, including the creation timestamp. */
    private PartnerApplicationMedia mapStagedMedia(ResultSet resultSet) throws SQLException {
        PartnerApplicationMedia media = new PartnerApplicationMedia();
        media.setId(resultSet.getInt("id"));
        media.setApplicationId(resultSet.getInt("application_id"));
        media.setClientRoomKey(resultSet.getString("client_room_key"));
        media.setStoredName(resultSet.getString("stored_name"));
        media.setMediaType(resultSet.getString("media_type"));
        media.setContentType(resultSet.getString("content_type"));
        media.setSortOrder(resultSet.getInt("sort_order"));
        media.setCreatedAt(resultSet.getTimestamp("created_at"));
        return media;
    }

    private boolean isValidClientRoomKey(String clientRoomKey) {
        return clientRoomKey != null && clientRoomKey.matches("^[A-Za-z0-9_-]{1,64}$");
    }

    private boolean isValidMedia(String storedName, String mediaType, String contentType) {
        if (storedName == null || mediaType == null || contentType == null) {
            return false;
        }
        return switch (contentType) {
            case "image/jpeg" -> "IMAGE".equals(mediaType)
                    && storedName.matches("^[0-9a-f]{32}\\.jpg$");
            case "image/png" -> "IMAGE".equals(mediaType)
                    && storedName.matches("^[0-9a-f]{32}\\.png$");
            case "video/mp4" -> "VIDEO".equals(mediaType)
                    && storedName.matches("^[0-9a-f]{32}\\.mp4$");
            case "video/webm" -> "VIDEO".equals(mediaType)
                    && storedName.matches("^[0-9a-f]{32}\\.webm$");
            default -> false;
        };
    }

    /** Maps one room row into the application-room model. */
    private PartnerApplicationRoom mapRoom(ResultSet resultSet) throws SQLException {
        PartnerApplicationRoom room = new PartnerApplicationRoom();
        room.setId(resultSet.getInt("id"));
        room.setApplicationId(resultSet.getInt("application_id"));
        room.setRoomName(resultSet.getString("room_name"));
        room.setRoomType(resultSet.getString("room_type"));
        room.setPricePerNight(resultSet.getBigDecimal("price_per_night"));
        room.setMaxGuests(resultSet.getInt("max_guests"));
        room.setBedCount(resultSet.getInt("bed_count"));
        room.setBathroomCount(resultSet.getInt("bathroom_count"));
        room.setSortOrder(resultSet.getInt("sort_order"));
        return room;
    }



    private void bindRoom(PreparedStatement statement, PartnerApplicationRoom room)
            throws SQLException {
        bindRoom(statement, room, 1);
    }

    private void bindRoom(PreparedStatement statement, PartnerApplicationRoom room, int index)
            throws SQLException {
        statement.setString(index++, room.getRoomName().trim());
        statement.setString(index++, room.getRoomType());
        statement.setBigDecimal(index++, room.getPricePerNight());
        statement.setInt(index++, room.getMaxGuests());
        statement.setInt(index++, room.getBedCount());
        statement.setInt(index++, room.getBathroomCount());
        statement.setInt(index, room.getSortOrder());
    }
}
