package com.homestay.service;

import com.homestay.context.DBContext;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Objects;

public class PaymentAllocationService {

    private static final String CONFIG_TYPE = "PLATFORM_COMMISSION";
    private static final String CURRENCY = "VND";
    private static final int MONEY_SCALE = 2;

    public record AllocationPreview(
            BigDecimal grossAmount,
            BigDecimal platformFeeAmount,
            BigDecimal hostNetAmount,
            String currency,
            long paymentConfigId
    ) {
    }

    public record AllocationResult(
            long allocationId,
            long paymentId,
            long bookingId,
            long propertyId,
            long beneficiaryUserId,
            BigDecimal grossAmount,
            BigDecimal platformFeeAmount,
            BigDecimal hostNetAmount,
            String currency,
            long paymentConfigId,
            boolean created
    ) {
    }

    public AllocationPreview preview(
            BigDecimal grossAmount,
            LocalDateTime effectiveAt
    ) throws SQLException {

        validateGrossAmount(grossAmount);
        Objects.requireNonNull(effectiveAt, "effectiveAt must not be null");

        try (Connection connection = DBContext.getConnection()) {
            return preview(connection, grossAmount, effectiveAt);
        }
    }

    public AllocationPreview preview(
            Connection connection,
            BigDecimal grossAmount,
            LocalDateTime effectiveAt
    ) throws SQLException {

        Objects.requireNonNull(connection, "connection must not be null");
        Objects.requireNonNull(effectiveAt, "effectiveAt must not be null");

        validateGrossAmount(grossAmount);

        final String sql = """
                SELECT
                    payment_config_id,
                    calculation_type,
                    config_value
                FROM payment_configs
                WHERE config_type = ?
                  AND status = 'ACTIVE'
                  AND currency = ?
                  AND country_code IS NULL
                  AND listing_type IS NULL
                  AND property_id IS NULL
                  AND effective_from <= ?
                  AND (
                      effective_to IS NULL
                      OR effective_to > ?
                  )
                ORDER BY payment_config_id
                LIMIT 2
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, CONFIG_TYPE);
            statement.setString(2, CURRENCY);

            Timestamp timestamp = Timestamp.valueOf(effectiveAt);
            statement.setTimestamp(3, timestamp);
            statement.setTimestamp(4, timestamp);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    throw new SQLException(
                            "No active PLATFORM_COMMISSION config for VND at "
                                    + effectiveAt
                    );
                }

                long configId = rs.getLong("payment_config_id");
                String calculationType = rs.getString("calculation_type");
                BigDecimal configValue = rs.getBigDecimal("config_value");

                if (rs.next()) {
                    throw new SQLException(
                            "Multiple active PLATFORM_COMMISSION configs match"
                    );
                }

                if (!"PERCENT".equals(calculationType)) {
                    throw new SQLException(
                            "Unsupported commission calculation type: "
                                    + calculationType
                    );
                }

                if (configValue == null
                        || configValue.signum() < 0
                        || configValue.compareTo(new BigDecimal("100")) > 0) {
                    throw new SQLException(
                            "Invalid platform commission percentage"
                    );
                }

                BigDecimal gross = grossAmount.setScale(
                        MONEY_SCALE,
                        RoundingMode.UNNECESSARY
                );

                BigDecimal fee = gross
                        .multiply(configValue)
                        .divide(
                                new BigDecimal("100"),
                                MONEY_SCALE,
                                RoundingMode.HALF_UP
                        );

                BigDecimal hostNet = gross.subtract(fee);

                if (hostNet.signum() < 0) {
                    throw new SQLException(
                            "Host net amount cannot be negative"
                    );
                }

                return new AllocationPreview(
                        gross,
                        fee,
                        hostNet,
                        CURRENCY,
                        configId
                );
            }
        }
    }

    /**
     * Tạo Allocation và Fee Snapshot cho Payment PENDING.
     *
     * Lock order:
     * 1. Đọc booking_id từ Payment, không khóa.
     * 2. Khóa Booking.
     * 3. Khóa Payment.
     * 4. Xác minh booking_id vẫn không thay đổi.
     *
     * Connection thuộc quyền quản lý của caller.
     * Không commit, rollback hoặc close Connection.
     */
    public AllocationResult allocatePendingPayment(
            Connection connection,
            long paymentId
    ) throws SQLException {

        Objects.requireNonNull(connection, "connection must not be null");

        if (paymentId <= 0) {
            throw new IllegalArgumentException(
                    "paymentId must be greater than zero"
            );
        }

        if (connection.isClosed()) {
            throw new SQLException("Connection is closed");
        }

        if (connection.getAutoCommit()) {
            throw new SQLException(
                    "Allocation requires a caller-managed transaction "
                            + "(autoCommit=false)"
            );
        }

        Long initialBookingId = findPaymentBookingId(
                connection,
                paymentId
        );

        if (initialBookingId == null) {
            throw new SQLException(
                    "Payment " + paymentId + " has no booking_id"
            );
        }

        BookingContext booking = findAndLockBookingContext(
                connection,
                initialBookingId
        );

        PaymentContext payment = findAndLockPaymentContext(
                connection,
                paymentId
        );

        if (payment.bookingId() == null
                || !payment.bookingId().equals(initialBookingId)) {
            throw new SQLException(
                    "Payment booking_id changed while acquiring locks"
            );
        }

        if (!"PENDING".equals(payment.status())) {
            throw new SQLException(
                    "Payment must be PENDING, current status is "
                            + payment.status()
            );
        }

        if (!"PENDING".equals(booking.bookingStatus())) {
            throw new SQLException(
                    "Booking must be PENDING, current status is "
                            + booking.bookingStatus()
            );
        }

        if (payment.userId() != booking.userId()) {
            throw new SQLException(
                    "Payment user does not match booking user"
            );
        }

        BigDecimal paymentAmount = normalizeDatabaseAmount(
                payment.amount(),
                "Payment amount"
        );

        BigDecimal bookingAmount = normalizeDatabaseAmount(
                booking.totalAmount(),
                "Booking total_amount"
        );

        if (paymentAmount.signum() <= 0
                || bookingAmount.signum() <= 0) {
            throw new SQLException(
                    "Payment and booking amounts must be positive"
            );
        }

        if (paymentAmount.compareTo(bookingAmount) != 0) {
            throw new SQLException(
                    "Payment amount does not match booking total_amount"
            );
        }

        /*
         * Idempotency:
         * Nếu Allocation đã tồn tại, chỉ trả về khi Allocation
         * và Fee Snapshot đều tồn tại và nhất quán.
         *
         * Không tự sửa hoặc tạo bù dữ liệu bị thiếu.
         */
        AllocationResult existing = findExistingAllocation(
                connection,
                paymentId,
                booking,
                paymentAmount
        );

        if (existing != null) {
            return existing;
        }

        PropertyBeneficiaryContext beneficiary =
                findEligibleBeneficiary(
                        connection,
                        booking.propertyId()
                );

        LocalDateTime effectiveAt = payment.paidAt() != null
                ? payment.paidAt()
                : LocalDateTime.now();

        AllocationPreview preview = preview(
                connection,
                paymentAmount,
                effectiveAt
        );

        long allocationId = insertAllocation(
                connection,
                paymentId,
                booking.bookingId(),
                booking.propertyId(),
                beneficiary.beneficiaryUserId(),
                preview
        );

        insertFeeSnapshot(
                connection,
                paymentId,
                preview
        );

        return new AllocationResult(
                allocationId,
                paymentId,
                booking.bookingId(),
                booking.propertyId(),
                beneficiary.beneficiaryUserId(),
                preview.grossAmount(),
                preview.platformFeeAmount(),
                preview.hostNetAmount(),
                preview.currency(),
                preview.paymentConfigId(),
                true
        );
    }

    private Long findPaymentBookingId(
            Connection connection,
            long paymentId
    ) throws SQLException {

        final String sql = """
                SELECT booking_id
                FROM payments
                WHERE payment_id = ?
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, paymentId);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    throw new SQLException(
                            "Payment not found: " + paymentId
                    );
                }

                long bookingId = rs.getLong("booking_id");

                if (rs.wasNull()) {
                    return null;
                }

                return bookingId;
            }
        }
    }

    private PaymentContext findAndLockPaymentContext(
            Connection connection,
            long paymentId
    ) throws SQLException {

        final String sql = """
                SELECT
                    payment_id,
                    user_id,
                    booking_id,
                    amount,
                    status,
                    paid_at
                FROM payments
                WHERE payment_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, paymentId);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    throw new SQLException(
                            "Payment not found: " + paymentId
                    );
                }

                long userId = rs.getLong("user_id");

                if (rs.wasNull() || userId <= 0) {
                    throw new SQLException(
                            "Payment has invalid user_id"
                    );
                }

                long bookingIdValue = rs.getLong("booking_id");
                Long bookingId = rs.wasNull() ? null : bookingIdValue;

                BigDecimal amount = rs.getBigDecimal("amount");
                String status = rs.getString("status");

                Timestamp paidAtTimestamp = rs.getTimestamp("paid_at");

                LocalDateTime paidAt = paidAtTimestamp == null
                        ? null
                        : paidAtTimestamp.toLocalDateTime();

                if (amount == null || amount.signum() <= 0) {
                    throw new SQLException(
                            "Payment amount must be greater than zero"
                    );
                }

                return new PaymentContext(
                        userId,
                        bookingId,
                        amount,
                        status,
                        paidAt
                );
            }
        }
    }

    private BookingContext findAndLockBookingContext(
            Connection connection,
            long bookingId
    ) throws SQLException {

        final String sql = """
                SELECT
                    booking_id,
                    user_id,
                    property_id,
                    total_amount,
                    booking_status
                FROM bookings
                WHERE booking_id = ?
                FOR UPDATE
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, bookingId);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    throw new SQLException(
                            "Booking not found: " + bookingId
                    );
                }

                long userId = rs.getLong("user_id");

                if (rs.wasNull() || userId <= 0) {
                    throw new SQLException(
                            "Booking has invalid user_id"
                    );
                }

                long propertyId = rs.getLong("property_id");

                if (rs.wasNull() || propertyId <= 0) {
                    throw new SQLException(
                            "Booking has invalid property_id"
                    );
                }

                BigDecimal totalAmount = rs.getBigDecimal("total_amount");

                if (totalAmount == null || totalAmount.signum() <= 0) {
                    throw new SQLException(
                            "Booking total_amount must be positive"
                    );
                }

                return new BookingContext(
                        bookingId,
                        userId,
                        propertyId,
                        totalAmount,
                        rs.getString("booking_status")
                );
            }
        }
    }

    private PropertyBeneficiaryContext findEligibleBeneficiary(
            Connection connection,
            long propertyId
    ) throws SQLException {

        final String sql = """
                SELECT
                    p.owner_id AS beneficiary_user_id
                FROM properties p
                JOIN users u
                    ON u.user_id = p.owner_id
                WHERE p.property_id = ?
                  AND u.status = 'ACTIVE'
                  AND EXISTS (
                      SELECT 1
                      FROM userroles ur
                      JOIN roles r
                          ON r.role_id = ur.role_id
                      WHERE ur.user_id = p.owner_id
                        AND r.role_name = 'ROLE_HOST'
                  )
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, propertyId);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    throw new SQLException(
                            "Property " + propertyId
                                    + " does not have an ACTIVE ROLE_HOST owner"
                    );
                }

                long beneficiaryUserId = rs.getLong("beneficiary_user_id");

                if (rs.wasNull() || beneficiaryUserId <= 0) {
                    throw new SQLException(
                            "Property has invalid owner_id"
                    );
                }

                if (rs.next()) {
                    throw new SQLException(
                            "Multiple eligible beneficiaries found"
                    );
                }

                return new PropertyBeneficiaryContext(
                        propertyId,
                        beneficiaryUserId
                );
            }
        }
    }

    private AllocationResult findExistingAllocation(
            Connection connection,
            long paymentId,
            BookingContext booking,
            BigDecimal expectedGross
    ) throws SQLException {

        final String allocationSql = """
                SELECT
                    allocation_id,
                    booking_id,
                    property_id,
                    beneficiary_user_id,
                    gross_amount,
                    host_net_amount,
                    platform_fee_amount,
                    currency,
                    status
                FROM payment_allocations
                WHERE payment_id = ?
                """;

        try (PreparedStatement statement =
                     connection.prepareStatement(allocationSql)) {

            statement.setLong(1, paymentId);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    return null;
                }

                long allocationId = rs.getLong("allocation_id");
                long bookingId = rs.getLong("booking_id");
                long propertyId = rs.getLong("property_id");
                long beneficiaryId = rs.getLong("beneficiary_user_id");

                if (rs.wasNull() || beneficiaryId <= 0) {
                    throw new SQLException(
                            "Existing allocation has invalid beneficiary"
                    );
                }

                BigDecimal gross = rs.getBigDecimal("gross_amount");
                BigDecimal hostNet = rs.getBigDecimal("host_net_amount");
                BigDecimal fee = rs.getBigDecimal("platform_fee_amount");

                String currency = rs.getString("currency");
                String status = rs.getString("status");

                if (rs.next()) {
                    throw new SQLException(
                            "Multiple allocations found for one payment"
                    );
                }

                if (allocationId <= 0
                        || bookingId != booking.bookingId()
                        || propertyId != booking.propertyId()) {
                    throw new SQLException(
                            "Existing allocation does not match booking"
                    );
                }

                if (!"PENDING_REVIEW".equals(status)
                        && !"ALLOCATED".equals(status)) {
                    throw new SQLException(
                            "Existing allocation has unsupported status: "
                                    + status
                    );
                }

                if (!CURRENCY.equals(currency)) {
                    throw new SQLException(
                            "Existing allocation has invalid currency"
                    );
                }

                gross = normalizeDatabaseAmount(
                        gross,
                        "Existing allocation gross_amount"
                );

                hostNet = normalizeDatabaseAmount(
                        hostNet,
                        "Existing allocation host_net_amount"
                );

                fee = normalizeDatabaseAmount(
                        fee,
                        "Existing allocation platform_fee_amount"
                );

                if (gross.compareTo(expectedGross) != 0
                        || hostNet.signum() < 0
                        || fee.signum() < 0
                        || hostNet.add(fee).compareTo(gross) != 0) {
                    throw new SQLException(
                            "Existing allocation amounts are inconsistent"
                    );
                }

                FeeSnapshotContext snapshot = findExistingFeeSnapshot(
                        connection,
                        paymentId
                );

                if (snapshot == null) {
                    throw new SQLException(
                            "Existing allocation has no fee snapshot"
                    );
                }

                if (!CURRENCY.equals(snapshot.currency())
                        || !"PLATFORM_COMMISSION".equals(snapshot.feeType())
                        || !"PERCENT".equals(snapshot.calculationType())
                        || !"HOST".equals(snapshot.chargedTo())
                        || snapshot.paymentConfigId() == null
                        || snapshot.paymentConfigId() <= 0) {
                    throw new SQLException(
                            "Existing fee snapshot has invalid metadata"
                    );
                }

                BigDecimal snapshotBase = normalizeDatabaseAmount(
                        snapshot.baseAmount(),
                        "Fee snapshot base_amount"
                );

                BigDecimal snapshotFee = normalizeDatabaseAmount(
                        snapshot.feeAmount(),
                        "Fee snapshot fee_amount"
                );

                BigDecimal appliedValue = snapshot.appliedValue();

                if (appliedValue == null
                        || appliedValue.signum() < 0
                        || appliedValue.compareTo(
                                new BigDecimal("100")
                        ) > 0) {
                    throw new SQLException(
                            "Existing fee snapshot has invalid applied_value"
                    );
                }

                BigDecimal calculatedFee = snapshotBase
                        .multiply(appliedValue)
                        .divide(
                                new BigDecimal("100"),
                                MONEY_SCALE,
                                RoundingMode.HALF_UP
                        );

                if (snapshotBase.compareTo(gross) != 0
                        || snapshotFee.compareTo(fee) != 0
                        || calculatedFee.compareTo(fee) != 0) {
                    throw new SQLException(
                            "Existing fee snapshot does not match allocation"
                    );
                }

                return new AllocationResult(
                        allocationId,
                        paymentId,
                        bookingId,
                        propertyId,
                        beneficiaryId,
                        gross,
                        fee,
                        hostNet,
                        currency,
                        snapshot.paymentConfigId(),
                        false
                );
            }
        }
    }

    private FeeSnapshotContext findExistingFeeSnapshot(
            Connection connection,
            long paymentId
    ) throws SQLException {

        final String sql = """
                SELECT
                    payment_config_id,
                    fee_type,
                    calculation_type,
                    applied_value,
                    base_amount,
                    fee_amount,
                    charged_to,
                    currency
                FROM payment_fee_snapshots
                WHERE payment_id = ?
                  AND fee_type = 'PLATFORM_COMMISSION'
                  AND charged_to = 'HOST'
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, paymentId);

            try (ResultSet rs = statement.executeQuery()) {

                if (!rs.next()) {
                    return null;
                }

                long configIdValue = rs.getLong("payment_config_id");

                Long configId = rs.wasNull()
                        ? null
                        : configIdValue;

                FeeSnapshotContext snapshot = new FeeSnapshotContext(
                        configId,
                        rs.getString("fee_type"),
                        rs.getString("calculation_type"),
                        rs.getBigDecimal("applied_value"),
                        rs.getBigDecimal("base_amount"),
                        rs.getBigDecimal("fee_amount"),
                        rs.getString("charged_to"),
                        rs.getString("currency")
                );

                if (rs.next()) {
                    throw new SQLException(
                            "Multiple PLATFORM_COMMISSION fee snapshots found"
                    );
                }

                return snapshot;
            }
        }
    }

    private long insertAllocation(
            Connection connection,
            long paymentId,
            long bookingId,
            long propertyId,
            long beneficiaryUserId,
            AllocationPreview preview
    ) throws SQLException {

        final String sql = """
                INSERT INTO payment_allocations (
                    payment_id,
                    booking_id,
                    property_id,
                    beneficiary_user_id,
                    gross_amount,
                    host_net_amount,
                    platform_fee_amount,
                    currency,
                    status
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_REVIEW')
                """;

        try (PreparedStatement statement = connection.prepareStatement(
                sql,
                PreparedStatement.RETURN_GENERATED_KEYS
        )) {

            statement.setLong(1, paymentId);
            statement.setLong(2, bookingId);
            statement.setLong(3, propertyId);
            statement.setLong(4, beneficiaryUserId);
            statement.setBigDecimal(5, preview.grossAmount());
            statement.setBigDecimal(6, preview.hostNetAmount());
            statement.setBigDecimal(7, preview.platformFeeAmount());
            statement.setString(8, preview.currency());

            if (statement.executeUpdate() != 1) {
                throw new SQLException(
                        "Expected exactly one payment allocation row"
                );
            }

            try (ResultSet keys = statement.getGeneratedKeys()) {

                if (!keys.next()) {
                    throw new SQLException(
                            "No allocation_id generated"
                    );
                }

                return keys.getLong(1);
            }
        }
    }

    private void insertFeeSnapshot(
            Connection connection,
            long paymentId,
            AllocationPreview preview
    ) throws SQLException {

        final String sql = """
                INSERT INTO payment_fee_snapshots (
                    payment_id,
                    payment_config_id,
                    fee_type,
                    calculation_type,
                    applied_value,
                    base_amount,
                    fee_amount,
                    charged_to,
                    currency
                )
                SELECT
                    ?,
                    payment_config_id,
                    'PLATFORM_COMMISSION',
                    'PERCENT',
                    config_value,
                    ?,
                    ?,
                    'HOST',
                    ?
                FROM payment_configs
                WHERE payment_config_id = ?
                  AND config_type = 'PLATFORM_COMMISSION'
                  AND calculation_type = 'PERCENT'
                """;

        try (PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, paymentId);
            statement.setBigDecimal(2, preview.grossAmount());
            statement.setBigDecimal(3, preview.platformFeeAmount());
            statement.setString(4, preview.currency());
            statement.setLong(5, preview.paymentConfigId());

            if (statement.executeUpdate() != 1) {
                throw new SQLException(
                        "Expected exactly one payment fee snapshot row"
                );
            }
        }
    }

    private BigDecimal normalizeDatabaseAmount(
            BigDecimal amount,
            String fieldName
    ) throws SQLException {

        if (amount == null) {
            throw new SQLException(fieldName + " must not be NULL");
        }

        try {
            return amount.setScale(
                    MONEY_SCALE,
                    RoundingMode.UNNECESSARY
            );
        } catch (ArithmeticException ex) {
            throw new SQLException(
                    fieldName + " has more than 2 decimal places",
                    ex
            );
        }
    }

    private void validateGrossAmount(BigDecimal grossAmount) {

        if (grossAmount == null) {
            throw new IllegalArgumentException(
                    "grossAmount must not be null"
            );
        }

        if (grossAmount.signum() <= 0) {
            throw new IllegalArgumentException(
                    "grossAmount must be greater than zero"
            );
        }

        if (grossAmount.scale() > MONEY_SCALE) {
            throw new IllegalArgumentException(
                    "VND amount must have at most 2 decimal places"
            );
        }
    }

    private record PaymentContext(
            long userId,
            Long bookingId,
            BigDecimal amount,
            String status,
            LocalDateTime paidAt
    ) {
    }

    private record BookingContext(
            long bookingId,
            long userId,
            long propertyId,
            BigDecimal totalAmount,
            String bookingStatus
    ) {
    }

    private record PropertyBeneficiaryContext(
            long propertyId,
            long beneficiaryUserId
    ) {
    }

    private record FeeSnapshotContext(
            Long paymentConfigId,
            String feeType,
            String calculationType,
            BigDecimal appliedValue,
            BigDecimal baseAmount,
            BigDecimal feeAmount,
            String chargedTo,
            String currency
    ) {
    }
}