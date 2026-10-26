package com.homestay.controller;

import com.homestay.dao.RoomDAO;
import com.homestay.dao.WishlistDAO;
import com.homestay.model.Room;
import com.homestay.dao.ReviewDAO;
import com.homestay.dao.ReviewReplyDAO;
import com.homestay.model.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * RoomController - Handles listing and viewing rich details of homestay rooms.
 */
@WebServlet(name = "RoomController", urlPatterns = {"/rooms", "/room-detail"})
public class RoomController extends HttpServlet {

    private RoomDAO roomDAO;
    private WishlistDAO wishlistDAO;
    private ReviewDAO reviewDAO;
    private ReviewReplyDAO replyDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.roomDAO = new RoomDAO();
        this.wishlistDAO = new WishlistDAO();
        this.reviewDAO = new ReviewDAO();
        this.replyDAO = new ReviewReplyDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        if ("/room-detail".equals(servletPath)) {
            handleRoomDetail(request, response);
        } else {
            handleRoomList(request, response);
        }
    }

    private void handleRoomList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String typeIdStr = request.getParameter("typeId");
        String capacityStr = request.getParameter("capacity");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String sortBy = request.getParameter("sortBy");

        Integer typeId = null;
        if (typeIdStr != null && !typeIdStr.trim().isEmpty()) {
            try {
                typeId = Integer.parseInt(typeIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        Integer capacity = null;
        if (capacityStr != null && !capacityStr.trim().isEmpty()) {
            try {
                capacity = Integer.parseInt(capacityStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        java.math.BigDecimal minPrice = null;
        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            try {
                minPrice = new java.math.BigDecimal(minPriceStr.trim());
            } catch (Exception ignored) {
            }
        }

        java.math.BigDecimal maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                maxPrice = new java.math.BigDecimal(maxPriceStr.trim());
            } catch (Exception ignored) {
            }
        }

        String ratingParam = request.getParameter("rating");
        if (ratingParam == null || ratingParam.trim().isEmpty()) {
            ratingParam = request.getParameter("minRating");
        }

        Double minRating = null;
        Double maxRating = null;
        if (ratingParam != null && !ratingParam.trim().isEmpty()) {
            ratingParam = ratingParam.trim();
            if (ratingParam.contains("-")) {
                String[] parts = ratingParam.split("-");
                try {
                    minRating = Double.parseDouble(parts[0].trim());
                    maxRating = Double.parseDouble(parts[1].trim());
                } catch (NumberFormatException ignored) {
                }
            } else {
                try {
                    double val = Double.parseDouble(ratingParam);
                    if (Math.abs(val - 3.5) < 0.01) {
                        minRating = 3.5;
                        maxRating = 3.99;
                    } else if (Math.abs(val - 4.0) < 0.01) {
                        minRating = 4.0;
                        maxRating = 4.49;
                    } else if (Math.abs(val - 4.5) < 0.01) {
                        minRating = 4.5;
                        maxRating = 4.79;
                    } else if (Math.abs(val - 4.8) < 0.01 || Math.abs(val - 5.0) < 0.01) {
                        minRating = 4.8;
                        maxRating = 5.0;
                    } else if (Math.abs(val - 3.0) < 0.01) {
                        minRating = 3.0;
                        maxRating = 3.49;
                    } else {
                        minRating = val;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }

        String provinceIdStr = request.getParameter("provinceId");
        Integer provinceId = null;
        if (provinceIdStr != null && !provinceIdStr.trim().isEmpty()) {
            try {
                provinceId = Integer.parseInt(provinceIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        // Phân trang danh sách phòng: 6 phòng trên 1 trang
        final int pageSize = 6;
        String pageParam = request.getParameter("page");
        int currentPage = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam.trim());
                if (currentPage < 1) {
                    currentPage = 1;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        int totalRoomsFound = roomDAO.countRooms(keyword, minPrice, maxPrice, capacity, typeId, provinceId, minRating, maxRating);
        int totalPages = (totalRoomsFound > 0) ? (int) Math.ceil((double) totalRoomsFound / pageSize) : 1;
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int offset = (currentPage - 1) * pageSize;
        List<Room> rooms = roomDAO.searchRooms(keyword, minPrice, maxPrice, capacity, typeId, provinceId, minRating, maxRating, sortBy, offset, pageSize);
        List<com.homestay.model.RoomType> roomTypes = roomDAO.getAllRoomTypes();
        List<com.homestay.model.Province> provinces = roomDAO.getAllProvinces();

        request.setAttribute("rooms", rooms);
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("provinces", provinces);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        request.setAttribute("typeId", typeId);
        request.setAttribute("provinceId", provinceId);
        request.setAttribute("capacity", capacity);
        request.setAttribute("minPrice", minPrice);
        request.setAttribute("maxPrice", maxPrice);
        request.setAttribute("rating", ratingParam != null ? ratingParam : "");
        request.setAttribute("minRating", minRating);
        request.setAttribute("maxRating", maxRating);
        request.setAttribute("sortBy", sortBy != null ? sortBy : "");
        request.setAttribute("totalRoomsFound", totalRoomsFound);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("activePage", "rooms");

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
        if (userId != null) {
            Set<Integer> wishlistRoomIds = wishlistDAO.getWishlistRoomIds(userId);
            request.setAttribute("wishlistRoomIds", wishlistRoomIds);
            request.setAttribute("wishlistCount", wishlistRoomIds.size());
        }

        request.getRequestDispatcher("/WEB-INF/views/rooms.jsp").forward(request, response);
    }

    private void handleRoomDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam.trim());
                Optional<Room> roomOpt = roomDAO.findById(id);
                if (roomOpt.isPresent()) {
                    request.setAttribute("room", roomOpt.get());
                    List<Review> reviews = reviewDAO.findApprovedReviewsByRoomId(id, 0, 10);
                    replyDAO.attachReplies(reviews);
                    request.setAttribute("reviews", reviews);
                    request.setAttribute("reviewTotal", reviewDAO.countApprovedReviewsByRoomId(id));

                      request.setAttribute("activePage", "rooms");

                    HttpSession session = request.getSession(false);
                    Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;
                    if (userId != null) {
                        boolean isWishlisted = wishlistDAO.isRoomInWishlist(userId, id);
                        request.setAttribute("isWishlisted", isWishlisted);
                        request.setAttribute("wishlistCount", wishlistDAO.getWishlistCount(userId));
                    }

                    request.getRequestDispatcher("/WEB-INF/views/room-detail.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        response.sendRedirect(request.getContextPath() + "/rooms");
    }
}
