package com.homestay.controller;

import com.homestay.dao.VoucherDAO;
import com.homestay.model.User;
import com.homestay.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Date;
import java.util.Base64;
import java.util.Optional;
import java.util.regex.Pattern;

@WebServlet(name = "VoucherController", urlPatterns = {"/host/vouchers"})
public class VoucherController extends HttpServlet {

    private static final String VIEW =
            "/WEB-INF/views/vouchers.jsp";

    private static final Pattern CODE_PATTERN =
            Pattern.compile("[A-Za-z0-9_-]{3,50}");

    private final VoucherDAO voucherDAO = new VoucherDAO();

    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (!isAuthenticatedHost(session)) {
            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;
        }

        ensureCsrfToken(session);

        // Lấy Host ID từ session đăng nhập chung của nhóm.
        User currentHost = (User) session.getAttribute("user");
        int hostId = currentHost.getId();

        String action = request.getParameter("action");

        if ("edit".equals(action)) {
            Integer id = parsePositiveId(request.getParameter("id"));

            if (id == null) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "ID voucher không hợp lệ.");
                return;
            }

            Optional<Voucher> result =
                    voucherDAO.findByIdAndHostId(id, hostId);

            if (result.isEmpty()) {
                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy voucher.");
                return;
            }

            request.setAttribute("editingVoucher", result.get());
        }

        request.setAttribute(
                "vouchers", voucherDAO.findByHostId(hostId));
        request.setAttribute("activePage", "host-vouchers");

        request.getRequestDispatcher(VIEW)
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (!isAuthenticatedHost(session)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Bạn cần đăng nhập bằng tài khoản Host.");
            return;
        }

        if (!isValidCsrfToken(
                session, request.getParameter("csrfToken"))) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Yêu cầu không hợp lệ. Vui lòng tải lại trang.");
            return;
        }

        // Lấy Host ID từ session, không lấy từ dữ liệu form.
        User currentHost = (User) session.getAttribute("user");
        int hostId = currentHost.getId();

        String action = request.getParameter("action");

        if (action == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Thiếu thao tác voucher.");
            return;
        }

        switch (action) {
            case "create":
                createVoucher(request, response, hostId);
                break;

            case "update":
                updateVoucher(request, response, hostId);
                break;

            case "delete":
                deleteVoucher(request, response, hostId);
                break;

            case "toggle":
                toggleVoucher(request, response, hostId);
                break;

            default:
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Thao tác voucher không hợp lệ.");
                break;
        }
    }

    /**
     * Create a new voucher for the authenticated Host.
     */
    private void createVoucher(
            HttpServletRequest request,
            HttpServletResponse response,
            int hostId) throws IOException {

        Voucher voucher = readVoucher(request, hostId, null);

        if (voucher == null) {
            redirectWithMessage(
                    request, response, "error",
                    "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            return;
        }

        voucher.setUsedCount(0);
        voucher.setStatus("ACTIVE");

        if (voucherDAO.insert(voucher)) {
            redirectWithMessage(
                    request, response, "success",
                    "Tạo voucher thành công.");
        } else {
            redirectWithMessage(
                    request, response, "error",
                    "Không thể tạo voucher. Hãy kiểm tra mã đã tồn tại chưa.");
        }
    }

    /**
     * Update a voucher owned by the authenticated Host.
     * The DAO preserves used_count.
     */
    private void updateVoucher(
            HttpServletRequest request,
            HttpServletResponse response,
            int hostId) throws IOException {

        Integer id = parsePositiveId(request.getParameter("id"));

        if (id == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID voucher không hợp lệ.");
            return;
        }

        Optional<Voucher> existing =
                voucherDAO.findByIdAndHostId(id, hostId);

        if (existing.isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy voucher.");
            return;
        }

        Voucher voucher =
                readVoucher(request, hostId, existing.get());

        if (voucher == null) {
            redirectWithMessage(
                    request, response, "error",
                    "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.");
            return;
        }

        if (voucherDAO.updateForHost(voucher, hostId)) {
            redirectWithMessage(
                    request, response, "success",
                    "Cập nhật voucher thành công.");
        } else {
            redirectWithMessage(
                    request, response, "error",
                    "Không thể cập nhật voucher. Hãy kiểm tra mã và dữ liệu.");
        }
    }

    /**
     * Delete only a voucher belonging to this Host.
     */
    private void deleteVoucher(
            HttpServletRequest request,
            HttpServletResponse response,
            int hostId) throws IOException {

        Integer id = parsePositiveId(request.getParameter("id"));

        if (id == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID voucher không hợp lệ.");
            return;
        }

        if (voucherDAO.deleteForHost(id, hostId)) {
            redirectWithMessage(
                    request, response, "success",
                    "Xóa voucher thành công.");
        } else {
            redirectWithMessage(
                    request, response, "error",
                    "Không thể xóa voucher hoặc voucher không thuộc về bạn.");
        }
    }

    /**
     * Toggle voucher status using a dedicated DAO method.
     *
     * This operation changes only the status column,
     * without overwriting used_count or other fields.
     */
    private void toggleVoucher(
            HttpServletRequest request,
            HttpServletResponse response,
            int hostId) throws IOException {

        Integer id = parsePositiveId(request.getParameter("id"));

        if (id == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "ID voucher không hợp lệ.");
            return;
        }

        if (voucherDAO.toggleStatusForHost(id, hostId)) {
            redirectWithMessage(
                    request, response, "success",
                    "Đã cập nhật trạng thái voucher.");
        } else {
            redirectWithMessage(
                    request, response, "error",
                    "Không thể cập nhật trạng thái voucher hoặc voucher không thuộc về bạn.");
        }
    }

    /**
     * Read and validate voucher information from the form.
     *
     * hostId comes from the authenticated session,
     * never from user-submitted form data.
     */
    private Voucher readVoucher(
            HttpServletRequest request,
            int hostId,
            Voucher existing) {

        try {
            String code = trim(request.getParameter("code"));
            String type = trim(request.getParameter("discountType"));
            String valueText =
                    trim(request.getParameter("discountValue"));
            String startText =
                    trim(request.getParameter("startDate"));
            String endText =
                    trim(request.getParameter("endDate"));
            String limitText =
                    trim(request.getParameter("usageLimit"));

            if (code == null
                    || !CODE_PATTERN.matcher(code).matches()) {
                return null;
            }

            if (!"PERCENTAGE".equals(type)
                    && !"FIXED_AMOUNT".equals(type)) {
                return null;
            }

            BigDecimal value = new BigDecimal(valueText);
            Date start = Date.valueOf(startText);
            Date end = Date.valueOf(endText);
            int limit = Integer.parseInt(limitText);

            if (value.signum() <= 0
                    || ("PERCENTAGE".equals(type)
                    && value.compareTo(
                            new BigDecimal("100")) > 0)
                    || end.before(start)
                    || limit <= 0) {
                return null;
            }

            Voucher voucher = existing == null
                    ? new Voucher()
                    : existing;

            voucher.setHostId(hostId);
            voucher.setCode(
                    code.toUpperCase(java.util.Locale.ROOT));
            voucher.setDiscountType(type);
            voucher.setDiscountValue(value);
            voucher.setStartDate(start);
            voucher.setEndDate(end);
            voucher.setUsageLimit(limit);

            // Do not reset used_count when updating.
            if (existing != null
                    && existing.getUsedCount() > limit) {
                return null;
            }

            return voucher;

        } catch (IllegalArgumentException | NullPointerException e) {
            return null;
        }
    }

    /**
     * Check that the session belongs to a logged-in Host.
     * Uses the same session attributes as LoginServlet and HostFilter.
     */
    private boolean isAuthenticatedHost(HttpSession session) {
        if (session == null) {
            return false;
        }

        Object attribute = session.getAttribute("user");

        if (!(attribute instanceof User)) {
            return false;
        }

        User user = (User) attribute;

        return user.getId() > 0
                && user.getRole() != null
                && "ROLE_HOST".equals(user.getRole().getRoleName());
    }

    /**
     * Generate a CSRF token if one does not exist.
     */
    private void ensureCsrfToken(HttpSession session) {
        if (!(session.getAttribute("csrfToken")
                instanceof String)) {

            byte[] bytes = new byte[32];
            secureRandom.nextBytes(bytes);

            session.setAttribute(
                    "csrfToken",
                    Base64.getUrlEncoder()
                            .withoutPadding()
                            .encodeToString(bytes));
        }
    }

    /**
     * Validate the submitted CSRF token.
     */
    private boolean isValidCsrfToken(
            HttpSession session,
            String submittedToken) {

        if (session == null || submittedToken == null) {
            return false;
        }

        Object saved = session.getAttribute("csrfToken");

        return saved instanceof String
                && MessageDigest.isEqual(
                        ((String) saved).getBytes(
                                java.nio.charset.StandardCharsets.UTF_8),
                        submittedToken.getBytes(
                                java.nio.charset.StandardCharsets.UTF_8));
    }

    /**
     * Parse a positive integer ID.
     */
    private Integer parsePositiveId(String value) {
        try {
            int id = Integer.parseInt(value);
            return id > 0 ? id : null;

        } catch (NumberFormatException | NullPointerException e) {
            return null;
        }
    }

    /**
     * Trim text and convert blank values to null.
     */
    private String trim(String value) {
        return value == null || value.trim().isEmpty()
                ? null
                : value.trim();
    }

    /**
     * Store a flash message and redirect to voucher management.
     */
    private void redirectWithMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            String key,
            String message) throws IOException {

        request.getSession().setAttribute(key, message);

        response.sendRedirect(
                request.getContextPath() + "/host/vouchers");
    }
}