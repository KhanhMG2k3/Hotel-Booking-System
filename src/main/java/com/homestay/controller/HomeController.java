package com.homestay.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * HomeController - Handles requests to home / introduction page.
 * Purely serves homestay introduction, story, highlights, gallery and testimonials.
 */
@WebServlet(name = "HomeController", urlPatterns = {"", "/home", "/index"})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activePage", "home");
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}
