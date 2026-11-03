package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.ContactMessageDAO;
import com.homestay.dao.NotificationDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.SupportReplyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.exception.DataAccessException;
import com.homestay.model.ContactMessage;
import com.homestay.model.Role;
import com.homestay.model.SupportReply;
import com.homestay.model.TicketCategory;
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
import org.mockito.ArgumentCaptor;

import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * BO KIEM THU NGHIEM THU DOT 6/6 (PERMISSION, TRANSITION, IDEMPOTENCY, PARAMETER TAMPERING & DB ERROR SANITIZATION)
 */
class SupportAcceptanceAuditTest {

    private ContactMessageDAO contactMessageDAO;
    private SupportReplyDAO supportReplyDAO;
    private BookingDAO bookingDAO;
    private UserDAO userDAO;
    private NotificationDAO notificationDAO;
    private RoomDAO roomDAO;
    private Connection mockConnection;
    private SupportService supportService;

    private ContactController contactController;
    private SupportController supportController;
    private AdminSupportController adminSupportController;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;
    private Map<String, Object> sessionStore;

    @BeforeEach
    void setUp() throws Exception {
        contactMessageDAO = mock(ContactMessageDAO.class);
        supportReplyDAO = mock(SupportReplyDAO.class);
        bookingDAO = mock(BookingDAO.class);
        userDAO = mock(UserDAO.class);
        notificationDAO = mock(NotificationDAO.class);
        roomDAO = mock(RoomDAO.class);
        mockConnection = mock(Connection.class);

        supportService = new SupportService(contactMessageDAO, supportReplyDAO, bookingDAO, notificationDAO) {
            @Override
            protected Connection getConnection() {
                return mockConnection;
            }
        };

        contactController = new ContactController(supportService, bookingDAO, userDAO);
        supportController = new SupportController(supportService, contactMessageDAO, supportReplyDAO, userDAO);
        adminSupportController = new AdminSupportController(supportService, bookingDAO, roomDAO, userDAO);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);
        sessionStore = new HashMap<>();

        when(request.getContextPath()).thenReturn("/HomestayBooking");
        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(request.getSession()).thenReturn(session);

