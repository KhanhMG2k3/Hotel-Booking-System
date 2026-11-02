package com.homestay.controller;

import com.homestay.dao.AboutUsDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.AboutUs;
import com.homestay.model.AboutUs.CommitCard;
import com.homestay.model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "EditAboutController", urlPatterns = {"/admin/about/edit", "/host/about/edit", "/about/edit"})
public class EditAboutController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/admin/edit-about.jsp";
    private final AboutUsDAO aboutUsDAO = new AboutUsDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = checkPermission(request, response);
        if (user == null) {
            return;
        }
        AboutUs aboutData = aboutUsDAO.getAboutUs();
        List<User> allUsers = aboutUsDAO.getAllAvailableUsers();
        request.setAttribute("about", aboutData);
        request.setAttribute("allUsers", allUsers);
        request.setAttribute("currentUser", user);
        request.setAttribute("activePage", "about");
        request.setAttribute("pageTitle", "Chỉnh Sửa Giới Thiệu | Sogo Homestay");
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = checkPermission(request, response);
        if (user == null) {
            return;
        }
        request.setCharacterEncoding("UTF-8");
        AboutUs a = new AboutUs();
        a.setTitle(request.getParameter("title"));
        a.setIntroContent(request.getParameter("introContent"));
        a.setBtnExploreText(request.getParameter("btnExploreText"));
        a.setBtnBookText(request.getParameter("btnBookText"));
        a.setCommitTitle(request.getParameter("commitTitle"));
        a.setTeamTitle(request.getParameter("teamTitle"));

        // 1. Nhận danh sách các thẻ lý do động (Icon + Tiêu đề phụ + Nội dung)
        String[] cardIcons = request.getParameterValues("cardIcon");
        String[] cardTitles = request.getParameterValues("cardTitle");
        String[] cardDescs = request.getParameterValues("cardDesc");
        List<CommitCard> cards = new ArrayList<>();
        if (cardTitles != null) {
            for (int i = 0; i < cardTitles.length; i++) {
                String cTitle = cardTitles[i] != null ? cardTitles[i].trim() : "";
                if (!cTitle.isEmpty()) {
                    String cIcon = (cardIcons != null && i < cardIcons.length) ? cardIcons[i] : "ion-ios-home";
                    String cDesc = (cardDescs != null && i < cardDescs.length) ? cardDescs[i] : "";
                    cards.add(new CommitCard(cIcon, cTitle, cDesc));
                }
            }
        }
        a.setCommitCards(cards);

        // 2. Nhận danh sách ID nhân sự được chọn từ Dropdown
        String[] teamUserIdParams = request.getParameterValues("teamUserIds");
        List<Integer> teamUserIds = new ArrayList<>();
        if (teamUserIdParams != null) {
            for (String idStr : teamUserIdParams) {
                try {
                    int uid = Integer.parseInt(idStr.trim());
                    if (uid > 0) {
                        teamUserIds.add(uid);
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }
        a.setTeamUserIds(teamUserIds);

        boolean updated = aboutUsDAO.updateAboutUs(a);
        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin/about/edit?success=true");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/about/edit?error=failed");
        }
    }

    private User checkPermission(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        Integer userId = null;
        if (session.getAttribute("userId") instanceof Number) {
            userId = ((Number) session.getAttribute("userId")).intValue();
        } else if (session.getAttribute("user") instanceof User) {
            userId = ((User) session.getAttribute("user")).getId();
        }

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User user = userDAO.findById(userId).orElse(null);
        if (user == null || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        // Xác định quyền theo TÊN role (sau khi đã có biến user)
        String roleName = "";
        if (user.getRole() != null && user.getRole().getRoleName() != null) {
            roleName = user.getRole().getRoleName().trim().toUpperCase(java.util.Locale.ROOT);
        }
        boolean isAdmin = "ROLE_ADMIN".equals(roleName) || "ADMIN".equals(roleName);
        boolean isHost = "ROLE_HOST".equals(roleName) || "HOST".equals(roleName)
                || "HOTEL_OWNER".equals(roleName);

        if (!isAdmin && !isHost) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa trang này.");
            return null;
        }
        return user;
    }
}
