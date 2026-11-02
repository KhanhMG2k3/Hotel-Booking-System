package com.homestay.filter;

import com.homestay.dao.UserDAO;
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
import java.util.Locale;

// Guard all /admin/* endpoints and delegate shared content-management routes to both Admin and Host
@WebFilter(urlPatterns = {"/admin/*"})
public class RoleFilter implements Filter {

    private final UserDAO userDAO = new UserDAO();

    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Step 1: Resolve the authenticated user from session or load via userId fallback
        HttpSession session = httpRequest.getSession(false);
        User user = null;

        if (session != null) {
            Object userAttribute = session.getAttribute("user");
            if (userAttribute instanceof User) {
                user = (User) userAttribute;
            } else if (session.getAttribute("userId") instanceof Number) {
                int uid = ((Number) session.getAttribute("userId")).intValue();
                user = userDAO.findById(uid).orElse(null);
                if (user != null) {
                    session.setAttribute("user", user);
                }
            }
        }

        if (user == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // Step 2: Determine role permissions strictly by role name (role IDs may vary across environments)
        String roleName = "";
        if (user.getRole() != null) {
            String rawRole = user.getRole().getRoleName() != null
                    ? user.getRole().getRoleName()
                    : user.getRole().getName();
            if (rawRole != null) {
                roleName = rawRole.trim().toUpperCase(Locale.ROOT);
            }
        }

        boolean isAdmin = "ROLE_ADMIN".equals(roleName)
                || "ADMIN".equals(roleName)
                || "ADMINISTRATOR".equals(roleName);
        boolean isHost = "ROLE_HOST".equals(roleName)
                || "HOST".equals(roleName)
                || "HOTEL_OWNER".equals(roleName);

        // Step 3: Allow Admin everywhere under /admin/*, and allow Host on About Us, Terms, and FAQ management routes
        String uri = httpRequest.getRequestURI();
        boolean isHostAllowedContent = uri != null
                && (uri.contains("/admin/about")
                    || uri.contains("/admin/terms")
                    || uri.contains("/admin/faqs"));

        if (isAdmin || (isHost && isHostAllowedContent)) {
            chain.doFilter(request, response);
            return;
        }

        // Step 4: Redirect authenticated users without required privileges back to home
        httpResponse.sendRedirect(httpRequest.getContextPath() + "/home?error=no_permission");
    }
}
