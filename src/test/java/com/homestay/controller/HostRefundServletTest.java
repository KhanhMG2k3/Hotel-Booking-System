package com.homestay.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.io.PrintWriter;
import java.io.StringWriter;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class HostRefundServletTest {

    private HostRefundServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private StringWriter responseWriter;

    @BeforeEach
    void setUp() throws Exception {
        servlet = new HostRefundServlet();
        request = Mockito.mock(HttpServletRequest.class);
        response = Mockito.mock(HttpServletResponse.class);
        session = Mockito.mock(HttpSession.class);

        responseWriter = new StringWriter();
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
    }

    @Test
    @DisplayName("doGet redirects to /login when not logged in")
    void testDoGetUnauthenticated() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("");

        servlet.doGet(request, response);

        verify(response).sendRedirect(contains("/login"));
    }

    @Test
    @DisplayName("doPost returns 401 when not logged in")
    void testDoPostUnauthenticated() throws Exception {
        when(request.getSession(false)).thenReturn(null);

        servlet.doPost(request, response);

        verify(response).setStatus(eq(HttpServletResponse.SC_UNAUTHORIZED));
        assertTrue(responseWriter.toString().contains("false"));
    }

    @Test
    @DisplayName("doPost returns 400 when missing parameters")
    void testDoPostMissingParameters() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(3); // host user
        when(request.getParameter("refundId")).thenReturn(null);

        servlet.doPost(request, response);

        verify(response).setStatus(eq(HttpServletResponse.SC_BAD_REQUEST));
    }
}

