package com.homestay.service;

import com.homestay.controller.AdminSupportController;
import com.homestay.controller.NotificationController;
import com.homestay.controller.SupportController;
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
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * BO KIEM THU DOT 5/6: TICH HOP NOTIFICATION CHO CONTACT & SUPPORT.
 * BAO PHU: DUNG SU KIEN - DUNG NGUOI NHAN - DUNG LINK - CHONG TRUNG RETRY - NHIEU PHAN HOI RIENG BIET -
 * ROLLBACK TRANSACTION - PHAN QUYEN LINK - DEM SO CHUA DOC - KHONG SINH THONG BAO KHI GET.
 */
class SupportNotificationTest {

    private ContactMessageDAO contactMessageDAO;
    private SupportReplyDAO supportReplyDAO;
    private BookingDAO bookingDAO;
    private NotificationDAO notificationDAO;
    private Connection mockConnection;
    private SupportService supportService;

    @BeforeEach
    void setUp() {
        contactMessageDAO = mock(ContactMessageDAO.class);
        supportReplyDAO = mock(SupportReplyDAO.class);
        bookingDAO = mock(BookingDAO.class);
        notificationDAO = mock(NotificationDAO.class);
        mockConnection = mock(Connection.class);

        supportService = new SupportService(contactMessageDAO, supportReplyDAO, bookingDAO, notificationDAO) {
            @Override
            protected Connection getConnection() {
                return mockConnection;
            }
        };
    }

    private User buildUser(int id, String username, String fullName, int roleId, String roleName) {
        User u = new User();
        u.setId(id);
        u.setUsername(username);
        u.setFullName(fullName);
        u.setEmail(username + "@example.com");
        u.setRole(new Role(roleId, roleName, roleName));
        return u;
    }

    @Test
    @DisplayName("Su kien 1: Yeu cau moi -> Gui thong bao cho cac Admin dang hoat dong, dung link Admin, khong chua noi dung nhay cam")
    void testNewTicketNotifiesActiveAdminsWithoutSensitiveBody() throws Exception {
        User customer = buildUser(2, "khanhmg", "Khanh MG", 2, "ROLE_CUSTOMER");
        ContactMessage ticket = new ContactMessage();
        ticket.setSubject("Hoi nhan phong som");
        ticket.setMessage("NOI_DUNG_NHAY_CAM_CHI_TIET_KHONG_DUOC_XUAT_HIEN_TRONG_NOTIFICATION_123456");
        ticket.setCategory(TicketCategory.BOOKING_INQUIRY);

        doAnswer(inv -> {
            ContactMessage t = inv.getArgument(0);
            t.setMessageId(101);
            return true;
        }).when(contactMessageDAO).insert(any(ContactMessage.class), eq(mockConnection));

        when(notificationDAO.findActiveAdminIds(mockConnection)).thenReturn(List.of(1, 11));
        when(notificationDAO.createNotificationIfAbsent(anyInt(), anyString(), anyString(), anyString(), anyString(), eq(mockConnection)))
                .thenReturn(true);

        ContactMessage created = supportService.createTicket(ticket, customer);

        ArgumentCaptor<String> titleCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> msgCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<String> urlCaptor = ArgumentCaptor.forClass(String.class);

        verify(notificationDAO).createNotificationIfAbsent(
                eq(1), titleCaptor.capture(), msgCaptor.capture(), eq("SYSTEM"), urlCaptor.capture(), eq(mockConnection));
        verify(notificationDAO).createNotificationIfAbsent(
                eq(11), anyString(), anyString(), eq("SYSTEM"), eq("/admin/support/detail?id=101"), eq(mockConnection));
        // Khong gui thong bao cho nguoi gui
        verify(notificationDAO, never()).createNotificationIfAbsent(
                eq(2), anyString(), anyString(), anyString(), anyString(), any());

        assertEquals("/admin/support/detail?id=101", urlCaptor.getValue());
        assertTrue(titleCaptor.getValue().contains(created.getTicketCode()));
        assertFalse(msgCaptor.getValue().contains("NOI_DUNG_NHAY_CAM_CHI_TIET"));
        verify(mockConnection).commit();
    }

