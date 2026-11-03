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
    "/admin/faqs/toggle",
    "/admin/faqs/reorder" // <-- THÊM URL REORDER NÀY
})
public class AdminFaqController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final FaqDAO faqDAO = new FaqDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = checkPermission(request, response, false);
        if (user == null) {
            return;
        }

        String action = request.getServletPath();

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
        User user = checkPermission(request, response, true);
        if (user == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getServletPath();

        // XỬ LÝ LƯU THỨ TỰ KÉO THẢ (AJAX REORDER)
        if ("/admin/faqs/reorder".equals(action)) {
            String idsStr = request.getParameter("ids");
            if (idsStr != null && !idsStr.trim().isEmpty()) {
                String[] ids = idsStr.split(",");
                faqDAO.updateFaqOrders(ids);
            }
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": true}");
            return;
        }

        try {
            String idStr = request.getParameter("id");
            String category = request.getParameter("category");
            String question = request.getParameter("question");
            String answer = request.getParameter("answer");
            String orderStr = request.getParameter("orderIndex");
            String status = request.getParameter("status");

            int orderIndex = (orderStr != null && !orderStr.trim().isEmpty()) ? Integer.parseInt(orderStr) : 999;
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
        }

        if (userId == null) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn cần đăng nhập để thực hiện thao tác này.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return null;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = userDAO.findById(userId).orElse(null);
        }

        if (user == null || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            session.invalidate();
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản không hoạt động.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login?error=account_disabled");
            }
            return null;
        }

        boolean isAdmin = user.getRoleId() == 1 || user.getRoleId() == 5
                || (user.getRole() != null && ("ROLE_ADMIN".equalsIgnoreCase(user.getRole().getRoleName())
                || "ADMIN".equalsIgnoreCase(user.getRole().getRoleName())));

        if (!isAdmin) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            } else {
                response.sendRedirect(request.getContextPath() + "/home?error=unauthorized");
            }
            return null;
        }
        return user;
    }
}