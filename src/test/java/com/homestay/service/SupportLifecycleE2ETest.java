package com.homestay.service;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.ContactMessageDAO;
import com.homestay.dao.SupportReplyDAO;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * SupportLifecycleE2ETest - Full end-to-end lifecycle integration test covering:
 * 1. Customer creates ticket NEW.
 * 2. Admin claims ticket -> PROCESSING.
 * 3. Admin replies; Customer can see the reply.
 * 4. Customer adds follow-up message; Admin can see it.
 * 5. Admin resolves ticket -> RESOLVED.
 * 6. Customer replies to RESOLVED ticket -> automatically re-opens to PROCESSING.
 * 7. Host cannot perform Admin management operations.
 */
class SupportLifecycleE2ETest {

    private ContactMessageDAO contactMessageDAO;
    private SupportReplyDAO supportReplyDAO;
    private BookingDAO bookingDAO;
    private Connection mockConnection;
    private SupportService supportService;

    private User customer;
    private User admin;
    private User host;

    private ContactMessage inMemoryTicket;
    private List<SupportReply> inMemoryReplies;

    @BeforeEach
    void setUp() throws SQLException {
        contactMessageDAO = mock(ContactMessageDAO.class);
        supportReplyDAO = mock(SupportReplyDAO.class);
        bookingDAO = mock(BookingDAO.class);
        mockConnection = mock(Connection.class);

        // Subclass SupportService to inject mock connection
        supportService = new SupportService(contactMessageDAO, supportReplyDAO, bookingDAO) {
            @Override
            protected Connection getConnection() {
                return mockConnection;
            }
        };

        // Customer
        customer = new User();
        customer.setId(101);
        customer.setUsername("customer_le");
        customer.setFullName("Le Van Customer");
        customer.setEmail("customer@gmail.com");
        customer.setRole(new Role(2, "ROLE_CUSTOMER", "Customer"));

        // Admin
        admin = new User();
        admin.setId(1);
        admin.setUsername("admin_support");
        admin.setFullName("Nguyen Admin Support");
        admin.setEmail("admin@sogohomestay.com");
        admin.setRole(new Role(1, "ROLE_ADMIN", "Admin"));

        // Host
        host = new User();
        host.setId(202);
        host.setUsername("host_tran");
        host.setFullName("Tran Van Host");
        host.setEmail("host@gmail.com");
        host.setRole(new Role(3, "ROLE_HOST", "Host"));

        inMemoryReplies = new ArrayList<>();

        // Wire in-memory state store for ContactMessageDAO
        when(contactMessageDAO.insert(any(ContactMessage.class), eq(mockConnection))).thenAnswer(inv -> {
            ContactMessage m = inv.getArgument(0);
            m.setMessageId(999);
            inMemoryTicket = m;
            return true;
        });

        when(contactMessageDAO.findById(999)).thenAnswer(inv -> {
            if (inMemoryTicket != null) {
                ContactMessage copy = new ContactMessage();
                copy.setMessageId(inMemoryTicket.getMessageId());
                copy.setUserId(inMemoryTicket.getUserId());
                copy.setTicketCode(inMemoryTicket.getTicketCode());
                copy.setFullName(inMemoryTicket.getFullName());
                copy.setEmail(inMemoryTicket.getEmail());
                copy.setSubject(inMemoryTicket.getSubject());
                copy.setMessage(inMemoryTicket.getMessage());
                copy.setStatus(inMemoryTicket.getStatus());
                copy.setCategory(inMemoryTicket.getCategory());
                copy.setReplies(new ArrayList<>(inMemoryReplies));
                return Optional.of(copy);
            }
            return Optional.empty();
        });

        when(contactMessageDAO.findByIdAndUserId(999, 101)).thenAnswer(inv -> {
            if (inMemoryTicket != null && inMemoryTicket.getUserId() == 101) {
                return Optional.of(inMemoryTicket);
            }
            return Optional.empty();
        });

        when(contactMessageDAO.updateStatus(eq(999), any(TicketStatus.class), any(TicketStatus.class), any(Connection.class)))
                .thenAnswer(inv -> {
                    TicketStatus newStatus = inv.getArgument(1);
                    inMemoryTicket.setStatus(newStatus);
                    return true;
                });

        when(contactMessageDAO.updateStatus(eq(999), any(TicketStatus.class), any(TicketStatus.class)))
                .thenAnswer(inv -> {
                    TicketStatus newStatus = inv.getArgument(1);
                    inMemoryTicket.setStatus(newStatus);
                    return true;
                });

        when(supportReplyDAO.insert(any(SupportReply.class), eq(mockConnection))).thenAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(inMemoryReplies.size() + 1);
            if (r.getSenderId() == admin.getId()) {
                r.setSenderRole("ROLE_ADMIN");
                r.setSenderName(admin.getFullName());
            } else if (r.getSenderId() == customer.getId()) {
                r.setSenderRole("ROLE_CUSTOMER");
                r.setSenderName(customer.getFullName());
            }
            inMemoryReplies.add(r);
            return true;
        });

        when(supportReplyDAO.findByTicketId(999)).thenAnswer(inv -> new ArrayList<>(inMemoryReplies));
    }

    @Test
    @DisplayName("End-to-End full lifecycle of ticket from Customer -> Admin processing -> resolve -> Customer reopen")
    void testFullSupportLifecycleEndToEnd() {
        // Step 1: Customer creates ticket NEW
        ContactMessage newTicket = new ContactMessage();
        newTicket.setSubject("Yêu cầu hướng dẫn check-in");
        newTicket.setMessage("Tôi muốn hỏi giờ nhận phòng sớm của homestay Đà Lạt.");
        newTicket.setCategory(TicketCategory.BOOKING_INQUIRY);

        ContactMessage created = supportService.createTicket(newTicket, customer);
        assertNotNull(created);
        assertEquals(999, created.getMessageId());
        assertEquals(TicketStatus.NEW, inMemoryTicket.getStatus());
        assertTrue(created.getTicketCode().startsWith("TK-"));

        // Step 2: Admin claims ticket -> PROCESSING
        boolean claimed = supportService.updateTicketStatus(999, TicketStatus.PROCESSING, TicketStatus.NEW, true);
        assertTrue(claimed, "Admin should successfully claim NEW ticket to PROCESSING");
        assertEquals(TicketStatus.PROCESSING, inMemoryTicket.getStatus());

        // Step 3: Admin replies; Customer views the reply in thread
        SupportReply adminReply = supportService.addAdminReply(
                999, admin.getId(),
                "Chào bạn, homestay hỗ trợ nhận phòng sớm từ 12:00 nếu phòng trống nhé.",
                false
        );
        assertNotNull(adminReply);
        assertEquals(TicketStatus.PROCESSING, inMemoryTicket.getStatus()); // Does NOT auto-resolve

        // Customer views ticket details
        Optional<ContactMessage> customerView = supportService.getTicketDetailForUser(999, customer.getId());
        assertTrue(customerView.isPresent());
        assertEquals(1, customerView.get().getReplies().size());
        assertEquals("Chào bạn, homestay hỗ trợ nhận phòng sớm từ 12:00 nếu phòng trống nhé.",
                customerView.get().getReplies().get(0).getMessage());
        assertEquals("ROLE_ADMIN", customerView.get().getReplies().get(0).getSenderRole());

        // Step 4: Customer adds follow-up message; Admin views it
        SupportReply customerReply = supportService.addSenderReply(
                999, customer.getId(),
                "Dạ vâng em cảm ơn ban quản trị nhiều ạ!"
        );
        assertNotNull(customerReply);

        // Admin views ticket details
        Optional<ContactMessage> adminView = supportService.getTicketDetailForAdmin(999);
        assertTrue(adminView.isPresent());
        assertEquals(2, adminView.get().getReplies().size());
        assertEquals("ROLE_CUSTOMER", adminView.get().getReplies().get(1).getSenderRole());

        // Step 5: Admin resolves ticket -> RESOLVED
        boolean resolved = supportService.updateTicketStatus(999, TicketStatus.RESOLVED, TicketStatus.PROCESSING, true);
        assertTrue(resolved, "Admin marks ticket as RESOLVED");
        assertEquals(TicketStatus.RESOLVED, inMemoryTicket.getStatus());

        // Step 6: Customer sends another message into RESOLVED ticket -> automatically re-opens to PROCESSING
        SupportReply reopenReply = supportService.addSenderReply(
                999, customer.getId(),
                "Em muốn hỏi thêm chút về phụ phí trả phòng muộn thì tính thế nào ạ?"
        );
        assertNotNull(reopenReply);
        assertEquals(TicketStatus.PROCESSING, inMemoryTicket.getStatus(),
                "Ticket should automatically reopen to PROCESSING when sender sends a new reply");
        assertEquals(3, inMemoryReplies.size());

        // Step 7: Host attempts to call Admin status update -> rejected with SecurityException
        assertThrows(SecurityException.class, () -> {
            supportService.updateTicketStatus(999, TicketStatus.RESOLVED, false);
        }, "Non-admin must be rejected when attempting to update status");
    }

    @Test
    @DisplayName("Admin status transition rules: cannot jump NEW -> RESOLVED without PROCESSING")
    void testInvalidTransitionNewToResolvedRejected() {
        inMemoryTicket = new ContactMessage();
        inMemoryTicket.setMessageId(999);
        inMemoryTicket.setStatus(TicketStatus.NEW);

        assertThrows(IllegalStateException.class, () -> {
            supportService.updateTicketStatus(999, TicketStatus.RESOLVED, true);
        }, "Admin cannot skip PROCESSING and jump directly from NEW to RESOLVED");
    }

    @Test
    @DisplayName("Host cannot access or reply on ticket belonging to another customer")
    void testHostCannotAccessCustomerTicket() {
        inMemoryTicket = new ContactMessage();
        inMemoryTicket.setMessageId(999);
        inMemoryTicket.setUserId(customer.getId());
        inMemoryTicket.setStatus(TicketStatus.PROCESSING);

        // Host tries to view
        Optional<ContactMessage> hostView = supportService.getTicketDetailForUser(999, host.getId());
        assertTrue(hostView.isEmpty(), "Host must not be able to retrieve ticket owned by Customer");

        // Host tries to reply
        assertThrows(SecurityException.class, () -> {
            supportService.addSenderReply(999, host.getId(), "Phản hồi trái phép từ Host khác");
        }, "Host must be blocked from replying to another user's ticket");
    }
}
