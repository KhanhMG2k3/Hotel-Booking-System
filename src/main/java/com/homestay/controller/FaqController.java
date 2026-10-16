/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.homestay.controller;

import com.homestay.dao.FaqDAO;
import com.homestay.model.Faq;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author admin
 */
public class FaqController extends HttpServlet {

    private final FaqDAO faqDAO = new FaqDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("q");
        String category = request.getParameter("cat");
        List<Faq> faqs = faqDAO.getActiveFaqs(keyword, category);
        request.setAttribute("faqs", faqs);
        request.setAttribute("searchKeyword", keyword);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("activePage", "faq");
        request.setAttribute("pageTitle", "Câu Hỏi Thường Gặp (FAQ) | Sogo Homestay");
        request.getRequestDispatcher("/WEB-INF/views/faq.jsp").forward(request, response);
    }

}
