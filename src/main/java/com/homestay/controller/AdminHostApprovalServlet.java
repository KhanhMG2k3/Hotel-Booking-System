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
import java.util.Optional;

/**
 *
 * @author admin
 */
@WebServlet(name = "AdminHostApprovalServlet", urlPatterns = {"/admin/host/approve"})
public class AdminHostApprovalServlet extends HttpServlet {

    private static final int ROLE_HOST_ID = 3;
    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();

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
            out.println("<title>Servlet AdminHostApprovalServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminHostApprovalServlet at " + request.getContextPath() + "</h1>");
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
        processRequest(request, response);
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
        String profileIdParameter
                = request.getParameter("profileId");

        if (profileIdParameter == null
                || profileIdParameter.isBlank()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/dashboard"
            );
            return;
        }

        int profileId;

        try {
            profileId
                    = Integer.parseInt(profileIdParameter);
        } catch (NumberFormatException exception) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/dashboard"
            );
            return;
        }

        Optional<HostProfile> profileOptional
                = hostProfileDAO.findById(profileId);

        if (profileOptional.isEmpty()) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/dashboard"
            );
            return;
        }

        HostProfile profile
                = profileOptional.get();

        if (!"PENDING".equals(
                profile.getVerificationStatus())) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/dashboard"
            );  
            return;
        }

        boolean approved
                = hostProfileDAO.approveAndAssignHostRole(
                        profile.getId(),
                        profile.getUserId(),
                        ROLE_HOST_ID
                );

        response.sendRedirect(
                request.getContextPath()
                + "/admin/dashboard"
        );
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
