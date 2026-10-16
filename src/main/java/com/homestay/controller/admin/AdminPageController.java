/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.homestay.controller.admin;

import com.homestay.dao.StaticPageDAO;
import com.homestay.model.StaticPage;
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
@WebServlet(name = "AdminPageController", urlPatterns = {"/admin/pages", "/admin/pages/edit"})
public class AdminPageController extends HttpServlet {

    private final StaticPageDAO pageDAO = new StaticPageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/home?error=unauthorized");
            return;
        }
        String slug = request.getParameter("slug");
        if (slug == null || slug.isEmpty()) {
            slug = "about-us";
        }
        StaticPage page = pageDAO.getPageBySlug(slug);
        request.setAttribute("pageData", page);
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-page-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String slug = request.getParameter("slug");
        String title = request.getParameter("title");
        String metaDescription = request.getParameter("metaDescription");
        String content = request.getParameter("content");
        pageDAO.updatePage(slug, title, metaDescription, content);
        response.sendRedirect(request.getContextPath() + "/admin/pages/edit?slug=" + slug + "&msg=updated");
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return false;
        }
        User user = (User) session.getAttribute("currentUser");
        return user != null && (user.getRoleId() == 1 || (user.getRole() != null && "ROLE_ADMIN".equalsIgnoreCase(user.getRole().getRoleName())));
    }
}
