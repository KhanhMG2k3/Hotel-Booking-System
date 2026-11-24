package com.homestay.controller;

import com.homestay.dao.TermDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.TermSection;
import com.homestay.model.TermSetting;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

public class TermsController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final TermDAO termDAO = new TermDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Step 1: Load public terms settings and ordered sections
        TermSetting setting = termDAO.getSetting();
        List<TermSection> sections = termDAO.getAllSections();

        // Step 2: Determine whether the current viewer is Admin or Host to expose management entry points
        String roleName = resolveNormalizedRoleName(request);
        boolean isAdmin = "ROLE_ADMIN".equals(roleName)
                || "ADMIN".equals(roleName)
                || "ADMINISTRATOR".equals(roleName);
        boolean isHost = "ROLE_HOST".equals(roleName)
                || "HOST".equals(roleName)
                || "HOTEL_OWNER".equals(roleName);

        request.setAttribute("setting", setting);
        request.setAttribute("sections", sections);
        request.setAttribute("activePage", "terms");
        request.setAttribute("isAdmin", isAdmin);
        request.setAttribute("isHost", isHost);
        request.setAttribute("canManageTerms", isAdmin || isHost);

        request.getRequestDispatcher("/WEB-INF/views/term.jsp").forward(request, response);
    }

    private String resolveNormalizedRoleName(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return "";
        }

        User user = null;
        if (session.getAttribute("user") instanceof User) {
            user = (User) session.getAttribute("user");
        } else if (session.getAttribute("userId") instanceof Number) {
            int uid = ((Number) session.getAttribute("userId")).intValue();
            user = userDAO.findById(uid).orElse(null);
            if (user != null) {
                session.setAttribute("user", user);
            }
        }

        if (user != null && user.getRole() != null) {
            String rawRole = user.getRole().getRoleName() != null
                    ? user.getRole().getRoleName()
                    : user.getRole().getName();
            if (rawRole != null) {
                return rawRole.trim().toUpperCase(Locale.ROOT);
            }
        }

        Object sessionRole = session.getAttribute("role");
        if (sessionRole instanceof String) {
            return ((String) sessionRole).trim().toUpperCase(Locale.ROOT);
        }

        return "";
    }
}
