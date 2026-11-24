package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.dao.RefundDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.Refund;
import com.homestay.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Optional;

/**
 * RefundController - Handles customer refund requests and refund status tracking.
 * URLs: /refund/request (POST), /refund/status (GET)
 */
@WebServlet(name = "RefundController", urlPatterns = {"/refund/request", "/refund/status"})
public class RefundController extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final RefundDAO refundDAO = new RefundDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        if ("/refund/status".equals(path)) {
            handleRefundStatus(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/my-bookings");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        if ("/refund/request".equals(path)) {
            handleRefundRequest(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Handles customer submission of cancellation and refund request.
     */
    private void handleRefundRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Vui lòng đăng nhập để thực hiện.");
            return;
        }

        String bookingIdParam = request.getParameter("bookingId");
        String reason = request.getParameter("reason");
        String bankName = request.getParameter("bankName");
        String accountNumber = request.getParameter("accountNumber");
        String accountHolder = request.getParameter("accountHolder");

        if (bookingIdParam == null || bookingIdParam.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Mã đơn đặt phòng không hợp lệ.");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdParam.trim());
        } catch (NumberFormatException e) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Mã đơn đặt phòng không đúng định dạng.");
            return;
        }

        if (reason == null || reason.trim().isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Vui lòng nhập lý do hủy phòng.");
            return;
        }

        if (bankName == null || bankName.trim().isBlank()
                || accountNumber == null || accountNumber.trim().isBlank()
                || accountHolder == null || accountHolder.trim().isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Vui lòng nhập đầy đủ thông tin tài khoản ngân hàng nhận tiền hoàn.");
            return;
        }

        Optional<Booking> bookingOpt = bookingDAO.findByIdWithDetails(bookingId);
        if (bookingOpt.isEmpty()) {
            sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false, "Không tìm thấy thông tin đơn đặt phòng.");
            return;
        }

        Booking booking = bookingOpt.get();
        if (booking.getUserId() == null || !booking.getUserId().equals(userId)) {
            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, false, "Bạn không có quyền yêu cầu hủy đơn này.");
            return;
        }

        String currentStatus = booking.getStatus() != null ? booking.getStatus().toUpperCase() : "";
        if (!"CONFIRMED".equals(currentStatus)) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false,
                    "Chỉ có thể yêu cầu hoàn tiền cho đơn đặt phòng ĐÃ XÁC NHẬN (CONFIRMED). Trạng thái hiện tại: " + currentStatus);
            return;
        }

        // Check if there is already an active refund
        Optional<Refund> existingRefundOpt = refundDAO.findLatestByBookingId(bookingId);
        if (existingRefundOpt.isPresent()) {
            Refund existing = existingRefundOpt.get();
            if ("REQUESTED".equalsIgnoreCase(existing.getStatus()) || "APPROVED".equalsIgnoreCase(existing.getStatus())) {
                sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false,
                        "Đơn đặt phòng này đã có yêu cầu hoàn tiền đang được xử lý.");
                return;
            }
        }

        // Find associated payment
        Payment payment = paymentDAO.findLatestByBookingId(bookingId);

        String customerBankInfo = bankName.trim() + " - " + accountNumber.trim() + " (" + accountHolder.trim().toUpperCase() + ")";

        Refund refund = new Refund();
        refund.setBookingId((long) bookingId);
        if (payment != null) {
            refund.setPaymentId(payment.getPaymentId());
        }
        refund.setAmount(booking.getTotalAmount());
        refund.setCurrency("VND");
        refund.setReason(reason.trim());
        refund.setRequestedBy((long) userId);
        refund.setCustomerBankInfo(customerBankInfo);

        long refundId = refundDAO.createRefundRequest(refund);
        if (refundId <= 0) {
            sendJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Gửi yêu cầu hoàn tiền thất bại. Vui lòng thử lại sau.");
            return;
        }

        // If AJAX request, return JSON
        String acceptHeader = request.getHeader("Accept");
        String isAjax = request.getParameter("ajax");
        if ("true".equals(isAjax) || (acceptHeader != null && acceptHeader.contains("application/json"))) {
            sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Yêu cầu hoàn tiền đã được gửi thành công!");
        } else {
            response.sendRedirect(request.getContextPath() + "/my-bookings?msg=refund_requested");
        }
    }

    /**
     * Handles customer querying refund tracking status and timeline.
     */
    private void handleRefundStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = getLoggedInUserId(session);

        if (userId == null) {
            sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Vui lòng đăng nhập.");
            return;
        }

        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null || bookingIdParam.isBlank()) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Thiếu mã đơn đặt phòng.");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdParam.trim());
        } catch (NumberFormatException e) {
            sendJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST, false, "Mã đơn không hợp lệ.");
            return;
        }

        Optional<Booking> bookingOpt = bookingDAO.findByIdWithDetails(bookingId);
        if (bookingOpt.isEmpty()) {
            sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false, "Không tìm thấy đơn đặt phòng.");
            return;
        }

        Booking booking = bookingOpt.get();
        if (booking.getUserId() == null || !booking.getUserId().equals(userId)) {
            sendJsonResponse(response, HttpServletResponse.SC_FORBIDDEN, false, "Bạn không có quyền xem thông tin này.");
            return;
        }

        Optional<Refund> refundOpt = refundDAO.findLatestByBookingId(bookingId);
        if (refundOpt.isEmpty()) {
            sendJsonResponse(response, HttpServletResponse.SC_NOT_FOUND, false, "Chưa có thông tin hoàn tiền cho đơn này.");
            return;
        }

        Refund refund = refundOpt.get();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{");
            out.print("\"success\": true,");
            out.print("\"refundId\": " + refund.getRefundId() + ",");
            out.print("\"bookingCode\": \"" + escapeJson(booking.getBookingCode()) + "\",");
            out.print("\"propertyName\": \"" + escapeJson(booking.getPropertyName()) + "\",");
            out.print("\"amount\": " + refund.getAmount() + ",");
            out.print("\"status\": \"" + escapeJson(refund.getStatus()) + "\",");
            out.print("\"reason\": \"" + escapeJson(refund.getReason()) + "\",");
            out.print("\"customerBankInfo\": \"" + escapeJson(refund.getCustomerBankInfo()) + "\",");
            out.print("\"hostNote\": \"" + escapeJson(refund.getHostNote()) + "\",");
            out.print("\"createdAt\": \"" + (refund.getCreatedAt() != null ? sdf.format(refund.getCreatedAt()) : "") + "\",");
            out.print("\"completedAt\": \"" + (refund.getCompletedAt() != null ? sdf.format(refund.getCompletedAt()) : "") + "\"");
            out.print("}");
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
