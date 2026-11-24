package com.homestay.controller;

import com.homestay.dao.FaqDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Faq;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

public class FaqController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final FaqDAO faqDAO = new FaqDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        String category = request.getParameter("cat");

        // Step 1: Load active FAQ entries filtered by optional keyword and category
        List<Faq> faqs = faqDAO.getActiveFaqs(keyword, category);

        // Step 2: Check whether the current viewer is Admin or Host to display the FAQ management bar
        String roleName = resolveNormalizedRoleName(request);
        boolean isAdmin = "ROLE_ADMIN".equals(roleName)
                || "ADMIN".equals(roleName)
                || "ADMINISTRATOR".equals(roleName);
        boolean isHost = "ROLE_HOST".equals(roleName)
                || "HOST".equals(roleName)
                || "HOTEL_OWNER".equals(roleName);

        request.setAttribute("faqs", faqs);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("activePage", "faq");
        request.setAttribute("pageTitle", "Câu Hỏi Thường Gặp (FAQ) | Sogo Homestay");
        request.setAttribute("isAdmin", isAdmin);
        request.setAttribute("isHost", isHost);
        request.setAttribute("canManageFaq", isAdmin || isHost);

        request.getRequestDispatcher("/WEB-INF/views/faq.jsp").forward(request, response);
    }

    private String resolveNormalizedRoleName(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return "";
        }

        User user = null;
        if (session.getAttribute("user") instanceof User) {
            user = (User) session.getAttribute("user");
        } else if (session.getAttribute("currentUser") instanceof User) {
            user = (User) session.getAttribute("currentUser");
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
