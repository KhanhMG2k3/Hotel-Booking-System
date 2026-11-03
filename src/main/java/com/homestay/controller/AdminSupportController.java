package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.dao.RoomDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.Booking;
import com.homestay.model.ContactMessage;
import com.homestay.model.Room;
import com.homestay.model.SupportReply;
import com.homestay.model.TicketCategory;
import com.homestay.model.TicketStatus;
import com.homestay.model.User;
import com.homestay.service.SupportService;
import com.homestay.util.LoginUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AdminSupportController - Dedicated management controller for Admin Support operations.
 * Handles ticket listing with server-side pagination/filtering/search, detailed thread inspection,
 * safe booking inspection (without sensitive financial data), admin reply dispatch,
 * and optimistic concurrency status transitions.
 */
@WebServlet(name = "AdminSupportController", urlPatterns = {"/admin/support", "/admin/support/*"})
public class AdminSupportController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminSupportController.class.getName());

    private static final Set<String> ALLOWED_SORT_COLUMNS = Set.of(
            "updated_at", "created_at", "status", "category", "subject"
    );
    private static final Set<String> ALLOWED_SORT_ORDERS = Set.of("ASC", "DESC");
    private static final long REPLY_COOLDOWN_MS = 3000L;

    private final SupportService supportService;
    private final BookingDAO bookingDAO;
    private final RoomDAO roomDAO;
    private final UserDAO userDAO;

    public AdminSupportController() {
        this(new SupportService(), new BookingDAO(), new RoomDAO(), new UserDAO());
    }

    public AdminSupportController(SupportService supportService, BookingDAO bookingDAO, RoomDAO roomDAO, UserDAO userDAO) {
        this.supportService = supportService;
        this.bookingDAO = bookingDAO;
        this.roomDAO = roomDAO;
        this.userDAO = userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User adminUser = requireAdmin(request, response);
        if (adminUser == null) {
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty() || "/".equals(pathInfo) || "/list".equals(pathInfo)) {
            handleList(request, response);
        } else if ("/detail".equals(pathInfo)) {
            handleDetail(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/support");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User adminUser = requireAdmin(request, response);
        if (adminUser == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();

        if ("/status".equals(pathInfo)) {
//            handleUpdateStatus(request, response);
            // TRUYEN ADMINUSER VAO HANDLEUPDATESTATUS DE KHONG TU GUI THONG BAO CHO CHINH NGUOI THUC HIEN (DOT 5)
            handleUpdateStatus(request, response, adminUser);
        } else if ("/reply".equals(pathInfo)) {
            handleAdminReply(request, response, adminUser);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    /**
     * Lists support tickets with filtering, search, sorting, and pagination.
     */
    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String statusParam = request.getParameter("status");
        String categoryParam = request.getParameter("category");
        String searchParam = request.getParameter("search");
        String sortParam = request.getParameter("sortBy");
        String orderParam = request.getParameter("sortOrder");
        String pageParam = request.getParameter("page");
        String pageSizeParam = request.getParameter("pageSize");

        // Normalize status filter
        String statusFilter = null;
        if (statusParam != null && !statusParam.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusParam.trim())) {
            TicketStatus status = TicketStatus.fromCode(statusParam.trim());
            if (status != null) {
                statusFilter = status.name();
            }
        }

        // Normalize category filter
        String categoryFilter = null;
        if (categoryParam != null && !categoryParam.trim().isEmpty() && !"ALL".equalsIgnoreCase(categoryParam.trim())) {
            TicketCategory category = TicketCategory.fromCode(categoryParam.trim());
            if (category != null) {
                categoryFilter = category.name();
            }
        }

        // Normalize search keyword
        String searchKeyword = null;
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            searchKeyword = searchParam.trim();
            if (searchKeyword.length() > 100) {
                searchKeyword = searchKeyword.substring(0, 100);
            }
        }

        // Normalize sort parameters
        String sortBy = "updated_at";
        if (sortParam != null && ALLOWED_SORT_COLUMNS.contains(sortParam.trim().toLowerCase(Locale.ROOT))) {
            sortBy = sortParam.trim().toLowerCase(Locale.ROOT);
        }

        String sortOrder = "DESC";
        if (orderParam != null && ALLOWED_SORT_ORDERS.contains(orderParam.trim().toUpperCase(Locale.ROOT))) {
            sortOrder = orderParam.trim().toUpperCase(Locale.ROOT);
        }

        // Normalize pagination
        int page = 1;
        if (pageParam != null) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            } catch (NumberFormatException ignored) {
            }
        }

        int pageSize = 10;
        if (pageSizeParam != null) {
            try {
                int parsed = Integer.parseInt(pageSizeParam.trim());
                if (parsed == 10 || parsed == 20 || parsed == 50) {
                    pageSize = parsed;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        // Query data
        List<ContactMessage> tickets = supportService.findTicketsForAdmin(
                statusFilter, categoryFilter, searchKeyword, sortBy, sortOrder, page, pageSize
        );
        int totalTickets = supportService.countTicketsForAdmin(statusFilter, categoryFilter, searchKeyword);
        int totalPages = (int) Math.ceil((double) totalTickets / pageSize);

        Map<String, Integer> kpiStats = supportService.getAdminTicketKpiStats();

        // Handle flash message from session if any
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object flashSuccess = session.getAttribute("supportSuccessMsg");
            if (flashSuccess != null) {
                request.setAttribute("successMessage", flashSuccess);
                session.removeAttribute("supportSuccessMsg");
            }
            Object flashError = session.getAttribute("supportErrorMsg");
            if (flashError != null) {
                request.setAttribute("errorMessage", flashError);
                session.removeAttribute("supportErrorMsg");
            }
        }

        // Set request attributes for view
        request.setAttribute("tickets", tickets);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalTickets", totalTickets);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");
        request.setAttribute("categoryFilter", categoryFilter != null ? categoryFilter : "ALL");
        request.setAttribute("searchKeyword", searchKeyword);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("sortOrder", sortOrder);

        request.setAttribute("kpiStats", kpiStats);
        request.setAttribute("categories", TicketCategory.values());
        request.setAttribute("statuses", TicketStatus.values());
        request.setAttribute("activePage", "support");

        request.getRequestDispatcher("/WEB-INF/views/admin/admin-support-list.jsp").forward(request, response);
    }

    /**
     * Inspects a single support ticket and its threaded conversation.
     */
    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        String codeParam = request.getParameter("code");

        Optional<ContactMessage> ticketOpt = Optional.empty();

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int ticketId = Integer.parseInt(idParam.trim());
                ticketOpt = supportService.getTicketDetailForAdmin(ticketId);
            } catch (NumberFormatException ignored) {
            }
        } else if (codeParam != null && !codeParam.trim().isEmpty()) {
            // Find ticket by unique ticket code
            Optional<ContactMessage> byCode = supportService.findTicketsForAdmin(null, null, codeParam.trim(), "updated_at", "DESC", 1, 1)
                    .stream()
                    .filter(t -> codeParam.trim().equalsIgnoreCase(t.getTicketCode()))
                    .findFirst();
            if (byCode.isPresent()) {
                ticketOpt = supportService.getTicketDetailForAdmin(byCode.get().getMessageId());
            }
        }

        if (ticketOpt.isEmpty()) {
            HttpSession session = request.getSession(true);
            session.setAttribute("supportErrorMsg", "Không tìm thấy yêu cầu hỗ trợ với thông tin đã cung cấp.");
            response.sendRedirect(request.getContextPath() + "/admin/support");
            return;
        }

        ContactMessage ticket = ticketOpt.get();

        // Safe inspection of related booking if present (strictly no financial/card leak)
        if (ticket.getBookingId() != null && ticket.getBookingId() > 0) {
            bookingDAO.findById(ticket.getBookingId()).ifPresent(booking -> {
                Map<String, Object> sanitizedBooking = new HashMap<>();
                sanitizedBooking.put("id", booking.getId());
                sanitizedBooking.put("bookingCode", booking.getBookingCode());
                sanitizedBooking.put("checkInDate", booking.getCheckInDate());
                sanitizedBooking.put("checkOutDate", booking.getCheckOutDate());
                sanitizedBooking.put("guestCount", booking.getGuestCount());
                sanitizedBooking.put("status", booking.getStatus());

                // Resolve room name if room exists
                String roomName = "Phòng #" + booking.getRoomId();
                try {
                    Optional<Room> roomOpt = roomDAO.findById(booking.getRoomId());
                    if (roomOpt.isPresent() && roomOpt.get().getRoomName() != null) {
                        roomName = roomOpt.get().getRoomName();
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.FINE, "Could not resolve room name for booking " + booking.getId(), e);
                }
                sanitizedBooking.put("roomName", roomName);

                request.setAttribute("relatedBooking", sanitizedBooking);
            });
        }

        // Generate CSRF token for state-changing forms
        HttpSession session = request.getSession(true);
        String csrfToken = LoginUtil.getOrCreateCsrfToken(request);
        request.setAttribute("csrfToken", csrfToken);

        // Flash message consumption
        Object flashSuccess = session.getAttribute("supportSuccessMsg");
        if (flashSuccess != null) {
            request.setAttribute("successMessage", flashSuccess);
            session.removeAttribute("supportSuccessMsg");
        }
        Object flashError = session.getAttribute("supportErrorMsg");
        if (flashError != null) {
            request.setAttribute("errorMessage", flashError);
            session.removeAttribute("supportErrorMsg");
        }
        // KHOI PHUC NOI DUNG NHAP PHAN HOI KHI CO LOI VALIDATION/CSRF/RATE-LIMIT/DB DE GIU DU LIEU NGUOI DUNG (DOT 6)
        Object replyDraft = session.getAttribute("adminReplyDraft");
        if (replyDraft != null) {
            request.setAttribute("replyDraft", replyDraft);
            session.removeAttribute("adminReplyDraft");
        }

        request.setAttribute("ticket", ticket);
        request.setAttribute("activePage", "support");
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-support-detail.jsp").forward(request, response);
    }

    /**
     * Updates ticket status with strict lifecycle checks and optimistic locking.
     */
