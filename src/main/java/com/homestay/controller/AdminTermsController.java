package com.homestay.controller;

import com.homestay.dao.TermDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.TermSection;
import com.homestay.model.TermSetting;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@WebServlet(name = "AdminTermsController", urlPatterns = {"/admin/terms"})
public class AdminTermsController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final TermDAO termDAO = new TermDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Verify that the current user is an active Admin or Host
        User user = checkPermission(request, response, false);
        if (user == null) {
            return;
        }

        // Step 2: Load current terms setting and sections and forward to the editor view
        renderTermsEditor(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Step 1: Enforce Admin or Host write permission before processing form data
        User user = checkPermission(request, response, true);
        if (user == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Step 2: Read main title and dynamic section blocks from request parameters
        String mainTitle = request.getParameter("mainTitle");
        String lastUpdated = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());

        String[] sectionTitles = request.getParameterValues("sectionTitle");
        String[] sectionBlocksJsons = request.getParameterValues("sectionBlocksJson");

        if (mainTitle == null || mainTitle.trim().isEmpty()) {
            request.setAttribute("error", "Tiêu đề chính không được để trống!");
            renderTermsEditor(request, response);
            return;
        }

        // Step 3: Validate each section title and assemble TermSection models
        List<TermSection> sectionList = new ArrayList<>();
        if (sectionTitles != null) {
            for (int i = 0; i < sectionTitles.length; i++) {
                String title = sectionTitles[i] != null ? sectionTitles[i].trim() : "";
                String blocksJson = (sectionBlocksJsons != null && i < sectionBlocksJsons.length)
                        ? sectionBlocksJsons[i]
                        : "[]";

                if (title.isEmpty()) {
                    request.setAttribute("error", "Mục thứ " + (i + 1) + " chưa nhập Tiêu đề!");
                    renderTermsEditor(request, response);
                    return;
                }

                TermSection sec = new TermSection();
                sec.setSectionOrder(i + 1);
                sec.setSidebarTitle(title);
                sec.setContentTitle(title);
                sec.setContentType("multi-block");
                // Persist ordered multi-block JSON array in contentText
                sec.setContentText(blocksJson);
                sec.setTableJson(null);
                sec.setCalloutText(null);
                sec.setCalloutType(null);

                sectionList.add(sec);
            }
        }

        // Step 4: Save updated terms setting and sections, then redirect or show error
        TermSetting setting = new TermSetting(mainTitle, lastUpdated);
        boolean success = termDAO.saveAllTerms(setting, sectionList);
        if (success) {
            request.getSession().setAttribute("msg", "Đã lưu và cập nhật điều khoản thành công lúc " + lastUpdated + "!");
            response.sendRedirect(request.getContextPath() + "/admin/terms");
        } else {
            request.setAttribute("error", "Lưu thất bại! Đã xảy ra lỗi cơ sở dữ liệu.");
            renderTermsEditor(request, response);
        }
    }

    private void renderTermsEditor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        TermSetting setting = termDAO.getSetting();
        List<TermSection> sections = termDAO.getAllSections();
        request.setAttribute("setting", setting);
        request.setAttribute("sections", sections);
        request.setAttribute("activePage", "terms");
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-terms.jsp").forward(request, response);
    }

    /**
     * Validate that the session belongs to an active user with Admin or Host privileges.
     */
    private User checkPermission(HttpServletRequest request, HttpServletResponse response, boolean isPost)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn cần đăng nhập để thực hiện thao tác này.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return null;
        }

        Integer userId = null;
        if (session.getAttribute("userId") instanceof Number) {
            userId = ((Number) session.getAttribute("userId")).intValue();
        } else if (session.getAttribute("user") instanceof User) {
            userId = ((User) session.getAttribute("user")).getId();
        }

        User user = null;
        if (userId != null && userId > 0) {
            user = userDAO.findById(userId).orElse(null);
            if (user == null || (user.getStatus() != null && !"ACTIVE".equalsIgnoreCase(user.getStatus()))) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return null;
            }
        } else if (session.getAttribute("user") instanceof User) {
            user = (User) session.getAttribute("user");
        }

        if (user == null) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn cần đăng nhập để thực hiện thao tác này.");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return null;
        }

        String roleName = "";
        if (user.getRole() != null) {
            String rawRole = user.getRole().getRoleName() != null
                    ? user.getRole().getRoleName()
                    : user.getRole().getName();
            if (rawRole != null) {
                roleName = rawRole.trim().toUpperCase(Locale.ROOT);
            }
        } else if (session.getAttribute("role") instanceof String) {
            roleName = ((String) session.getAttribute("role")).trim().toUpperCase(Locale.ROOT);
        }

        boolean isAdmin = "ROLE_ADMIN".equals(roleName)
                || "ADMIN".equals(roleName)
                || "ADMINISTRATOR".equals(roleName);
        boolean isHost = "ROLE_HOST".equals(roleName)
                || "HOST".equals(roleName)
                || "HOTEL_OWNER".equals(roleName);

        if (!isAdmin && !isHost) {
            if (isPost) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa điều khoản.");
            } else {
                response.sendRedirect(request.getContextPath() + "/home?error=no_permission");
            }
            return null;
        }

        return user;
    }
}
