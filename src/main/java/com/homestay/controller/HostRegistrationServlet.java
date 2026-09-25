/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.homestay.controller;

import com.homestay.dao.HostProfileDAO;
import com.homestay.model.HostProfile;
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
@WebServlet(name="HostRegistrationServlet", urlPatterns={"/become-host"})
public class HostRegistrationServlet extends HttpServlet {
   private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
            out.println("<title>Servlet HostRegistrationServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet HostRegistrationServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
         request.getRequestDispatcher(
                "/WEB-INF/views/host/register.jsp"
        ).forward(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session =
                request.getSession(false);

        if (session == null
                || !(session.getAttribute("userId")
                instanceof Integer)) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        int userId =
                (Integer) session.getAttribute("userId");

        if (hostProfileDAO.findByUserId(userId).isPresent()) {
            request.setAttribute(
                    "error",
                    "Bạn đã có hồ sơ Host."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/register.jsp"
            ).forward(request, response);

            return;
        }

        String businessName =
                request.getParameter("businessName");

        String businessType =
                request.getParameter("businessType");

        String phone =
                request.getParameter("phone");

        businessName = businessName == null
                ? ""
                : businessName.trim();

        businessType = businessType == null
                ? ""
                : businessType.trim();

        phone = phone == null
                ? ""
                : phone.trim();

        if (businessName.isEmpty()) {
            request.setAttribute(
                    "error",
                    "Vui lòng nhập tên doanh nghiệp."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/register.jsp"
            ).forward(request, response);

            return;
        }

        HostProfile hostProfile = new HostProfile(
                userId,
                businessName,
                businessType,
                phone
        );

        int profileId =
                hostProfileDAO.create(hostProfile);

        if (profileId == -1) {
            request.setAttribute(
                    "error",
                    "Không thể tạo hồ sơ Host."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/register.jsp"
            ).forward(request, response);

            return;
        }

        response.sendRedirect(
                request.getContextPath() + "/home"
        );
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
