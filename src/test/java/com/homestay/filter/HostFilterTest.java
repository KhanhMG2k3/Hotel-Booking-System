package com.homestay.filter;

import com.homestay.dao.HostProfileDAO;
import com.homestay.model.HostProfile;
import com.homestay.model.Role;
import com.homestay.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class HostFilterTest {

    private final HostProfileDAO hostProfileDAO = mock(HostProfileDAO.class);
    private final HostFilter filter = new HostFilter(hostProfileDAO);

    private User userWithRole(String roleName) {
        User user = new User();
        user.setId(5);
        Role role = new Role();
        role.setRoleName(roleName);
        user.setRole(role);
        return user;
    }

    @Test
    @DisplayName("Redirects anonymous user without session to login")
    void redirectsAnonymousToLogin() throws Exception {
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
    @DisplayName("Redirects customer user without ROLE_HOST to home?error=no_permission")
    void redirectsCustomerToHome() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);
        User user = userWithRole("ROLE_CUSTOMER");

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getContextPath()).thenReturn("/app");

        filter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/home?error=no_permission");
        verifyNoInteractions(chain);
    }

    @Test
    @DisplayName("Redirects host without APPROVED verification to home?error=host_not_approved")
    void redirectsPendingHostToHome() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);
        User user = userWithRole("ROLE_HOST");

        HostProfile profile = new HostProfile();
        profile.setUserId(5);
        profile.setVerificationStatus("PENDING");

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getContextPath()).thenReturn("/app");
        when(hostProfileDAO.findByUserId(5)).thenReturn(Optional.of(profile));

        filter.doFilter(request, response, chain);

        verify(response).sendRedirect("/app/home?error=host_not_approved");
        verifyNoInteractions(chain);
    }

    @Test
    @DisplayName("Allows approved host user through filter chain")
    void allowsApprovedHostThrough() throws Exception {
        HttpServletRequest request = mock(HttpServletRequest.class);
        HttpServletResponse response = mock(HttpServletResponse.class);
        HttpSession session = mock(HttpSession.class);
        FilterChain chain = mock(FilterChain.class);
        User user = userWithRole("ROLE_HOST");

        HostProfile profile = new HostProfile();
        profile.setUserId(5);
        profile.setVerificationStatus("APPROVED");

        when(request.getSession(false)).thenReturn(session);
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getContextPath()).thenReturn("/app");
        when(hostProfileDAO.findByUserId(5)).thenReturn(Optional.of(profile));

        filter.doFilter(request, response, chain);

        verify(chain).doFilter(request, response);
    }
}

