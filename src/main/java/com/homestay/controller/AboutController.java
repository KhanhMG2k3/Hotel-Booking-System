
package com.homestay.controller;

import com.homestay.dao.AboutUsDAO;
import com.homestay.model.AboutUs;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author admin
 */
@WebServlet(name = "AboutController", urlPatterns = {"/about", "/about-us"})
public class AboutController extends HttpServlet {
   
    private static final long serialVersionUID = 1L;
    private final AboutUsDAO aboutUsDAO = new AboutUsDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        AboutUs aboutData = aboutUsDAO.getAboutUs();
        request.setAttribute("about", aboutData);
        request.setAttribute("page", aboutData); // Tương thích ngược
        request.setAttribute("activePage", "about");
        request.setAttribute("pageTitle", "Về Chúng Tôi | Sogo Homestay");
        request.getRequestDispatcher("/WEB-INF/views/about.jsp").forward(request, response); 
    } 
}
