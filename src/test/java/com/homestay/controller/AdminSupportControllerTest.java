package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.ContactMessage;
import com.homestay.model.Role;
import com.homestay.model.Room;
import com.homestay.model.SupportReply;
import com.homestay.model.TicketCategory;
import com.homestay.model.TicketStatus;
import com.homestay.model.User;
import com.homestay.service.SupportService;
import com.homestay.util.LoginUtil;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AdminSupportControllerTest {

    private SupportService supportService;
    private BookingDAO bookingDAO;
    private RoomDAO roomDAO;
    private UserDAO userDAO;
    private AdminSupportController controller;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    private User adminUser;
    private User customerUser;
    private User hostUser;

    @BeforeEach
    void setUp() {
        supportService = mock(SupportService.class);
        bookingDAO = mock(BookingDAO.class);
        roomDAO = mock(RoomDAO.class);
        userDAO = mock(UserDAO.class);

        controller = new AdminSupportController(supportService, bookingDAO, roomDAO, userDAO);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);

        when(request.getContextPath()).thenReturn("/test");
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);

        // Admin User (Role 1)
        adminUser = new User();
        adminUser.setId(1);
        adminUser.setUsername("admin");
        adminUser.setFullName("System Admin");
        Role adminRole = new Role(1, "ROLE_ADMIN", "Admin");
        adminUser.setRole(adminRole);

        // Customer User (Role 2)
        customerUser = new User();
        customerUser.setId(10);
        customerUser.setUsername("customer");
        customerUser.setFullName("Customer John");
        Role customerRole = new Role(2, "ROLE_CUSTOMER", "Customer");
        customerUser.setRole(customerRole);

        // Host User (Role 3)
        hostUser = new User();
        hostUser.setId(20);
        hostUser.setUsername("host");
        hostUser.setFullName("Host Jane");
        Role hostRole = new Role(3, "ROLE_HOST", "Host");
        hostUser.setRole(hostRole);
    }

    private void authenticateAs(User user) {
        when(request.getSession()).thenReturn(session);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(user);
        when(session.getAttribute("userId")).thenReturn(user.getId());
        when(session.getAttribute("roleId")).thenReturn(user.getRole().getId());
    }

    @Test
    @DisplayName("GET /admin/support - Unauthenticated guest is redirected to login")
    void testGetListUnauthenticatedRedirectsToLogin() throws ServletException, IOException {
        when(request.getSession(false)).thenReturn(null);

        controller.doGet(request, response);

        verify(response).sendRedirect("/test/login");
        verify(request, never()).getRequestDispatcher(anyString());
    }

    @Test
    @DisplayName("GET /admin/support - Customer is rejected with 403 Forbidden")
    void testGetListCustomerRejectedWith403() throws ServletException, IOException {
        authenticateAs(customerUser);

        controller.doGet(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(request, never()).getRequestDispatcher(anyString());
    }

    @Test
    @DisplayName("GET /admin/support - Host is rejected with 403 Forbidden")
    void testGetListHostRejectedWith403() throws ServletException, IOException {
        authenticateAs(hostUser);

        controller.doGet(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(request, never()).getRequestDispatcher(anyString());
    }

    @Test
    @DisplayName("GET /admin/support - Admin successfully views ticket list with filters and KPIs")
    void testGetListAdminSuccess() throws ServletException, IOException {
        authenticateAs(adminUser);
        when(request.getPathInfo()).thenReturn("/list");
        when(request.getParameter("status")).thenReturn("NEW");
        when(request.getParameter("page")).thenReturn("1");

        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(101);
        ticket.setTicketCode("TK-20261031-ABCD");
        ticket.setSubject("Need refund help");
        ticket.setStatus(TicketStatus.NEW);

        when(supportService.findTicketsForAdmin(eq("NEW"), any(), any(), anyString(), anyString(), eq(1), eq(10)))
                .thenReturn(List.of(ticket));
        when(supportService.countTicketsForAdmin(eq("NEW"), any(), any())).thenReturn(1);

        Map<String, Integer> kpi = new HashMap<>();
        kpi.put("TOTAL", 5);
        kpi.put("NEW", 1);
        kpi.put("PROCESSING", 2);
        kpi.put("RESOLVED", 2);
        when(supportService.getAdminTicketKpiStats()).thenReturn(kpi);

        controller.doGet(request, response);

        verify(request).setAttribute(eq("tickets"), any());
        verify(request).setAttribute("statusFilter", "NEW");
        verify(request).setAttribute("totalTickets", 1);
        verify(request).setAttribute("kpiStats", kpi);
        verify(request).getRequestDispatcher("/WEB-INF/views/admin/admin-support-list.jsp");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("GET /admin/support/detail - Admin views ticket and sanitized booking without sensitive data")
    void testGetDetailAdminSuccess() throws ServletException, IOException {
        authenticateAs(adminUser);
        when(request.getPathInfo()).thenReturn("/detail");
        when(request.getParameter("id")).thenReturn("50");

        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(50);
        ticket.setTicketCode("TK-20261031-WXYZ");
        ticket.setBookingId(77);
        ticket.setStatus(TicketStatus.NEW);

        when(supportService.getTicketDetailForAdmin(50)).thenReturn(Optional.of(ticket));

        Booking booking = new Booking();
        booking.setId(77);
        booking.setBookingCode("BK-9999");
        booking.setRoomId(12);
        booking.setStatus("CONFIRMED");
        when(bookingDAO.findById(77)).thenReturn(Optional.of(booking));

        Room room = new Room();
        room.setId(12);
        room.setRoomName("Deluxe Ocean View");
        when(roomDAO.findById(12)).thenReturn(Optional.of(room));

        controller.doGet(request, response);

        verify(request).setAttribute("ticket", ticket);
        @SuppressWarnings("unchecked")
        ArgumentCaptor<Map<String, Object>> bookingCaptor = ArgumentCaptor.forClass(Map.class);
        verify(request).setAttribute(eq("relatedBooking"), bookingCaptor.capture());

        Map<String, Object> sanitized = bookingCaptor.getValue();
        assertEquals("BK-9999", sanitized.get("bookingCode"));
        assertEquals("Deluxe Ocean View", sanitized.get("roomName"));
        // Ensure sensitive fields (pricing breakdown, card tokens, bank) are NOT present
        assertNull(sanitized.get("totalPrice"));
        assertNull(sanitized.get("creditCard"));

        verify(request).getRequestDispatcher("/WEB-INF/views/admin/admin-support-detail.jsp");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("POST /admin/support/status - Admin successfully claims ticket NEW -> PROCESSING")
    void testPostStatusNewToProcessingSuccess() throws ServletException, IOException {
        authenticateAs(adminUser);
        when(request.getPathInfo()).thenReturn("/status");
        when(request.getParameter("ticketId")).thenReturn("101");
        when(request.getParameter("expectedStatus")).thenReturn("NEW");
        when(request.getParameter("newStatus")).thenReturn("PROCESSING");
        when(request.getParameter("csrfToken")).thenReturn("valid-csrf");
        when(session.getAttribute("loginCsrfToken")).thenReturn("valid-csrf");

//        when(supportService.updateTicketStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, true))
//                .thenReturn(true);
        // CAP NHAT KIEM THU THEO PHUONG THUC CO ACTORUSERID (DOT 5)
        when(supportService.updateTicketStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, true, adminUser.getId()))
                .thenReturn(true);

        controller.doPost(request, response);

//        verify(supportService).updateTicketStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, true);
        // XAC MINH CONTROLLER TRUYEN ADMINUSER.GETID() DE CHONG TU GUI THONG BAO CHO CHINH ACTOR (DOT 5)
        verify(supportService).updateTicketStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, true, adminUser.getId());
        verify(session).setAttribute(eq("supportSuccessMsg"), anyString());
        verify(response).sendRedirect("/test/admin/support/detail?id=101");
    }

    @Test
    @DisplayName("POST /admin/support/status - Concurrency conflict detected via optimistic locking")
    void testPostStatusConcurrencyConflict() throws ServletException, IOException {
        authenticateAs(adminUser);
        when(request.getPathInfo()).thenReturn("/status");
        when(request.getParameter("ticketId")).thenReturn("101");
        when(request.getParameter("expectedStatus")).thenReturn("NEW");
        when(request.getParameter("newStatus")).thenReturn("PROCESSING");
        when(request.getParameter("csrfToken")).thenReturn("valid-csrf");
        when(session.getAttribute("loginCsrfToken")).thenReturn("valid-csrf");

        // Another admin already moved it, so updateTicketStatus returns false
//        when(supportService.updateTicketStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, true))
//                .thenReturn(false);
        // CAP NHAT KIEM THU XUNG DOT DONG THOI VOI THAM SO ACTORUSERID (DOT 5)
        when(supportService.updateTicketStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, true, adminUser.getId()))
                .thenReturn(false);

        controller.doPost(request, response);

        verify(session).setAttribute(eq("supportErrorMsg"),
                argThat(msg -> msg.toString().contains("Cảnh báo xung đột đồng thời")));
        verify(response).sendRedirect("/test/admin/support/detail?id=101");
    }

    @Test
    @DisplayName("POST /admin/support/status - Host calling admin action is rejected with 403 Forbidden")
    void testPostStatusHostRejectedWith403() throws ServletException, IOException {
        authenticateAs(hostUser);
        when(request.getPathInfo()).thenReturn("/status");

        controller.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(supportService, never()).updateTicketStatus(anyInt(), any(), any(), anyBoolean());
    }

    @Test
    @DisplayName("POST /admin/support/reply - Admin replies and touches timestamp without auto-resolving")
    void testPostAdminReplySuccess() throws ServletException, IOException {
        authenticateAs(adminUser);
        when(request.getPathInfo()).thenReturn("/reply");
        when(request.getParameter("ticketId")).thenReturn("101");
        when(request.getParameter("message")).thenReturn("Chúng tôi đã tiếp nhận yêu cầu và đang kiểm tra với Host.");
        when(request.getParameter("changeToProcessing")).thenReturn("true");
        when(request.getParameter("csrfToken")).thenReturn("valid-csrf");
        when(session.getAttribute("loginCsrfToken")).thenReturn("valid-csrf");
        when(session.getAttribute("LAST_ADMIN_REPLY_TIME")).thenReturn(null);

        controller.doPost(request, response);

        verify(supportService).addAdminReply(eq(101), eq(adminUser.getId()),
                eq("Chúng tôi đã tiếp nhận yêu cầu và đang kiểm tra với Host."), eq(true));
        verify(session).setAttribute(eq("supportSuccessMsg"), anyString());
        verify(response).sendRedirect("/test/admin/support/detail?id=101");
    }

    @Test
    @DisplayName("POST /admin/support/reply - Cooldown rate limit rejects rapid replies")
    void testPostAdminReplyRateLimitCooldown() throws ServletException, IOException {
        authenticateAs(adminUser);
        when(request.getPathInfo()).thenReturn("/reply");
        when(request.getParameter("ticketId")).thenReturn("101");
        when(request.getParameter("message")).thenReturn("Phản hồi nhanh");
        when(request.getParameter("csrfToken")).thenReturn("valid-csrf");
        when(session.getAttribute("loginCsrfToken")).thenReturn("valid-csrf");
        // Simulated last reply just 500ms ago
        when(session.getAttribute("LAST_ADMIN_REPLY_TIME")).thenReturn(System.currentTimeMillis() - 500L);

        controller.doPost(request, response);

        verify(supportService, never()).addAdminReply(anyInt(), anyInt(), anyString(), anyBoolean());
        verify(session).setAttribute(eq("supportErrorMsg"),
                argThat(msg -> msg.toString().contains("Bạn đang gửi phản hồi quá nhanh")));
        verify(response).sendRedirect("/test/admin/support/detail?id=101");
    }

    private static <T> T argThat(org.mockito.ArgumentMatcher<T> matcher) {
        return org.mockito.ArgumentMatchers.argThat(matcher);
    }
}
