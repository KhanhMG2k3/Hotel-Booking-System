package com.homestay.controller;

import com.homestay.dao.FaqDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Faq;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "AdminFaqController", urlPatterns = {
    "/admin/faqs",
    "/admin/faqs/add",
    "/admin/faqs/edit",
    "/admin/faqs/delete",
    "/admin/faqs/toggle"
})
public class AdminFaqController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final FaqDAO faqDAO = new FaqDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Verify that the current user is an active Admin or Host
        User user = checkPermission(request, response, false);
        if (user == null) {
            return;
        }

        String action = request.getServletPath();

        // Step 2: Handle FAQ deletion request
        if ("/admin/faqs/delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                faqDAO.deleteFaq(id);
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=deleted");
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=error");
            }
            return;
        }

        // Step 3: Handle FAQ visibility toggle (ACTIVE / INACTIVE on public FAQ page)
        if ("/admin/faqs/toggle".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                faqDAO.toggleStatus(id);
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=toggled");
            } catch (Exception e) {
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=error");
            }
            return;
        }

        // Step 4: Load FAQ list for management (with optional keyword filtering)
        List<Faq> faqList = faqDAO.getAllFaqsForAdmin();
        String searchKeyword = request.getParameter("search");
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = searchKeyword.trim().toLowerCase(Locale.ROOT);
            faqList.removeIf(f -> !f.getQuestion().toLowerCase(Locale.ROOT).contains(kw)
                    && !f.getAnswer().toLowerCase(Locale.ROOT).contains(kw)
                    && !f.getCategory().toLowerCase(Locale.ROOT).contains(kw));
            request.setAttribute("searchKeyword", searchKeyword);
        }

        request.setAttribute("faqList", faqList);
        request.setAttribute("activePage", "faq");
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-faq-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Enforce Admin or Host write permission on POST actions
        User user = checkPermission(request, response, true);
        if (user == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getServletPath();

        // Step 2: Parse FAQ payload and execute create or update operation
        try {
            String idStr = request.getParameter("id");
            String category = request.getParameter("category");
            String question = request.getParameter("question");
            String answer = request.getParameter("answer");
            String orderStr = request.getParameter("orderIndex");
            String status = request.getParameter("status");

            int orderIndex = (orderStr != null && !orderStr.trim().isEmpty()) ? Integer.parseInt(orderStr) : 1;
            if (status == null || status.trim().isEmpty()) {
                status = "ACTIVE";
            }
            int id = (idStr != null && !idStr.trim().isEmpty()) ? Integer.parseInt(idStr) : 0;
            Faq faq = new Faq(id, category, question, answer, orderIndex, status);

            if ("/admin/faqs/edit".equals(action)) {
                faqDAO.updateFaq(faq);
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=updated");
            } else {
                faqDAO.insertFaq(faq);
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=added");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=error");
        }
    }

    /**
     * Validate that the session belongs to an active user with Admin or Host privileges.
     */
    private User checkPermission(HttpServletRequest request, HttpServletResponse response, boolean isPost)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn cần đăng nhập để thực hiện thao tác này.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return null;
        }

        Integer userId = null;
        if (session.getAttribute("userId") instanceof Number) {
            userId = ((Number) session.getAttribute("userId")).intValue();
        } else if (session.getAttribute("user") instanceof User) {
            userId = ((User) session.getAttribute("user")).getId();
        } else if (session.getAttribute("currentUser") instanceof User) {
            userId = ((User) session.getAttribute("currentUser")).getId();
        }

        User user = null;
        if (userId != null && userId > 0) {
            user = userDAO.findById(userId).orElse(null);
            if (user == null || (user.getStatus() != null && !"ACTIVE".equalsIgnoreCase(user.getStatus()))) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return null;
            }
        } else if (session.getAttribute("user") instanceof User) {
            user = (User) session.getAttribute("user");
        } else if (session.getAttribute("currentUser") instanceof User) {
            user = (User) session.getAttribute("currentUser");
        }

        if (user == null) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn cần đăng nhập để thực hiện thao tác này.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return null;
        }

        String roleName = "";
        if (user.getRole() != null) {
            String rawRole = user.getRole().getRoleName() != null
                    ? user.getRole().getRoleName()
                    : user.getRole().getName();
            if (rawRole != null) {
                roleName = rawRole.trim().toUpperCase(Locale.ROOT);
            }
        } else if (session.getAttribute("role") instanceof String) {
            roleName = ((String) session.getAttribute("role")).trim().toUpperCase(Locale.ROOT);
        }

        boolean isAdmin = "ROLE_ADMIN".equals(roleName)
                || "ADMIN".equals(roleName)
                || "ADMINISTRATOR".equals(roleName);
        boolean isHost = "ROLE_HOST".equals(roleName)
                || "HOST".equals(roleName)
                || "HOTEL_OWNER".equals(roleName);

        if (!isAdmin && !isHost) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý FAQ.");
            } else {
                response.sendRedirect(request.getContextPath() + "/home?error=no_permission");
            }
            return null;
        }

        return user;
    }
}
