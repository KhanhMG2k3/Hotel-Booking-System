package com.homestay.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.*;

public class HostDashboardControllerTest {

    private HostDashboardController controller;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;

    @BeforeEach
    public void setUp() {
        controller = new HostDashboardController();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
    }

    @Test
    @DisplayName("doPost should redirect unauthenticated request to /login")
    public void testDoPostRedirectsToLoginWhenNoSession() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("");

        controller.doPost(request, response);

        verify(response).sendRedirect("/login");
    }

    @Test
    @DisplayName("doPost should redirect to /login when userId is missing in session")
    public void testDoPostRedirectsToLoginWhenNoUserIdInSession() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(null);
        when(request.getContextPath()).thenReturn("");

        controller.doPost(request, response);

        verify(response).sendRedirect("/login");
    }
}

