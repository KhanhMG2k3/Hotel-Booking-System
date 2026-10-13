/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.homestay.controller;

import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.model.HostProfile;
import com.homestay.model.Property;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;

/**
 *
 * @author admin
 */
@WebServlet(name = "HostDashboardServlet", urlPatterns = {"/host/dashboard"})
public class HostDashboardServlet extends HttpServlet {

    private final HostProfileDAO hostProfileDAO
            = new HostProfileDAO();

    private final PropertyDAO propertyDAO
            = new PropertyDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet HostDashboardServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HostDashboardServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session
                = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        Object userIdAttribute
                = session.getAttribute("userId");

        if (!(userIdAttribute instanceof Integer)) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        int userId = (Integer) userIdAttribute;

        Optional<HostProfile> hostProfileOptional
                = hostProfileDAO.findByUserId(userId);

        if (hostProfileOptional.isEmpty()) {
            request.setAttribute(
                    "error",
                    "Tài khoản chưa có hồ sơ Host."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/dashboard.jsp"
            ).forward(request, response);

            return;
        }

        HostProfile hostProfile
                = hostProfileOptional.get();

        List<Property> properties
                = propertyDAO.findByHostId(hostProfile.getId());

        request.setAttribute("hostProfile", hostProfile);
        request.setAttribute("properties", properties);

        request.getRequestDispatcher(
                "/WEB-INF/views/host/dashboard.jsp"
        ).forward(request, response);
    }


/**
 * Handles the HTTP <code>POST</code> method.
 *
 * @param request servlet request
 * @param response servlet response
 * @throws ServletException if a servlet-specific error occurs
 * @throws IOException if an I/O error occurs
 */
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
