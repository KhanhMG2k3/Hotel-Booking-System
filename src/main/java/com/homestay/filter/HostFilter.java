package com.homestay.filter;

import com.homestay.dao.HostProfileDAO;
import com.homestay.model.HostProfile;
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
import java.util.Optional;

@WebFilter(urlPatterns = {"/host/*"})
public class HostFilter implements Filter {

    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);

        User user = null;
        if (session != null) {
            Object userAttribute = session.getAttribute("user");
            if (userAttribute instanceof User) {
                user = (User) userAttribute;
            }
        }

        // 1. Phải login và có role ROLE_HOST
        boolean isHost = user != null
                && user.getRole() != null
                && "ROLE_HOST".equals(user.getRole().getRoleName());

        if (!isHost) {
            if (user == null) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            } else {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/home?error=no_permission");
            }
            return;
        }

        // 2. Phải có host_profiles và verification_status = APPROVED
        Optional<HostProfile> profileOpt = hostProfileDAO.findByUserId(user.getId());
        boolean isApproved = profileOpt.isPresent()
                && "APPROVED".equalsIgnoreCase(profileOpt.get().getVerificationStatus());

        if (!isApproved) {
            httpResponse.sendRedirect(
                    httpRequest.getContextPath() + "/home?error=host_not_approved"
            );
            return;
        }

        chain.doFilter(request, response);
    }
}