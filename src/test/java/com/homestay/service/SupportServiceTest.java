package com.homestay.service;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.ContactMessageDAO;
import com.homestay.dao.SupportReplyDAO;
import com.homestay.exception.DataAccessException;
import com.homestay.model.ContactMessage;
import com.homestay.model.Role;
import com.homestay.model.SupportReply;
import com.homestay.model.TicketCategory;
import com.homestay.model.TicketStatus;
import com.homestay.model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests with Mockito testing SupportService business logic, validations,
 * permissions, and JDBC transaction commits and rollbacks without requiring a live MySQL server.
 */
class SupportServiceTest {

    private ContactMessageDAO contactMessageDAO;
    private SupportReplyDAO supportReplyDAO;
    private BookingDAO bookingDAO;
    private Connection mockConnection;
    private SupportService supportService;

    @BeforeEach
    void setUp() throws Exception {
        contactMessageDAO = mock(ContactMessageDAO.class);
        supportReplyDAO = mock(SupportReplyDAO.class);
        bookingDAO = mock(BookingDAO.class);
        mockConnection = mock(Connection.class);

        // Subclass SupportService to inject mock Connection
        supportService = new SupportService(contactMessageDAO, supportReplyDAO, bookingDAO) {
            @Override
            protected Connection getConnection() {
                return mockConnection;
            }
        };
    }

    private User createCustomer(int id) {
        User u = new User();
        u.setId(id);
        u.setUsername("customer" + id);
        u.setFullName("Customer Name " + id);
        u.setEmail("cust" + id + "@example.com");
        u.setPhone("0987654321");
        u.setRole(new Role(2, "ROLE_CUSTOMER", "Customer"));
        return u;
    }

    private User createHost(int id) {
        User u = new User();
        u.setId(id);
        u.setUsername("host" + id);
        u.setFullName("Host Name " + id);
        u.setEmail("host" + id + "@example.com");
        u.setPhone("0912345678");
        u.setRole(new Role(3, "ROLE_HOST", "Host"));
        return u;
    }

    @Test
    @DisplayName("createTicket: Success scenario generates ticket code, sets NEW status, and commits transaction")
    void testCreateTicketSuccess() throws Exception {
        User sender = createCustomer(2);
        ContactMessage ticket = new ContactMessage();
        ticket.setSubject("Cần hỗ trợ về phòng");
        ticket.setMessage("Tôi đã đặt phòng nhưng muốn hỏi về giờ check in sớm.");
        ticket.setCategory(TicketCategory.BOOKING_INQUIRY);

        doAnswer(invocation -> {
            ContactMessage m = invocation.getArgument(0);
            m.setMessageId(10);
            return true;
        }).when(contactMessageDAO).insert(any(ContactMessage.class), eq(mockConnection));

        ContactMessage created = supportService.createTicket(ticket, sender);

        assertNotNull(created);
        assertEquals(10, created.getMessageId());
        assertEquals(TicketStatus.NEW, created.getStatus());
        assertNotNull(created.getTicketCode());
        assertTrue(created.getTicketCode().startsWith("TK-"));
        assertEquals(2, created.getUserId());
        assertEquals("Customer Name 2", created.getFullName());

        verify(mockConnection).setAutoCommit(false);
        verify(mockConnection).commit();
        verify(mockConnection, never()).rollback();
    }

    @Test
    @DisplayName("createTicket: Throws IllegalArgumentException on invalid subject or message length")
    void testCreateTicketValidation() {
        User sender = createCustomer(2);

        // Subject too short (< 5 chars)
        ContactMessage shortSubject = new ContactMessage();
        shortSubject.setSubject("Hi");
        shortSubject.setMessage("Nội dung hợp lệ trên mười ký tự.");
        assertThrows(IllegalArgumentException.class, () -> supportService.createTicket(shortSubject, sender));

        // Message too short (< 10 chars)
        ContactMessage shortMessage = new ContactMessage();
        shortMessage.setSubject("Tiêu đề hợp lệ");
        shortMessage.setMessage("Ngắn");
        assertThrows(IllegalArgumentException.class, () -> supportService.createTicket(shortMessage, sender));

        // Null sender
        ContactMessage validTicket = new ContactMessage();
        validTicket.setSubject("Tiêu đề hợp lệ");
        validTicket.setMessage("Nội dung hợp lệ trên mười ký tự.");
        assertThrows(IllegalArgumentException.class, () -> supportService.createTicket(validTicket, null));
    }

