package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.Property;
import com.homestay.model.Room;
import com.homestay.model.Room.RoomImage;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

public class PropertyDAO {

    public Optional<Property> findById(int propertyId) {
        String sql = """
                SELECT id, host_id, name, description, property_type,
                       address, city, country, status,
                       created_at, updated_at
                FROM properties
                WHERE id = ?
                """;

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, propertyId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapResultSetToProperty(resultSet));
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return Optional.empty();
    }

    public Optional<Property> findByIdAndHostId(
            int propertyId,
            int hostProfileId) {

        String sql = """
                SELECT id, host_id, name, description, property_type,
                       address, city, country, status,
                       created_at, updated_at
                FROM properties
                WHERE id = ?
                  AND host_id = ?
                """;

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, propertyId);
            statement.setInt(2, hostProfileId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapResultSetToProperty(resultSet));
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return Optional.empty();
    }

    public List<Property> findByHostId(int hostProfileId) {
        String sql = """
                SELECT id, host_id, name, description, property_type,
                       address, city, country, status,
                       created_at, updated_at
                FROM properties
                WHERE host_id = ?
                ORDER BY created_at DESC
                """;

        List<Property> properties = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, hostProfileId);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    properties.add(mapResultSetToProperty(resultSet));
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return properties;
    }

    public List<Property> findPublished() {
        String sql = """
                SELECT id, host_id, name, description, property_type,
                       address, city, country, status,
                       created_at, updated_at
                FROM properties
                WHERE status = 'PUBLISHED'
                ORDER BY created_at DESC
                """;

        List<Property> properties = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                properties.add(mapResultSetToProperty(resultSet));
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return properties;
    }

    public List<Property> findAll() {
        String sql = """
                SELECT id, host_id, name, description, property_type,
                       address, city, country, status,
                       created_at, updated_at
                FROM properties
                ORDER BY created_at DESC
                """;

        List<Property> properties = new ArrayList<>();

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                properties.add(mapResultSetToProperty(resultSet));
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return properties;
    }

    public int create(Property property) {
        String sql = """
                INSERT INTO properties
                    (host_id, name, description, property_type,
                     address, city, country, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     sql,
                     Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, property.getHostId());
            statement.setString(2, property.getName());
            statement.setString(3, property.getDescription());
            statement.setString(4, property.getPropertyType());
            statement.setString(5, property.getAddress());
            statement.setString(6, property.getCity());
            statement.setString(7, property.getCountry());
            statement.setString(
                    8,
                    property.getStatus() == null
                            ? "DRAFT"
                            : property.getStatus()
            );

            int affectedRows = statement.executeUpdate();

            if (affectedRows == 0) {
                return -1;
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return -1;
    }

    public boolean updateByHostId(Property property) {
        String sql = """
                UPDATE properties
                SET name = ?,
                    description = ?,
                    property_type = ?,
                    address = ?,
                    city = ?,
                    country = ?
                WHERE id = ?
                  AND host_id = ?
                """;

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, property.getName());
            statement.setString(2, property.getDescription());
            statement.setString(3, property.getPropertyType());
            statement.setString(4, property.getAddress());
            statement.setString(5, property.getCity());
            statement.setString(6, property.getCountry());
            statement.setInt(7, property.getId());
            statement.setInt(8, property.getHostId());

            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return false;
    }

    public boolean deleteByHostId(
            int propertyId,
            int hostProfileId) {

        String sql = """
                DELETE FROM properties
                WHERE id = ?
                  AND host_id = ?
                """;

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, propertyId);
            statement.setInt(2, hostProfileId);

            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return false;
    }

    public boolean updateStatus(
            int propertyId,
            String status) {

        String sql = """
                UPDATE properties
                SET status = ?
                WHERE id = ?
                """;

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, status);
            statement.setInt(2, propertyId);

            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return false;
    }

    private Property mapResultSetToProperty(ResultSet resultSet)
            throws SQLException {

        Property property = new Property();

        property.setId(resultSet.getInt("id"));
        property.setHostId(resultSet.getInt("host_id"));
        property.setName(resultSet.getString("name"));
        property.setDescription(
                resultSet.getString("description"));
        property.setPropertyType(
                resultSet.getString("property_type"));
        property.setAddress(resultSet.getString("address"));
        property.setCity(resultSet.getString("city"));
        property.setCountry(resultSet.getString("country"));
        property.setStatus(resultSet.getString("status"));
        property.setCreatedAt(
                resultSet.getTimestamp("created_at"));
        property.setUpdatedAt(
                resultSet.getTimestamp("updated_at"));

        return property;
    }

    /** Checks whether an active account has both the Host role and an approval record. */
    public boolean isApprovedHost(int userId) throws SQLException {
        String sql = "SELECT 1 FROM users u JOIN roles r ON r.id = u.role_id " +
                "WHERE u.id = ? AND u.status = 'ACTIVE' AND r.name = 'HOST' " +
                "AND EXISTS (SELECT 1 FROM host_applications a " +
                "WHERE a.user_id = u.id AND a.status = 'APPROVED') LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet results = statement.executeQuery()) {
                return results.next();
            }
        }
    }

    /** Loads a property only when the requested owner matches; returns {@code null} otherwise. */
    public Property findByIdAndOwner(int propertyId, int ownerId) throws SQLException {
        String sql = "SELECT id, owner_id, application_id, property_name, property_type, " +
                "description, address, city, district, ward, latitude, longitude, room_count, " +
                "max_guests, status, created_at, updated_at FROM properties " +
                "WHERE id = ? AND owner_id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, propertyId);
            statement.setInt(2, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                return results.next() ? mapProperty(results) : null;
            }
        }
    }

    /** Checks whether a property ID exists under a different Host. */
    public boolean belongsToAnotherHost(int propertyId, int ownerId) throws SQLException {
        return exists("SELECT 1 FROM properties WHERE id = ? AND owner_id <> ? LIMIT 1",
                propertyId, ownerId);
    }

    /** Validates and inserts an approved Host's property, returning its generated ID or zero. */
    public int create(int ownerId, Property property) throws SQLException {
        if (!isValidProperty(property)) {
            return 0;
        }
        String sql = "INSERT INTO properties (owner_id, application_id, property_name, " +
                "property_type, description, address, city, district, ward, latitude, longitude, " +
                "room_count, max_guests, status) " +
                "SELECT ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 'ACTIVE' " +
                "FROM users u JOIN roles r ON r.id = u.role_id " +
                "WHERE u.id = ? AND u.status = 'ACTIVE' AND r.name = 'HOST' " +
                "AND EXISTS (SELECT 1 FROM host_applications a " +
                "WHERE a.user_id = u.id AND a.status = 'APPROVED')";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, ownerId);
            bindProperty(statement, property, 2);
            statement.setInt(11, ownerId);
            if (statement.executeUpdate() != 1) {
                return 0;
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    /** Updates a valid property only when it belongs to the active approved Host. */
    public boolean update(int ownerId, int propertyId, Property property) throws SQLException {
        if (!isValidProperty(property)) {
            return false;
        }
        String sql = "UPDATE properties p JOIN users u ON u.id = p.owner_id " +
                "JOIN roles r ON r.id = u.role_id SET p.property_name = ?, p.property_type = ?, " +
                "p.description = ?, p.address = ?, p.city = ?, p.district = ?, p.ward = ?, " +
                "p.latitude = ?, p.longitude = ? WHERE p.id = ? AND p.owner_id = ? " +
                "AND u.status = 'ACTIVE' AND r.name = 'HOST' " +
                "AND EXISTS (SELECT 1 FROM host_applications a " +
                "WHERE a.user_id = u.id AND a.status = 'APPROVED')";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            bindProperty(statement, property, 1);
            statement.setInt(10, propertyId);
            statement.setInt(11, ownerId);
            return statement.executeUpdate() == 1;
        }
    }

    /** Deletes a property only when it belongs to the active approved Host. */
    public boolean delete(int ownerId, int propertyId) throws SQLException {
        String sql = "DELETE p FROM properties p JOIN users u ON u.id = p.owner_id " +
                "JOIN roles r ON r.id = u.role_id WHERE p.id = ? AND p.owner_id = ? " +
                "AND u.status = 'ACTIVE' AND r.name = 'HOST' " +
                "AND EXISTS (SELECT 1 FROM host_applications a " +
                "WHERE a.user_id = u.id AND a.status = 'APPROVED')";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, propertyId);
            statement.setInt(2, ownerId);
            return statement.executeUpdate() == 1;
        }
    }

    /** Creates a property and copies its rooms within the caller's approval transaction. */
    public int createFromApprovedApplication(Connection connection, int applicationId)
            throws SQLException {
        String insertPropertySql = "INSERT INTO properties " +
                "(owner_id, application_id, property_name, property_type, description, address, " +
                "city, district, ward, latitude, longitude, room_count, max_guests, status) " +
                "SELECT a.user_id, a.id, a.property_name, a.property_type, a.property_description, " +
                "a.property_address, a.property_city, a.property_district, a.property_ward, " +
                "a.latitude, a.longitude, a.room_count, a.max_guests, 'ACTIVE' " +
                "FROM host_applications a JOIN users u ON u.id = a.user_id " +
                "JOIN roles r ON r.id = u.role_id " +
                "WHERE a.id = ? AND a.status = 'PENDING' AND u.status = 'ACTIVE' AND r.name = 'HOST'";

        int propertyId;
        try (PreparedStatement statement = connection.prepareStatement(
                insertPropertySql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, applicationId);
            if (statement.executeUpdate() != 1) {
                throw new SQLException(
                        "The approved application could not be converted to a property.");
            }
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("The database did not return a property ID.");
                }
                propertyId = keys.getInt(1);
            }
        }

        // Copy the approved room inventory before returning the new property ID.
        copyRooms(connection, applicationId, propertyId);
        return propertyId;
    }

    /** Loads a Host's properties and their room details in newest-first order. */
    public List<Property> findByOwnerId(int ownerId) throws SQLException {
        String sql = "SELECT id, owner_id, application_id, property_name, property_type, " +
                "description, address, city, district, ward, latitude, longitude, room_count, " +
                "max_guests, status, created_at, updated_at FROM properties " +
                "WHERE owner_id = ? ORDER BY created_at DESC, id DESC";
        List<Property> properties = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                while (results.next()) {
                    properties.add(mapProperty(results));
                }
            }
        }
        for (Property property : properties) {
            property.setRooms(findRoomsByPropertyAndOwner(property.getId(), ownerId));
        }
        return properties;
    }

    /** Lists a property's rooms only when the specified Host owns the property. */
    public List<Room> findRoomsByPropertyAndOwner(int propertyId, int ownerId)
            throws SQLException {
        String sql = "SELECT r.id, r.property_id, r.room_name, r.room_type, r.price_per_night, " +
                "r.max_guests, r.bed_count, r.bathroom_count, r.sort_order " +
                "FROM rooms r JOIN properties p ON p.id = r.property_id " +
                "WHERE p.id = ? AND p.owner_id = ? ORDER BY r.sort_order, r.id";
        List<Room> rooms = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, propertyId);
            statement.setInt(2, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                while (results.next()) {
                    Room room = mapRoom(results);
                    room.setAmenities(findAmenities(connection, room.getId()));
                    room.setRoomImages(findImages(connection, room.getId()));
                    rooms.add(room);
                }
            }
        }
        return rooms;
    }

    /** Loads one room only when its parent property belongs to the specified Host. */
    public Room findRoomByIdAndOwner(int roomId, int ownerId) throws SQLException {
        String sql = "SELECT r.id, r.property_id, r.room_name, r.room_type, r.price_per_night, " +
                "r.max_guests, r.bed_count, r.bathroom_count, r.sort_order " +
                "FROM rooms r JOIN properties p ON p.id = r.property_id " +
                "WHERE r.id = ? AND p.owner_id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, roomId);
            statement.setInt(2, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                if (!results.next()) {
                    return null;
                }
                Room room = mapRoom(results);
                room.setAmenities(findAmenities(connection, roomId));
                room.setRoomImages(findImages(connection, roomId));
                return room;
            }
        }
    }

    /** Checks whether a room ID exists under another Host's property. */
    public boolean roomBelongsToAnotherHost(int roomId, int ownerId) throws SQLException {
        return exists("SELECT 1 FROM rooms r JOIN properties p ON p.id = r.property_id " +
                "WHERE r.id = ? AND p.owner_id <> ? LIMIT 1", roomId, ownerId);
    }

    /** Creates a validated owned room and saves its amenities in one transaction. */
    public int createRoom(int ownerId, int propertyId, Room room) throws SQLException {
        if (!isValidRoom(room)) {
            return 0;
        }
        // Lock the owned property so room creation and capacity updates stay consistent.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockOwnedProperty(connection, propertyId, ownerId)) {
                    connection.rollback();
                    return 0;
                }
                try (PreparedStatement count = connection.prepareStatement(
                        "SELECT COUNT(*) FROM rooms WHERE property_id = ?")) {
                    count.setInt(1, propertyId);
                    try (ResultSet results = count.executeQuery()) {
                        results.next();
                        if (results.getInt(1) >= 65535) {
                            connection.rollback();
                            return 0;
                        }
                    }
                }
                String sql = "INSERT INTO rooms (property_id, room_name, room_type, " +
                        "price_per_night, max_guests, bed_count, bathroom_count, sort_order) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(
                        sql, Statement.RETURN_GENERATED_KEYS)) {
                    statement.setInt(1, propertyId);
                    bindRoom(statement, room, 2);
                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return 0;
                    }
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("The database did not return a room ID.");
                        }
                        room.setId(keys.getInt(1));
                    }
                }
                saveAmenities(connection, room.getId(), room.getAmenities());
                updatePropertyCapacity(connection, propertyId);
                connection.commit();
                return room.getId();
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Updates an owned room and its amenities within one transaction. */
    public boolean updateRoom(int ownerId, int propertyId, int roomId, Room room)
            throws SQLException {
        if (!isValidRoom(room)) {
            return false;
        }
        // Keep the room update, amenity replacement, and capacity total in one transaction.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockOwnedProperty(connection, propertyId, ownerId)) {
                    connection.rollback();
                    return false;
                }
                String sql = "UPDATE rooms r JOIN properties p ON p.id = r.property_id " +
                        "SET r.room_name = ?, r.room_type = ?, r.price_per_night = ?, " +
                        "r.max_guests = ?, r.bed_count = ?, r.bathroom_count = ?, r.sort_order = ? " +
                        "WHERE r.id = ? AND r.property_id = ? AND p.owner_id = ?";
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    bindRoom(statement, room, 1);
                    statement.setInt(8, roomId);
                    statement.setInt(9, propertyId);
                    statement.setInt(10, ownerId);
                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }
                replaceAmenities(connection, roomId, room.getAmenities());
                updatePropertyCapacity(connection, propertyId);
                connection.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Deletes an owned room and refreshes property capacity in one transaction. */
    public boolean deleteRoom(int ownerId, int propertyId, int roomId) throws SQLException {
        // Keep deletion and derived property capacity synchronized if either step fails.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockOwnedProperty(connection, propertyId, ownerId)) {
                    connection.rollback();
                    return false;
                }
                String sql = "DELETE r FROM rooms r JOIN properties p ON p.id = r.property_id " +
                        "WHERE r.id = ? AND r.property_id = ? AND p.owner_id = ?";
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setInt(1, roomId);
                    statement.setInt(2, propertyId);
                    statement.setInt(3, ownerId);
                    if (statement.executeUpdate() != 1) {
                        connection.rollback();
                        return false;
                    }
                }
                updatePropertyCapacity(connection, propertyId);
                connection.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Returns a room image filename only after confirming Host ownership. */
    public String findRoomImagePath(int ownerId, int propertyId, int roomId, int imageId)
            throws SQLException {
        String sql = "SELECT i.stored_name FROM room_images i " +
                "JOIN rooms r ON r.id = i.room_id JOIN properties p ON p.id = r.property_id " +
                "WHERE i.id = ? AND r.id = ? AND p.id = ? AND p.owner_id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, imageId);
            statement.setInt(2, roomId);
            statement.setInt(3, propertyId);
            statement.setInt(4, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                return results.next() ? results.getString("stored_name") : null;
            }
        }
    }

    /** Checks whether an image ID belongs to a room under a different Host. */
    public boolean roomImageBelongsToAnotherHost(int imageId, int ownerId) throws SQLException {
        return exists("SELECT 1 FROM room_images i JOIN rooms r ON r.id = i.room_id " +
                "JOIN properties p ON p.id = r.property_id " +
                "WHERE i.id = ? AND p.owner_id <> ? LIMIT 1", imageId, ownerId);
    }

    /** Locks the active approved Host's property within a write transaction. */
    private boolean lockOwnedProperty(Connection connection, int propertyId, int ownerId)
            throws SQLException {
        String sql = "SELECT p.id FROM properties p JOIN users u ON u.id = p.owner_id " +
                "JOIN roles r ON r.id = u.role_id WHERE p.id = ? AND p.owner_id = ? " +
                "AND u.status = 'ACTIVE' AND r.name = 'HOST' " +
                "AND EXISTS (SELECT 1 FROM host_applications a " +
                "WHERE a.user_id = u.id AND a.status = 'APPROVED') FOR UPDATE";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, propertyId);
            statement.setInt(2, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                return results.next();
            }
        }
    }

    /** Recalculates room and guest totals using persisted room rows. */
    private void updatePropertyCapacity(Connection connection, int propertyId)
            throws SQLException {
        String capacitySql = "SELECT COALESCE(SUM(max_guests), 0) FROM rooms WHERE property_id = ?";
        try (PreparedStatement statement = connection.prepareStatement(capacitySql)) {
            statement.setInt(1, propertyId);
            try (ResultSet results = statement.executeQuery()) {
                results.next();
                if (results.getLong(1) > 65535) {
                    throw new IllegalArgumentException(
                            "The property guest capacity exceeds the supported limit.");
                }
            }
        }
        String sql = "UPDATE properties SET " +
                "room_count = (SELECT COUNT(*) FROM rooms WHERE property_id = ?), " +
                "max_guests = (SELECT COALESCE(SUM(max_guests), 0) FROM rooms " +
                "WHERE property_id = ?) WHERE id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, propertyId);
            statement.setInt(2, propertyId);
            statement.setInt(3, propertyId);
            statement.executeUpdate();
        }
    }

    private void saveAmenities(Connection connection, int roomId, List<String> amenities)
            throws SQLException {
        String sql = "INSERT INTO room_amenities (room_id, amenity_name) VALUES (?, ?)";
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

    private void replaceAmenities(Connection connection, int roomId, List<String> amenities)
            throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "DELETE FROM room_amenities WHERE room_id = ?")) {
            statement.setInt(1, roomId);
            statement.executeUpdate();
        }
        saveAmenities(connection, roomId, amenities);
    }

    private boolean exists(String sql, int resourceId, int ownerId) throws SQLException {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, resourceId);
            statement.setInt(2, ownerId);
            try (ResultSet results = statement.executeQuery()) {
                return results.next();
            }
        }
    }

    /** Checks property fields and coordinate ranges before SQL persistence. */
    private boolean isValidProperty(Property property) {
        if (property == null || !hasText(property.getPropertyName())
                || property.getPropertyName().trim().length() > 150
                || !hasText(property.getPropertyType())
                || !property.getPropertyType().matches("Homestay|Apartment|Villa|Hotel|Guesthouse")
                || !hasText(property.getDescription()) || property.getDescription().length() > 5000
                || !hasText(property.getAddress()) || property.getAddress().length() > 255
                || !hasText(property.getCity()) || property.getCity().length() > 100
                || !hasText(property.getDistrict()) || property.getDistrict().length() > 100
                || !hasText(property.getWard()) || property.getWard().length() > 100) {
            return false;
        }
        Double latitude = property.getLatitude();
        Double longitude = property.getLongitude();
        return (latitude == null) == (longitude == null)
                && (latitude == null || Double.isFinite(latitude) && Double.isFinite(longitude)
                && latitude >= -90 && latitude <= 90
                && longitude >= -180 && longitude <= 180);
    }

    /** Checks room fields, price, capacity, and amenities before SQL persistence. */
    private boolean isValidRoom(Room room) {
        return room != null && hasText(room.getRoomName())
                && room.getRoomName().trim().length() <= 120
                && room.getRoomTypeName() != null
                && room.getRoomTypeName().matches("SINGLE|DOUBLE|TWIN|FAMILY|SUITE|OTHER")
                && room.getPricePerNight() != null
                && room.getPricePerNight().compareTo(BigDecimal.ZERO) > 0
                && room.getPricePerNight().scale() <= 2
                && room.getPricePerNight().compareTo(new BigDecimal("99999999.99")) <= 0
                && room.getMaxGuests() > 0 && room.getMaxGuests() <= 65535
                && room.getBedCount() > 0 && room.getBedCount() <= 65535
                && room.getBathroomCount() > 0 && room.getBathroomCount() <= 65535
                && room.getSortOrder() >= 0 && room.getSortOrder() <= 65535
                && room.getAmenities() != null && room.getAmenities().size() <= 30
                && room.getAmenities().stream().allMatch(
                amenity -> amenity != null && amenity.trim().length() <= 80);
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private void bindProperty(PreparedStatement statement, Property property, int index)
            throws SQLException {
        statement.setString(index++, property.getPropertyName().trim());
        statement.setString(index++, property.getPropertyType());
        statement.setString(index++, property.getDescription().trim());
        statement.setString(index++, property.getAddress().trim());
        statement.setString(index++, property.getCity().trim());
        statement.setString(index++, property.getDistrict().trim());
        statement.setString(index++, property.getWard().trim());
        if (property.getLatitude() == null) {
            statement.setNull(index++, java.sql.Types.DECIMAL);
            statement.setNull(index, java.sql.Types.DECIMAL);
        } else {
            statement.setDouble(index++, property.getLatitude());
            statement.setDouble(index, property.getLongitude());
        }
    }

    private void bindRoom(PreparedStatement statement, Room room, int index)
            throws SQLException {
        statement.setString(index++, room.getRoomName().trim());
        statement.setString(index++, room.getRoomTypeName());
        statement.setBigDecimal(index++, room.getPricePerNight());
        statement.setInt(index++, room.getMaxGuests());
        statement.setInt(index++, room.getBedCount());
        statement.setInt(index++, room.getBathroomCount());
        statement.setInt(index, room.getSortOrder());
    }

    /** Copies each approved application room and its child details into a property. */
    private void copyRooms(Connection connection, int applicationId, int propertyId)
            throws SQLException {
        String selectSql = "SELECT id, room_name, room_type, price_per_night, max_guests, " +
                "bed_count, bathroom_count, sort_order FROM partner_application_rooms " +
                "WHERE application_id = ? ORDER BY sort_order, id";
        String insertSql = "INSERT INTO rooms (property_id, room_name, room_type, " +
                "price_per_night, max_guests, bed_count, bathroom_count, sort_order) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement select = connection.prepareStatement(selectSql);
             PreparedStatement insert = connection.prepareStatement(
                     insertSql, Statement.RETURN_GENERATED_KEYS)) {
            select.setInt(1, applicationId);
            try (ResultSet sourceRooms = select.executeQuery()) {
                int roomCount = 0;
                while (sourceRooms.next()) {
                    insert.setInt(1, propertyId);
                    insert.setString(2, sourceRooms.getString("room_name"));
                    insert.setString(3, sourceRooms.getString("room_type"));
                    insert.setBigDecimal(4, sourceRooms.getBigDecimal("price_per_night"));
                    insert.setInt(5, sourceRooms.getInt("max_guests"));
                    insert.setInt(6, sourceRooms.getInt("bed_count"));
                    insert.setInt(7, sourceRooms.getInt("bathroom_count"));
                    insert.setInt(8, sourceRooms.getInt("sort_order"));
                    if (insert.executeUpdate() != 1) {
                        throw new SQLException("An approved application room could not be copied.");
                    }

                    int roomId;
                    try (ResultSet keys = insert.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("The database did not return a room ID.");
                        }
                        roomId = keys.getInt(1);
                    }
                    copyRoomDetails(connection, sourceRooms.getInt("id"), roomId);
                    roomCount++;
                }
                if (roomCount == 0) {
                    throw new SQLException("An approved property must contain at least one room.");
                }
            }
        }
    }

    private void copyRoomDetails(Connection connection, int sourceRoomId, int roomId)
            throws SQLException {
        String amenitiesSql = "INSERT INTO room_amenities (room_id, amenity_name) " +
                "SELECT ?, amenity_name FROM partner_application_room_amenities WHERE room_id = ?";
        String imagesSql = "INSERT INTO room_images " +
                "(room_id, stored_name, media_type, content_type, sort_order) " +
                "SELECT ?, stored_name, media_type, content_type, sort_order " +
                "FROM partner_application_room_images WHERE room_id = ?";
        try (PreparedStatement amenities = connection.prepareStatement(amenitiesSql);
             PreparedStatement images = connection.prepareStatement(imagesSql)) {
            amenities.setInt(1, roomId);
            amenities.setInt(2, sourceRoomId);
            amenities.executeUpdate();
            images.setInt(1, roomId);
            images.setInt(2, sourceRoomId);
            images.executeUpdate();
        }
    }

    private List<String> findAmenities(Connection connection, int roomId) throws SQLException {
        List<String> amenities = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT amenity_name FROM room_amenities WHERE room_id = ? ORDER BY amenity_name")) {
            statement.setInt(1, roomId);
            try (ResultSet results = statement.executeQuery()) {
                while (results.next()) {
                    amenities.add(results.getString("amenity_name"));
                }
            }
        }
        return amenities;
    }

    private List<RoomImage> findImages(Connection connection, int roomId) throws SQLException {
        List<RoomImage> images = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT id, stored_name, media_type, content_type, sort_order FROM room_images " +
                        "WHERE room_id = ? ORDER BY sort_order, id")) {
            statement.setInt(1, roomId);
            try (ResultSet results = statement.executeQuery()) {
                while (results.next()) {
                    RoomImage image = new RoomImage();
                    image.setId(results.getInt("id"));
                    image.setStoredName(results.getString("stored_name"));
                    image.setMediaType(results.getString("media_type"));
                    image.setContentType(results.getString("content_type"));
                    image.setSortOrder(results.getInt("sort_order"));
                    images.add(image);
                }
            }
        }
        return images;
    }

    /** Maps one property query row into the property model. */
    private Property mapProperty(ResultSet results) throws SQLException {
        Property property = new Property();
        property.setId(results.getInt("id"));
        property.setOwnerId(results.getInt("owner_id"));
        property.setApplicationId(results.getInt("application_id"));
        property.setPropertyName(results.getString("property_name"));
        property.setPropertyType(results.getString("property_type"));
        property.setDescription(results.getString("description"));
        property.setAddress(results.getString("address"));
        property.setCity(results.getString("city"));
        property.setDistrict(results.getString("district"));
        property.setWard(results.getString("ward"));
        double latitude = results.getDouble("latitude");
        property.setLatitude(results.wasNull() ? null : latitude);
        double longitude = results.getDouble("longitude");
        property.setLongitude(results.wasNull() ? null : longitude);
        property.setRoomCount(results.getInt("room_count"));
        property.setMaxGuests(results.getInt("max_guests"));
        property.setStatus(Property.Status.valueOf(results.getString("status")));
        property.setCreatedAt(results.getTimestamp("created_at"));
        property.setUpdatedAt(results.getTimestamp("updated_at"));
        return property;
    }

    /** Maps one room query row into the room model. */
    private Room mapRoom(ResultSet results) throws SQLException {
        Room room = new Room();
        room.setId(results.getInt("id"));
        room.setPropertyId(results.getInt("property_id"));
        room.setRoomName(results.getString("room_name"));
        room.setRoomType(results.getString("room_type"));
        room.setPricePerNight(results.getBigDecimal("price_per_night"));
        room.setMaxGuests(results.getInt("max_guests"));
        room.setBedCount(results.getInt("bed_count"));
        room.setBathroomCount(results.getInt("bathroom_count"));
        room.setSortOrder(results.getInt("sort_order"));
        return room;
    }
}
