package com.homestay.dao;

import com.homestay.context.DBContext;
import com.homestay.model.HostApplication;
import com.homestay.model.HostApplication.DocumentStatus;
import com.homestay.model.HostApplication.IdentificationType;
import com.homestay.model.HostApplication.Status;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/** Persists Host applications and enforces application state and review rules. */
public class HostApplicationDAO {
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[0-9+() .-]{7,30}$");

    private static final String APPLICATION_COLUMNS =
            "id, user_id, application_note, status, submitted_at, reviewed_by, reviewed_at, " +
                    "rejection_reason, applicant_name, applicant_email, applicant_phone, " +
                    "identification_type, identification_number, property_name, property_type, " +
                    "property_description, property_address, property_city, property_district, " +
                    "property_ward, latitude, longitude, room_count, max_guests, " +
                    "identity_document_url, ownership_document_url, business_document_url, " +
                    "document_status, supersedes_application_id";

    private static final String APPLICATION_FIELDS =
            "application_note = ?, applicant_name = ?, applicant_email = ?, applicant_phone = ?, " +
                    "identification_type = ?, identification_number = ?, property_name = ?, " +
                    "property_type = ?, property_description = ?, property_address = ?, " +
                    "property_city = ?, property_district = ?, property_ward = ?, latitude = ?, " +
                    "longitude = ?, room_count = ?, max_guests = ?, identity_document_url = ?, " +
                    "ownership_document_url = ?, business_document_url = ?, document_status = ?";

    private final PropertyDAO propertyDAO = new PropertyDAO();

