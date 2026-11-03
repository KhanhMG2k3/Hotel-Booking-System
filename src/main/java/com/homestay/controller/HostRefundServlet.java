package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.HostProfileDAO;
import com.homestay.dao.RefundDAO;
import com.homestay.dao.WalletDAO;
import com.homestay.model.Booking;
import com.homestay.model.HostProfile;
import com.homestay.model.Refund;
import com.homestay.model.RefundApprovalResult;
import com.homestay.model.User;
import com.homestay.model.WalletTransaction;
import com.homestay.service.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * HostRefundServlet - Controller for Host to view, approve, and reject refund requests.
 * Integrates with Model 2 Host Wallet Balance deduction.
 * URLs: /host/refunds (GET), /host/refunds/action (POST)
 */
@WebServlet(name = "HostRefundServlet", urlPatterns = {"/host/refunds", "/host/refunds/action"})
public class HostRefundServlet extends HttpServlet {

    private final RefundDAO refundDAO = new RefundDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final HostProfileDAO hostProfileDAO = new HostProfileDAO();
    private final WalletDAO walletDAO = new WalletDAO();
    private final EmailService emailService = EmailService.getInstance();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/host/refunds");
            return;
        }

        Optional<HostProfile> hostProfileOpt = hostProfileDAO.findByUserId(userId);
        if (hostProfileOpt.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/become-host");
            return;
        }

        // Fetch all refund requests for properties owned by this host
        List<Refund> allRefunds = refundDAO.findByHostUserId((long) userId);
        Map<String, Object> stats = refundDAO.getRefundStatsForHost((long) userId);

        // Status tab filtering: ALL, REQUESTED, APPROVED, REJECTED
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isBlank()) {
            statusFilter = "ALL";
        } else {
            statusFilter = statusFilter.trim().toUpperCase();
        }

        List<Refund> displayRefunds = new ArrayList<>();
        if ("ALL".equals(statusFilter)) {
            displayRefunds = allRefunds;
        } else {
            for (Refund r : allRefunds) {
                if (statusFilter.equalsIgnoreCase(r.getStatus())
                        || ("APPROVED".equals(statusFilter) && "SUCCEEDED".equalsIgnoreCase(r.getStatus()))) {
                    displayRefunds.add(r);
                }
            }
        }

        // Search query by booking code, customer name, property name
        String q = request.getParameter("q");
        if (q != null && !q.isBlank()) {
            String lowerQ = q.trim().toLowerCase();
            List<Refund> filtered = new ArrayList<>();
            for (Refund r : displayRefunds) {
                boolean matchCode = r.getBookingCode() != null && r.getBookingCode().toLowerCase().contains(lowerQ);
                boolean matchCustomer = r.getCustomerName() != null && r.getCustomerName().toLowerCase().contains(lowerQ);
                boolean matchProp = r.getPropertyName() != null && r.getPropertyName().toLowerCase().contains(lowerQ);
                if (matchCode || matchCustomer || matchProp) {
                    filtered.add(r);
                }
            }
            displayRefunds = filtered;
            request.setAttribute("searchKeyword", q.trim());
        }

        request.setAttribute("hostProfile", hostProfileOpt.get());
        request.setAttribute("refunds", displayRefunds);
        request.setAttribute("stats", stats);
        request.setAttribute("currentFilter", statusFilter);

        // Model 2: Host Wallet & Transactions
        BigDecimal hostBalance = walletDAO.getHostBalance((long) userId);
        List<WalletTransaction> walletTransactions = walletDAO.getTransactionsByUserId((long) userId, 20);
        request.setAttribute("hostBalance", hostBalance);
        request.setAttribute("walletTransactions", walletTransactions);

        String msg = request.getParameter("msg");
        if ("approved".equals(msg)) {
            request.setAttribute("successMessage", "Đã xác nhận hoàn tiền thành công cho khách hàng qua VietQR!");
        } else if ("rejected".equals(msg)) {
            request.setAttribute("successMessage", "Đã từ chối yêu cầu hoàn tiền thành công.");
        } else if ("topup_success".equals(msg)) {
            request.setAttribute("successMessage", "Nạp tiền vào Ví Host thành công!");
        }

        request.getRequestDispatcher("/WEB-INF/views/host/refunds.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Vui lòng đăng nhập.");
            return;
        }

        Optional<HostProfile> hostProfileOpt = hostProfileDAO.findByUserId(userId);
        if (hostProfileOpt.isEmpty()) {
            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, false, "Chỉ tài khoản Host mới có quyền thao tác.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Hành động không hợp lệ.");
            return;
        }

        // Action: Top-up wallet balance
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
                    sendJsonResponse(response, HttpServletResponse.SC_OK, true,
                            String.format("Nạp %,.0f VNĐ vào ví thành công!", amount));
                } else {
                    sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Nạp tiền thất bại. Vui lòng thử lại.");
                }
            } catch (NumberFormatException e) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Số tiền nạp không đúng định dạng số.");
            }
            return;
        }

        // Action: Withdraw booking revenue
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
                sendJsonResponse(response, HttpServletResponse.SC_OK, true,
                        "Rút tiền doanh thu phòng về ngân hàng thành công! Số dư ví đã được trừ tương ứng.");
            } catch (Exception e) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, e.getMessage());
            }
            return;
        }

        String refundIdParam = request.getParameter("refundId");
        String hostNote = request.getParameter("hostNote");

        if (refundIdParam == null || refundIdParam.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Mã yêu cầu hoàn tiền không được để trống.");
            return;
        }

        long refundId;
        try {
            refundId = Long.parseLong(refundIdParam.trim());
        } catch (NumberFormatException e) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Mã yêu cầu hoàn tiền không hợp lệ.");
            return;
        }

        Optional<Refund> refundOpt = refundDAO.findById(refundId);
        if (refundOpt.isEmpty()) {
            sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false, "Không tìm thấy yêu cầu hoàn tiền.");
            return;
        }

        Refund refund = refundOpt.get();
        if (!"REQUESTED".equalsIgnoreCase(refund.getStatus())) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false,
                    "Yêu cầu này đã được xử lý trước đó (Trạng thái: " + refund.getStatus() + ").");
            return;
        }

        boolean success = false;
        String actionResult = "";

        if ("approve".equalsIgnoreCase(action.trim())) {
            String note = (hostNote != null && !hostNote.isBlank()) ? hostNote.trim() : "Host đã quét VietQR chuyển tiền hoàn cho khách";
            success = refundDAO.approveRefundTraditional(refundId, (long) userId, note);

            if (!success) {
                response.sendRedirect(request.getContextPath() + "/host/refunds?error=already_processed");
                return;
            }

            actionResult = "approved";

            // Fetch booking for email notification
            Optional<Booking> bookingOpt = bookingDAO.findByIdWithDetails(refund.getBookingId().intValue());
            bookingOpt.ifPresent(booking -> emailService.sendRefundDecisionEmailAsync(booking, refund, true, note));

            response.sendRedirect(request.getContextPath() + "/host/refunds?msg=approved");
            return;

        } else if ("reject".equalsIgnoreCase(action.trim())) {
            if (hostNote == null || hostNote.trim().isBlank()) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Vui lòng nhập lý do từ chối để thông báo cho khách hàng.");
                return;
            }
            success = refundDAO.rejectRefund(refundId, (long) userId, hostNote.trim());
            actionResult = "rejected";

            if (success) {
                Optional<Booking> bookingOpt = bookingDAO.findByIdWithDetails(refund.getBookingId().intValue());
                bookingOpt.ifPresent(booking -> emailService.sendRefundDecisionEmailAsync(booking, refund, false, hostNote.trim()));
            }
        } else {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Hành động không được hỗ trợ.");
            return;
        }

        if (!success) {
            sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Cập nhật yêu cầu thất bại. Vui lòng thử lại.");
            return;
        }

        String isAjax = request.getParameter("ajax");
        String acceptHeader = request.getHeader("Accept");
        if ("true".equals(isAjax) || (acceptHeader != null && acceptHeader.contains("application/json"))) {
            sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Xử lý yêu cầu thành công.");
        } else {
            response.sendRedirect(request.getContextPath() + "/host/refunds?msg=" + actionResult);
        }
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message)
            throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\": " + success + ", \"message\": \"" + escapeJson(message) + "\"}");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }

    private Integer getLoggedInUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object userIdObj = session.getAttribute("userId");
        if (userIdObj instanceof Integer id) {
            return id;
        }
        Object userObj = session.getAttribute("user");
        if (userObj instanceof User u) {
            return u.getId();
        }
        return null;
    }
}
