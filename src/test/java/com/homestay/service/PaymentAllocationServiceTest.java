package com.homestay.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class PaymentAllocationServiceTest {

    private PaymentAllocationService service;

    private Connection connection;
    private PreparedStatement statement;
    private ResultSet resultSet;

    private final LocalDateTime effectiveAt =
            LocalDateTime.of(2026, 10, 30, 23, 28, 40);

    @BeforeEach
    void setUp() throws Exception {

        service = new PaymentAllocationService();

        connection = mock(Connection.class);
        statement = mock(PreparedStatement.class);
        resultSet = mock(ResultSet.class);

        when(connection.prepareStatement(anyString()))
                .thenReturn(statement);

        when(statement.executeQuery())
                .thenReturn(resultSet);
    }

    @Test
    void previewShouldCalculateTenPercentCommission() throws Exception {

        mockSingleActiveConfig(
                1L,
                "PERCENT",
                new BigDecimal("10.000000")
        );

        PaymentAllocationService.AllocationPreview preview =
                service.preview(
                        connection,
                        new BigDecimal("1000000.00"),
                        effectiveAt
                );

        assertEquals(
                0,
                preview.grossAmount()
                        .compareTo(new BigDecimal("1000000.00"))
        );

        assertEquals(
                0,
                preview.platformFeeAmount()
                        .compareTo(new BigDecimal("100000.00"))
        );

        assertEquals(
                0,
                preview.hostNetAmount()
                        .compareTo(new BigDecimal("900000.00"))
        );

        assertEquals("VND", preview.currency());
        assertEquals(1L, preview.paymentConfigId());

        verify(statement).setString(1, "PLATFORM_COMMISSION");
        verify(statement).setString(2, "VND");

        verify(statement).setTimestamp(
                eq(3),
                any(Timestamp.class)
        );

        verify(statement).setTimestamp(
                eq(4),
                any(Timestamp.class)
        );
    }

    @Test
    void previewShouldRejectZeroAmount() {

        assertThrows(
                IllegalArgumentException.class,
                () -> service.preview(
                        connection,
                        BigDecimal.ZERO,
                        effectiveAt
                )
        );
    }

    @Test
    void previewShouldRejectNegativeAmount() {

        assertThrows(
                IllegalArgumentException.class,
                () -> service.preview(
                        connection,
                        new BigDecimal("-100.00"),
                        effectiveAt
                )
        );
    }

    @Test
    void previewShouldRejectAmountWithMoreThanTwoDecimalPlaces() {

        assertThrows(
                IllegalArgumentException.class,
                () -> service.preview(
                        connection,
                        new BigDecimal("100.123"),
                        effectiveAt
                )
        );
    }

    @Test
    void previewShouldRejectMissingConfig() throws Exception {

        when(resultSet.next()).thenReturn(false);

        assertThrows(
                SQLException.class,
                () -> service.preview(
                        connection,
                        new BigDecimal("1000000.00"),
                        effectiveAt
                )
        );
    }

    @Test
    void previewShouldRejectMultipleMatchingConfigs() throws Exception {

        when(resultSet.next())
                .thenReturn(true, true);

        when(resultSet.getLong("payment_config_id"))
                .thenReturn(1L);

        when(resultSet.getString("calculation_type"))
                .thenReturn("PERCENT");

        when(resultSet.getBigDecimal("config_value"))
                .thenReturn(new BigDecimal("10.000000"));

        assertThrows(
                SQLException.class,
                () -> service.preview(
                        connection,
                        new BigDecimal("1000000.00"),
                        effectiveAt
                )
        );
    }

    @Test
    void previewShouldRejectUnsupportedCalculationType() throws Exception {

        mockSingleActiveConfig(
                1L,
                "FIXED",
                new BigDecimal("10000.000000")
        );

        assertThrows(
                SQLException.class,
                () -> service.preview(
                        connection,
                        new BigDecimal("1000000.00"),
                        effectiveAt
                )
        );
    }

    @Test
    void previewShouldRoundCommissionHalfUp() throws Exception {

        mockSingleActiveConfig(
                1L,
                "PERCENT",
                new BigDecimal("10.000000")
        );

        PaymentAllocationService.AllocationPreview preview =
                service.preview(
                        connection,
                        new BigDecimal("100.05"),
                        effectiveAt
                );

        assertEquals(
                0,
                preview.platformFeeAmount()
                        .compareTo(new BigDecimal("10.01"))
        );

        assertEquals(
                0,
                preview.hostNetAmount()
                        .compareTo(new BigDecimal("90.04"))
        );
    }

    @Test
    void allocationShouldRejectAutoCommitConnection() throws Exception {

        when(connection.getAutoCommit()).thenReturn(true);

        assertThrows(
                SQLException.class,
                () -> service.allocatePendingPayment(
                        connection,
                        1L
                )
        );

        verify(connection, never()).prepareStatement(anyString());
    }

    @Test
    void allocationShouldRejectClosedConnection() throws Exception {

        when(connection.isClosed()).thenReturn(true);

        assertThrows(
                SQLException.class,
                () -> service.allocatePendingPayment(
                        connection,
                        1L
                )
        );

        verify(connection, never()).prepareStatement(anyString());
    }

    private void mockSingleActiveConfig(
            long configId,
            String calculationType,
            BigDecimal configValue
    ) throws Exception {

        when(resultSet.next())
                .thenReturn(true, false);

        when(resultSet.getLong("payment_config_id"))
                .thenReturn(configId);

        when(resultSet.getString("calculation_type"))
                .thenReturn(calculationType);

        when(resultSet.getBigDecimal("config_value"))
                .thenReturn(configValue);
    }
}