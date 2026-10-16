package com.homestay.controller;

import com.homestay.dao.StaticPageDAO;
import com.homestay.model.StaticPage;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author admin
 */
public class TermsController extends HttpServlet {

    private final StaticPageDAO staticPageDAO = new StaticPageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        StaticPage page = staticPageDAO.getPageBySlug("terms-and-conditions");
        request.setAttribute("page", page);
        request.setAttribute("activePage", "terms");
        request.setAttribute("pageTitle", "Chính Sách & Điều Khoản | Sogo Homestay");
        request.getRequestDispatcher("/WEB-INF/views/term.jsp").forward(request, response);
    }

}
