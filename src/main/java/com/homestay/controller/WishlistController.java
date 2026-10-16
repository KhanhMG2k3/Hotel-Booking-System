package com.homestay.controller;

import com.homestay.dao.WishlistDAO;
import com.homestay.model.Wishlist;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * WishlistController - Manages user wishlist operations (viewing, adding, removing, toggling).
 */
@WebServlet(name = "WishlistController", urlPatterns = {
        "/wishlist",
        "/api/wishlist/toggle",
        "/api/wishlist/remove",
        "/api/wishlist/clear",
        "/api/wishlist/count"
})
public class WishlistController extends HttpServlet {

    private WishlistDAO wishlistDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.wishlistDAO = new WishlistDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        // API Endpoint: Count
        if ("/api/wishlist/count".equals(path)) {
            sendJsonCountResponse(response, userId != null ? wishlistDAO.getWishlistCount(userId) : 0, userId != null);
            return;
        }

        // Must be logged in to view /wishlist
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=" +
                    java.net.URLEncoder.encode("Vui lòng đăng nhập để xem danh sách yêu thích", java.nio.charset.StandardCharsets.UTF_8));
            return;
        }

        List<Wishlist> wishlistItems = wishlistDAO.findByUserId(userId);
        request.setAttribute("wishlistItems", wishlistItems);
        request.setAttribute("wishlistCount", wishlistItems.size());
        request.setAttribute("activePage", "wishlist");

        request.getRequestDispatcher("/WEB-INF/views/wishlist.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || "application/json".equalsIgnoreCase(request.getHeader("Accept"))
                || request.getParameter("ajax") != null;

        if (userId == null) {
            if (isAjax) {
                sendJsonResponse(response, HttpServletResponse.SC_OK,
                        "{\"success\": false, \"requireLogin\": true, \"message\": \"Vui lòng đăng nhập để lưu phòng yêu thích!\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/login");
            }
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            if ("/api/wishlist/toggle".equals(path)) {
                action = "toggle";
            } else if ("/api/wishlist/remove".equals(path)) {
                action = "remove";
            } else if ("/api/wishlist/clear".equals(path)) {
                action = "clear";
            } else {
                action = "toggle";
            }
        }

        String roomIdStr = request.getParameter("roomId");
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            roomIdStr = request.getParameter("id");
        }

        Integer roomId = null;
        if (roomIdStr != null && !roomIdStr.trim().isEmpty()) {
            try {
                roomId = Integer.parseInt(roomIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        if ("clear".equalsIgnoreCase(action)) {
            wishlistDAO.clearAll(userId);
            if (isAjax) {
                sendJsonResponse(response, HttpServletResponse.SC_OK,
                        "{\"success\": true, \"count\": 0, \"message\": \"Đã làm trống danh sách yêu thích!\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/wishlist");
            }
            return;
        }

        if (roomId == null || roomId <= 0) {
            if (isAjax) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST,
                        "{\"success\": false, \"message\": \"Mã phòng không hợp lệ!\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/rooms");
            }
            return;
        }

        if ("remove".equalsIgnoreCase(action)) {
            boolean removed = wishlistDAO.removeRoom(userId, roomId);
            int count = wishlistDAO.getWishlistCount(userId);
            if (isAjax) {
                sendJsonResponse(response, HttpServletResponse.SC_OK,
                        "{\"success\": true, \"isWishlisted\": false, \"count\": " + count +
                                ", \"message\": \"Đã bỏ phòng khỏi danh sách yêu thích!\"}");
            } else {
                String referer = request.getHeader("Referer");
                response.sendRedirect(referer != null ? referer : request.getContextPath() + "/wishlist");
            }
            return;
        }

        // Default action: toggle
        boolean isAdded = wishlistDAO.toggleRoomWishlist(userId, roomId);
        int count = wishlistDAO.getWishlistCount(userId);
        String msg = isAdded ? "Đã thêm vào danh sách yêu thích!" : "Đã bỏ khỏi danh sách yêu thích!";

        if (isAjax) {
            sendJsonResponse(response, HttpServletResponse.SC_OK,
                    "{\"success\": true, \"isWishlisted\": " + isAdded + ", \"count\": " + count +
                            ", \"message\": \"" + msg + "\"}");
        } else {
            String referer = request.getHeader("Referer");
            response.sendRedirect(referer != null ? referer : request.getContextPath() + "/rooms");
        }
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, String json) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(statusCode);
        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }

    private void sendJsonCountResponse(HttpServletResponse response, int count, boolean loggedIn) throws IOException {
        sendJsonResponse(response, HttpServletResponse.SC_OK,
                "{\"count\": " + count + ", \"loggedIn\": " + loggedIn + "}");
    }
}
