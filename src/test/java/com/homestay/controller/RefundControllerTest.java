package com.homestay.controller;

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
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RefundControllerTest {

    private RefundController controller;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private StringWriter responseWriter;

    @BeforeEach
    void setUp() throws Exception {
        controller = new RefundController();
        request = Mockito.mock(HttpServletRequest.class);
        response = Mockito.mock(HttpServletResponse.class);
        session = Mockito.mock(HttpSession.class);

        responseWriter = new StringWriter();
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
    }

    @Test
    @DisplayName("POST /refund/request returns 401 when unauthenticated")
    void testRefundRequestUnauthenticated() throws Exception {
        when(request.getServletPath()).thenReturn("/refund/request");
        when(request.getSession(false)).thenReturn(null);

        controller.doPost(request, response);

        verify(response).setStatus(eq(HttpServletResponse.SC_UNAUTHORIZED));
        assertTrue(responseWriter.toString().contains("false"));
    }

    @Test
    @DisplayName("POST /refund/request returns 400 when parameters are missing")
    void testRefundRequestMissingParams() throws Exception {
        when(request.getServletPath()).thenReturn("/refund/request");
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);
        when(request.getParameter("bookingId")).thenReturn(null);

        controller.doPost(request, response);

        verify(response).setStatus(eq(HttpServletResponse.SC_BAD_REQUEST));
    }

    @Test
    @DisplayName("GET /refund/status returns 401 when unauthenticated")
    void testRefundStatusUnauthenticated() throws Exception {
        when(request.getServletPath()).thenReturn("/refund/status");
        when(request.getSession(false)).thenReturn(null);

        controller.doGet(request, response);

        verify(response).setStatus(eq(HttpServletResponse.SC_UNAUTHORIZED));
    }

    @Test
    @DisplayName("GET /refund/status returns 400 when bookingId is missing")
    void testRefundStatusMissingBookingId() throws Exception {
        when(request.getServletPath()).thenReturn("/refund/status");
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);
        when(request.getParameter("bookingId")).thenReturn("");

        controller.doGet(request, response);

        verify(response).setStatus(eq(HttpServletResponse.SC_BAD_REQUEST));
    }
}

