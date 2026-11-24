package com.homestay.controller;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.io.StringWriter;
import org.junit.jupiter.api.Test;

class GoogleLoginControllerTest {

    @Test
    void rejectsInvalidCsrfTokenBeforeReadingGoogleCredential() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter responseBody = new StringWriter();

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("csrfToken")).thenReturn("expected-token");
        when(request.getParameter("csrfToken")).thenReturn("invalid-token");
        when(response.getWriter()).thenReturn(new PrintWriter(responseBody));

        new GoogleLoginController().doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        verify(request, never()).getParameter("credential");
        assertTrue(responseBody.toString().contains("Phiên đăng nhập hết hạn"));
    }
}

