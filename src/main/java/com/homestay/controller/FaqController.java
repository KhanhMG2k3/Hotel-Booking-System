package com.homestay.controller;

import com.homestay.dao.FaqDAO;
import com.homestay.model.Faq;
import com.homestay.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

public class FaqController extends HttpServlet {

    private final FaqDAO faqDAO = new FaqDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        String category = request.getParameter("cat");
        
        // 1. Lấy danh sách câu hỏi đang hiển thị cho khách
        List<Faq> faqs = faqDAO.getActiveFaqs(keyword, category);
        
        // 2. Kiểm tra xem người đang xem trang FAQ có phải là Admin hay không
        boolean isAdmin = checkAdminRole(request);
        
        request.setAttribute("faqs", faqs);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("activePage", "faq");
        request.setAttribute("pageTitle", "Câu Hỏi Thường Gặp (FAQ) | Sogo Homestay");
        request.setAttribute("isAdmin", isAdmin); // Cờ nhận diện Admin để hiện nút Quản lý FAQ
        
        request.getRequestDispatcher("/WEB-INF/views/faq.jsp").forward(request, response);
    }

    /**
     * Hàm kiểm tra quyền Admin linh hoạt (nhận diện qua session user, currentUser, role, roleId)
     */
    private boolean checkAdminRole(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        // Kiểm tra User object trong session
        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute("currentUser");
        }
        if (user != null) {
            if (user.getRoleId() == 1 || user.getRoleId() == 5) return true;
            if (user.getRole() != null) {
                String roleName = user.getRole().getName() != null ? user.getRole().getName() : user.getRole().getRoleName();
                if (roleName != null && ("ADMIN".equalsIgnoreCase(roleName) || "ROLE_ADMIN".equalsIgnoreCase(roleName) || "ADMINISTRATOR".equalsIgnoreCase(roleName))) {
                    return true;
                }
            }
        }

        // Kiểm tra các thuộc tính string/int lưu rời trong session
        String role = (String) session.getAttribute("role");
        if (role != null && ("ADMIN".equalsIgnoreCase(role) || "ROLE_ADMIN".equalsIgnoreCase(role) || "ADMINISTRATOR".equalsIgnoreCase(role))) {
            return true;
        }
        Integer roleId = (Integer) session.getAttribute("roleId");
        if (roleId != null && (roleId == 1 || roleId == 5)) {
            return true;
        }

        // Kiểm tra username hoặc display name có từ 'admin'
        String displayName = (String) session.getAttribute("displayName");
        String username = (String) session.getAttribute("username");
        return (displayName != null && "Administrator".equalsIgnoreCase(displayName)) 
            || (username != null && "admin".equalsIgnoreCase(username));
    }
}