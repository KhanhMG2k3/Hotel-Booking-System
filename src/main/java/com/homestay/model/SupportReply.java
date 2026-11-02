package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * SupportReply - Represents a single threaded message in a support ticket exchange.
 */
public class SupportReply implements Serializable {

    private static final long serialVersionUID = 1L;

    private int replyId;
    private int ticketId;
    private int senderId;
    private String message;
    private Timestamp createdAt;

    // Helper display fields populated on join
    private String senderName;
    private String senderRole;
    private String senderAvatar;
    private boolean isAdminReply;

    public SupportReply() {
    }

    public SupportReply(int ticketId, int senderId, String message) {
        this.ticketId = ticketId;
        this.senderId = senderId;
        this.message = message;
    }

    public int getReplyId() {
        return replyId;
    }

    public void setReplyId(int replyId) {
        this.replyId = replyId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public String getSenderAvatar() {
        return senderAvatar;
    }

    public void setSenderAvatar(String senderAvatar) {
        this.senderAvatar = senderAvatar;
    }

    public boolean isAdminReply() {
        return isAdminReply;
    }

    public void setAdminReply(boolean adminReply) {
        isAdminReply = adminReply;
    }

    @Override
    public String toString() {
        return "SupportReply{" +
                "replyId=" + replyId +
                ", ticketId=" + ticketId +
                ", senderId=" + senderId +
                ", createdAt=" + createdAt +
                '}';
    }
}
