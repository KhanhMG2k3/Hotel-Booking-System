package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.ContactMessage;
import com.homestay.model.Role;
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

import java.util.Collections;
import java.util.List;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests verifying ContactController public info, guest prompt,
 * authenticated submission, CSRF, rate-limiting, and validation protection.
 */
class ContactControllerTest {

    private SupportService supportService;
    private BookingDAO bookingDAO;
    private UserDAO userDAO;
    private ContactController controller;

    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    @BeforeEach
    void setUp() {
        supportService = mock(SupportService.class);
        bookingDAO = mock(BookingDAO.class);
        userDAO = mock(UserDAO.class);
        controller = new ContactController(supportService, bookingDAO, userDAO);

        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        dispatcher = mock(RequestDispatcher.class);

        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
        when(request.getContextPath()).thenReturn("/app");
    }

    private User createCustomer(int id) {
        User u = new User();
        u.setId(id);
        u.setUsername("customer" + id);
        u.setFullName("Customer Test " + id);
        u.setEmail("customer" + id + "@example.com");
        u.setRole(new Role(2, "ROLE_CUSTOMER", "Customer"));
        return u;
    }

    private User createHost(int id) {
        User u = new User();
        u.setId(id);
        u.setUsername("host" + id);
        u.setFullName("Host Test " + id);
        u.setEmail("host" + id + "@example.com");
        u.setRole(new Role(3, "ROLE_HOST", "Host"));
        return u;
    }

    @Test
    @DisplayName("GET /contact: Guest sees contact info and login prompt (isLoggedIn=false)")
    void testGuestGetContact() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        controller.doGet(request, response);

        verify(request).setAttribute("activePage", "contact");
        verify(request).setAttribute("isLoggedIn", false);
        verify(request).getRequestDispatcher("/WEB-INF/views/contact.jsp");
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("GET /contact: Customer sees form with their bookings preloaded and CSRF token")
    void testCustomerGetContact() throws Exception {
        User customer = createCustomer(2);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(bookingDAO.findBookingsByUserId(2)).thenReturn(List.of(new Booking()));

        controller.doGet(request, response);

        verify(request).setAttribute("isLoggedIn", true);
        verify(request).setAttribute("currentUser", customer);
        verify(bookingDAO).findBookingsByUserId(2);
        verify(request).setAttribute(eq("userBookings"), anyList());
        verify(request).setAttribute(eq("csrfToken"), anyString());
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("GET /contact: Host sees bookings from their homestay properties")
    void testHostGetContact() throws Exception {
        User host = createHost(3);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(host);
        when(bookingDAO.findBookingsByHostProperties(3)).thenReturn(Collections.emptyList());

        controller.doGet(request, response);

        verify(bookingDAO).findBookingsByHostProperties(3);
        verify(bookingDAO, never()).findBookingsByUserId(anyInt());
    }

    @Test
    @DisplayName("POST /contact: Guest is rejected and redirected to login")
    void testGuestPostContactRedirects() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        controller.doPost(request, response);

        verify(response).sendRedirect("/app/login?redirect=/contact");
        verifyNoInteractions(supportService);
    }

    @Test
    @DisplayName("POST /contact: Rejects submission when CSRF token is invalid or missing")
    void testCustomerPostInvalidCsrfRejected() throws Exception {
        User customer = createCustomer(2);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(session.getAttribute("loginCsrfToken")).thenReturn("valid-secret-token");
        when(request.getParameter("csrfToken")).thenReturn("forged-wrong-token");

        controller.doPost(request, response);

        verify(request).setAttribute(eq("errorMessage"), contains("Phiên bảo mật không hợp lệ"));
        verify(dispatcher).forward(request, response);
        verifyNoInteractions(supportService);
    }

    @Test
    @DisplayName("POST /contact: Rejects submission within rate-limit cooldown window")
    void testCustomerPostRateLimited() throws Exception {
        User customer = createCustomer(2);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(session.getAttribute("loginCsrfToken")).thenReturn("token123");
        when(request.getParameter("csrfToken")).thenReturn("token123");

        // Last submission was 2 seconds ago (< 15 seconds)
        when(session.getAttribute("LAST_CONTACT_SUBMISSION_TIME")).thenReturn(System.currentTimeMillis() - 2000);

        controller.doPost(request, response);

        verify(request).setAttribute(eq("errorMessage"), contains("Vui lòng đợi thêm"));
        verify(dispatcher).forward(request, response);
        verifyNoInteractions(supportService);
    }

    @Test
    @DisplayName("POST /contact: Rejects when subject is too short and preserves form inputs")
    void testCustomerPostValidationFailurePreservesInputs() throws Exception {
        User customer = createCustomer(2);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(session.getAttribute("loginCsrfToken")).thenReturn("token123");
        when(request.getParameter("csrfToken")).thenReturn("token123");

        when(request.getParameter("subject")).thenReturn("Hi"); // too short (< 5 chars)
        when(request.getParameter("category")).thenReturn("BOOKING_INQUIRY");
        when(request.getParameter("message")).thenReturn("Đây là nội dung hợp lệ trên mười ký tự.");

        controller.doPost(request, response);

        verify(request).setAttribute("errorMessage", "Tiêu đề yêu cầu phải có độ dài từ 5 đến 150 ký tự.");
        verify(request).setAttribute("formSubject", "Hi");
        verify(request).setAttribute("formMessage", "Đây là nội dung hợp lệ trên mười ký tự.");
        verify(dispatcher).forward(request, response);
        verifyNoInteractions(supportService);
    }

    @Test
    @DisplayName("POST /contact: Success scenario creates ticket, updates cooldown, and redirects via PRG")
    void testCustomerPostSuccess() throws Exception {
        User customer = createCustomer(2);
        when(request.getSession(false)).thenReturn(session);
        when(request.getSession(true)).thenReturn(session);
        when(request.getSession()).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(customer);
        when(session.getAttribute("loginCsrfToken")).thenReturn("token123");
        when(request.getParameter("csrfToken")).thenReturn("token123");

        when(request.getParameter("subject")).thenReturn("Cần đổi ngày check-in");
        when(request.getParameter("category")).thenReturn("BOOKING_INQUIRY");
        when(request.getParameter("message")).thenReturn("Tôi muốn đổi ngày check in từ ngày 15 sang ngày 16 tháng sau.");
        when(request.getParameter("bookingId")).thenReturn("101");

        ContactMessage createdTicket = new ContactMessage();
        createdTicket.setMessageId(5);
        createdTicket.setTicketCode("TK-20261031-ABCD");
        createdTicket.setStatus(TicketStatus.NEW);

        when(supportService.createTicket(any(ContactMessage.class), eq(customer))).thenReturn(createdTicket);

        controller.doPost(request, response);

        verify(supportService).createTicket(any(ContactMessage.class), eq(customer));
        verify(session).setAttribute(eq("LAST_CONTACT_SUBMISSION_TIME"), anyLong());
        verify(session).setAttribute("flashSuccessCode", "TK-20261031-ABCD");
        verify(response).sendRedirect("/app/support/ticket?code=TK-20261031-ABCD&created=1");
    }
}