    @Test
    @DisplayName("Khong tu gui thong bao cho chinh nguoi thuc hien su kien")
    void testActorDoesNotNotifySelf() throws Exception {
        User adminSender = buildUser(1, "admin", "System Admin", 1, "ROLE_ADMIN");
        ContactMessage ticket = new ContactMessage();
        ticket.setSubject("Kiem tra he thong ho tro");
        ticket.setMessage("Noi dung kiem tra noi bo tren 10 ky tu.");
        ticket.setCategory(TicketCategory.TECHNICAL_ISSUE);

        doAnswer(inv -> {
            ContactMessage t = inv.getArgument(0);
            t.setMessageId(202);
            return true;
        }).when(contactMessageDAO).insert(any(ContactMessage.class), eq(mockConnection));

        // DB co 2 Admin: 1 (chinh actor) va 11 (Admin khac)
        when(notificationDAO.findActiveAdminIds(mockConnection)).thenReturn(List.of(1, 11));

        supportService.createTicket(ticket, adminSender);

        verify(notificationDAO, never()).createNotificationIfAbsent(
                eq(1), anyString(), anyString(), anyString(), anyString(), any());
        verify(notificationDAO).createNotificationIfAbsent(
                eq(11), anyString(), anyString(), eq("SYSTEM"), eq("/admin/support/detail?id=202"), eq(mockConnection));
    }

