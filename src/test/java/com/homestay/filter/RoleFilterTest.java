package com.homestay.filter;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.homestay.model.Role;
import com.homestay.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;

class RoleFilterTest {

    private final RoleFilter filter = new RoleFilter();

    @Test
    void redirectsAnonymousUsersToLogin() throws Exception {
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
    void redirectsNonAdminUsersToHome() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);
        User user = userWithRole("ROLE_CUSTOMER");

        when(request.getSession(false)).thenReturn(session);
        when(request.getContextPath()).thenReturn("/app");
        when(session.getAttribute("user")).thenReturn(user);

        filter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/home?error=no_permission");
        verifyNoInteractions(chain);
    }

    @Test
    void allowsAdminUsersThrough() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(userWithRole("ROLE_ADMIN"));

        filter.doFilter(request, response, chain);

        verify(chain).doFilter(request, response);
        verify(response, never()).sendRedirect(org.mockito.ArgumentMatchers.anyString());
    }

    private User userWithRole(String roleName) {
        User user = new User();
        user.setRole(new Role(1, roleName, ""));
        return user;
    }
}