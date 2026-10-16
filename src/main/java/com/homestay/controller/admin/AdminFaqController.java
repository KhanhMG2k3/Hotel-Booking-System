/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.homestay.controller.admin;

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

/**
 *
 * @author admin
 */
@WebServlet(name="AdminFaqController", urlPatterns={"/admin/faqs", "/admin/faqs/add", "/admin/faqs/delete", "/admin/faqs/edit"})
public class AdminFaqController extends HttpServlet {
    
        private final FaqDAO faqDAO = new FaqDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
                // Kiểm tra quyền Admin
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/home?error=unauthorized");
            return;
        }
        String action = request.getServletPath();
        if ("/admin/faqs/delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            faqDAO.deleteFaq(id);
            response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=deleted");
            return;
        }
        request.setAttribute("faqList", faqDAO.getAllFaqsForAdmin());
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-faq-list.jsp").forward(request, response);
    } 

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
                if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String action = request.getServletPath();
        String idStr = request.getParameter("id");
        String category = request.getParameter("category");
        String question = request.getParameter("question");
        String answer = request.getParameter("answer");
        int orderIndex = Integer.parseInt(request.getParameter("orderIndex"));
        String status = request.getParameter("status");
        Faq faq = new Faq(idStr != null && !idStr.isEmpty() ? Integer.parseInt(idStr) : 0, 
                          category, question, answer, orderIndex, status);
        if ("/admin/faqs/edit".equals(action)) {
            faqDAO.updateFaq(faq);
        } else {
            faqDAO.insertFaq(faq);
        }
        response.sendRedirect(request.getContextPath() + "/admin/faqs?msg=saved");
    }

        private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("currentUser");
        return user != null && (user.getRoleId() == 1 || (user.getRole() != null && "ROLE_ADMIN".equalsIgnoreCase(user.getRole().getRoleName())));
    }
}
