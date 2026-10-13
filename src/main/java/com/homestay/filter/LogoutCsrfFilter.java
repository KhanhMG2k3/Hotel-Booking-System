package com.homestay.filter;

import com.homestay.util.LoginUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Adds a session-bound token to authenticated requests that render logout controls. */
public class LogoutCsrfFilter implements Filter {
    /** Exposes the logout token to the request before continuing the filter chain. */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);
        if (session != null && session.getAttribute("userId") instanceof Number) {
            httpRequest.setAttribute(
                    "logoutCsrfToken", LoginUtil.getOrCreateLogoutCsrfToken(httpRequest));
        }

        // Continue normal request processing after attaching the logout token.
        chain.doFilter(request, response);
    }
}
