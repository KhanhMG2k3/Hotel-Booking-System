package com.homestay.dao;

import com.homestay.model.ContactMessage;
import com.homestay.model.TicketCategory;
import com.homestay.model.TicketStatus;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Unit tests with Mockito for ContactMessageDAO testing allowlist sorting,
 * query parameterization, and boundary checks.
 */
class ContactMessageDAOTest {

    @Test
    @DisplayName("findAllForAdmin: Safe execution with allowlist sorting fallback against SQL injection")
    void testFindAllForAdminAllowlistSorting() throws Exception {
        Connection mockConn = mock(Connection.class);
        PreparedStatement mockPs = mock(PreparedStatement.class);
        ResultSet mockRs = mock(ResultSet.class);

        when(mockConn.prepareStatement(anyString())).thenReturn(mockPs);
        when(mockPs.executeQuery()).thenReturn(mockRs);
        when(mockRs.next()).thenReturn(false);

        ContactMessageDAO dao = new ContactMessageDAO() {
            @Override
            protected Connection getConnection() {
                return mockConn;
            }
        };

        // Pass malicious sortBy and sortOrder
        List<ContactMessage> result = dao.findAllForAdmin(
                "NEW", "BOOKING_INQUIRY", "test",
                "created_at; DROP TABLE users;--", "INVALID_ORDER", 1, 10
        );

        assertNotNull(result);
        verify(mockConn).prepareStatement(argThat(sql -> {
            // Must contain safe sanitized order by and not contain raw injection
            return sql.contains("ORDER BY c.updated_at DESC") && !sql.contains("DROP TABLE");
        }));
    }

    @Test
    @DisplayName("findByUserId: Ensures user isolation boundary in query")
    void testFindByUserIdQueryStructure() throws Exception {
        Connection mockConn = mock(Connection.class);
        PreparedStatement mockPs = mock(PreparedStatement.class);
        ResultSet mockRs = mock(ResultSet.class);

        when(mockConn.prepareStatement(anyString())).thenReturn(mockPs);
        when(mockPs.executeQuery()).thenReturn(mockRs);
        when(mockRs.next()).thenReturn(false);

        ContactMessageDAO dao = new ContactMessageDAO() {
            @Override
            protected Connection getConnection() {
                return mockConn;
            }
        };

        int targetUserId = 42;
        List<ContactMessage> result = dao.findByUserId(targetUserId, "PROCESSING", 1, 10);

        assertNotNull(result);
        verify(mockConn).prepareStatement(argThat(sql -> sql.contains("WHERE c.user_id = ?")));
        verify(mockPs).setObject(1, targetUserId);
        verify(mockPs).setObject(2, TicketStatus.PROCESSING.name());
    }

    @Test
    @DisplayName("updateStatus: Conditional optimistic lock query structure")
    void testOptimisticUpdateQuery() throws Exception {
        Connection mockConn = mock(Connection.class);
        PreparedStatement mockPs = mock(PreparedStatement.class);

        when(mockConn.prepareStatement(anyString())).thenReturn(mockPs);
        when(mockPs.executeUpdate()).thenReturn(1);

        ContactMessageDAO dao = new ContactMessageDAO() {
            @Override
            protected Connection getConnection() {
                return mockConn;
            }
        };

        boolean updated = dao.updateStatus(10, TicketStatus.RESOLVED, TicketStatus.PROCESSING, mockConn);
        assertTrue(updated);

        verify(mockConn).prepareStatement(argThat(sql ->
                sql.contains("UPDATE contactmessages SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE message_id = ? AND status = ?")
        ));
        verify(mockPs).setString(1, TicketStatus.RESOLVED.name());
        verify(mockPs).setInt(2, 10);
        verify(mockPs).setString(3, TicketStatus.PROCESSING.name());
    }
}
