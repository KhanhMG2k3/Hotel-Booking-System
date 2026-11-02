package com.homestay.controller;

import com.homestay.dao.ContactMessageDAO;
import com.homestay.dao.SupportReplyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.ContactMessage;
import com.homestay.model.Role;
import com.homestay.model.SupportReply;
import com.homestay.model.TicketStatus;
import com.homestay.model.User;
import com.homestay.service.SupportService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests verifying SupportController security boundaries, ownership checks,
 * my-tickets listing, and threaded reply handling.
 */
class SupportControllerTest {

    private SupportService supportService;
    private ContactMessageDAO contactMessageDAO;
    private SupportReplyDAO supportReplyDAO;
    private UserDAO userDAO;
    private SupportController controller;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    @BeforeEach
    void setUp() {
        supportService = mock(SupportService.class);
        contactMessageDAO = mock(ContactMessageDAO.class);
        supportReplyDAO = mock(SupportReplyDAO.class);
        userDAO = mock(UserDAO.class);
        controller = new SupportController(supportService, contactMessageDAO, supportReplyDAO, userDAO);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);

        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getContextPath()).thenReturn("/app");
    }

    private User createUser(int id, String roleName) {
        User u = new User();
        u.setId(id);
        u.setUsername("user" + id);
        u.setFullName("User " + id);
        u.setEmail("user" + id + "@example.com");
        u.setRole(new Role(2, roleName, roleName));
        return u;
    }

    @Test
    @DisplayName("GET /support/my-tickets: Guest is redirected to login")
    void testMyTicketsGuestRedirects() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        controller.doGet(request, response);

        verify(response).sendRedirect("/app/login?redirect=/support/my-tickets");
        verifyNoInteractions(contactMessageDAO);
    }

    @Test
    @DisplayName("GET /support/my-tickets: User only sees tickets belonging to their own user_id")
    void testMyTicketsUserBoundaryEnforced() throws Exception {
        User customer = createUser(2, "ROLE_CUSTOMER");
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(request.getPathInfo()).thenReturn("/my-tickets");

        when(contactMessageDAO.findByUserId(eq(2), any(), eq(1), eq(10)))
                .thenReturn(Collections.emptyList());
        when(contactMessageDAO.countByUserId(eq(2), any())).thenReturn(0);

        controller.doGet(request, response);

        verify(contactMessageDAO).findByUserId(eq(2), isNull(), eq(1), eq(10));
        verify(contactMessageDAO).countByUserId(eq(2), isNull());
        verify(request).getRequestDispatcher("/WEB-INF/views/my-tickets.jsp");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("GET /support/ticket: Owner can view ticket details and reply thread")
    void testTicketDetailOwnerAccessAllowed() throws Exception {
        User customer = createUser(2, "ROLE_CUSTOMER");
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(request.getPathInfo()).thenReturn("/ticket");
        when(request.getParameter("code")).thenReturn("TK-20261031-1001");

        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(1);
        ticket.setTicketCode("TK-20261031-1001");
        ticket.setUserId(2); // Same as current user

        when(contactMessageDAO.findByTicketCode("TK-20261031-1001")).thenReturn(Optional.of(ticket));
        when(supportReplyDAO.findByTicketId(1)).thenReturn(List.of(new SupportReply()));

        controller.doGet(request, response);

        verify(request).setAttribute(eq("ticket"), eq(ticket));
        verify(supportReplyDAO).findByTicketId(1);
        verify(request).getRequestDispatcher("/WEB-INF/views/ticket-detail.jsp");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("GET /support/ticket: Non-owner is BLOCKED and ticket data is NEVER exposed to JSP")
    void testTicketDetailNonOwnerBlocked() throws Exception {
        User impostor = createUser(5, "ROLE_CUSTOMER"); // Impostor with user_id = 5
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(impostor);
        when(request.getPathInfo()).thenReturn("/ticket");
        when(request.getParameter("code")).thenReturn("TK-20261031-1001");

        ContactMessage victimTicket = new ContactMessage();
        victimTicket.setMessageId(1);
        victimTicket.setTicketCode("TK-20261031-1001");
        victimTicket.setUserId(2); // Belongs to user_id = 2

        when(contactMessageDAO.findByTicketCode("TK-20261031-1001")).thenReturn(Optional.of(victimTicket));

        controller.doGet(request, response);

        // Verify redirection and that detail JSP was NEVER requested
        verify(response).sendRedirect(contains("/app/support/my-tickets?error="));
        verify(request, never()).getRequestDispatcher("/WEB-INF/views/ticket-detail.jsp");
        verifyNoInteractions(supportReplyDAO);
    }

    @Test
    @DisplayName("POST /support/reply: Owner sends reply successfully")
    void testPostReplySuccess() throws Exception {
        User customer = createUser(2, "ROLE_CUSTOMER");
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(request.getPathInfo()).thenReturn("/reply");

        when(request.getParameter("ticketId")).thenReturn("1");
        when(session.getAttribute("loginCsrfToken")).thenReturn("token123");
        when(request.getParameter("csrfToken")).thenReturn("token123");
        when(request.getParameter("message")).thenReturn("Cảm ơn, tôi muốn hỏi thêm thông tin này.");

        controller.doPost(request, response);

        verify(supportService).addSenderReply(1, 2, "Cảm ơn, tôi muốn hỏi thêm thông tin này.");
        verify(session).setAttribute(eq("LAST_REPLY_TIME"), anyLong());
        verify(response).sendRedirect("/app/support/ticket?id=1&replySuccess=1");
    }

    @Test
    @DisplayName("POST /support/reply: Rejects reply when CSRF token is invalid")
    void testPostReplyInvalidCsrfRejected() throws Exception {
        User customer = createUser(2, "ROLE_CUSTOMER");
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(request.getPathInfo()).thenReturn("/reply");

        when(request.getParameter("ticketId")).thenReturn("1");
        when(session.getAttribute("loginCsrfToken")).thenReturn("valid-token");
        when(request.getParameter("csrfToken")).thenReturn("wrong-token");

        controller.doPost(request, response);

        verify(response).sendRedirect(contains("replyError="));
        verifyNoInteractions(supportService);
    }

    @Test
    @DisplayName("POST /support/reply: Rejects reply when rate-limit cooldown is active")
    void testPostReplyRateLimited() throws Exception {
        User customer = createUser(2, "ROLE_CUSTOMER");
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(request.getPathInfo()).thenReturn("/reply");

        when(request.getParameter("ticketId")).thenReturn("1");
        when(session.getAttribute("loginCsrfToken")).thenReturn("token123");
        when(request.getParameter("csrfToken")).thenReturn("token123");
        when(session.getAttribute("LAST_REPLY_TIME")).thenReturn(System.currentTimeMillis() - 1000); // 1s ago (< 5s)

        controller.doPost(request, response);

        verify(response).sendRedirect(contains("replyError="));
        verifyNoInteractions(supportService);
    }

    @Test
    @DisplayName("POST /support/reply: Blocked when user tries to reply to another user's ticket")
    void testPostReplyNonOwnerBlocked() throws Exception {
        User impostor = createUser(5, "ROLE_CUSTOMER");
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(impostor);
        when(request.getPathInfo()).thenReturn("/reply");

        when(request.getParameter("ticketId")).thenReturn("1");
        when(session.getAttribute("loginCsrfToken")).thenReturn("token123");
        when(request.getParameter("csrfToken")).thenReturn("token123");
        when(request.getParameter("message")).thenReturn("Tin nhắn giả mạo.");

        doThrow(new SecurityException("Bạn không có quyền phản hồi trên yêu cầu hỗ trợ của người khác."))
                .when(supportService).addSenderReply(1, 5, "Tin nhắn giả mạo.");

        controller.doPost(request, response);

        verify(response).sendRedirect(contains("/app/support/my-tickets?error="));
    }
}
