package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.HostProfile;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class HostProfileDAO {

    public Optional<HostProfile> findById(int id) {
        String sql = """
                SELECT id, user_id, business_name, business_type,
                       phone, verification_status, rejection_reason,
                       created_at, updated_at
                FROM host_profiles
                WHERE id = ?
                """;

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapResultSetToHostProfile(resultSet));
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return Optional.empty();
    }

    public Optional<HostProfile> findByUserId(int userId) {
        String sql = """
                SELECT id, user_id, business_name, business_type,
                       phone, verification_status, rejection_reason,
                       created_at, updated_at
                FROM host_profiles
                WHERE user_id = ?
                """;

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapResultSetToHostProfile(resultSet));
                }
            }
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return Optional.empty();
    }

    public int create(HostProfile hostProfile) {
        String sql = """
                INSERT INTO host_profiles
                    (user_id, business_name, business_type, phone,
                     verification_status)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(
                sql,
                Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, hostProfile.getUserId());
            statement.setString(2, hostProfile.getBusinessName());
            statement.setString(3, hostProfile.getBusinessType());
            statement.setString(4, hostProfile.getPhone());
            statement.setString(
                    5,
                    hostProfile.getVerificationStatus() == null
                    ? "PENDING"
                    : hostProfile.getVerificationStatus()
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

    public boolean updateBasicInfo(HostProfile hostProfile) {
        String sql = """
                UPDATE host_profiles
                SET business_name = ?,
                    business_type = ?,
                    phone = ?
                WHERE id = ?
                """;

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, hostProfile.getBusinessName());
            statement.setString(2, hostProfile.getBusinessType());
            statement.setString(3, hostProfile.getPhone());
            statement.setInt(4, hostProfile.getId());

            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return false;
    }

    public boolean updateVerificationStatus(
            int profileId,
            String verificationStatus,
            String rejectionReason) {

        String sql = """
                UPDATE host_profiles
                SET verification_status = ?,
                    rejection_reason = ?
                WHERE id = ?
                """;

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, verificationStatus);
            statement.setString(2, rejectionReason);
            statement.setInt(3, profileId);

            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return false;
    }

    private HostProfile mapResultSetToHostProfile(ResultSet resultSet)
            throws SQLException {

        HostProfile hostProfile = new HostProfile();

        hostProfile.setId(resultSet.getInt("id"));
        hostProfile.setUserId(resultSet.getInt("user_id"));
        hostProfile.setBusinessName(
                resultSet.getString("business_name"));
        hostProfile.setBusinessType(
                resultSet.getString("business_type"));
        hostProfile.setPhone(
                resultSet.getString("phone"));
        hostProfile.setVerificationStatus(
                resultSet.getString("verification_status"));
        hostProfile.setRejectionReason(
                resultSet.getString("rejection_reason"));
        hostProfile.setCreatedAt(
                resultSet.getTimestamp("created_at"));
        hostProfile.setUpdatedAt(
                resultSet.getTimestamp("updated_at"));

        return hostProfile;
    }

    /*
    Admin duyệt thì cần thực hiện hai thao tác trong một transaction:
    1. host_profiles.verification_status = APPROVED
    2. users.role_id = ID của ROLE_HOST
     */
    public boolean approveAndAssignHostRole(
            int hostProfileId,
            int hostUserId,
            int hostRoleId) {

        String updateProfileSql = """
            UPDATE host_profiles
            SET verification_status = 'APPROVED',
                rejection_reason = NULL
            WHERE id = ?
              AND user_id = ?
            """;

        String updateUserRoleSql = """
            UPDATE users
            SET role_id = ?
            WHERE id = ?
            """;

        Connection connection = null;

        try {
            connection = DBContext.getConnection();
            connection.setAutoCommit(false);

            try (PreparedStatement profileStatement
                    = connection.prepareStatement(updateProfileSql); PreparedStatement userStatement
                    = connection.prepareStatement(updateUserRoleSql)) {

                profileStatement.setInt(1, hostProfileId);
                profileStatement.setInt(2, hostUserId);

                int profileRows
                        = profileStatement.executeUpdate();

                if (profileRows != 1) {
                    connection.rollback();
                    return false;
                }

                userStatement.setInt(1, hostRoleId);
                userStatement.setInt(2, hostUserId);

                int userRows
                        = userStatement.executeUpdate();

                if (userRows != 1) {
                    connection.rollback();
                    return false;
                }

                connection.commit();
                return true;

            } catch (SQLException exception) {
                if (connection != null) {
                    connection.rollback();
                }
                exception.printStackTrace();
                return false;
            } finally {
                if (connection != null) {
                    connection.setAutoCommit(true);
                    connection.close();
                }
            }

        } catch (SQLException exception) {
            exception.printStackTrace();
            return false;
        }
    }

    // lấy tất cả hồ sơ đang chờ admin duyệt 
    public List<HostProfile> findPendingProfiles() {
        String sql = """
            SELECT id, user_id, business_name, business_type,
                   phone, verification_status, rejection_reason,
                   created_at, updated_at
            FROM host_profiles
            WHERE verification_status = 'PENDING'
            ORDER BY created_at ASC
            """;

        List<HostProfile> profiles = new ArrayList<>();

        try (Connection connection = DBContext.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql); ResultSet resultSet
                = statement.executeQuery()) {

            while (resultSet.next()) {
                profiles.add(
                        mapResultSetToHostProfile(resultSet)
                );
            }

        } catch (SQLException exception) {
            exception.printStackTrace();
        }

        return profiles;
    }
}
