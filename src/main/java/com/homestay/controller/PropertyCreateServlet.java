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
import java.util.Optional;

/**
 *
 * @author admin
 */
@WebServlet(name = "PropertyCreateServlet", urlPatterns = {"/host/property/create"})
public class PropertyCreateServlet extends HttpServlet {

    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();

    private final PropertyDAO propertyDAO = new PropertyDAO();

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
            out.println("<title>Servlet PropertyCreateServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet PropertyCreateServlet at " + request.getContextPath() + "</h1>");
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
        request.getRequestDispatcher(
                "/WEB-INF/views/host/property-create.jsp"
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

        Optional<HostProfile> hostProfileOptional =
                hostProfileDAO.findByUserId(userId);

        if (hostProfileOptional.isEmpty()) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/become-host"
            );
            return;
        }

        HostProfile hostProfile =
                hostProfileOptional.get();

        if (!"APPROVED".equals(
                hostProfile.getVerificationStatus())) {

            request.setAttribute(
                    "error",
                    "Hồ sơ Host chưa được duyệt."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/property-create.jsp"
            ).forward(request, response);

            return;
        }

        String name = request.getParameter("name");
        String description =
                request.getParameter("description");
        String propertyType =
                request.getParameter("propertyType");
        String address =
                request.getParameter("address");
        String city =
                request.getParameter("city");
        String country =
                request.getParameter("country");

        name = name == null ? "" : name.trim();
        description = description == null
                ? ""
                : description.trim();
        propertyType = propertyType == null
                ? ""
                : propertyType.trim();
        address = address == null
                ? ""
                : address.trim();
        city = city == null ? "" : city.trim();
        country = country == null
                ? "Vietnam"
                : country.trim();

        if (name.isEmpty() || address.isEmpty()) {
            request.setAttribute(
                    "error",
                    "Tên property và địa chỉ là bắt buộc."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/property-create.jsp"
            ).forward(request, response);

            return;
        }

        Property property = new Property(
                hostProfile.getId(),
                name,
                description,
                propertyType,
                address,
                city,
                country
        );

        int propertyId =
                propertyDAO.create(property);

        if (propertyId == -1) {
            request.setAttribute(
                    "error",
                    "Không thể tạo property."
            );

            request.getRequestDispatcher(
                    "/WEB-INF/views/host/property-create.jsp"
            ).forward(request, response);

            return;
        }

        response.sendRedirect(
                request.getContextPath() + "/host/dashboard"
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
