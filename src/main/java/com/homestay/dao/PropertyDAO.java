package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.Property;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

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
}