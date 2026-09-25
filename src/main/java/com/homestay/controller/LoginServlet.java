/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.homestay.controller;

import com.homestay.dao.UserDAO;
import com.homestay.model.User;
import com.homestay.security.CsrfToken;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Optional;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

/**
 *
 * @author admin
 */
@WebServlet(name = "LoginServlet", urlPatterns = { "/login" })
public class LoginServlet extends HttpServlet {

    private final UserDAO userDao = new UserDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet LoginServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet LoginServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the
    // + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepareGoogleLoginCsrfToken(request);
        request.getRequestDispatcher("/Login.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request  servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String loginValue = request.getParameter("username");
        String password = request.getParameter("password");

        String normalizedLoginValue = loginValue == null ? "" : loginValue.trim();
        Optional<User> matchingUser = normalizedLoginValue.isEmpty()
                ? Optional.empty()
                : userDao.findByUsername(normalizedLoginValue);
        if (matchingUser.isEmpty() && !normalizedLoginValue.isEmpty()) {
            matchingUser = userDao.findByEmail(normalizedLoginValue);
        }
        User user = matchingUser.orElse(null);

        boolean validPassword = false;
        if (user != null && user.getPassword() != null && password != null) {
            String dbPass = user.getPassword();
            if (dbPass.startsWith("$2a$") || dbPass.startsWith("$2b$") || dbPass.startsWith("$2y$")) {
                try {
                    validPassword = BCrypt.checkpw(password, dbPass);
                } catch (Exception ignored) {
                    validPassword = false;
                }
            } else {
                validPassword = password.equals(dbPass);
            }
        }

        if (user == null || !validPassword || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            prepareGoogleLoginCsrfToken(request);
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng");
            request.getRequestDispatcher("/Login.jsp").forward(request, response);
            return;
        }

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);

        String displayName = (user.getFullName() != null && !user.getFullName().trim().isEmpty())
                ? user.getFullName().trim()
                : user.getUsername();
        session.setAttribute("userId", user.getId());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("userName", displayName);
        session.setAttribute("roleId", user.getRoleId());
        session.setAttribute("avatar", user.getAvatarUrl());
        session.setAttribute("user", user);

        // phan quyen admin & host & customer
        String roleName = "";
        if (user.getRole() != null && user.getRole().getRoleName() != null) {
            roleName = user.getRole().getRoleName();
        }

        boolean isAdmin = "ROLE_ADMIN".equalsIgnoreCase(roleName) || "ADMIN".equalsIgnoreCase(roleName) || user.getRoleId() == 5;
        boolean isHost = "ROLE_HOST".equalsIgnoreCase(roleName) || "HOST".equalsIgnoreCase(roleName) || "HOTEL_OWNER".equalsIgnoreCase(roleName) || user.getRoleId() == 2;
        String redirectPath;
        if (isAdmin) {
            redirectPath = "/admin/dashboard";
        } else if (isHost) {
            redirectPath = "/host/dashboard";
        } else {
            redirectPath = "/home";
        }

        response.sendRedirect(request.getContextPath() + redirectPath);
    }

    private void prepareGoogleLoginCsrfToken(HttpServletRequest request) {
        String csrfToken = CsrfToken.generate();
        request.getSession(true).setAttribute(CsrfToken.SESSION_ATTRIBUTE, csrfToken);
        request.setAttribute(CsrfToken.SESSION_ATTRIBUTE, csrfToken);
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
