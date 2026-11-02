package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostApplicationDAO;
import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.dao.WalletDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostApplication;
import com.homestay.model.HostProfile;
import com.homestay.model.Property;
import com.homestay.model.Room;
import com.homestay.model.User;
import com.homestay.model.WalletTransaction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * HostDashboardController - Complete host management overview:
 * - Property and room management
 * - Real Model 2 Host Wallet balance, top-up, and revenue withdrawal
 * - Interactive revenue analytics and reservation calendar
 */
@WebServlet(name = "HostDashboardController", urlPatterns = {"/host/dashboard"})
public class HostDashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VIEW = "/WEB-INF/views/host/dashboard.jsp";

    private final UserDAO userDAO = new UserDAO();
    private final HostApplicationDAO applicationDAO = new HostApplicationDAO();
    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final WalletDAO walletDAO = new WalletDAO();

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
            User user = userDAO.findById(userId).orElse(null);
            if (user == null || !"ACTIVE".equals(user.getStatus())) {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Optional<HostProfile> hostProfileOptional = hostProfileDAO.findByUserId(userId);
            request.setAttribute("hostProfile", hostProfileOptional.orElse(null));

            String hostDisplayName = user.getDisplayName() == null || user.getDisplayName().isBlank()
                    ? user.getUsername() : user.getDisplayName();
            request.setAttribute("hostName", hostDisplayName);

            HostApplication application = applicationDAO.findLatestByUserId(userId);
            request.setAttribute("application", application);

            List<Property> properties = propertyDAO.findByOwnerId(userId);
            if (properties == null || properties.isEmpty()) {
                properties = propertyDAO.findByHostId(userId);
            }
            request.setAttribute("properties", properties);

            // Fetch dynamic revenue statistics
            int currentYear = LocalDate.now().getYear();
            BigDecimal totalRevenue = bookingDAO.getTotalRevenueByHost(userId);
            int totalBookings = bookingDAO.countTotalBookingsByHost(userId);
            int completedStays = bookingDAO.countCompletedStaysByHost(userId);
            Map<Integer, BigDecimal> monthlyData = bookingDAO.getMonthlyRevenueByHost(userId, currentYear);
            List<Booking> recentBookings = bookingDAO.findRecentBookingsByHost(userId, 10);

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

            // Host Wallet Balance, Transactions, and Bookings for Withdrawal
            BigDecimal walletBalance = walletDAO.getWalletBalance(userId);
            List<WalletTransaction> transactions = walletDAO.findTransactionsByUserId(userId);
            List<Booking> bookingsForWithdrawal = bookingDAO.findBookingsByHostProperties(userId);

            request.setAttribute("walletBalance", walletBalance);
            request.setAttribute("transactions", transactions);
            request.setAttribute("bookings", bookingsForWithdrawal);

            String msg = request.getParameter("msg");
            if ("withdraw_success".equalsIgnoreCase(msg)) {
                request.setAttribute("successMessage", "Rút tiền doanh thu về tài khoản ngân hàng thành công! Số dư ví đã được cập nhật.");
            } else if ("topup_success".equalsIgnoreCase(msg)) {
                request.setAttribute("successMessage", "Nạp tiền vào Ví Host thành công!");
            }

            request.setAttribute("activePage", "host-dashboard");
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to load the host dashboard.", e);
        }
    }

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
            String action = request.getParameter("action");
            if (action == null) {
                action = "";
            }

            boolean wantsJson = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                    || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

            if ("withdraw".equalsIgnoreCase(action.trim())) {
                handleWithdraw(request, response, userId, wantsJson);
                return;
            }

            if ("topup".equalsIgnoreCase(action.trim())) {
                handleTopup(request, response, userId, wantsJson);
                return;
            }

            if ("editRoom".equalsIgnoreCase(action.trim())) {
                handleEditRoom(request, response, session, userId);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/host/dashboard");
        } catch (Exception e) {
            throw new ServletException("Error handling host dashboard post", e);
        }
    }

    private void handleWithdraw(HttpServletRequest request, HttpServletResponse response, int userId, boolean wantsJson)
            throws IOException, ServletException {
        String bookingIdParam = request.getParameter("bookingId");
        String bankCode = request.getParameter("bankCode");
        String accountNumber = request.getParameter("accountNumber");
        String accountHolder = request.getParameter("accountHolder");
        String notes = request.getParameter("notes");

        if (bookingIdParam == null || bookingIdParam.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Mã đơn đặt phòng không được để trống.");
            return;
        }

        try {
            long bookingId = Long.parseLong(bookingIdParam.trim());
            walletDAO.withdrawBookingRevenue(userId, bookingId, bankCode, accountNumber, accountHolder, notes);

            if (wantsJson) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, true,
                        "Rút tiền doanh thu về ngân hàng thành công! Số dư ví đã được trừ tương ứng.");
            } else {
                response.sendRedirect(request.getContextPath() + "/host/dashboard?msg=withdraw_success");
            }
        } catch (Exception e) {
            if (wantsJson) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, e.getMessage());
            } else {
                request.setAttribute("errorMessage", e.getMessage());
                doGet(request, response);
            }
        }
    }

    private void handleTopup(HttpServletRequest request, HttpServletResponse response, int userId, boolean wantsJson)
            throws IOException, ServletException {
        String amountParam = request.getParameter("amount");
        String note = request.getParameter("note");
        if (amountParam == null || amountParam.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Vui lòng nhập số tiền cần nạp.");
            return;
        }
        try {
            BigDecimal amount = new BigDecimal(amountParam.trim().replace(",", ""));
            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Số tiền nạp phải lớn hơn 0 VNĐ.");
                return;
            }
            boolean topupOk = walletDAO.topUpWallet((long) userId, amount,
                    (note != null && !note.isBlank()) ? note.trim() : "Nạp tiền vào Ví Host");
            if (topupOk) {
                if (wantsJson) {
                    sendJsonResponse(response, HttpServletResponse.SC_OK, true,
                            String.format("Nạp %,.0f VNĐ vào ví thành công!", amount));
                } else {
                    response.sendRedirect(request.getContextPath() + "/host/dashboard?msg=topup_success");
                }
            } else {
                sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Nạp tiền thất bại. Vui lòng thử lại.");
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Số tiền nạp không đúng định dạng.");
        }
    }

    private void handleEditRoom(HttpServletRequest request, HttpServletResponse response, HttpSession session, int userId)
            throws IOException, SQLException {
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String roomName = request.getParameter("roomName");
        BigDecimal price = new BigDecimal(request.getParameter("pricePerNight"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        int bedCount = Integer.parseInt(request.getParameter("bedCount"));
        int bathroomCount = Integer.parseInt(request.getParameter("bathroomCount"));
        String status = request.getParameter("status");

        Room room = new Room();
        room.setId(roomId);
        room.setRoomName(roomName);
        room.setPricePerNight(price);
        room.setCapacity(capacity);
        room.setBedCount(bedCount);
        room.setBathroomCount(bathroomCount);
        room.setStatus(status);

        boolean updated = propertyDAO.updateRoomDetails(room);
        if (updated) {
            session.setAttribute("successMessage", "Cập nhật phòng thành công!");
        } else {
            session.setAttribute("errorMessage", "Không thể cập nhật phòng.");
        }
        response.sendRedirect(request.getContextPath() + "/host/dashboard");
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        String json = String.format("{\"success\":%b,\"message\":\"%s\"}",
                success,
                message != null ? message.replace("\"", "\\\"").replace("\n", " ") : "");
        out.print(json);
        out.flush();
    }
}