//    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
    // BO SUNG THAM SO ADMINUSER DE XAC DINH NGUOI THUC HIEN SU KIEN CHUYEN TRANG THAI (DOT 5)
    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, User adminUser)
            throws IOException {

        HttpSession session = request.getSession(true);
        String csrfToken = request.getParameter("csrfToken");
        if (!LoginUtil.consumeCsrfToken(request, csrfToken)) {
            session.setAttribute("supportErrorMsg", "Mã xác thực biểu mẫu (CSRF) không hợp lệ hoặc đã hết hạn. Vui lòng tải lại trang.");
            String tid = request.getParameter("ticketId");
            response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + (tid != null ? tid : ""));
            return;
        }

        int ticketId = 0;
        try {
            ticketId = Integer.parseInt(request.getParameter("ticketId"));
        } catch (NumberFormatException e) {
            session.setAttribute("supportErrorMsg", "Mã yêu cầu hỗ trợ không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/support");
            return;
        }

        String newStatusStr = request.getParameter("newStatus");
        String expectedStatusStr = request.getParameter("expectedStatus");

        TicketStatus targetStatus = TicketStatus.fromCode(newStatusStr);
        TicketStatus expectedStatus = TicketStatus.fromCode(expectedStatusStr);

        if (targetStatus == null) {
            session.setAttribute("supportErrorMsg", "Trạng thái mới không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + ticketId);
            return;
        }

        try {
//            boolean success = supportService.updateTicketStatus(ticketId, targetStatus, expectedStatus, true);
            // GOI UPDATETICKETSTATUS CO ACTORUSERID DE GUI THONG BAO KHI CHUYEN SANG RESOLVED MA KHONG GUI CHO CHINH ACTOR (DOT 5)
            boolean success = supportService.updateTicketStatus(ticketId, targetStatus, expectedStatus, true, adminUser.getId());
            if (!success) {
                session.setAttribute("supportErrorMsg",
                        "Cảnh báo xung đột đồng thời: Trạng thái yêu cầu đã bị thay đổi bởi quản trị viên khác. Vui lòng kiểm tra lại trạng thái hiện tại.");
            } else {
                session.setAttribute("supportSuccessMsg",
                        "Đã chuyển trạng thái yêu cầu sang: " + targetStatus.getDisplayName());
            }
        } catch (IllegalStateException | IllegalArgumentException e) {
            session.setAttribute("supportErrorMsg", e.getMessage());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating status for ticket " + ticketId, e);
            session.setAttribute("supportErrorMsg", "Lỗi hệ thống khi cập nhật trạng thái yêu cầu.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + ticketId);
    }

    /**
     * Dispatches an administrator reply to the ticket thread.
     */
    private void handleAdminReply(HttpServletRequest request, HttpServletResponse response, User adminUser)
            throws IOException {

        HttpSession session = request.getSession(true);
        // LUU TAM NOI DUNG PHAN HOI DE GIU DU LIEU NEU BI LOI VALIDATION/CSRF/RATE-LIMIT/DB (DOT 6)
        String rawDraftMessage = request.getParameter("message");
        String csrfToken = request.getParameter("csrfToken");
        if (!LoginUtil.consumeCsrfToken(request, csrfToken)) {
            if (rawDraftMessage != null) {
                session.setAttribute("adminReplyDraft", rawDraftMessage);
            }
            session.setAttribute("supportErrorMsg", "Mã xác thực biểu mẫu (CSRF) không hợp lệ hoặc đã hết hạn. Vui lòng tải lại trang.");
            String tid = request.getParameter("ticketId");
            response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + (tid != null ? tid : ""));
            return;
        }

        int ticketId = 0;
        try {
            ticketId = Integer.parseInt(request.getParameter("ticketId"));
        } catch (NumberFormatException e) {
            session.setAttribute("supportErrorMsg", "Mã yêu cầu hỗ trợ không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/admin/support");
            return;
        }

        // Enforce cooldown rate limiting per session
        Long lastReplyTime = (Long) session.getAttribute("LAST_ADMIN_REPLY_TIME");
        long now = System.currentTimeMillis();
        if (lastReplyTime != null && (now - lastReplyTime) < REPLY_COOLDOWN_MS) {
            long remaining = (REPLY_COOLDOWN_MS - (now - lastReplyTime)) / 1000 + 1;
            if (rawDraftMessage != null) {
                session.setAttribute("adminReplyDraft", rawDraftMessage);
            }
            session.setAttribute("supportErrorMsg", "Bạn đang gửi phản hồi quá nhanh. Vui lòng đợi " + remaining + " giây.");
            response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + ticketId);
            return;
        }

        String message = request.getParameter("message");
        if (message == null || message.trim().length() < 2 || message.trim().length() > 2000) {
            if (message != null) {
                session.setAttribute("adminReplyDraft", message);
            }
            session.setAttribute("supportErrorMsg", "Nội dung phản hồi phải từ 2 đến 2000 ký tự.");
            response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + ticketId);
            return;
        }

        boolean changeToProcessing = "true".equalsIgnoreCase(request.getParameter("changeToProcessing"))
                || "on".equalsIgnoreCase(request.getParameter("changeToProcessing"));

        try {
            supportService.addAdminReply(ticketId, adminUser.getId(), message.trim(), changeToProcessing);
            session.setAttribute("LAST_ADMIN_REPLY_TIME", now);
            session.removeAttribute("adminReplyDraft");
            session.setAttribute("supportSuccessMsg", "Đã gửi phản hồi hỗ trợ thành công.");
        // TACH LOI NGHIEP VU HOP LE KHOI LOI HE THONG/DATABASE DE KHONG LO THONG TIN NHAY CAM RA CLIENT (DOT 6)
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("adminReplyDraft", message);
            session.setAttribute("supportErrorMsg", e.getMessage());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error submitting admin reply for ticket " + ticketId, e);
//            session.setAttribute("supportErrorMsg", e.getMessage());
            session.setAttribute("adminReplyDraft", message);
            session.setAttribute("supportErrorMsg", "Lỗi hệ thống khi gửi phản hồi hỗ trợ. Vui lòng thử lại sau.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/support/detail?id=" + ticketId);
    }

    /**
     * Enforces strict administrator role verification.
     * Rejects non-admins (Host, Customer, Guests) with appropriate HTTP errors.
     */
    private User requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User user = null;
        Object userObj = session.getAttribute("user");
        if (userObj instanceof User) {
            user = (User) userObj;
        } else if (session.getAttribute("userId") instanceof Number) {
            int uid = ((Number) session.getAttribute("userId")).intValue();
            user = userDAO.findById(uid).orElse(null);
            if (user != null) {
                session.setAttribute("user", user);
            }
        }

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        String roleName = "";
        if (user.getRole() != null) {
            String rawRole = user.getRole().getRoleName() != null ? user.getRole().getRoleName() : user.getRole().getName();
            if (rawRole != null) {
                roleName = rawRole.trim().toUpperCase(Locale.ROOT);
            }
        }
        Integer roleId = (Integer) session.getAttribute("roleId");
        if (roleId == null && user.getRole() != null) {
            roleId = user.getRole().getId();
        }

        boolean isAdmin = "ROLE_ADMIN".equals(roleName)
                || "ADMIN".equals(roleName)
                || "ADMINISTRATOR".equals(roleName)
                || (roleId != null && (roleId == 1 || roleId == 5));

        if (!isAdmin) {
            LOGGER.warning("Unauthorized access attempt to admin support by user: " + user.getId() + " (" + roleName + ")");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang quản trị hỗ trợ.");
            return null;
        }

        return user;
    }
}
