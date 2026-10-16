/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

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
public class AboutController extends HttpServlet {
   
    private final StaticPageDAO staticPageDAO = new StaticPageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        StaticPage page = staticPageDAO.getPageBySlug("about-us");
        
        request.setAttribute("page", page);
        request.setAttribute("activePage", "about");
        request.setAttribute("pageTitle", "Về Chúng Tôi | Sogo Homestay");
        request.getRequestDispatcher("/WEB-INF/views/about.jsp").forward(request, response);    } 
}
