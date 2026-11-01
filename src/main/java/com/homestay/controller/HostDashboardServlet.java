package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.PropertyDAO;
import com.homestay.dao.WalletDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostProfile;
import com.homestay.model.Property;
import com.homestay.model.WalletTransaction;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * HostDashboardServlet - Dashboard overview for Host, including properties,
 * bookings revenue withdrawal to bank, and wallet ledger transactions.
 */
@WebServlet(name = "HostDashboardServlet", urlPatterns = {"/host/dashboard"})
public class HostDashboardServlet extends HttpServlet {

    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final PropertyDAO propertyDAO = new PropertyDAO();
    private final WalletDAO walletDAO = new WalletDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object userIdAttribute = session.getAttribute("userId");
        if (!(userIdAttribute instanceof Integer)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int userId = (Integer) userIdAttribute;
        Optional<HostProfile> hostProfileOptional = hostProfileDAO.findByUserId(userId);

        if (hostProfileOptional.isEmpty()) {
            request.setAttribute("error", "Tài khoản chưa có hồ sơ Host.");
            request.getRequestDispatcher("/WEB-INF/views/host/dashboard.jsp").forward(request, response);
            return;
        }

        HostProfile hostProfile = hostProfileOptional.get();
        List<Property> properties = propertyDAO.findByHostId(hostProfile.getId());

        // Model 2: Host Wallet & Recent Transactions
        BigDecimal hostBalance = walletDAO.getHostBalance((long) userId);
        List<WalletTransaction> recentTransactions = walletDAO.getTransactionsByUserId((long) userId, 10);

        // Host Bookings for revenue withdrawal
        List<Booking> hostBookings = bookingDAO.findByHostUserId((long) userId, 25);

        // Success / info messages
        String msg = request.getParameter("msg");
        if ("withdraw_success".equals(msg)) {
            request.setAttribute("successMessage", "Rút tiền doanh thu phòng về tài khoản ngân hàng thành công! Số dư ví đã được cập nhật.");
        } else if ("topup_success".equals(msg)) {
            request.setAttribute("successMessage", "Nạp tiền vào Ví Host thành công!");
        }

        request.setAttribute("hostProfile", hostProfile);
        request.setAttribute("properties", properties);
        request.setAttribute("hostBalance", hostBalance);
        request.setAttribute("recentTransactions", recentTransactions);
        request.setAttribute("hostBookings", hostBookings);

        request.getRequestDispatcher("/WEB-INF/views/host/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        if (session == null) {
            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Vui lòng đăng nhập.");
            return;
        }

        Object userIdAttribute = session.getAttribute("userId");
        if (!(userIdAttribute instanceof Integer)) {
            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Vui lòng đăng nhập.");
            return;
        }

        int userId = (Integer) userIdAttribute;
        Optional<HostProfile> hostProfileOptional = hostProfileDAO.findByUserId(userId);

        if (hostProfileOptional.isEmpty()) {
            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, false, "Tài khoản chưa có hồ sơ Host.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Hành động không hợp lệ.");
            return;
        }

        String isAjax = request.getParameter("ajax");
        String acceptHeader = request.getHeader("Accept");
        boolean wantsJson = "true".equalsIgnoreCase(isAjax) || (acceptHeader != null && acceptHeader.contains("application/json"));

        if ("withdraw".equalsIgnoreCase(action.trim())) {
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
            } catch (IllegalArgumentException | IllegalStateException | SecurityException e) {
                if (wantsJson) {
                    sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, e.getMessage());
                } else {
                    request.setAttribute("errorMessage", e.getMessage());
                    doGet(request, response);
                }
            } catch (Exception e) {
                if (wantsJson) {
                    sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Lỗi xử lý rút tiền: " + e.getMessage());
                } else {
                    request.setAttribute("errorMessage", "Lỗi xử lý rút tiền: " + e.getMessage());
                    doGet(request, response);
                }
            }
            return;
        }

        if ("topup".equalsIgnoreCase(action.trim())) {
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
            return;
        }

        sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Hành động không được hỗ trợ.");
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

    @Override
    public String getServletInfo() {
        return "Host Dashboard Controller";
    }
}
