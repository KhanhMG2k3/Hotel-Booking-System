package com.homestay.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.homestay.security.CsrfToken;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.io.StringWriter;
import org.junit.jupiter.api.Test;

class GoogleLoginServletTest {

    @Test
    void rejectsMismatchedCsrfTokenBeforeReadingGoogleCredential() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        StringWriter responseBody = new StringWriter();

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute(CsrfToken.SESSION_ATTRIBUTE)).thenReturn("expected-token");
        when(request.getParameter("csrfToken")).thenReturn("invalid-token");
        when(response.getWriter()).thenReturn(new PrintWriter(responseBody));

        new GoogleLoginServlet().doPost(request, response);

        verify(response).setStatus(HttpServletResponse.SC_FORBIDDEN);
        verify(request, never()).getParameter("credential");
        assertEquals("Yêu cầu đăng nhập không hợp lệ. Vui lòng tải lại trang.", responseBody.toString());
    }
}