        // MO PHONG HTTP SESSION THUC TE DE KIEM TRA TIEU HAO ONE-TIME CSRF TOKEN VA LUU DRAFT
        doAnswer(inv -> sessionStore.get(inv.getArgument(0))).when(session).getAttribute(anyString());
        doAnswer(inv -> {
            sessionStore.put(inv.getArgument(0), inv.getArgument(1));
            return null;
        }).when(session).setAttribute(anyString(), any());
        doAnswer(inv -> {
            sessionStore.remove(inv.getArgument(0));
            return null;
        }).when(session).removeAttribute(anyString());
    }

    private User buildUser(int id, String username, String roleName) {
        User u = new User();
        u.setId(id);
        u.setUsername(username);
        u.setFullName("User " + username);
        u.setEmail(username + "@sogo.vn");
        u.setPhone("0901234567");
        u.setRole(new Role(id, roleName, roleName));
        return u;
    }

    @Test
    @DisplayName("1. Parameter Tampering: Spoofed senderId, role, recipientId, status in POST /contact are ignored")
    void testParameterTamperingIgnoredOnCreateTicket() throws Exception {
        User realCustomer = buildUser(8, "hoangnam", "ROLE_CUSTOMER");
        sessionStore.put("user", realCustomer);
        sessionStore.put("loginCsrfToken", "csrf-once-1");

        // GIA MAO THAM SO REQUEST: SENDERID=1, ROLE=ROLE_ADMIN, RECIPIENTID=99, STATUS=RESOLVED
        when(request.getParameter("csrfToken")).thenReturn("csrf-once-1");
        when(request.getParameter("senderId")).thenReturn("1");
        when(request.getParameter("userId")).thenReturn("1");
        when(request.getParameter("role")).thenReturn("ROLE_ADMIN");
        when(request.getParameter("recipientId")).thenReturn("99");
        when(request.getParameter("status")).thenReturn("RESOLVED");
        when(request.getParameter("category")).thenReturn("GENERAL_FEEDBACK");
        when(request.getParameter("subject")).thenReturn("Cần tư vấn quy định nhận phòng");
        when(request.getParameter("message")).thenReturn("Cho tôi hỏi quy định nhận phòng sớm tại Đà Lạt như thế nào?");

        when(contactMessageDAO.findByTicketCode(anyString())).thenReturn(Optional.empty());
        doAnswer(inv -> {
            ContactMessage t = inv.getArgument(0);
            t.setMessageId(501);
            return true;
        }).when(contactMessageDAO).insert(any(ContactMessage.class), eq(mockConnection));
        when(notificationDAO.findActiveAdminIds(mockConnection)).thenReturn(List.of(1));

        contactController.doPost(request, response);

        ArgumentCaptor<ContactMessage> msgCaptor = ArgumentCaptor.forClass(ContactMessage.class);
        verify(contactMessageDAO).insert(msgCaptor.capture(), eq(mockConnection));
        ContactMessage saved = msgCaptor.getValue();

        // XAC MINH DANH TINH VA TRANG THAI LAY TU SESSION/BACKEND, KHONG DUNG THAM SO GIA MAO
        assertEquals(8, saved.getUserId());
        assertEquals("hoangnam@sogo.vn", saved.getEmail());
        assertEquals(TicketStatus.NEW, saved.getStatus());

        // RECIPIENT LAY TU DATABASE (ADMIN ID = 1), KHONG GUI CHO RECIPIENTID=99
        verify(notificationDAO).createNotificationIfAbsent(
                eq(1), anyString(), anyString(), eq("SYSTEM"),
                eq("/admin/support/detail?id=501"), eq(mockConnection));
        verify(notificationDAO, never()).createNotificationIfAbsent(
                eq(99), anyString(), anyString(), anyString(), anyString(), any());
    }

    @Test
    @DisplayName("2. CSRF Replay / Double-Submit Idempotency: Second identical POST /contact is blocked")
    void testCsrfOneTimeConsumptionPreventsDuplicateSubmit() throws Exception {
        User customer = buildUser(8, "hoangnam", "ROLE_CUSTOMER");
        sessionStore.put("user", customer);
        sessionStore.put("loginCsrfToken", "csrf-unique-token");

        when(request.getParameter("csrfToken")).thenReturn("csrf-unique-token");
        when(request.getParameter("category")).thenReturn("BOOKING_INQUIRY");
        when(request.getParameter("subject")).thenReturn("Hỏi về lịch nhận phòng");
        when(request.getParameter("message")).thenReturn("Nội dung gửi yêu cầu hỗ trợ hợp lệ trên 10 ký tự.");

        when(contactMessageDAO.findByTicketCode(anyString())).thenReturn(Optional.empty());
        doAnswer(inv -> {
            ContactMessage t = inv.getArgument(0);
            t.setMessageId(601);
            return true;
        }).when(contactMessageDAO).insert(any(ContactMessage.class), eq(mockConnection));
        when(notificationDAO.findActiveAdminIds(mockConnection)).thenReturn(List.of(1));

        // LAN SUBMIT 1 -> THANH CONG VA TIEU HAO TOKEN KHOI SESSION
        contactController.doPost(request, response);
        assertNull(sessionStore.get("loginCsrfToken"), "Token một lần phải bị xóa ngay sau lần submit hợp lệ đầu tiên");

        // LAN SUBMIT 2 (DOUBLE CLICK VOI CUNG TOKEN CU) -> BI CHAN NGAY TAI CSRF CHECK VA CAP TOKEN MOI KHAC TOKEN CU
        contactController.doPost(request, response);

        verify(contactMessageDAO, times(1)).insert(any(ContactMessage.class), eq(mockConnection));
        assertNotEquals("csrf-unique-token", sessionStore.get("loginCsrfToken"));
    }

    @Test
    @DisplayName("3. Permission Matrix: Customer & Host calling Admin POST /reply and /status get 403 Forbidden")
    void testCustomerAndHostRejectedFromAllAdminPostActions() throws Exception {
        User customer = buildUser(2, "khanhmg", "ROLE_CUSTOMER");
        sessionStore.put("user", customer);
        when(request.getPathInfo()).thenReturn("/reply");

        adminSupportController.doPost(request, response);
        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());

        reset(response);
        User host = buildUser(3, "hostdemo", "ROLE_HOST");
        sessionStore.put("user", host);
        when(request.getPathInfo()).thenReturn("/reply");

        adminSupportController.doPost(request, response);
        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());

        verify(supportReplyDAO, never()).insert(any(SupportReply.class), any(Connection.class));
        verify(contactMessageDAO, never()).updateStatus(anyInt(), any(), any(), any(Connection.class));
    }

    @Test
    @DisplayName("4. Permission Matrix: Host cannot access or reply to Customer's ticket via GET/POST")
    void testHostCannotAccessOrReplyCustomerTicket() throws Exception {
        User host = buildUser(3, "hostdemo", "ROLE_HOST");
        sessionStore.put("user", host);

        ContactMessage customerTicket = new ContactMessage();
        customerTicket.setMessageId(77);
        customerTicket.setTicketCode("TK-20261101-CUST");
        customerTicket.setUserId(2); // THUOC CUSTOMER #2
        customerTicket.setStatus(TicketStatus.PROCESSING);

        when(contactMessageDAO.findById(77)).thenReturn(Optional.of(customerTicket));
        when(contactMessageDAO.findByTicketCode("TK-20261101-CUST")).thenReturn(Optional.of(customerTicket));

        // GET BY CODE -> REDIRECTED
        when(request.getPathInfo()).thenReturn("/ticket");
        when(request.getParameter("code")).thenReturn("TK-20261101-CUST");
        supportController.doGet(request, response);
        verify(response).sendRedirect(contains("/HomestayBooking/support/my-tickets?error="));

        // POST REPLY BY ID -> BLOCKED BY OWNERSHIP CHECK
        reset(response);
        sessionStore.put("loginCsrfToken", "csrf-host");
        when(request.getPathInfo()).thenReturn("/reply");
        when(request.getParameter("ticketId")).thenReturn("77");
        when(request.getParameter("csrfToken")).thenReturn("csrf-host");
        when(request.getParameter("message")).thenReturn("Host cố tình gửi phản hồi vào ticket của khách.");

        supportController.doPost(request, response);
        verify(response).sendRedirect(contains("/HomestayBooking/support/my-tickets?error="));
        verify(supportReplyDAO, never()).insert(any(SupportReply.class), any(Connection.class));
    }

    @Test
    @DisplayName("5. Permission Matrix: Host cannot attach booking belonging to another Host's property")
    void testHostCannotAttachForeignPropertyBooking() throws Exception {
        User host = buildUser(3, "hostdemo", "ROLE_HOST");
        sessionStore.put("user", host);
        sessionStore.put("loginCsrfToken", "csrf-host-bk");

        when(request.getParameter("csrfToken")).thenReturn("csrf-host-bk");
        when(request.getParameter("category")).thenReturn("HOST_ASSISTANCE");
        when(request.getParameter("bookingId")).thenReturn("999");
        when(request.getParameter("subject")).thenReturn("Hỗ trợ đơn đặt phòng");
        when(request.getParameter("message")).thenReturn("Nội dung yêu cầu hỗ trợ dài hơn 10 ký tự hợp lệ.");

        when(bookingDAO.isBookingOwnedByHost(999, 3)).thenReturn(false);

        contactController.doPost(request, response);

        verify(request).setAttribute(eq("errorMessage"), anyString());
        // GIU DU LIEU FORM KHI VALIDATION LOI
        verify(request).setAttribute("formSubject", "Hỗ trợ đơn đặt phòng");
        verify(contactMessageDAO, never()).insert(any(ContactMessage.class), any(Connection.class));
    }

    @Test
    @DisplayName("6. Transition & No Side Effects: Full lifecycle never mutates BookingDAO and Admin reply never auto-closes")
    void testFullLifecycleTransitionsAndZeroBookingMutationSideEffects() throws Exception {
        User customer = buildUser(2, "khanhmg", "ROLE_CUSTOMER");
        when(notificationDAO.findActiveAdminIds(mockConnection)).thenReturn(List.of(1));
        when(bookingDAO.isBookingOwnedByUser(108, 2)).thenReturn(true);

        ContactMessage state = new ContactMessage();
        state.setMessageId(300);
        state.setTicketCode("TK-20261102-FLOW");
        state.setUserId(2);
        state.setBookingId(108);
        state.setStatus(TicketStatus.NEW);

        when(contactMessageDAO.findByTicketCode(anyString())).thenReturn(Optional.empty());
        doAnswer(inv -> {
            ContactMessage t = inv.getArgument(0);
            t.setMessageId(300);
            return true;
        }).when(contactMessageDAO).insert(any(ContactMessage.class), eq(mockConnection));
        when(contactMessageDAO.findById(300)).thenReturn(Optional.of(state));

        final int[] replySeq = {10};
        doAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(++replySeq[0]);
            return true;
        }).when(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));

        // 1. CREATE -> NEW
        ContactMessage draft = new ContactMessage();
        draft.setCategory(TicketCategory.BOOKING_INQUIRY);
        draft.setBookingId(108);
        draft.setSubject("Hỗ trợ đổi giờ checkin");
        draft.setMessage("Tôi muốn xin nhận phòng sớm 1 tiếng tại Đà Lạt.");
        ContactMessage created = supportService.createTicket(draft, customer);
        assertEquals(TicketStatus.NEW, created.getStatus());

        // 2. ADMIN REPLY WITH changeToProcessing=true -> PROCESSING (KHONG TU DONG DONG TICKET)
        when(contactMessageDAO.updateStatus(300, TicketStatus.PROCESSING, TicketStatus.NEW, mockConnection)).thenReturn(true);
        supportService.addAdminReply(300, 1, "Ban quản trị đang liên hệ chủ nhà cho bạn.", true);
        state.setStatus(TicketStatus.PROCESSING);
        verify(contactMessageDAO, never()).updateStatus(eq(300), eq(TicketStatus.RESOLVED), any(), any(Connection.class));

        // 3. ADMIN REPLY ON PROCESSING -> STAYS PROCESSING (KHONG TU DONG CHUYEN RESOLVED)
        supportService.addAdminReply(300, 1, "Chủ nhà xác nhận bạn có thể gửi đồ trước.", true);
        assertEquals(TicketStatus.PROCESSING, state.getStatus());

        // 4. ADMIN MARKS RESOLVED -> RESOLVED
        when(contactMessageDAO.updateStatus(300, TicketStatus.RESOLVED, TicketStatus.PROCESSING, mockConnection)).thenReturn(true);
        assertTrue(supportService.updateTicketStatus(300, TicketStatus.RESOLVED, TicketStatus.PROCESSING, true, 1));
        state.setStatus(TicketStatus.RESOLVED);

        // 5. CUSTOMER REPLIES ON RESOLVED -> AUTO REOPENS TO PROCESSING
        when(contactMessageDAO.updateStatus(300, TicketStatus.PROCESSING, TicketStatus.RESOLVED, mockConnection)).thenReturn(true);
        supportService.addSenderReply(300, 2, "Cảm ơn Admin, cho tôi hỏi thêm chỗ gửi xe ô tô?");
        verify(contactMessageDAO).updateStatus(300, TicketStatus.PROCESSING, TicketStatus.RESOLVED, mockConnection);

        // XAC MINH KHONG CO BAT KY THAO TAC GHI/CAP NHAT/XOA NAO LEN BANG BOOKINGS
        verify(bookingDAO, never()).insert(any());
        verify(bookingDAO, never()).update(any());
        verify(bookingDAO, never()).delete(any());
        verify(bookingDAO, never()).createBooking(any());
    }

    @Test
    @DisplayName("7. DB Error Sanitization & Draft Preservation: Raw SQL error never leaks to Admin or Customer")
    void testDatabaseErrorsSanitizedAndDraftPreserved() throws Exception {
        // CASE A: ADMIN REPLY DB FAILURE
        User admin = buildUser(1, "admin", "ROLE_ADMIN");
        sessionStore.put("user", admin);
        sessionStore.put("loginCsrfToken", "csrf-admin-err");

        when(request.getPathInfo()).thenReturn("/reply");
        when(request.getParameter("ticketId")).thenReturn("101");
        when(request.getParameter("csrfToken")).thenReturn("csrf-admin-err");
        when(request.getParameter("message")).thenReturn("Nội dung phản hồi quan trọng của Admin cần giữ lại");

        SupportService failingService = mock(SupportService.class);
        doThrow(new DataAccessException("Communications link failure jdbc:mysql://10.0.0.15:3306/homestay_secret", new RuntimeException()))
                .when(failingService).addAdminReply(anyInt(), anyInt(), anyString(), anyBoolean());

        AdminSupportController errAdminCtrl = new AdminSupportController(failingService, bookingDAO, roomDAO, userDAO);
        errAdminCtrl.doPost(request, response);

        String adminFlashErr = (String) sessionStore.get("supportErrorMsg");
        assertNotNull(adminFlashErr);
        assertFalse(adminFlashErr.contains("10.0.0.15"), "Không được lộ IP/chuỗi kết nối DB trong thông báo lỗi");
        assertFalse(adminFlashErr.contains("homestay_secret"), "Không được lộ tên schema DB trong thông báo lỗi");
        assertEquals("Nội dung phản hồi quan trọng của Admin cần giữ lại", sessionStore.get("adminReplyDraft"));

        // CASE B: CUSTOMER REPLY DB FAILURE
        reset(response);
        User customer = buildUser(2, "khanhmg", "ROLE_CUSTOMER");
        sessionStore.put("user", customer);
        sessionStore.put("loginCsrfToken", "csrf-cust-err");

        when(request.getPathInfo()).thenReturn("/reply");
        when(request.getParameter("ticketId")).thenReturn("101");
        when(request.getParameter("csrfToken")).thenReturn("csrf-cust-err");
        when(request.getParameter("message")).thenReturn("Tin nhắn bổ sung của khách hàng không bị mất khi lỗi mạng");

        doThrow(new DataAccessException("Table 'homestay_secret.support_replies' doesn't exist", new RuntimeException()))
                .when(failingService).addSenderReply(anyInt(), anyInt(), anyString());

        SupportController errSupportCtrl = new SupportController(failingService, contactMessageDAO, supportReplyDAO, userDAO);
        errSupportCtrl.doPost(request, response);

        ArgumentCaptor<String> redirectCaptor = ArgumentCaptor.forClass(String.class);
        verify(response).sendRedirect(redirectCaptor.capture());
        assertFalse(redirectCaptor.getValue().contains("homestay_secret"), "Redirect URL không được chứa chi tiết lỗi SQL");
        assertEquals("Tin nhắn bổ sung của khách hàng không bị mất khi lỗi mạng", sessionStore.get("supportReplyDraft"));
    }
}
