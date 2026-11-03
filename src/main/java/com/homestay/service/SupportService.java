package com.homestay.service;

import com.homestay.context.DBContext;
import com.homestay.dao.BookingDAO;
import com.homestay.dao.ContactMessageDAO;
// THEM IMPORT NOTIFICATIONDAO CHO DOT 5 - TAI SU DUNG MODULE NOTIFICATION HIEN CO
import com.homestay.dao.NotificationDAO;
import com.homestay.dao.SupportReplyDAO;
import com.homestay.exception.DataAccessException;
import com.homestay.model.ContactMessage;
import com.homestay.model.SupportReply;
import com.homestay.model.TicketCategory;
import com.homestay.model.TicketStatus;
import com.homestay.model.User;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * SupportService - Thin business & transaction service coordinating support tickets,
 * message threads, permissions, and lifecycle transitions.
 */
public class SupportService {

    private static final Logger LOGGER = Logger.getLogger(SupportService.class.getName());
    private static final String CODE_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"; // excludes 0,1,I,O to prevent ambiguity
    private static final SecureRandom RANDOM = new SecureRandom();

    private final ContactMessageDAO contactMessageDAO;
    private final SupportReplyDAO supportReplyDAO;
    private final BookingDAO bookingDAO;
    // BO SUNG NOTIFICATIONDAO DE GHI NHAN THONG BAO TRONG CUNG TRANSACTION NGHIEP VU (DOT 5)
    private final NotificationDAO notificationDAO;

    public SupportService() {
//        this(new ContactMessageDAO(), new SupportReplyDAO(), new BookingDAO());
        // KHOI TAO THEM NOTIFICATIONDAO HIEN CO (KHONG TAO MODULE NOTIFICATION THU HAI)
        this(new ContactMessageDAO(), new SupportReplyDAO(), new BookingDAO(), new NotificationDAO());
    }

    public SupportService(ContactMessageDAO contactMessageDAO, SupportReplyDAO supportReplyDAO, BookingDAO bookingDAO) {
//        this.contactMessageDAO = contactMessageDAO;
//        this.supportReplyDAO = supportReplyDAO;
//        this.bookingDAO = bookingDAO;
        // GIU TONG THICH NGUOC CHO CONSTRUCTOR 3 THAM SO VA CHUYEN TIEP SANG CONSTRUCTOR 4 THAM SO
        this(contactMessageDAO, supportReplyDAO, bookingDAO, new NotificationDAO());
    }

    // CONSTRUCTOR 4 THAM SO HO TRO TIEM NOTIFICATIONDAO TRUC TIEP DE KIEM THU TRANSACTION & CHONG TRUNG (DOT 5)
    public SupportService(ContactMessageDAO contactMessageDAO, SupportReplyDAO supportReplyDAO,
                          BookingDAO bookingDAO, NotificationDAO notificationDAO) {
        this.contactMessageDAO = contactMessageDAO;
        this.supportReplyDAO = supportReplyDAO;
        this.bookingDAO = bookingDAO;
        this.notificationDAO = notificationDAO;
    }

    protected Connection getConnection() throws SQLException {
        return DBContext.getConnection();
    }

