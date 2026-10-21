package com.homestay.controller;

import com.homestay.dao.FaqDAO;
import com.homestay.model.Faq;
import com.homestay.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

@WebServlet(name = "AdminFaqController", urlPatterns = {"/admin/faqs", "/admin/faqs/add", "/admin/faqs/edit", "/admin/faqs/delete", "/admin/faqs/toggle"})
public class AdminFaqController extends HttpServlet {

 private final FaqDAO faqDAO = new FaqDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. Kiểm tra quyền Admin (Đã sửa chuẩn theo session của hệ thống)
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/home?error=unauthorized");
            return;
        }
        String action = request.getServletPath();
        // 2. Chức năng XÓA CÂU HỎI
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
        // 3. Chức năng NÚT CHỌN HIỂN THỊ LÊN TRANG FAQ TĨNH KHÁCH (TOGGLE ACTIVE / INACTIVE)
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
        // 4. Mặc định: Lấy danh sách câu hỏi cho Admin (Hỗ trợ tìm kiếm từ khóa trong admin)
        List<Faq> faqList = faqDAO.getAllFaqsForAdmin();
        String searchKeyword = request.getParameter("search");
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = searchKeyword.trim().toLowerCase();
            faqList.removeIf(f -> !f.getQuestion().toLowerCase().contains(kw) 
                               && !f.getAnswer().toLowerCase().contains(kw) 
                               && !f.getCategory().toLowerCase().contains(kw));
            request.setAttribute("searchKeyword", searchKeyword);
        }
        request.setAttribute("faqList", faqList);
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-faq-list.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Kiểm tra quyền Admin
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String action = request.getServletPath();
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
                // SỬA CÂU HỎI CÂU TRẢ LỜI
                faqDAO.updateFaq(faq);
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=updated");
            } else {
                // THÊM CÂU HỎI CÂU TRẢ LỜI
                faqDAO.insertFaq(faq);
                response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=added");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=error");
        }
    }
    /**
     * Kiểm tra user hiện tại có phải Admin không
     */
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return false;
        }
        // 1. Lấy User từ session (Hệ thống lưu với key "user")
        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("currentUser");
        }
        if (user != null) {
            if (user.getRoleId() == 1 || user.getRoleId() == 5) {
                return true;
            }
            if (user.getRole() != null) {
                String roleName = user.getRole().getRoleName() != null ? user.getRole().getRoleName() : user.getRole().getName();
                if ("ROLE_ADMIN".equalsIgnoreCase(roleName) || "ADMIN".equalsIgnoreCase(roleName) || "ADMINISTRATOR".equalsIgnoreCase(roleName)) {
                    return true;
                }
            }
        }
        // 2. Kiểm tra theo roleId hoặc role chuỗi lưu trong session
        Integer roleId = (Integer) session.getAttribute("roleId");
        if (roleId != null && (roleId == 1 || roleId == 5)) {
            return true;
        }
        String role = (String) session.getAttribute("role");
        if (role != null && ("ROLE_ADMIN".equalsIgnoreCase(role) || "ADMIN".equalsIgnoreCase(role) || "ADMINISTRATOR".equalsIgnoreCase(role))) {
            return true;
        }
        String displayName = (String) session.getAttribute("displayName");
        return "Administrator".equalsIgnoreCase(displayName);
    }
}
