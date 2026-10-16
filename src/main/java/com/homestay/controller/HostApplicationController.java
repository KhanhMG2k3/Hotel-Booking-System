package com.homestay.controller;

import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.HostApplication;
import com.homestay.model.User;
import com.homestay.util.LoginUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/** Serves and accepts customer requests to become a Host. */
public class HostApplicationController extends HttpServlet {
    private static final String VIEW = "/WEB-INF/views/become-host.jsp";

    private final HostApplicationDAO applicationDAO = new HostApplicationDAO();
    private final UserDAO userDAO = new UserDAO();

    /** Loads the Host application page for an eligible signed-in account. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer userId = getSignedInUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            String roleName = user.getRole() != null ? user.getRole().getName() : "";
            if (!roleName.contains("CUSTOMER") && !roleName.contains("HOST")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            request.getSession().setAttribute("role", user.getRole().getName());
            if ("1".equals(request.getParameter("submitted"))) {
                request.setAttribute("messageSuccess", "Yêu cầu trở thành Host đã được gửi.");
            }
            showPage(request, response, userId);
        } catch (SQLException e) {
            throw new ServletException("Unable to load the host application page.", e);
        }
    }

    /** Validates and submits a Host application, then redirects after success. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        Integer userId = getSignedInUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Reject stale or forged form submissions before accepting application details.
        if (!LoginUtil.consumeCsrfToken(request, request.getParameter("csrfToken"))) {
            request.setAttribute("messageError", "Phiên đăng ký đã hết hạn. Vui lòng thử lại.");
            forwardToPage(request, response, userId);
            return;
        }

        // Enforce the note length on the server before calling the application DAO.
        String applicationNote = valueOrEmpty(request.getParameter("applicationNote")).trim();
        if (applicationNote.length() < 20 || applicationNote.length() > 1000) {
            request.setAttribute("messageError",
                    "Thông tin đăng ký cần có từ 20 đến 1000 ký tự.");
            request.setAttribute("applicationNote", applicationNote);
            forwardToPage(request, response, userId);
            return;
        }

        try {
            HostApplication application = applicationDAO.submit(userId, applicationNote);
            if (application == null) {
                request.setAttribute("messageError",
                        "Tài khoản không đủ điều kiện hoặc đã có yêu cầu đang chờ duyệt.");
                request.setAttribute("applicationNote", applicationNote);
                forwardToPage(request, response, userId);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/become-host?submitted=1");
        } catch (SQLException e) {
            throw new ServletException("Unable to submit the host application.", e);
        }
    }

    /** Reloads the application page after a validation or submission error. */
    private void forwardToPage(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        try {
            showPage(request, response, userId);
        } catch (SQLException e) {
            throw new ServletException("Unable to reload the host application page.", e);
        }
    }

    /** Loads the applicant's latest application and forwards it to the JSP. */
    private void showPage(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, ServletException, IOException {
        HostApplication application = applicationDAO.findLatestByUserId(userId);
        request.setAttribute("application", application);
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));
        request.setAttribute("activePage", "become-host");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    /** Returns the session user ID, or {@code null} when the visitor is signed out. */
    private Integer getSignedInUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            return null;
        }
        return ((Number) session.getAttribute("userId")).intValue();
    }

    private String valueOrEmpty(String value) {
        return value == null ? "" : value;
    }
}
