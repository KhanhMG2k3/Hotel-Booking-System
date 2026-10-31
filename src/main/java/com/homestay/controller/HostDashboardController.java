package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostApplication;
import com.homestay.model.Room;
import com.homestay.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Loads the signed-in Host's dashboard, owned property summaries, and dynamic revenue metrics. */
public class HostDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/host-dashboard.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final HostApplicationDAO applicationDAO = new HostApplicationDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    /** Authorizes the Host and forwards dashboard data to the JSP. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int userId = ((Number) session.getAttribute("userId")).intValue();
            // Check the persisted account and approval state before exposing Host data.
            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            String roleName = user.getRole() != null ? user.getRole().getName() : "";
            if (!roleName.contains("HOST")) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            if (!propertyDAO.isApprovedHost(userId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            session.setAttribute("role", "HOST");
            request.setAttribute("hostName", user.getDisplayName() == null
                    || user.getDisplayName().isBlank() ? user.getUsername() : user.getDisplayName());
            HostApplication application = applicationDAO.findLatestByUserId(userId);
            request.setAttribute("application", application);
            boolean isApproved = application != null && application.getStatus() == HostApplication.Status.APPROVED;
            request.setAttribute("applicationApproved", isApproved);

            // Fetch dynamic revenue statistics and recent reservations for approved Host
            if (isApproved) {
                int currentYear = LocalDate.now().getYear();
                BigDecimal totalRevenue = bookingDAO.getTotalRevenueByHost(userId);
                int totalBookings = bookingDAO.countTotalBookingsByHost(userId);
                int completedStays = bookingDAO.countCompletedStaysByHost(userId);
                Map<Integer, BigDecimal> monthlyData = bookingDAO.getMonthlyRevenueByHost(userId, currentYear);
                List<Booking> recentBookings = bookingDAO.findRecentBookingsByHost(userId, 10);

                // Build a JSON array of 12 monthly amounts for Chart.js
                StringBuilder sb = new StringBuilder("[");
                for (int m = 1; m <= 12; m++) {
                    BigDecimal amt = monthlyData.getOrDefault(m, BigDecimal.ZERO);
                    sb.append(amt.toPlainString());
                    if (m < 12) {
                        sb.append(",");
                    }
                }
                sb.append("]");

                request.setAttribute("totalRevenue", totalRevenue);
                request.setAttribute("totalBookings", totalBookings);
                request.setAttribute("completedStays", completedStays);
                request.setAttribute("currentYear", currentYear);
                request.setAttribute("monthlyRevenueJson", sb.toString());
                request.setAttribute("recentBookings", recentBookings);
            }

            request.setAttribute("properties", propertyDAO.findByOwnerId(userId));
            request.setAttribute("activePage", "host-dashboard");
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load the host dashboard.", e);
        }
    }

    /** Handles Host actions such as editing room details. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("userId") instanceof Number)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int userId = ((Number) session.getAttribute("userId")).intValue();
            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            String roleName = user.getRole() != null ? user.getRole().getName() : "";
            if (!roleName.contains("HOST") || !propertyDAO.isApprovedHost(userId)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String action = request.getParameter("action");
            if ("editRoom".equals(action)) {
                handleEditRoom(request, response, session, userId);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/host/dashboard");
        } catch (SQLException e) {
            throw new ServletException("Unable to process host request.", e);
        }
    }

    private void handleEditRoom(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session, int userId)
            throws SQLException, IOException {
        String propertyIdStr = request.getParameter("propertyId");
        String roomIdStr = request.getParameter("roomId");
        String roomName = request.getParameter("roomName");
        String roomType = request.getParameter("roomType");
        String priceStr = request.getParameter("pricePerNight");
        String maxGuestsStr = request.getParameter("maxGuests");
        String bedCountStr = request.getParameter("bedCount");
        String bathroomCountStr = request.getParameter("bathroomCount");
        String sortOrderStr = request.getParameter("sortOrder");
        String[] amenities = request.getParameterValues("amenities");

        if (propertyIdStr == null || roomIdStr == null || roomName == null || priceStr == null) {
            session.setAttribute("messageError", "Dữ liệu phòng không đầy đủ. Vui lòng thử lại.");
            response.sendRedirect(request.getContextPath() + "/host/dashboard");
            return;
        }

        try {
            int propertyId = Integer.parseInt(propertyIdStr.trim());
            int roomId = Integer.parseInt(roomIdStr.trim());
            roomName = roomName.trim();

            if (roomName.isEmpty() || roomName.length() > 120) {
                session.setAttribute("messageError", "Tên phòng không được để trống và tối đa 120 ký tự.");
                response.sendRedirect(request.getContextPath() + "/host/dashboard");
                return;
            }

            if (roomType == null || !roomType.matches("SINGLE|DOUBLE|TWIN|FAMILY|SUITE|OTHER")) {
                roomType = "DOUBLE";
            }

            priceStr = priceStr.trim().replace(",", "");
            BigDecimal price = new BigDecimal(priceStr);
            if (price.compareTo(BigDecimal.ZERO) <= 0 || price.compareTo(new BigDecimal("99999999.99")) > 0) {
                session.setAttribute("messageError", "Giá phòng phải lớn hơn 0 và không vượt quá 99.999.999 VNĐ.");
                response.sendRedirect(request.getContextPath() + "/host/dashboard");
                return;
            }

            int maxGuests = maxGuestsStr != null && !maxGuestsStr.isBlank()
                    ? Math.max(1, Integer.parseInt(maxGuestsStr.trim())) : 2;
            int bedCount = bedCountStr != null && !bedCountStr.isBlank()
                    ? Math.max(1, Integer.parseInt(bedCountStr.trim())) : 1;
            int bathroomCount = bathroomCountStr != null && !bathroomCountStr.isBlank()
                    ? Math.max(1, Integer.parseInt(bathroomCountStr.trim())) : 1;
            int sortOrder = sortOrderStr != null && !sortOrderStr.isBlank()
                    ? Math.max(0, Integer.parseInt(sortOrderStr.trim())) : 0;

            Room room = new Room();
            room.setId(roomId);
            room.setPropertyId(propertyId);
            room.setRoomName(roomName);
            room.setRoomType(roomType);
            room.setPricePerNight(price);
            room.setMaxGuests(maxGuests);
            room.setBedCount(bedCount);
            room.setBathroomCount(bathroomCount);
            room.setSortOrder(sortOrder);

            List<String> amenityList = new ArrayList<>();
            if (amenities != null) {
                for (String a : amenities) {
                    if (a != null && !a.isBlank()) {
                        amenityList.add(a.trim());
                    }
                }
            }
            room.setAmenities(amenityList);

            boolean updated = propertyDAO.updateRoom(userId, propertyId, roomId, room);
            if (updated) {
                session.setAttribute("messageSuccess", "Đã cập nhật thông tin phòng \"" + roomName + "\" thành công!");
            } else {
                session.setAttribute("messageError", "Không thể cập nhật phòng. Vui lòng kiểm tra quyền sở hữu hoặc tính hợp lệ của dữ liệu.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("messageError", "Dữ liệu nhập số (giá, sức chứa, số giường, v.v.) không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/host/dashboard");
    }
}