    /**
     * Creates a new support ticket submitted by an authenticated Customer or Host.
     */
    public ContactMessage createTicket(ContactMessage ticket, User sender) {
        if (sender == null || sender.getId() <= 0) {
            throw new IllegalArgumentException("Người gửi phải đăng nhập để tạo yêu cầu hỗ trợ.");
        }
        if (ticket == null) {
            throw new IllegalArgumentException("Thông tin yêu cầu hỗ trợ không được để trống.");
        }

        // Validate subject
        if (ticket.getSubject() == null || ticket.getSubject().trim().length() < 5 || ticket.getSubject().trim().length() > 150) {
            throw new IllegalArgumentException("Tiêu đề yêu cầu phải từ 5 đến 150 ký tự.");
        }

        // Validate message body
        if (ticket.getMessage() == null || ticket.getMessage().trim().length() < 10 || ticket.getMessage().trim().length() > 3000) {
            throw new IllegalArgumentException("Nội dung chi tiết phải từ 10 đến 3000 ký tự.");
        }

        // Validate category
        if (ticket.getCategory() == null) {
            ticket.setCategory(TicketCategory.GENERAL_FEEDBACK);
        }

        // Validate optional related booking
        if (ticket.getBookingId() != null && ticket.getBookingId() > 0) {
            validateBookingOwnership(ticket.getBookingId(), sender);
        } else {
            ticket.setBookingId(null);
        }

        // Generate tracking code and initialize ticket state
        String ticketCode = generateTicketCode();
        ticket.setTicketCode(ticketCode);
        ticket.setUserId(sender.getId());
        ticket.setFullName(sender.getFullName() != null ? sender.getFullName().trim() : sender.getUsername());
        ticket.setEmail(sender.getEmail() != null ? sender.getEmail().trim() : "");
        ticket.setPhone(sender.getPhone());
        ticket.setStatus(TicketStatus.NEW);

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            boolean success = contactMessageDAO.insert(ticket, conn);
            if (!success || ticket.getMessageId() <= 0) {
                conn.rollback();
                throw new DataAccessException("Không thể lưu yêu cầu hỗ trợ vào cơ sở dữ liệu.");
            }

            // TICH HOP NOTIFICATION DOT 5 - SU KIEN 1: YEU CAU MOI -> ADMIN DANG HOAT DONG NHAN THONG BAO (CUNG TRANSACTION)
            notifyAdminsOnNewTicket(ticket, sender.getId(), conn);

            conn.commit();
            return ticket;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.WARNING, "Failed to rollback ticket creation", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Error creating support ticket", e);
            throw new DataAccessException("Lỗi hệ thống khi tạo yêu cầu hỗ trợ", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Adds a follow-up reply from the ticket sender.
     * Business rule: If the ticket is currently RESOLVED, it is automatically reopened to PROCESSING.
     */
    public SupportReply addSenderReply(int ticketId, int senderUserId, String messageText) {
        if (senderUserId <= 0) {
            throw new IllegalArgumentException("Người gửi không hợp lệ.");
        }
        if (messageText == null || messageText.trim().length() < 2 || messageText.trim().length() > 2000) {
            throw new IllegalArgumentException("Nội dung phản hồi phải từ 2 đến 2000 ký tự.");
        }

        Optional<ContactMessage> ticketOpt = contactMessageDAO.findById(ticketId);
        if (ticketOpt.isEmpty()) {
            throw new IllegalArgumentException("Yêu cầu hỗ trợ không tồn tại.");
        }

        ContactMessage ticket = ticketOpt.get();
        if (ticket.getUserId() == null || ticket.getUserId() != senderUserId) {
            throw new SecurityException("Bạn không có quyền phản hồi trên yêu cầu hỗ trợ của người khác.");
        }

        SupportReply reply = new SupportReply(ticketId, senderUserId, messageText.trim());
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            boolean inserted = supportReplyDAO.insert(reply, conn);
            if (!inserted) {
                conn.rollback();
                throw new DataAccessException("Không thể lưu tin nhắn phản hồi.");
            }

            // If ticket was RESOLVED, reopen to PROCESSING
            if (ticket.getStatus() == TicketStatus.RESOLVED) {
                boolean updated = contactMessageDAO.updateStatus(ticketId, TicketStatus.PROCESSING, TicketStatus.RESOLVED, conn);
                if (!updated) {
                    conn.rollback();
                    throw new DataAccessException("Không thể tự động cập nhật trạng thái yêu cầu sang Đang xử lý.");
                }
            } else {
                contactMessageDAO.touchUpdatedAt(ticketId, conn);
            }

            // TICH HOP NOTIFICATION DOT 5 - SU KIEN 3: NGUOI GUI BO SUNG -> ADMIN XU LY / ADMIN DANG HOAT DONG NHAN THONG BAO
            notifyAdminsOnSenderReply(ticket, reply, senderUserId, ticket.getStatus() == TicketStatus.RESOLVED, conn);

            conn.commit();
            return reply;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.WARNING, "Failed to rollback sender reply", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Error adding sender reply for ticket: " + ticketId, e);
            throw new DataAccessException("Lỗi hệ thống khi gửi phản hồi", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Adds an administrator reply to a ticket.
     * Optionally transitions ticket from NEW to PROCESSING on first response.
     * Business rule: Does NOT auto-resolve the ticket.
     */
    public SupportReply addAdminReply(int ticketId, int adminUserId, String messageText, boolean changeToProcessing) {
        if (adminUserId <= 0) {
            throw new IllegalArgumentException("Quản trị viên không hợp lệ.");
        }
        if (messageText == null || messageText.trim().length() < 2 || messageText.trim().length() > 2000) {
            throw new IllegalArgumentException("Nội dung phản hồi của quản trị viên phải từ 2 đến 2000 ký tự.");
        }

        Optional<ContactMessage> ticketOpt = contactMessageDAO.findById(ticketId);
        if (ticketOpt.isEmpty()) {
            throw new IllegalArgumentException("Yêu cầu hỗ trợ không tồn tại.");
        }

        ContactMessage ticket = ticketOpt.get();
        SupportReply reply = new SupportReply(ticketId, adminUserId, messageText.trim());

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            boolean inserted = supportReplyDAO.insert(reply, conn);
            if (!inserted) {
                conn.rollback();
                throw new DataAccessException("Không thể lưu tin nhắn phản hồi của quản trị viên.");
            }

            if (changeToProcessing && ticket.getStatus() == TicketStatus.NEW) {
                contactMessageDAO.updateStatus(ticketId, TicketStatus.PROCESSING, TicketStatus.NEW, conn);
            } else {
                contactMessageDAO.touchUpdatedAt(ticketId, conn);
            }

            // TICH HOP NOTIFICATION DOT 5 - SU KIEN 2: ADMIN PHAN HOI -> CHU YEU CAU NHAN THONG BAO (CUNG TRANSACTION)
            notifyOwnerOnAdminReply(ticket, reply, adminUserId, conn);

            conn.commit();
            return reply;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.WARNING, "Failed to rollback admin reply", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Error adding admin reply for ticket: " + ticketId, e);
            throw new DataAccessException("Lỗi hệ thống khi quản trị viên gửi phản hồi", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Updates ticket status with strict lifecycle validation and optimistic concurrency check.
     * If expectedCurrentStatus is provided and doesn't match the ticket's current status in DB,
     * returns false to signify a concurrent conflict.
     */
    public boolean updateTicketStatus(int ticketId, TicketStatus newStatus, TicketStatus expectedCurrentStatus, boolean isAdmin) {
//        if (!isAdmin) {
//            throw new SecurityException("Chỉ Quản trị viên mới có quyền cập nhật trạng thái yêu cầu.");
//        }
//        if (newStatus == null) {
//            throw new IllegalArgumentException("Trạng thái mới không hợp lệ.");
//        }
//
//        Optional<ContactMessage> ticketOpt = contactMessageDAO.findById(ticketId);
//        if (ticketOpt.isEmpty()) {
//            throw new IllegalArgumentException("Yêu cầu hỗ trợ không tồn tại.");
//        }
//
//        ContactMessage ticket = ticketOpt.get();
//        TicketStatus currentStatus = ticket.getStatus();
//
//        if (expectedCurrentStatus != null && currentStatus != expectedCurrentStatus) {
//            LOGGER.warning("Concurrency conflict on ticket " + ticketId + ": expected " + expectedCurrentStatus + " but found " + currentStatus);
//            return false;
//        }
//
//        if (!currentStatus.canTransitionTo(newStatus, true, false)) {
//            throw new IllegalStateException("Không thể chuyển đổi trạng thái từ "
//                    + currentStatus.getDisplayName() + " sang " + newStatus.getDisplayName());
//        }
//
//        return contactMessageDAO.updateStatus(ticketId, newStatus, currentStatus);
        // CHUYEN TIEP SANG PHUONG THUC CO GIAO DICH TRANSACTION VA HO TRO ACTORUSERID (DOT 5)
        return updateTicketStatus(ticketId, newStatus, expectedCurrentStatus, isAdmin, null);
    }

    /**
     * CAP NHAT TRANG THAI TICKET TRONG TRANSACTION NHAT QUAN VOI GHI NHAN THONG BAO KHI CHUYEN SANG RESOLVED (DOT 5).
     * NEU ROLLBACK THI KHONG PHAT SINH THONG BAO SAI; KHONG GUI THONG BAO CHO CHINH ACTORUSERID.
     */
    public boolean updateTicketStatus(int ticketId, TicketStatus newStatus, TicketStatus expectedCurrentStatus,
                                      boolean isAdmin, Integer actorUserId) {
        if (!isAdmin) {
            throw new SecurityException("Chỉ Quản trị viên mới có quyền cập nhật trạng thái yêu cầu.");
        }
        if (newStatus == null) {
            throw new IllegalArgumentException("Trạng thái mới không hợp lệ.");
        }

        Optional<ContactMessage> ticketOpt = contactMessageDAO.findById(ticketId);
        if (ticketOpt.isEmpty()) {
            throw new IllegalArgumentException("Yêu cầu hỗ trợ không tồn tại.");
        }

        ContactMessage ticket = ticketOpt.get();
        TicketStatus currentStatus = ticket.getStatus();

        if (expectedCurrentStatus != null && currentStatus != expectedCurrentStatus) {
            LOGGER.warning("Concurrency conflict on ticket " + ticketId + ": expected " + expectedCurrentStatus + " but found " + currentStatus);
            return false;
        }

        if (!currentStatus.canTransitionTo(newStatus, true, false)) {
            throw new IllegalStateException("Không thể chuyển đổi trạng thái từ "
                    + currentStatus.getDisplayName() + " sang " + newStatus.getDisplayName());
        }

        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            boolean updated = contactMessageDAO.updateStatus(ticketId, newStatus, currentStatus, conn);
            if (!updated) {
                conn.rollback();
                return false;
            }

            // TICH HOP NOTIFICATION DOT 5 - SU KIEN 4: CHUYEN SANG RESOLVED -> CHU YEU CAU NHAN THONG BAO (CUNG TRANSACTION)
            if (newStatus == TicketStatus.RESOLVED) {
                notifyOwnerOnTicketResolved(ticket, actorUserId, conn);
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.WARNING, "Failed to rollback ticket status update", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Error updating ticket status for ticket: " + ticketId, e);
            throw new DataAccessException("Lỗi hệ thống khi cập nhật trạng thái yêu cầu hỗ trợ", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Backward-compatible ticket status update without expected status verification.
     */
    public boolean updateTicketStatus(int ticketId, TicketStatus newStatus, boolean isAdmin) {
        return updateTicketStatus(ticketId, newStatus, null, isAdmin);
    }

    /**
     * Finds tickets matching admin filter criteria with pagination.
     */
    public List<ContactMessage> findTicketsForAdmin(String statusFilter, String categoryFilter, String keyword,
                                                   String sortBy, String sortOrder, int page, int pageSize) {
        return contactMessageDAO.findAllForAdmin(statusFilter, categoryFilter, keyword, sortBy, sortOrder, page, pageSize);
    }

    /**
     * Counts tickets matching admin filter criteria for pagination.
     */
    public int countTicketsForAdmin(String statusFilter, String categoryFilter, String keyword) {
        return contactMessageDAO.countAllForAdmin(statusFilter, categoryFilter, keyword);
    }

    /**
     * Retrieves aggregated KPI stats for admin dashboard/list.
     */
    public Map<String, Integer> getAdminTicketKpiStats() {
        return contactMessageDAO.getTicketKpiStats();
    }

    /**
     * Retrieves ticket details ensuring user authorization boundary, and loads threaded replies.
     */
    public Optional<ContactMessage> getTicketDetailForUser(int ticketId, int userId) {
        Optional<ContactMessage> ticketOpt = contactMessageDAO.findByIdAndUserId(ticketId, userId);
        ticketOpt.ifPresent(ticket -> {
            List<SupportReply> replies = supportReplyDAO.findByTicketId(ticket.getMessageId());
            ticket.setReplies(replies);
        });
        return ticketOpt;
    }

    /**
     * Retrieves ticket details for administrators along with complete reply history.
     */
    public Optional<ContactMessage> getTicketDetailForAdmin(int ticketId) {
        Optional<ContactMessage> ticketOpt = contactMessageDAO.findById(ticketId);
        ticketOpt.ifPresent(ticket -> {
            List<SupportReply> replies = supportReplyDAO.findByTicketId(ticket.getMessageId());
            ticket.setReplies(replies);
        });
        return ticketOpt;
    }

    /**
     * Validates that the specified booking belongs to the sender.
     */
    private void validateBookingOwnership(int bookingId, User sender) {
        try {
            boolean isHost = sender.getRole() != null &&
                    ("ROLE_HOST".equalsIgnoreCase(sender.getRole().getRoleName()) || "HOST".equalsIgnoreCase(sender.getRole().getRoleName()));

            boolean owned;
            if (isHost) {
                owned = bookingDAO.isBookingOwnedByHost(bookingId, sender.getId());
            } else {
                owned = bookingDAO.isBookingOwnedByUser(bookingId, sender.getId());
            }

            if (!owned) {
                throw new IllegalArgumentException("Mã đặt phòng liên quan không thuộc quyền sở hữu của bạn.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error verifying booking ownership for bookingId: " + bookingId, e);
            throw new DataAccessException("Lỗi khi xác minh thông tin đặt phòng liên quan", e);
        }
    }

    /**
     * Generates a unique tracking code: TK-YYYYMMDD-XXXX
     */
    public String generateTicketCode() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String datePart = sdf.format(new Date());

        StringBuilder codeBuilder = new StringBuilder("TK-").append(datePart).append("-");
        for (int i = 0; i < 4; i++) {
            int index = RANDOM.nextInt(CODE_ALPHABET.length());
            codeBuilder.append(CODE_ALPHABET.charAt(index));
        }
        return codeBuilder.toString();
    }

    // ==================== BAT DAU THEM MOI DOT 5: CAC HAM TAO THONG BAO CONTACT & SUPPORT ====================

    /**
     * SU KIEN 1: YEU CAU MOI -> GUI THONG BAO CHO CAC ADMIN DANG HOAT DONG TRONG DATABASE.
     * - CHONG TRUNG THEO TICKET_ID QUA LINK /admin/support/detail?id={ticketId}
     * - KHONG DUA NOI DUNG HO TRO NHAY CAM VAO THONG BAO, KHONG GUI CHO CHINH NGUOI TAO.
     */
    private void notifyAdminsOnNewTicket(ContactMessage ticket, int actorUserId, Connection conn) throws SQLException {
        if (notificationDAO == null || ticket == null || ticket.getMessageId() <= 0) {
            return;
        }

        List<Integer> adminIds = notificationDAO.findActiveAdminIds(conn);
        if (adminIds == null || adminIds.isEmpty()) {
            return;
        }

        String codeLabel = resolveSafeTicketCodeLabel(ticket);
        String categoryLabel = (ticket.getCategory() != null)
                ? ticket.getCategory().getDisplayName()
                : TicketCategory.GENERAL_FEEDBACK.getDisplayName();
        String senderLabel = sanitizeNotificationLabel(ticket.getFullName(), "Người dùng");

        String title = "Yêu cầu hỗ trợ mới [" + codeLabel + "]";
        String message = senderLabel + " vừa gửi yêu cầu hỗ trợ thuộc mục " + categoryLabel + ".";
        String targetUrl = "/admin/support/detail?id=" + ticket.getMessageId();

        for (Integer adminId : adminIds) {
            if (adminId != null && adminId > 0 && adminId != actorUserId) {
                notificationDAO.createNotificationIfAbsent(adminId, title, message, "SYSTEM", targetUrl, conn);
            }
        }
    }

    /**
     * SU KIEN 2: ADMIN PHAN HOI -> GUI THONG BAO CHO CHU YEU CAU (LAY RECIPIENT TU DB).
     * - CHONG TRUNG THEO REPLY_ID QUA LINK /support/ticket?code={ticketCode}#reply-{replyId}
     * - MOI PHAN HOI MOI CO REPLY_ID RIENG NEN LUON CO THONG BAO RIENG, RETRY CUNG REPLY_ID KHONG TAO TRUNG.
     */
    private void notifyOwnerOnAdminReply(ContactMessage ticket, SupportReply reply,
                                         int adminUserId, Connection conn) throws SQLException {
        if (notificationDAO == null || ticket == null || reply == null) {
            return;
        }

        Integer ownerId = ticket.getUserId();
        if (ownerId == null || ownerId <= 0 || ownerId == adminUserId) {
            return;
        }

        String codeLabel = resolveSafeTicketCodeLabel(ticket);
        String title = "Phản hồi mới cho yêu cầu [" + codeLabel + "]";
        String message = "Ban quản trị đã phản hồi yêu cầu hỗ trợ " + codeLabel + " của bạn. Nhấn để xem chi tiết.";
        String targetUrl = buildOwnerTicketUrl(ticket) + "#reply-" + reply.getReplyId();

        notificationDAO.createNotificationIfAbsent(ownerId, title, message, "SYSTEM", targetUrl, conn);
    }

    /**
     * SU KIEN 3: NGUOI GUI BO SUNG -> GUI THONG BAO CHO ADMIN DANG XU LY TICKET NAY (DA TUNG PHAN HOI),
     * NEU CHUA CO ADMIN NAO PHAN HOI THI GUI CHO CAC ADMIN DANG HOAT DONG TRONG DATABASE.
     * - CHONG TRUNG THEO REPLY_ID QUA LINK /admin/support/detail?id={ticketId}#reply-{replyId}
     */
    private void notifyAdminsOnSenderReply(ContactMessage ticket, SupportReply reply,
                                           int senderUserId, boolean reopenedFromResolved,
                                           Connection conn) throws SQLException {
        if (notificationDAO == null || ticket == null || reply == null) {
            return;
        }

        List<Integer> recipientAdminIds = supportReplyDAO.findRepliedAdminIdsByTicketId(ticket.getMessageId(), conn);
        if (recipientAdminIds == null || recipientAdminIds.isEmpty()) {
            recipientAdminIds = notificationDAO.findActiveAdminIds(conn);
        }
        if (recipientAdminIds == null || recipientAdminIds.isEmpty()) {
            return;
        }

        String codeLabel = resolveSafeTicketCodeLabel(ticket);
        String title = "Phản hồi bổ sung [" + codeLabel + "]";
        String message = reopenedFromResolved
                ? "Người gửi vừa phản hồi bổ sung và mở lại yêu cầu hỗ trợ " + codeLabel + "."
                : "Người gửi vừa gửi thêm phản hồi cho yêu cầu hỗ trợ " + codeLabel + ".";
        String targetUrl = "/admin/support/detail?id=" + ticket.getMessageId() + "#reply-" + reply.getReplyId();

        for (Integer adminId : recipientAdminIds) {
            if (adminId != null && adminId > 0 && adminId != senderUserId) {
                notificationDAO.createNotificationIfAbsent(adminId, title, message, "SYSTEM", targetUrl, conn);
            }
        }
    }

    /**
     * SU KIEN 4: CHUYEN TRANG THAI SANG RESOLVED -> GUI THONG BAO CHO CHU YEU CAU (LAY RECIPIENT TU DB).
     * - CHONG TRUNG THEO TRANSITION/EVENT KEY (#resolved-{ticketId}-r{latestReplyId}[-v{stateVersion}]).
     */
    private void notifyOwnerOnTicketResolved(ContactMessage ticket, Integer actorUserId,
                                             Connection conn) throws SQLException {
        if (notificationDAO == null || ticket == null) {
            return;
        }

        Integer ownerId = ticket.getUserId();
        if (ownerId == null || ownerId <= 0) {
            return;
        }
        if (actorUserId != null && ownerId.equals(actorUserId)) {
            return;
        }

        int latestReplyId = supportReplyDAO.findLatestReplyId(ticket.getMessageId(), conn);
        long stateVersion = (ticket.getUpdatedAt() != null) ? (ticket.getUpdatedAt().getTime() / 1000L) : 0L;
        String transitionKey = "#resolved-" + ticket.getMessageId() + "-r" + latestReplyId
                + (stateVersion > 0 ? ("-v" + stateVersion) : "");

        String codeLabel = resolveSafeTicketCodeLabel(ticket);
        String title = "Yêu cầu [" + codeLabel + "] đã được giải quyết";
        String message = "Yêu cầu hỗ trợ " + codeLabel + " của bạn đã chuyển sang trạng thái Đã giải quyết.";
        String targetUrl = buildOwnerTicketUrl(ticket) + transitionKey;

        notificationDAO.createNotificationIfAbsent(ownerId, title, message, "SYSTEM", targetUrl, conn);
    }

    /**
     * TAO LINK CHI TIET PHU HOP VAI TRO NGUOI GUI (CUSTOMER / HOST).
     * CONTEXT PATH DUOC TU DONG GAN BOI NAVBAR.JSP / NOTIFICATIONS.JSP / NOTIFICATIONCONTROLLER.
     */
    private String buildOwnerTicketUrl(ContactMessage ticket) {
        if (ticket.getTicketCode() != null && !ticket.getTicketCode().isBlank()) {
            return "/support/ticket?code=" + ticket.getTicketCode().trim();
        }
        return "/support/ticket?id=" + ticket.getMessageId();
    }

    /**
     * LAY NHAN MA TICKET AN TOAN CHO TIEU DE VA NOI DUNG THONG BAO.
     */
    private String resolveSafeTicketCodeLabel(ContactMessage ticket) {
        if (ticket.getTicketCode() != null && !ticket.getTicketCode().isBlank()) {
            return sanitizeNotificationLabel(ticket.getTicketCode(), "#" + ticket.getMessageId());
        }
        return "#" + ticket.getMessageId();
    }

    /**
     * LAM SACH CHUOI HIEN THI NGAN GON TRONG THONG BAO DE NGANG CHONG XSS VA KHONG LO DU LIEU NHAY CAM.
     */
    private String sanitizeNotificationLabel(String raw, String fallback) {
        if (raw == null) {
            return fallback;
        }
        String cleaned = raw.replaceAll("[<>\"'&\\\\\\r\\n\\t]", " ").replaceAll("\\s+", " ").trim();
        if (cleaned.isEmpty()) {
            return fallback;
        }
        return cleaned.length() > 50 ? cleaned.substring(0, 50) + "..." : cleaned;
    }

    // ==================== KET THUC THEM MOI DOT 5: CAC HAM TAO THONG BAO CONTACT & SUPPORT ====================
}
