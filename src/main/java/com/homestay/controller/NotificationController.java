package com.homestay.controller;

import com.homestay.dao.NotificationDAO;
import com.homestay.model.Notification;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 *
 * @author admin
 */
@WebServlet(name = "NotificationController", urlPatterns = {"/notifications", "/api/notifications/count", "/api/notifications/recent", "/api/notifications/mark-read", "/api/notifications/mark-all-read", "/api/notifications/delete"})
public class NotificationController extends HttpServlet {

    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.notificationDAO = new NotificationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        // API Endpoint: Count unread
        if ("/api/notifications/count".equals(path)) {
            sendJsonCountResponse(response, userId != null ? notificationDAO.countUnreadByUserId(userId) : 0, userId != null);
            return;
        }
        // API Endpoint: Recent notifications for header dropdown
        if ("/api/notifications/recent".equals(path)) {
            sendJsonRecentResponse(response, userId);
            return;
        }
        // Must be logged in to view full page /notifications
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?error="
                    + URLEncoder.encode("Vui lòng đăng nhập để xem thông báo của bạn", StandardCharsets.UTF_8));
            return;
        }
        // Full Page /notifications
        String tab = request.getParameter("tab");
        if (tab == null || tab.isBlank()) {
            tab = "all";
        }
        tab = tab.toLowerCase();
        String filterType = null;
        Boolean unreadOnly = null;
        switch (tab) {
            case "unread":
                unreadOnly = true;
                break;
            case "booking":
                filterType = "BOOKING";
                break;
            case "promotion":
                filterType = "PROMOTION";
                break;
            case "review":
                filterType = "REVIEW";
                break;
            case "all":
            default:
                tab = "all";
                break;
        }
        int page = 1;
        int pageSize = 10;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isBlank()) {
                page = Math.max(1, Integer.parseInt(pageParam));
            }
        } catch (NumberFormatException ignored) {
        }
        int offset = (page - 1) * pageSize;
        int totalItems = notificationDAO.countByUserId(userId, filterType, unreadOnly);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);
        List<Notification> notifications = notificationDAO.findByUserId(userId, filterType, unreadOnly, pageSize, offset);
        int unreadCount = notificationDAO.countUnreadByUserId(userId);
        request.setAttribute("notifications", notifications);
        request.setAttribute("activeTab", tab);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("unreadCount", unreadCount);
        request.setAttribute("activePage", "notifications");
        request.getRequestDispatcher("/WEB-INF/views/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.setContentType("application/json;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }
        // Endpoint: Mark one notification as read
        if ("/api/notifications/mark-read".equals(path)) {
            try {
                int notificationId = Integer.parseInt(request.getParameter("id"));
                boolean success = notificationDAO.markAsRead(notificationId, userId);
                int remainingUnread = notificationDAO.countUnreadByUserId(userId);
                // Check if redirect is requested
                String redirect = request.getParameter("redirect");
                String targetUrl = request.getParameter("targetUrl");
                if ("true".equalsIgnoreCase(redirect) && targetUrl != null && !targetUrl.isBlank()) {
                    if (!targetUrl.startsWith("http") && !targetUrl.startsWith(request.getContextPath())) {
                        targetUrl = request.getContextPath() + (targetUrl.startsWith("/") ? "" : "/") + targetUrl;
                    }
                    response.sendRedirect(targetUrl);
                    return;
                }
                response.setContentType("application/json;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.write(String.format("{\"success\":%b,\"unreadCount\":%d}", success, remainingUnread));
            } catch (Exception e) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"ID không hợp lệ\"}");
            }
            return;
        }
        // Endpoint: Mark all notifications as read
        if ("/api/notifications/mark-all-read".equals(path)) {
            boolean success = notificationDAO.markAllAsRead(userId);
            String ajax = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equalsIgnoreCase(ajax) || "true".equals(request.getParameter("ajax"))) {
                response.setContentType("application/json;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.write(String.format("{\"success\":%b,\"unreadCount\":0}", success));
            } else {
                response.sendRedirect(request.getContextPath() + "/notifications");
            }
            return;
        }
        // Endpoint: Delete notification
        if ("/api/notifications/delete".equals(path)) {
            try {
                int notificationId = Integer.parseInt(request.getParameter("id"));
                boolean success = notificationDAO.deleteNotification(notificationId, userId);
                int remainingUnread = notificationDAO.countUnreadByUserId(userId);
                response.setContentType("application/json;charset=UTF-8");
                PrintWriter out = response.getWriter();
                out.write(String.format("{\"success\":%b,\"unreadCount\":%d}", success, remainingUnread));
            } catch (Exception e) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\":false,\"message\":\"ID không hợp lệ\"}");
            }
            return;
        }
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void sendJsonCountResponse(HttpServletResponse response, int count, boolean loggedIn) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.write(String.format("{\"success\":true,\"loggedIn\":%b,\"unreadCount\":%d}", loggedIn, count));
    }

    private void sendJsonRecentResponse(HttpServletResponse response, Integer userId) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        if (userId == null) {
            out.write("{\"success\":false,\"loggedIn\":false,\"notifications\":[]}");
            return;
        }
        List<Notification> list = notificationDAO.findTopRecentByUserId(userId, 5);
        int unreadCount = notificationDAO.countUnreadByUserId(userId);
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,\"loggedIn\":true,\"unreadCount\":").append(unreadCount).append(",\"notifications\":[");
        for (int i = 0; i < list.size(); i++) {
            Notification n = list.get(i);
            json.append("{")
                    .append("\"id\":").append(n.getId()).append(",")
                    .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                    .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                    .append("\"type\":\"").append(escapeJson(n.getType())).append("\",")
                    .append("\"typeLabel\":\"").append(escapeJson(n.getTypeLabel())).append("\",")
                    .append("\"iconClass\":\"").append(escapeJson(n.getIconClass())).append("\",")
                    .append("\"badgeClass\":\"").append(escapeJson(n.getBadgeClass())).append("\",")
                    .append("\"targetUrl\":\"").append(escapeJson(n.getTargetUrl())).append("\",")
                    .append("\"isRead\":").append(n.isRead()).append(",")
                    .append("\"timeAgo\":\"").append(escapeJson(n.getTimeAgo())).append("\"")
                    .append("}");
            if (i < list.size() - 1) {
                json.append(",");
            }
        }
        json.append("]}");
        out.write(json.toString());
    }

    private String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