    @Test
    @DisplayName("Su kien 2 & Nhieu phan hoi: Moi phan hoi cua Admin tao thong bao rieng theo replyId cho chu ticket")
    void testAdminMultipleRepliesCreateDistinctNotificationsForOwner() throws Exception {
        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(101);
        ticket.setUserId(2);
        ticket.setTicketCode("TK-20261101-ABCD");
        ticket.setStatus(TicketStatus.PROCESSING);

        when(contactMessageDAO.findById(101)).thenReturn(Optional.of(ticket));

        // Phan hoi Admin lan 1 -> replyId = 55
        doAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(55);
            return true;
        }).when(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));

        supportService.addAdminReply(101, 1, "CHI_TIET_PHAN_HOI_NHAY_CAM_LAN_1", false);

        // Phan hoi Admin lan 2 -> replyId = 56
        doAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(56);
            return true;
        }).when(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));

        supportService.addAdminReply(101, 1, "CHI_TIET_PHAN_HOI_NHAY_CAM_LAN_2", false);

        ArgumentCaptor<String> msgCaptor = ArgumentCaptor.forClass(String.class);
        verify(notificationDAO).createNotificationIfAbsent(
                eq(2), anyString(), msgCaptor.capture(), eq("SYSTEM"),
                eq("/support/ticket?code=TK-20261101-ABCD#reply-55"), eq(mockConnection));
        verify(notificationDAO).createNotificationIfAbsent(
                eq(2), anyString(), anyString(), eq("SYSTEM"),
                eq("/support/ticket?code=TK-20261101-ABCD#reply-56"), eq(mockConnection));
        // Khong gui cho Admin thuc hien
        verify(notificationDAO, never()).createNotificationIfAbsent(
                eq(1), anyString(), anyString(), anyString(), anyString(), any());
        // Khong lo noi dung nhay cam
        assertFalse(msgCaptor.getValue().contains("CHI_TIET_PHAN_HOI_NHAY_CAM"));
    }

    @Test
    @DisplayName("Su kien 3: Nguoi gui bo sung -> Uu tien gui cho Admin dang xu ly ticket, fallback tat ca Admin neu chua ai xu ly")
    void testSenderReplyNotifiesAssignedRepliedAdminsOrFallback() throws Exception {
        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(101);
        ticket.setUserId(3); // Host la nguoi gui
        ticket.setTicketCode("TK-20261101-HOST");
        ticket.setStatus(TicketStatus.PROCESSING);

        when(contactMessageDAO.findById(101)).thenReturn(Optional.of(ticket));

        // Truong hop A: Admin 11 da tung tra loi ticket nay -> Chi Admin 11 nhan thong bao
        when(supportReplyDAO.findRepliedAdminIdsByTicketId(101, mockConnection)).thenReturn(List.of(11));
        doAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(70);
            return true;
        }).when(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));

        supportService.addSenderReply(101, 3, "Bo sung thong tin ma phong cho Admin");

        verify(notificationDAO).createNotificationIfAbsent(
                eq(11), anyString(), anyString(), eq("SYSTEM"),
                eq("/admin/support/detail?id=101#reply-70"), eq(mockConnection));
        verify(notificationDAO, never()).findActiveAdminIds(mockConnection);

        // Truong hop B: Ticket chua co Admin nao phan hoi -> Fallback tat ca Admin dang hoat dong [1, 11]
        when(supportReplyDAO.findRepliedAdminIdsByTicketId(101, mockConnection)).thenReturn(Collections.emptyList());
        when(notificationDAO.findActiveAdminIds(mockConnection)).thenReturn(List.of(1, 11));
        doAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(71);
            return true;
        }).when(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));

        supportService.addSenderReply(101, 3, "Bo sung lan 2 khi chua co Admin nhan");

        verify(notificationDAO).createNotificationIfAbsent(
                eq(1), anyString(), anyString(), eq("SYSTEM"),
                eq("/admin/support/detail?id=101#reply-71"), eq(mockConnection));
        verify(notificationDAO).createNotificationIfAbsent(
                eq(11), anyString(), anyString(), eq("SYSTEM"),
                eq("/admin/support/detail?id=101#reply-71"), eq(mockConnection));
    }

    @Test
    @DisplayName("Su kien 4: Chuyen trang thai sang RESOLVED -> Gui thong bao cho chu yeu cau voi transition key rieng")
    void testTransitionToResolvedNotifiesTicketOwner() throws Exception {
        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(101);
        ticket.setUserId(2);
        ticket.setTicketCode("TK-20261101-RESV");
        ticket.setStatus(TicketStatus.PROCESSING);
        ticket.setUpdatedAt(new Timestamp(1730470000000L));

        when(contactMessageDAO.findById(101)).thenReturn(Optional.of(ticket));
        when(contactMessageDAO.updateStatus(101, TicketStatus.RESOLVED, TicketStatus.PROCESSING, mockConnection))
                .thenReturn(true);
        when(supportReplyDAO.findLatestReplyId(101, mockConnection)).thenReturn(55);

        boolean updated = supportService.updateTicketStatus(101, TicketStatus.RESOLVED, TicketStatus.PROCESSING, true, 1);

        assertTrue(updated);
        verify(notificationDAO).createNotificationIfAbsent(
                eq(2),
                contains("TK-20261101-RESV"),
                anyString(),
                eq("SYSTEM"),
                eq("/support/ticket?code=TK-20261101-RESV#resolved-101-r55-v1730470000"),
                eq(mockConnection)
        );
        verify(mockConnection).commit();
    }

    @Test
    @DisplayName("Chong trung theo su kien: Retry cung su kien khong tao thong bao trung trong NotificationDAO")
    void testRetryDoesNotCreateDuplicateNotification() throws Exception {
        Connection conn = mock(Connection.class);
        PreparedStatement checkPs = mock(PreparedStatement.class);
        PreparedStatement insertPs = mock(PreparedStatement.class);
        ResultSet checkRs = mock(ResultSet.class);

        Set<String> existingKeys = new HashSet<>();
        when(conn.prepareStatement(startsWith("SELECT 1 FROM notifications"))).thenReturn(checkPs);
        when(conn.prepareStatement(startsWith("INSERT INTO notifications"))).thenReturn(insertPs);

        final int[] currentUser = new int[1];
        final String[] currentUrl = new String[1];
        doAnswer(inv -> { currentUser[0] = inv.getArgument(1); return null; }).when(checkPs).setInt(eq(1), anyInt());
        doAnswer(inv -> { currentUrl[0] = inv.getArgument(1); return null; }).when(checkPs).setString(eq(2), anyString());
        when(checkPs.executeQuery()).thenReturn(checkRs);
        when(checkRs.next()).thenAnswer(inv -> existingKeys.contains(currentUser[0] + "|" + currentUrl[0]));

        final int[] insertUser = new int[1];
        final String[] insertUrl = new String[1];
        doAnswer(inv -> { insertUser[0] = inv.getArgument(1); return null; }).when(insertPs).setInt(eq(1), anyInt());
        doAnswer(inv -> { insertUrl[0] = inv.getArgument(1); return null; }).when(insertPs).setString(eq(5), anyString());
        when(insertPs.executeUpdate()).thenAnswer(inv -> {
            existingKeys.add(insertUser[0] + "|" + insertUrl[0]);
            return 1;
        });

        NotificationDAO realDao = new NotificationDAO();
        String targetUrl = "/support/ticket?code=TK-20261101-ABCD#reply-55";

        // Lan 1: Tao thanh cong
        boolean first = realDao.createNotificationIfAbsent(2, "Tieu de", "Noi dung", "SYSTEM", targetUrl, conn);
        // Lan 2 (Retry cung replyId=55): Bi chan boi existsByUserAndTargetUrl, khong INSERT them
        boolean retrySameReply = realDao.createNotificationIfAbsent(2, "Tieu de", "Noi dung", "SYSTEM", targetUrl, conn);
        // Lan 3 (Phan hoi moi replyId=56): Van tao thanh cong thong bao rieng
        boolean secondReply = realDao.createNotificationIfAbsent(2, "Tieu de", "Noi dung", "SYSTEM",
                "/support/ticket?code=TK-20261101-ABCD#reply-56", conn);

        assertTrue(first);
        assertFalse(retrySameReply);
        assertTrue(secondReply);
        verify(insertPs, times(2)).executeUpdate();
    }

    @Test
    @DisplayName("Rollback nhat quan: Loi khi ghi nhan thong bao hoac cap nhat trang thai se rollback toan bo transaction")
    void testRollbackLeavesNoOrphanNotification() throws Exception {
        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(101);
        ticket.setUserId(2);
        ticket.setTicketCode("TK-20261101-ROLL");
        ticket.setStatus(TicketStatus.NEW);

        when(contactMessageDAO.findById(101)).thenReturn(Optional.of(ticket));
        doAnswer(inv -> {
            SupportReply r = inv.getArgument(0);
            r.setReplyId(88);
            return true;
        }).when(supportReplyDAO).insert(any(SupportReply.class), eq(mockConnection));
        when(contactMessageDAO.updateStatus(101, TicketStatus.PROCESSING, TicketStatus.NEW, mockConnection))
                .thenReturn(true);

        // Gia lap loi DB ngay tai buoc ghi notification -> Phai rollback ca reply + status + notification
        when(notificationDAO.createNotificationIfAbsent(anyInt(), anyString(), anyString(), anyString(), anyString(), eq(mockConnection)))
                .thenThrow(new SQLException("Simulated DB failure during notification insert"));

        assertThrows(DataAccessException.class,
                () -> supportService.addAdminReply(101, 1, "Phan hoi bi loi DB", true));

        verify(mockConnection).rollback();
        verify(mockConnection, never()).commit();
    }

    @Test
    @DisplayName("GET danh sach va chi tiet ticket khong bao gio phat sinh thong bao")
    void testGetOperationsNeverCreateNotifications() {
        ContactMessage ticket = new ContactMessage();
        ticket.setMessageId(101);
        ticket.setUserId(2);
        when(contactMessageDAO.findByIdAndUserId(101, 2)).thenReturn(Optional.of(ticket));
        when(contactMessageDAO.findById(101)).thenReturn(Optional.of(ticket));
        when(supportReplyDAO.findByTicketId(101)).thenReturn(Collections.emptyList());
        when(contactMessageDAO.findAllForAdmin(any(), any(), any(), any(), any(), anyInt(), anyInt()))
                .thenReturn(List.of(ticket));

        supportService.getTicketDetailForUser(101, 2);
        supportService.getTicketDetailForAdmin(101);
        supportService.findTicketsForAdmin(null, null, null, "updated_at", "DESC", 1, 10);

        verifyNoInteractions(notificationDAO);
    }

    @Test
    @DisplayName("Bao mat quyen truy cap: User khac khong the xem ticket qua link notification cua chu ticket hoac Admin")
    void testOtherUserCannotAccessTicketViaNotificationLink() throws Exception {
        // 1. User 9 (hoangnam) co tinh mo link notification /support/ticket?code=TK-20261101-ABCD cua User 2 (khanhmg)
        ContactMessage ownedByUser2 = new ContactMessage();
        ownedByUser2.setMessageId(101);
        ownedByUser2.setUserId(2);
        ownedByUser2.setTicketCode("TK-20261101-ABCD");

        ContactMessageDAO mockCmDao = mock(ContactMessageDAO.class);
        SupportReplyDAO mockSrDao = mock(SupportReplyDAO.class);
        UserDAO mockUserDao = mock(UserDAO.class);
        when(mockCmDao.findByTicketCode("TK-20261101-ABCD")).thenReturn(Optional.of(ownedByUser2));

        SupportController supportController = new SupportController(supportService, mockCmDao, mockSrDao, mockUserDao);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        User impostor = buildUser(9, "hoangnam", "Hoang Nam", 2, "ROLE_CUSTOMER");

        when(req.getMethod()).thenReturn("GET");
        when(req.getContextPath()).thenReturn("/HomestayBooking");
        when(req.getPathInfo()).thenReturn("/ticket");
        when(req.getParameter("code")).thenReturn("TK-20261101-ABCD");
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(impostor);

        // Goi doGet qua class cung package hoac servlet service
        supportController.service(req, resp);

        verify(resp).sendRedirect(contains("/HomestayBooking/support/my-tickets?error="));
        verify(req, never()).setAttribute(eq("ticket"), any());

        // 2. Customer co tinh mo link Admin notification /admin/support/detail?id=101 -> Bi chan 403 Forbidden
        AdminSupportController adminController = new AdminSupportController(
                supportService, mock(BookingDAO.class), mock(RoomDAO.class), mockUserDao);
        HttpServletRequest adminReq = mock(HttpServletRequest.class);
        HttpServletResponse adminResp = mock(HttpServletResponse.class);
        RequestDispatcher dispatcher = mock(RequestDispatcher.class);
        when(adminReq.getMethod()).thenReturn("GET");
        when(adminReq.getContextPath()).thenReturn("/HomestayBooking");
        when(adminReq.getPathInfo()).thenReturn("/detail");
        when(adminReq.getParameter("id")).thenReturn("101");
        when(adminReq.getSession(false)).thenReturn(session);
        when(adminReq.getRequestDispatcher(anyString())).thenReturn(dispatcher);

        adminController.service(adminReq, adminResp);

        verify(adminResp).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
        verify(adminReq, never()).setAttribute(eq("ticket"), any());
    }

    @Test
    @DisplayName("So chua doc hoat dong dung theo co che hien co cua NotificationController")
    void testUnreadCountMechanismWorksCorrectly() throws Exception {
        NotificationController controller = new NotificationController();
        NotificationDAO mockNotifDao = mock(NotificationDAO.class);

        Field daoField = NotificationController.class.getDeclaredField("notificationDAO");
        daoField.setAccessible(true);
        daoField.set(controller, mockNotifDao);

        when(mockNotifDao.countUnreadByUserId(1)).thenReturn(3);

        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter body = new StringWriter();

        when(req.getMethod()).thenReturn("GET");
        when(req.getServletPath()).thenReturn("/api/notifications/count");
        when(req.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(1);
        when(resp.getWriter()).thenReturn(new PrintWriter(body));

        controller.service(req, resp);

        assertTrue(body.toString().contains("\"unreadCount\":3"));
        assertTrue(body.toString().contains("\"loggedIn\":true"));
    }
}
