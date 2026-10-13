package com.homestay.filter;

import com.homestay.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

//đăng ký filter cho toàn bộ URL bắt đầu bằng /admin/
@WebFilter(urlPatterns = {"/admin/*"})
public class RoleFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest
                = (HttpServletRequest) request;

        HttpServletResponse httpResponse
                = (HttpServletResponse) response;

        HttpSession session
                = httpRequest.getSession(false);

        User user = null;

        if (session != null) {
            Object userAttribute
                    = session.getAttribute("user");

            if (userAttribute instanceof User) {
                user = (User) userAttribute;
            }
        }

        boolean isAdmin = user != null
                && user.getRole() != null
                && "ROLE_ADMIN".equals(
                        user.getRole().getRoleName()
                );

        if (!isAdmin) {
            if (user == null) {
                httpResponse.sendRedirect(
                        httpRequest.getContextPath() + "/login"
                );
            } else {
                httpResponse.sendRedirect(
                        httpRequest.getContextPath() + "/home?error=no_permission"
                );
            }
            return;
        }

        chain.doFilter(request, response);
    }
}
