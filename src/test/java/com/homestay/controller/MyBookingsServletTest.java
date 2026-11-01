package com.homestay.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class MyBookingsServletTest {

    private MyBookingsServlet servlet;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private RequestDispatcher dispatcher;

    @BeforeEach
    void setUp() {
        servlet = new MyBookingsServlet();
        request = Mockito.mock(HttpServletRequest.class);
        response = Mockito.mock(HttpServletResponse.class);
        session = Mockito.mock(HttpSession.class);
        dispatcher = Mockito.mock(RequestDispatcher.class);
    }

    @Test
    @DisplayName("doGet redirects to /login when user is not logged in")
    void testDoGetUnauthenticatedRedirectsToLogin() throws Exception {
        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("");

        servlet.doGet(request, response);

        verify(response).sendRedirect(contains("/login"));
    }

    @Test
    @DisplayName("doGet forwards to my-bookings.jsp when user is logged in")
    void testDoGetAuthenticatedForwardsToJsp() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);
        when(request.getParameter("status")).thenReturn("ALL");
        when(request.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp")).thenReturn(dispatcher);

        servlet.doGet(request, response);

        verify(request).setAttribute(eq("bookings"), any());
        verify(request).setAttribute(eq("currentFilter"), eq("ALL"));
        verify(dispatcher).forward(request, response);
    }

    @Test
    @DisplayName("doGet applies status filter correctly")
    void testDoGetWithFilter() throws Exception {
        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("userId")).thenReturn(5);
        when(request.getParameter("status")).thenReturn("CONFIRMED");
        when(request.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp")).thenReturn(dispatcher);

        servlet.doGet(request, response);

        verify(request).setAttribute(eq("currentFilter"), eq("CONFIRMED"));
        verify(dispatcher).forward(request, response);
    }
}

