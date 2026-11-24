package com.homestay.filter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.homestay.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class AuthFilterTest {

    private final AuthFilter filter = new AuthFilter();

    @Test
    @DisplayName("Redirects unauthenticated user without session to login")
    void redirectsAnonymousWithoutSessionToLogin() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        FilterChain chain = mock(FilterChain.class);

        when(request.getSession(false)).thenReturn(null);
        when(request.getContextPath()).thenReturn("/app");

        filter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/login");
        verifyNoInteractions(chain);
    }

    @Test
    @DisplayName("Redirects unauthenticated user with empty session to login")
    void redirectsAnonymousWithEmptySessionToLogin() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(null);
        when(request.getContextPath()).thenReturn("/app");

        filter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/login");
        verifyNoInteractions(chain);
    }

    @Test
    @DisplayName("Allows authenticated user to proceed through filter chain")
    void allowsAuthenticatedUserThrough() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);

        User user = new User();
        user.setId(10);
        user.setEmail("user@example.com");

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(user);

        filter.doFilter(request, response, chain);

        verify(chain).doFilter(request, response);
    }
}