    @Test
    @DisplayName("createTicket: Rejects bookingId when not owned by Customer")
    void testCreateTicketRejectsUnownedBookingForCustomer() throws Exception {
        User sender = createCustomer(2);
        ContactMessage ticket = new ContactMessage();
        ticket.setSubject("Hỏi về booking người khác");
        ticket.setMessage("Nội dung câu hỏi chi tiết về đặt phòng.");
        ticket.setBookingId(999);

        when(bookingDAO.isBookingOwnedByUser(999, 2)).thenReturn(false);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> supportService.createTicket(ticket, sender));
        assertTrue(ex.getMessage().contains("không thuộc quyền sở hữu"));
    }

    @Test
    @DisplayName("createTicket: Rejects bookingId when not owned by Host")
    void testCreateTicketRejectsUnownedBookingForHost() throws Exception {
        User sender = createHost(3);
        ContactMessage ticket = new ContactMessage();
        ticket.setSubject("Hỏi về booking phòng khác");
        ticket.setMessage("Nội dung câu hỏi chi tiết về đặt phòng của homestay khác.");
        ticket.setBookingId(888);

        when(bookingDAO.isBookingOwnedByHost(888, 3)).thenReturn(false);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                () -> supportService.createTicket(ticket, sender));
        assertTrue(ex.getMessage().contains("không thuộc quyền sở hữu"));
    }

    @Test
    @DisplayName("addSenderReply: Reopens RESOLVED ticket back to PROCESSING in transaction")
    void testAddSenderReplyReopensResolvedTicket() throws Exception {
        int ticketId = 1;
        int senderId = 2;

        ContactMessage existingTicket = new ContactMessage();
        existingTicket.setMessageId(ticketId);
        existingTicket.setUserId(senderId);
        existingTicket.setStatus(TicketStatus.RESOLVED);

        when(contactMessageDAO.findById(ticketId)).thenReturn(Optional.of(existingTicket));
        when(supportReplyDAO.insert(any(SupportReply.class), eq(mockConnection))).thenReturn(true);
        when(contactMessageDAO.updateStatus(ticketId, TicketStatus.PROCESSING, TicketStatus.RESOLVED, mockConnection))
                .thenReturn(true);

        SupportReply reply = supportService.addSenderReply(ticketId, senderId, "Vấn đề vẫn chưa được giải quyết xong, nhờ hỗ trợ thêm.");

        assertNotNull(reply);
        assertEquals(ticketId, reply.getTicketId());
        assertEquals(senderId, reply.getSenderId());

        verify(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));
        verify(contactMessageDAO).updateStatus(ticketId, TicketStatus.PROCESSING, TicketStatus.RESOLVED, mockConnection);
        verify(mockConnection).commit();
        verify(mockConnection, never()).rollback();
    }

    @Test
    @DisplayName("addSenderReply: Rejects reply when user is not the ticket owner")
    void testAddSenderReplyRejectsNonOwner() {
        int ticketId = 1;
        int ownerId = 2;
        int impostorId = 5;

        ContactMessage existingTicket = new ContactMessage();
        existingTicket.setMessageId(ticketId);
        existingTicket.setUserId(ownerId);
        existingTicket.setStatus(TicketStatus.PROCESSING);

        when(contactMessageDAO.findById(ticketId)).thenReturn(Optional.of(existingTicket));

        SecurityException ex = assertThrows(SecurityException.class,
                () -> supportService.addSenderReply(ticketId, impostorId, "Phản hồi trái phép"));
        assertTrue(ex.getMessage().contains("không có quyền phản hồi"));
    }

    @Test
    @DisplayName("addSenderReply: Rolls back transaction when database update fails")
    void testAddSenderReplyRollbackOnFailure() throws Exception {
        int ticketId = 1;
        int senderId = 2;

        ContactMessage existingTicket = new ContactMessage();
        existingTicket.setMessageId(ticketId);
        existingTicket.setUserId(senderId);
        existingTicket.setStatus(TicketStatus.RESOLVED);

        when(contactMessageDAO.findById(ticketId)).thenReturn(Optional.of(existingTicket));
        when(supportReplyDAO.insert(any(SupportReply.class), eq(mockConnection))).thenReturn(true);
        // Fail the status update
        when(contactMessageDAO.updateStatus(ticketId, TicketStatus.PROCESSING, TicketStatus.RESOLVED, mockConnection))
                .thenReturn(false);

        assertThrows(DataAccessException.class,
                () -> supportService.addSenderReply(ticketId, senderId, "Thử gửi lại"));

        verify(mockConnection).rollback();
    }

    @Test
    @DisplayName("addAdminReply: Never auto-resolves ticket when admin replies")
    void testAddAdminReplyDoesNotAutoResolve() throws Exception {
        int ticketId = 1;
        int adminId = 1;

        ContactMessage existingTicket = new ContactMessage();
        existingTicket.setMessageId(ticketId);
        existingTicket.setUserId(2);
        existingTicket.setStatus(TicketStatus.NEW);

        when(contactMessageDAO.findById(ticketId)).thenReturn(Optional.of(existingTicket));
        when(supportReplyDAO.insert(any(SupportReply.class), eq(mockConnection))).thenReturn(true);

        SupportReply reply = supportService.addAdminReply(ticketId, adminId, "Chúng tôi đã tiếp nhận yêu cầu của bạn.", true);

        assertNotNull(reply);
        verify(contactMessageDAO).updateStatus(ticketId, TicketStatus.PROCESSING, TicketStatus.NEW, mockConnection);
        verify(contactMessageDAO, never()).updateStatus(anyInt(), eq(TicketStatus.RESOLVED), any(), any());
        verify(mockConnection).commit();
    }

    @Test
    @DisplayName("updateTicketStatus: Admin can transition PROCESSING to RESOLVED")
    void testUpdateTicketStatusAdminSuccess() {
        int ticketId = 1;
        ContactMessage existingTicket = new ContactMessage();
        existingTicket.setMessageId(ticketId);
        existingTicket.setStatus(TicketStatus.PROCESSING);

        when(contactMessageDAO.findById(ticketId)).thenReturn(Optional.of(existingTicket));
        when(contactMessageDAO.updateStatus(ticketId, TicketStatus.RESOLVED, TicketStatus.PROCESSING)).thenReturn(true);

        boolean success = supportService.updateTicketStatus(ticketId, TicketStatus.RESOLVED, true);
        assertTrue(success);
    }

    @Test
    @DisplayName("updateTicketStatus: Rejects invalid transition NEW to RESOLVED")
    void testUpdateTicketStatusRejectsInvalidTransition() {
        int ticketId = 1;
        ContactMessage existingTicket = new ContactMessage();
        existingTicket.setMessageId(ticketId);
        existingTicket.setStatus(TicketStatus.NEW);

        when(contactMessageDAO.findById(ticketId)).thenReturn(Optional.of(existingTicket));

        assertThrows(IllegalStateException.class,
                () -> supportService.updateTicketStatus(ticketId, TicketStatus.RESOLVED, true));
    }

    @Test
    @DisplayName("updateTicketStatus: Rejects non-admin status change")
    void testUpdateTicketStatusRejectsNonAdmin() {
        assertThrows(SecurityException.class,
                () -> supportService.updateTicketStatus(1, TicketStatus.RESOLVED, false));
    }
}
