package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * ReviewReply Model - Represents the single public reply a Host writes to a customer review.
 */
public class ReviewReply implements Serializable {
    private static final long serialVersionUID = 1L;

    // Database mapped attributes
    private int id;
    private int reviewId;
    private int hostId;
    private String replyContent;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Presentation helper attribute
    private String hostName;

    public ReviewReply() {
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }

    public int getHostId() { return hostId; }
    public void setHostId(int hostId) { this.hostId = hostId; }

    public String getReplyContent() { return replyContent; }
    public void setReplyContent(String replyContent) { this.replyContent = replyContent; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getHostName() { return hostName; }
    public void setHostName(String hostName) { this.hostName = hostName; }

    /** Returns the reply time as dd/MM/yyyy HH:mm for display. */
    public String getFormattedDate() {
        if (createdAt == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }
}