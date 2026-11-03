package com.homestay.controller;

import com.homestay.dao.ContactMessageDAO;
import com.homestay.dao.SupportReplyDAO;
import com.homestay.dao.UserDAO;
import com.homestay.model.ContactMessage;
import com.homestay.model.SupportReply;
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
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SupportController - Handles customer and host personal support ticket views,
 * ticket details, and threaded follow-up communication.
 */
@WebServlet(name = "SupportController", urlPatterns = {"/support/*"})
public class SupportController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(SupportController.class.getName());
    private static final long REPLY_COOLDOWN_MS = 5000; // 5 seconds cooldown between replies

    private final SupportService supportService;
    private final ContactMessageDAO contactMessageDAO;
    private final SupportReplyDAO supportReplyDAO;
    private final UserDAO userDAO;

    public SupportController() {
        this(new SupportService(), new ContactMessageDAO(), new SupportReplyDAO(), new UserDAO());
    }

    public SupportController(SupportService supportService, ContactMessageDAO contactMessageDAO,
                             SupportReplyDAO supportReplyDAO, UserDAO userDAO) {
        this.supportService = supportService;
        this.contactMessageDAO = contactMessageDAO;
        this.supportReplyDAO = supportReplyDAO;
        this.userDAO = userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = resolveUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/support/my-tickets");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/my-tickets")) {
            handleMyTickets(request, response, user);
        } else if (pathInfo.equals("/ticket")) {
            handleTicketDetail(request, response, user);
        } else {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = resolveUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String pathInfo = request.getPathInfo();
        if ("/reply".equals(pathInfo)) {
            handlePostReply(request, response, user);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleMyTickets(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        request.setAttribute("activePage", "my-tickets");

        String statusParam = request.getParameter("status");
        String pageParam = request.getParameter("page");

        int page = 1;
        if (pageParam != null) {
            try {
                page = Math.max(1, Integer.parseInt(pageParam.trim()));
            } catch (NumberFormatException ignored) {
            }
        }
        int pageSize = 10;

        String safeStatus = null;
        if (statusParam != null && !statusParam.isBlank() && !"ALL".equalsIgnoreCase(statusParam)) {
            TicketStatus parsed = TicketStatus.fromCode(statusParam);
            if (parsed != null) {
                safeStatus = parsed.name();
            }
        }

        List<ContactMessage> tickets = contactMessageDAO.findByUserId(user.getId(), safeStatus, page, pageSize);
        int totalTickets = contactMessageDAO.countByUserId(user.getId(), safeStatus);
        int totalPages = (int) Math.ceil((double) totalTickets / pageSize);

        request.setAttribute("tickets", tickets);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", Math.max(1, totalPages));
        request.setAttribute("totalCount", totalTickets);
        request.setAttribute("statusFilter", safeStatus != null ? safeStatus : "ALL");

        request.getRequestDispatcher("/WEB-INF/views/my-tickets.jsp").forward(request, response);
    }

    private void handleTicketDetail(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        request.setAttribute("activePage", "my-tickets");

        String code = request.getParameter("code");
        String idStr = request.getParameter("id");

        Optional<ContactMessage> ticketOpt = Optional.empty();
        if (code != null && !code.isBlank()) {
            ticketOpt = contactMessageDAO.findByTicketCode(code.trim());
        } else if (idStr != null && !idStr.isBlank()) {
            try {
                int ticketId = Integer.parseInt(idStr.trim());
                ticketOpt = contactMessageDAO.findById(ticketId);
            } catch (NumberFormatException ignored) {
            }
        }

        // Strict authorization check: ticket must exist AND belong to current user
        if (ticketOpt.isEmpty() || ticketOpt.get().getUserId() == null || ticketOpt.get().getUserId() != user.getId()) {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets?error="
                    + URLEncoder.encode("Yêu cầu không tồn tại hoặc bạn không có quyền truy cập.", StandardCharsets.UTF_8));
            return;
        }

        ContactMessage ticket = ticketOpt.get();
        List<SupportReply> replies = supportReplyDAO.findByTicketId(ticket.getMessageId());
        ticket.setReplies(replies);

        request.setAttribute("ticket", ticket);
        request.setAttribute("csrfToken", LoginUtil.getOrCreateCsrfToken(request));

        if ("1".equals(request.getParameter("created"))) {
            request.setAttribute("justCreated", true);
        }
        if ("1".equals(request.getParameter("replySuccess"))) {
            request.setAttribute("replySuccess", true);
        }

        String replyError = request.getParameter("replyError");
        if (replyError != null && !replyError.isBlank()) {
            request.setAttribute("replyError", replyError);
        }
        // KHOI PHUC NOI DUNG NHAP PHAN HOI TU SESSION KHI CO LOI VALIDATION/CSRF/RATE-LIMIT/DB (DOT 6)
        HttpSession detailSession = request.getSession(false);
        if (detailSession != null) {
            Object replyDraft = detailSession.getAttribute("supportReplyDraft");
            if (replyDraft != null) {
                request.setAttribute("replyDraft", replyDraft);
                detailSession.removeAttribute("supportReplyDraft");
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/ticket-detail.jsp").forward(request, response);
    }

    private void handlePostReply(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        String ticketIdStr = request.getParameter("ticketId");
        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdStr.trim());
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets?error="
                    + URLEncoder.encode("Mã yêu cầu không hợp lệ.", StandardCharsets.UTF_8));
            return;
        }

        // LUU TAM NOI DUNG PHAN HOI DE GIU DU LIEU NGUOI DUNG KHI VALIDATION/CSRF/RATE-LIMIT/DB LOI (DOT 6)
        String rawDraftMessage = request.getParameter("message");
        HttpSession draftSession = request.getSession(true);
        if (draftSession == null) {
            draftSession = request.getSession(false);
        }

        // CSRF Check (one-time token consumption)
        String submittedCsrf = request.getParameter("csrfToken");
        if (!LoginUtil.consumeCsrfToken(request, submittedCsrf)) {
            if (draftSession != null && rawDraftMessage != null) {
                draftSession.setAttribute("supportReplyDraft", rawDraftMessage);
            }
            response.sendRedirect(request.getContextPath() + "/support/ticket?id=" + ticketId + "&replyError="
                    + URLEncoder.encode("Phiên bảo mật hết hạn hoặc biểu mẫu đã được gửi đi. Vui lòng thử lại.", StandardCharsets.UTF_8));
            return;
        }

        // Rate limiting check
        HttpSession session = request.getSession(true);
        Long lastReply = (Long) session.getAttribute("LAST_REPLY_TIME");
        long now = System.currentTimeMillis();
        if (lastReply != null && (now - lastReply) < REPLY_COOLDOWN_MS) {
            if (rawDraftMessage != null) {
                session.setAttribute("supportReplyDraft", rawDraftMessage);
            }
            response.sendRedirect(request.getContextPath() + "/support/ticket?id=" + ticketId + "&replyError="
                    + URLEncoder.encode("Vui lòng đợi vài giây trước khi gửi tiếp tin nhắn tiếp theo.", StandardCharsets.UTF_8));
            return;
        }

        String message = request.getParameter("message");
        if (message == null || message.trim().length() < 2 || message.trim().length() > 2000) {
            if (message != null) {
                session.setAttribute("supportReplyDraft", message);
            }
            response.sendRedirect(request.getContextPath() + "/support/ticket?id=" + ticketId + "&replyError="
                    + URLEncoder.encode("Nội dung tin nhắn phải từ 2 đến 2000 ký tự.", StandardCharsets.UTF_8));
            return;
        }

        try {
            supportService.addSenderReply(ticketId, user.getId(), message.trim());
            session.setAttribute("LAST_REPLY_TIME", now);
            session.removeAttribute("supportReplyDraft");
            response.sendRedirect(request.getContextPath() + "/support/ticket?id=" + ticketId + "&replySuccess=1");
        } catch (SecurityException e) {
            response.sendRedirect(request.getContextPath() + "/support/my-tickets?error="
                    + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        } catch (IllegalArgumentException e) {
            session.setAttribute("supportReplyDraft", message);
            response.sendRedirect(request.getContextPath() + "/support/ticket?id=" + ticketId + "&replyError="
                    + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error adding reply", e);
            session.setAttribute("supportReplyDraft", message);
            response.sendRedirect(request.getContextPath() + "/support/ticket?id=" + ticketId + "&replyError="
                    + URLEncoder.encode("Lỗi hệ thống khi gửi phản hồi. Vui lòng thử lại.", StandardCharsets.UTF_8));
        }
    }

    private User resolveUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object userObj = session.getAttribute("user");
        if (userObj instanceof User) {
            return (User) userObj;
        }
        Object uidObj = session.getAttribute("userId");
        if (uidObj instanceof Number) {
            int uid = ((Number) uidObj).intValue();
            User user = userDAO.findById(uid).orElse(null);
            if (user != null) {
                session.setAttribute("user", user);
            }
            return user;
        }
        return null;
    }
}
