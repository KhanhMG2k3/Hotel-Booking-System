package com.homestay.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class CheckoutControllerTest {

    private CheckoutController controller;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;

    @BeforeEach
    void setUp() throws Exception {
        controller = new CheckoutController();
        controller.init();

        request = Mockito.mock(HttpServletRequest.class);
        response = Mockito.mock(HttpServletResponse.class);
        session = Mockito.mock(HttpSession.class);
    }

    @Test
    @DisplayName("doGet redirects to /login when unauthenticated")
    void testDoGetUnauthenticatedRedirectsToLogin() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("");

        controller.doGet(request, response);

        verify(response).sendRedirect(contains("/login"));
    }

    @Test
    @DisplayName("doGet returns 400 Bad Request when bookingId is missing")
    void testDoGetMissingBookingIdReturns400() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);
        when(session.getAttribute("csrfToken")).thenReturn("test-token");
        when(request.getParameter("bookingId")).thenReturn(null);

        controller.doGet(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_BAD_REQUEST), anyString());
    }

    @Test
    @DisplayName("doPost returns 401 Unauthorized when unauthenticated")
    void testDoPostUnauthenticatedReturns401() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        controller.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_UNAUTHORIZED), anyString());
    }

    @Test
    @DisplayName("doPost returns 403 Forbidden when CSRF token does not match")
    void testDoPostInvalidCsrfReturns403() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);
        when(session.getAttribute("csrfToken")).thenReturn("valid-token");
        when(request.getParameter("csrfToken")).thenReturn("invalid-token");

        controller.doPost(request, response);

        verify(response).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
    }
}

