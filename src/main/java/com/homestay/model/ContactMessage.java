package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * ContactMessage - Represents a customer or host support request ticket.
 */
public class ContactMessage implements Serializable {

    private static final long serialVersionUID = 1L;

    private int messageId;
    private Integer userId;
    private String ticketCode;
    private TicketCategory category = TicketCategory.GENERAL_FEEDBACK;
    private Integer bookingId;
    private String fullName;
    private String email;
    private String phone;
    private String subject;
    private String message;
    private TicketStatus status = TicketStatus.NEW;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Display helpers populated via join / secondary queries
    private String bookingCode;
    private String senderRole;
    private List<SupportReply> replies = new ArrayList<>();
    private int replyCount;

    public ContactMessage() {
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getTicketCode() {
        return ticketCode;
    }

    public void setTicketCode(String ticketCode) {
        this.ticketCode = ticketCode;
    }

    public TicketCategory getCategory() {
        return category;
    }

    public void setCategory(TicketCategory category) {
        this.category = category;
    }

    public void setCategoryCode(String categoryCode) {
        TicketCategory cat = TicketCategory.fromCode(categoryCode);
        this.category = cat != null ? cat : TicketCategory.GENERAL_FEEDBACK;
    }

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public TicketStatus getStatus() {
        return status;
    }

    public void setStatus(TicketStatus status) {
        this.status = status;
    }

    public void setStatusCode(String statusCode) {
        TicketStatus st = TicketStatus.fromCode(statusCode);
        this.status = st != null ? st : TicketStatus.NEW;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public List<SupportReply> getReplies() {
        return replies;
    }

    public void setReplies(List<SupportReply> replies) {
        this.replies = replies != null ? replies : new ArrayList<>();
    }

    public int getReplyCount() {
        return replyCount;
    }

    public void setReplyCount(int replyCount) {
        this.replyCount = replyCount;
    }

    @Override
    public String toString() {
        return "ContactMessage{" +
                "messageId=" + messageId +
                ", ticketCode='" + ticketCode + '\'' +
                ", userId=" + userId +
                ", category=" + category +
                ", status=" + status +
                ", subject='" + subject + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