    /** Loads the latest application for a user ID, or returns {@code null} when none exists. */
    public HostApplication findLatestByUserId(int userId) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.application_note, a.status, a.submitted_at, " +
                "a.reviewed_by, a.reviewed_at, a.rejection_reason, a.applicant_name, " +
                "a.applicant_email, a.applicant_phone, a.identification_type, " +
                "a.identification_number, a.property_name, a.property_type, a.property_description, " +
                "a.property_address, a.property_city, a.property_district, a.property_ward, " +
                "a.latitude, a.longitude, a.room_count, a.max_guests, a.identity_document_url, " +
                "a.ownership_document_url, a.business_document_url, a.document_status, " +
                "a.supersedes_application_id, " +
                "COALESCE(NULLIF(reviewer.display_name, ''), reviewer.username) AS reviewer_name " +
                "FROM host_applications a LEFT JOIN users reviewer ON reviewer.id = a.reviewed_by " +
                "WHERE a.user_id = ? ORDER BY a.id DESC LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                HostApplication application = mapApplication(resultSet);
                application.setReviewerName(resultSet.getString("reviewer_name"));
                return application;
            }
        }
    }

    /** Loads an application by ID, or returns {@code null} when it is missing. */
    public HostApplication findById(int applicationId) throws SQLException {
        String sql = "SELECT " + APPLICATION_COLUMNS +
                " FROM host_applications WHERE id = ? LIMIT 1";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? mapApplication(resultSet) : null;
            }
        }
    }

    /** Loads an application and reviewer display name for an administrator. */
    public HostApplication findForAdmin(int applicationId) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.application_note, a.status, a.submitted_at, " +
                "a.reviewed_by, a.reviewed_at, a.rejection_reason, a.applicant_name, " +
                "a.applicant_email, a.applicant_phone, a.identification_type, " +
                "a.identification_number, a.property_name, a.property_type, a.property_description, " +
                "a.property_address, a.property_city, a.property_district, a.property_ward, " +
                "a.latitude, a.longitude, a.room_count, a.max_guests, a.identity_document_url, " +
                "a.ownership_document_url, a.business_document_url, a.document_status, " +
                "a.supersedes_application_id, " +
                "COALESCE(NULLIF(reviewer.display_name, ''), reviewer.username) AS reviewer_name " +
                "FROM host_applications a LEFT JOIN users reviewer ON reviewer.id = a.reviewed_by " +
                "WHERE a.id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                HostApplication application = mapApplication(resultSet);
                application.setReviewerName(resultSet.getString("reviewer_name"));
                return application;
            }
        }
    }

    /** Lists applications matching a status, or all non-draft applications when absent. */
    public List<HostApplication> findApplications(Status status) throws SQLException {
        String sql = "SELECT a.id, a.user_id, a.application_note, a.status, a.submitted_at, " +
                "a.reviewed_by, a.reviewed_at, a.rejection_reason, a.applicant_name, " +
                "a.applicant_email, a.applicant_phone, a.identification_type, " +
                "a.identification_number, a.property_name, a.property_type, a.property_description, " +
                "a.property_address, a.property_city, a.property_district, a.property_ward, " +
                "a.latitude, a.longitude, a.room_count, a.max_guests, a.identity_document_url, " +
                "a.ownership_document_url, a.business_document_url, a.document_status, " +
                "a.supersedes_application_id, " +
                "COALESCE(NULLIF(reviewer.display_name, ''), reviewer.username) AS reviewer_name " +
                "FROM host_applications a LEFT JOIN users reviewer ON reviewer.id = a.reviewed_by " +
                (status == null ? "WHERE a.status <> 'DRAFT' " : "WHERE a.status = ? ") +
                "ORDER BY a.id DESC";
        List<HostApplication> applications = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            if (status != null) {
                statement.setString(1, status.name());
            }
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    HostApplication application = mapApplication(resultSet);
                    application.setReviewerName(resultSet.getString("reviewer_name"));
                    applications.add(application);
                }
            }
        }
        return applications;
    }

    /** Checks whether the active customer identified by {@code userId} may apply. */
    public boolean canApply(int userId) throws SQLException {
        String sql = "SELECT 1 FROM users u JOIN roles r ON r.id = u.role_id " +
                "WHERE u.id = ? AND u.status = 'ACTIVE' AND r.name = 'CUSTOMER' " +
                "AND NOT EXISTS (SELECT 1 FROM host_applications a WHERE a.user_id = u.id " +
                "AND a.status IN ('PENDING', 'APPROVED'))";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Saves an eligible customer's draft and returns whether the transaction succeeded. */
    public boolean saveDraft(HostApplication application) throws SQLException {
        if (!isValidDraft(application)) {
            return false;
        }

        // Keep eligibility, state checks, updates, and copied content in one transaction.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                // Lock the customer row so concurrent submissions cannot create multiple active applications.
                if (!lockEligibleCustomer(connection, application.getUserId())) {
                    connection.rollback();
                    return false;
                }

                ApplicationState existing = findLatestState(connection, application.getUserId());
                if (existing != null && (existing.status == Status.PENDING
                        || existing.status == Status.APPROVED)) {
                    connection.rollback();
                    return false;
                }
                if (existing != null && existing.status == Status.DRAFT
                        && application.getId() > 0 && existing.id != application.getId()) {
                    connection.rollback();
                    return false;
                }
                if (existing == null && application.getId() > 0
                        || existing != null && existing.status == Status.REJECTED
                        && application.getId() > 0 && application.getId() != existing.id) {
                    connection.rollback();
                    return false;
                }

                loadApplicantSnapshot(connection, application);
                application.setStatus(Status.DRAFT);
                application.setDocumentStatus(DocumentStatus.PENDING);
                if (existing != null && existing.status == Status.DRAFT) {
                    application.setId(existing.id);
                    application.setSupersedesApplicationId(existing.supersedesApplicationId);
                    updateApplication(connection, application, Status.DRAFT, null);
                } else {
                    application.setSupersedesApplicationId(
                            existing != null && existing.status == Status.REJECTED ? existing.id : null);
                    insertApplication(connection, application, null);
                    if (existing != null && existing.status == Status.REJECTED) {
                        // Keep the rejected record intact while carrying its content into a new draft.
                        copyRejectedDocuments(connection, existing.id, application.getId());
                        new PartnerApplicationRoomDAO().copyRooms(
                                connection, existing.id, application.getId());
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

    /** Validates and submits the current draft for review; returns whether it was accepted. */
    public boolean submitApplication(HostApplication application) throws SQLException {
        if (!isValidSubmission(application)) {
            return false;
        }

        // Lock and recheck the draft while calculating capacity to prevent stale submissions.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!lockEligibleCustomer(connection, application.getUserId())) {
                    connection.rollback();
                    return false;
                }

                ApplicationState existing = findLatestState(connection, application.getUserId());
                if (application.getId() <= 0 || existing == null
                        || existing.id != application.getId() || existing.status != Status.DRAFT) {
                    connection.rollback();
                    return false;
                }

                loadApplicantSnapshot(connection, application);
                if (!hasText(application.getApplicantName())
                        || !hasText(application.getApplicantEmail())
                        || !EMAIL_PATTERN.matcher(application.getApplicantEmail()).matches()
                        || !hasText(application.getApplicantPhone())
                        || !PHONE_PATTERN.matcher(application.getApplicantPhone()).matches()) {
                    connection.rollback();
                    return false;
                }
                // Derive the submitted capacity from persisted draft rooms rather than form input.
                int roomCount;
                int maxGuests;
                try (PreparedStatement statement = connection.prepareStatement(
                        "SELECT COUNT(*) AS room_count, COALESCE(SUM(max_guests), 0) AS max_guests " +
                                "FROM partner_application_rooms WHERE application_id = ?")) {
                    statement.setInt(1, application.getId());
                    try (ResultSet resultSet = statement.executeQuery()) {
                        resultSet.next();
                        roomCount = resultSet.getInt("room_count");
                        maxGuests = resultSet.getInt("max_guests");
                    }
                }
                if (roomCount < 1 || roomCount > 20 || maxGuests < 1 || maxGuests > 65535) {
                    connection.rollback();
                    return false;
                }
                application.setRoomCount(roomCount);
                application.setMaxGuests(maxGuests);
                application.setStatus(Status.PENDING);
                application.setDocumentStatus(DocumentStatus.PENDING);
                application.setSubmittedAt(new Timestamp(System.currentTimeMillis()));
                updateApplication(connection, application, Status.PENDING,
                        application.getSubmittedAt());
                connection.commit();
                return true;
            } catch (SQLException | RuntimeException e) {
                connection.rollback();
                throw e;
            }
        }
    }

    /** Submits the user's latest draft with a validated note, or returns {@code null}. */
    public HostApplication submit(int userId, String applicationNote) throws SQLException {
        if (applicationNote == null || applicationNote.isBlank()
                || applicationNote.length() > 1000) {
            return null;
        }

        HostApplication application = findLatestByUserId(userId);
        if (application == null) {
            return null;
        }
        application.setApplicationNote(applicationNote.trim());
        return submitApplication(application) ? application : null;
    }

    /** Returns the current applications awaiting administrator review. */
    public List<HostApplication> findPendingApplications() throws SQLException {
        return findApplications(Status.PENDING);
    }

    /** Updates one supported document reference on the user's editable draft. */
    public boolean updateDocument(int userId, int applicationId, String documentType,
                                  String storedPath) throws SQLException {
        String column = switch (documentType) {
            case "identity" -> "identity_document_url";
            case "ownership" -> "ownership_document_url";
            case "business" -> "business_document_url";
            default -> null;
        };
        if (column == null || storedPath == null
                || !storedPath.matches("^[0-9a-f]{32}\\.(pdf|png|jpg)$")) {
            return false;
        }

        String sql = "UPDATE host_applications a JOIN users u ON u.id = a.user_id " +
                "JOIN roles r ON r.id = u.role_id SET a." + column + " = ?, " +
                "a.document_status = 'PENDING' WHERE a.id = ? AND a.user_id = ? " +
                "AND a.status = 'DRAFT' AND u.status = 'ACTIVE' AND r.name = 'CUSTOMER'";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, storedPath);
            statement.setInt(2, applicationId);
            statement.setInt(3, userId);
            return statement.executeUpdate() == 1;
        }
    }

    /** Clears one supported document reference from the user's editable draft. */
    public boolean removeDocument(int userId, int applicationId, String documentType)
            throws SQLException {
        String column = switch (documentType) {
            case "identity" -> "identity_document_url";
            case "ownership" -> "ownership_document_url";
            case "business" -> "business_document_url";
            default -> null;
        };
        if (column == null) {
            return false;
        }
        String sql = "UPDATE host_applications a JOIN users u ON u.id = a.user_id " +
                "JOIN roles r ON r.id = u.role_id SET a." + column +
                " = NULL, a.document_status = 'PENDING' WHERE a.id = ? AND a.user_id = ? " +
                "AND a.status = 'DRAFT' AND u.status = 'ACTIVE' AND r.name = 'CUSTOMER'";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            statement.setInt(2, userId);
            return statement.executeUpdate() == 1;
        }
    }

    /** Returns a stored document reference for an allowed type, or {@code null}. */
    public String findDocumentPath(int applicationId, String documentType) throws SQLException {
        String column = switch (documentType) {
            case "identity" -> "identity_document_url";
            case "ownership" -> "ownership_document_url";
            case "business" -> "business_document_url";
            default -> null;
        };
        if (column == null) {
            return null;
        }
        String sql = "SELECT " + column + " FROM host_applications WHERE id = ? LIMIT 1";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, applicationId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getString(1) : null;
            }
        }
    }

    /** Reviews a pending application and applies the approved or rejected state transition. */
    public boolean review(int applicationId, int adminUserId, Status decision,
                          String rejectionReason) throws SQLException {
        if (applicationId <= 0 || decision != Status.APPROVED && decision != Status.REJECTED
                || decision == Status.REJECTED && (rejectionReason == null
                || rejectionReason.trim().length() < 10 || rejectionReason.trim().length() > 500)) {
            return false;
        }

        String adminSql = "SELECT r.name, u.status FROM users u " +
                "JOIN roles r ON r.id = u.role_id WHERE u.id = ? FOR UPDATE";
        String applicationSql = "SELECT user_id, applicant_name, applicant_email, applicant_phone, " +
                "identification_type, identification_number, property_name, property_type, " +
                "property_description, property_address, property_city, property_district, property_ward, " +
                "room_count, max_guests, identity_document_url, ownership_document_url " +
                "FROM host_applications WHERE id = ? AND status = 'PENDING' FOR UPDATE";
        String promoteSql = "UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'HOST') " +
                "WHERE id = ? AND role_id = (SELECT id FROM roles WHERE name = 'CUSTOMER') " +
                "AND status = 'ACTIVE'";
        String addHostRoleSql = "INSERT INTO userroles (user_id, role_id) " +
                "SELECT ?, id FROM roles WHERE name = 'HOST' " +
                "ON DUPLICATE KEY UPDATE role_id = role_id";
        String updateSql = "UPDATE host_applications SET status = ?, reviewed_by = ?, " +
                "reviewed_at = CURRENT_TIMESTAMP, rejection_reason = ?, document_status = ? " +
                "WHERE id = ? AND status = 'PENDING'";

        // Change application status, role, and generated property data atomically.
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            try {
                if (!isActiveAdmin(connection, adminSql, adminUserId)) {
                    connection.rollback();
                    return false;
                }

                int applicantId;
                try (PreparedStatement statement = connection.prepareStatement(applicationSql)) {
                    statement.setInt(1, applicationId);
                    try (ResultSet resultSet = statement.executeQuery()) {
                        if (!resultSet.next()) {
                            connection.rollback();
                            return false;
                        }
                        if (decision == Status.APPROVED && !isReviewableApplication(resultSet)) {
                            connection.rollback();
                            return false;
                        }
                        applicantId = resultSet.getInt("user_id");
                    }
                }

                if (decision == Status.APPROVED) {
                    try (PreparedStatement statement = connection.prepareStatement(promoteSql)) {
                        statement.setInt(1, applicantId);
                        if (statement.executeUpdate() != 1) {
                            connection.rollback();
                            return false;
                        }
                    }
                    try (PreparedStatement roleStatement = connection.prepareStatement(addHostRoleSql)) {
                        roleStatement.setInt(1, applicantId);
                        roleStatement.executeUpdate();
                    }
                    propertyDAO.createFromApprovedApplication(connection, applicationId);
                }

                try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                    statement.setString(1, decision.name());
                    statement.setInt(2, adminUserId);
                    statement.setString(3, decision == Status.REJECTED
                            ? rejectionReason.trim() : null);
                    statement.setString(4, decision == Status.APPROVED
                            ? DocumentStatus.VERIFIED.name() : DocumentStatus.REJECTED.name());
                    statement.setInt(5, applicationId);
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

    private boolean lockEligibleCustomer(Connection connection, int userId) throws SQLException {
        String sql = "SELECT r.name, u.status " +
                "FROM users u JOIN roles r ON r.id = u.role_id WHERE u.id = ? FOR UPDATE";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() && "ACTIVE".equals(resultSet.getString("status"))
                        && "CUSTOMER".equals(resultSet.getString("name"));
            }
        }
    }

    private void loadApplicantSnapshot(Connection connection, HostApplication application)
            throws SQLException {
        String sql = "SELECT COALESCE(NULLIF(display_name, ''), username) AS applicant_name, " +
                "email, phone FROM users WHERE id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, application.getUserId());
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    throw new SQLException("The applicant account no longer exists.");
                }
                if (!hasText(application.getApplicantName())) {
                    application.setApplicantName(resultSet.getString("applicant_name"));
                }
                if (!hasText(application.getApplicantEmail())) {
                    application.setApplicantEmail(resultSet.getString("email"));
                }
                if (!hasText(application.getApplicantPhone())) {
                    application.setApplicantPhone(resultSet.getString("phone"));
                }
            }
        }
    }

    private ApplicationState findLatestState(Connection connection, int userId) throws SQLException {
        String sql = "SELECT id, status, supersedes_application_id FROM host_applications " +
                "WHERE user_id = ? " +
                "ORDER BY CASE WHEN status IN ('DRAFT', 'PENDING', 'APPROVED') THEN 0 ELSE 1 END, " +
                "id DESC LIMIT 1 FOR UPDATE";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }
                int previousId = resultSet.getInt("supersedes_application_id");
                return new ApplicationState(resultSet.getInt("id"),
                        Status.valueOf(resultSet.getString("status")),
                        resultSet.wasNull() ? null : previousId);
            }
        }
    }

    private void insertApplication(Connection connection, HostApplication application, Status status)
            throws SQLException {
        String sql = "INSERT INTO host_applications (user_id, application_note, status, submitted_at, " +
                "applicant_name, applicant_email, applicant_phone, identification_type, " +
                "identification_number, property_name, property_type, property_description, " +
                "property_address, property_city, property_district, property_ward, latitude, longitude, " +
                "room_count, max_guests, identity_document_url, ownership_document_url, " +
                "business_document_url, document_status, supersedes_application_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, application.getUserId());
            statement.setString(2, valueOrEmpty(application.getApplicationNote()));
            statement.setString(3, status == null ? application.getStatus().name() : status.name());
            statement.setTimestamp(4, application.getSubmittedAt());
            int index = bindApplicationDetails(statement, application, 5);
            setNullableInteger(statement, index, application.getSupersedesApplicationId());
            if (statement.executeUpdate() != 1) {
                throw new SQLException("The host application was not inserted.");
            }

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (!generatedKeys.next()) {
                    throw new SQLException("The database did not return the host application ID.");
                }
                application.setId(generatedKeys.getInt(1));
            }
        }
    }

    private void copyRejectedDocuments(Connection connection, int rejectedId, int draftId)
            throws SQLException {
        String sql = "UPDATE host_applications draft " +
                "JOIN host_applications rejected ON rejected.id = ? " +
                "SET draft.identity_document_url = rejected.identity_document_url, " +
                "draft.ownership_document_url = rejected.ownership_document_url, " +
                "draft.business_document_url = rejected.business_document_url " +
                "WHERE draft.id = ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, rejectedId);
            statement.setInt(2, draftId);
            if (statement.executeUpdate() != 1) {
                throw new SQLException("Rejected application documents could not be copied.");
            }
        }
    }

    private void updateApplication(Connection connection, HostApplication application,
                                   Status status, Timestamp submittedAt) throws SQLException {
        String sql = "UPDATE host_applications SET " + APPLICATION_FIELDS +
                ", status = ?, submitted_at = ?, reviewed_by = NULL, reviewed_at = NULL, " +
                "rejection_reason = NULL WHERE id = ? AND user_id = ? " +
                "AND status IN ('DRAFT', 'REJECTED')";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            int index = bindApplicationFields(statement, application, 1);
            statement.setString(index++, status.name());
            statement.setTimestamp(index++, submittedAt);
            statement.setInt(index++, application.getId());
            statement.setInt(index, application.getUserId());
            if (statement.executeUpdate() != 1) {
                throw new SQLException("The host application could not be updated.");
            }
        }
    }

    private int bindApplicationFields(PreparedStatement statement, HostApplication application,
                                      int index) throws SQLException {
        statement.setString(index++, valueOrEmpty(application.getApplicationNote()));
        return bindApplicationDetails(statement, application, index);
    }

    private int bindApplicationDetails(PreparedStatement statement, HostApplication application,
                                       int index) throws SQLException {
        statement.setString(index++, application.getApplicantName());
        statement.setString(index++, application.getApplicantEmail());
        statement.setString(index++, application.getApplicantPhone());
        statement.setString(index++, enumName(application.getIdentificationType()));
        statement.setString(index++, application.getIdentificationNumber());
        statement.setString(index++, application.getPropertyName());
        statement.setString(index++, application.getPropertyType());
        statement.setString(index++, application.getPropertyDescription());
        statement.setString(index++, application.getPropertyAddress());
        statement.setString(index++, application.getPropertyCity());
        statement.setString(index++, application.getPropertyDistrict());
        statement.setString(index++, application.getPropertyWard());
        setNullableDouble(statement, index++, application.getLatitude());
        setNullableDouble(statement, index++, application.getLongitude());
        setNullableInteger(statement, index++, application.getRoomCount());
        setNullableInteger(statement, index++, application.getMaxGuests());
        statement.setString(index++, application.getIdentityDocumentUrl());
        statement.setString(index++, application.getOwnershipDocumentUrl());
        statement.setString(index++, application.getBusinessDocumentUrl());
        statement.setString(index++, application.getDocumentStatus() == null
                ? DocumentStatus.PENDING.name() : application.getDocumentStatus().name());
        return index;
    }

    private boolean isActiveAdmin(Connection connection, String sql, int adminUserId)
            throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, adminUserId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() && "ACTIVE".equals(resultSet.getString("status"))
                        && "ADMIN".equals(resultSet.getString("name"));
            }
        }
    }

    private boolean isValidDraft(HostApplication application) {
        return application != null && application.getUserId() > 0
                && lengthAtMost(application.getApplicationNote(), 1000)
                && lengthAtMost(application.getApplicantName(), 150)
                && lengthAtMost(application.getApplicantEmail(), 254)
                && lengthAtMost(application.getApplicantPhone(), 30)
                && lengthAtMost(application.getIdentificationNumber(), 100)
                && lengthAtMost(application.getPropertyName(), 150)
                && lengthAtMost(application.getPropertyType(), 50)
                && lengthAtMost(application.getPropertyDescription(), 5000)
                && lengthAtMost(application.getPropertyAddress(), 255)
                && lengthAtMost(application.getPropertyCity(), 100)
                && lengthAtMost(application.getPropertyDistrict(), 100)
                && lengthAtMost(application.getPropertyWard(), 100)
                && lengthAtMost(application.getIdentityDocumentUrl(), 1000)
                && lengthAtMost(application.getOwnershipDocumentUrl(), 1000)
                && lengthAtMost(application.getBusinessDocumentUrl(), 1000)
                && validCoordinates(application)
                && nonNegativeOrNull(application.getRoomCount())
                && nonNegativeOrNull(application.getMaxGuests());
    }

    private boolean isValidSubmission(HostApplication application) {
        return isValidDraft(application)
                && application.getIdentificationType() != null
                && hasText(application.getIdentificationNumber())
                && hasText(application.getPropertyName())
                && hasText(application.getPropertyType())
                && hasText(application.getPropertyDescription())
                && hasText(application.getPropertyAddress())
                && hasText(application.getPropertyCity())
                && hasText(application.getPropertyDistrict())
                && hasText(application.getPropertyWard())
                && application.getRoomCount() != null
                && application.getMaxGuests() != null
                && application.getRoomCount() <= 65535
                && application.getMaxGuests() <= 65535
                && hasText(application.getIdentityDocumentUrl())
                && hasText(application.getOwnershipDocumentUrl());
    }

    private boolean isReviewableApplication(ResultSet resultSet) throws SQLException {
        return hasText(resultSet.getString("applicant_name"))
                && hasText(resultSet.getString("applicant_email"))
                && hasText(resultSet.getString("applicant_phone"))
                && resultSet.getString("identification_type") != null
                && hasText(resultSet.getString("identification_number"))
                && hasText(resultSet.getString("property_name"))
                && hasText(resultSet.getString("property_type"))
                && hasText(resultSet.getString("property_description"))
                && hasText(resultSet.getString("property_address"))
                && hasText(resultSet.getString("property_city"))
                && hasText(resultSet.getString("property_district"))
                && hasText(resultSet.getString("property_ward"))
                && resultSet.getObject("room_count") != null
                && resultSet.getObject("max_guests") != null
                && hasText(resultSet.getString("identity_document_url"))
                && hasText(resultSet.getString("ownership_document_url"));
    }

    private boolean validCoordinates(HostApplication application) {
        Double latitude = application.getLatitude();
        Double longitude = application.getLongitude();
        if ((latitude == null) != (longitude == null)) {
            return false;
        }
        return latitude == null || latitude >= -90 && latitude <= 90
                && longitude >= -180 && longitude <= 180;
    }

    private boolean nonNegativeOrNull(Integer value) {
        return value == null || value >= 0;
    }

    private boolean lengthAtMost(String value, int maxLength) {
        return value == null || value.length() <= maxLength;
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private String enumName(Enum<?> value) {
        return value == null ? null : value.name();
    }

    private void setNullableDouble(PreparedStatement statement, int index, Double value)
            throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.DECIMAL);
        } else {
            statement.setDouble(index, value);
        }
    }

    private void setNullableInteger(PreparedStatement statement, int index, Integer value)
            throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.INTEGER);
        } else {
            statement.setInt(index, value);
        }
    }

    /** Maps one SQL row into the application model, including nullable columns and enums. */
    private HostApplication mapApplication(ResultSet resultSet) throws SQLException {
        HostApplication application = new HostApplication();
        application.setId(resultSet.getInt("id"));
        application.setUserId(resultSet.getInt("user_id"));
        int supersedesId = resultSet.getInt("supersedes_application_id");
        application.setSupersedesApplicationId(resultSet.wasNull() ? null : supersedesId);
        application.setApplicationNote(resultSet.getString("application_note"));
        application.setStatus(Status.valueOf(resultSet.getString("status")));
        application.setSubmittedAt(resultSet.getTimestamp("submitted_at"));
        int reviewedBy = resultSet.getInt("reviewed_by");
        application.setReviewedBy(resultSet.wasNull() ? null : reviewedBy);
        application.setReviewedAt(resultSet.getTimestamp("reviewed_at"));
        application.setRejectionReason(resultSet.getString("rejection_reason"));
        application.setApplicantName(resultSet.getString("applicant_name"));
        application.setApplicantEmail(resultSet.getString("applicant_email"));
        application.setApplicantPhone(resultSet.getString("applicant_phone"));
        String identificationType = resultSet.getString("identification_type");
        application.setIdentificationType(identificationType == null
                ? null : IdentificationType.valueOf(identificationType));
        application.setIdentificationNumber(resultSet.getString("identification_number"));
        application.setPropertyName(resultSet.getString("property_name"));
        application.setPropertyType(resultSet.getString("property_type"));
        application.setPropertyDescription(resultSet.getString("property_description"));
        application.setPropertyAddress(resultSet.getString("property_address"));
        application.setPropertyCity(resultSet.getString("property_city"));
        application.setPropertyDistrict(resultSet.getString("property_district"));
        application.setPropertyWard(resultSet.getString("property_ward"));
        double latitude = resultSet.getDouble("latitude");
        application.setLatitude(resultSet.wasNull() ? null : latitude);
        double longitude = resultSet.getDouble("longitude");
        application.setLongitude(resultSet.wasNull() ? null : longitude);
        int roomCount = resultSet.getInt("room_count");
        application.setRoomCount(resultSet.wasNull() ? null : roomCount);
        int maxGuests = resultSet.getInt("max_guests");
        application.setMaxGuests(resultSet.wasNull() ? null : maxGuests);
        application.setIdentityDocumentUrl(resultSet.getString("identity_document_url"));
        application.setOwnershipDocumentUrl(resultSet.getString("ownership_document_url"));
        application.setBusinessDocumentUrl(resultSet.getString("business_document_url"));
        String documentStatus = resultSet.getString("document_status");
        application.setDocumentStatus(documentStatus == null
                ? null : DocumentStatus.valueOf(documentStatus));
        return application;
    }

    /** Holds the locked latest application state needed during transactional updates. */
    private static final class ApplicationState {
        private final int id;
        private final Status status;
        private final Integer supersedesApplicationId;

        private ApplicationState(int id, Status status, Integer supersedesApplicationId) {
            this.id = id;
            this.status = status;
            this.supersedesApplicationId = supersedesApplicationId;
        }
    }
}
