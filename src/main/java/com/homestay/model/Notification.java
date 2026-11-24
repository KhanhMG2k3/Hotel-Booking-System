package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Model representing an In-App Notification for users (Customer, Host, Admin).
 */
public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String title;
    private String message;
    private String type; // BOOKING, PROMOTION, REVIEW, SYSTEM
    private String targetUrl;
    private boolean isRead;
    private Timestamp createdAt;

    public Notification() {
    }

    public Notification(int id, int userId, String title, String message, String type,
                        String targetUrl, boolean isRead, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.targetUrl = targetUrl;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTargetUrl() {
        return targetUrl;
    }

    public void setTargetUrl(String targetUrl) {
        this.targetUrl = targetUrl;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Returns a human-friendly relative time string (e.g., "5 phút trước", "2 giờ trước").
     */
    public String getTimeAgo() {
        if (createdAt == null) {
            return "";
        }
        LocalDateTime createdTime = createdAt.toLocalDateTime();
        LocalDateTime now = LocalDateTime.now();
        Duration duration = Duration.between(createdTime, now);

        long seconds = duration.getSeconds();
        if (seconds < 60) {
            return "Vừa xong";
        }
        long minutes = duration.toMinutes();
        if (minutes < 60) {
            return minutes + " phút trước";
        }
        long hours = duration.toHours();
        if (hours < 24) {
            return hours + " giờ trước";
        }
        long days = duration.toDays();
        if (days < 7) {
            return days + " ngày trước";
        }
        return createdTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    /**
     * FontAwesome icon class corresponding to the notification type.
     */
    public String getIconClass() {
        if (type == null) return "fa fa-bell text-secondary";
        switch (type.toUpperCase()) {
            case "BOOKING":
                return "fa fa-calendar-check-o text-primary";
            case "PROMOTION":
                return "fa fa-tag text-danger";
            case "REVIEW":
                return "fa fa-commenting-o text-warning";
            case "SYSTEM":
            default:
                return "fa fa-bell text-info";
        }
    }

    /**
     * Bootstrap badge class for notification type.
     */
    public String getBadgeClass() {
        if (type == null) return "badge badge-secondary";
        switch (type.toUpperCase()) {
            case "BOOKING":
                return "badge badge-primary";
            case "PROMOTION":
                return "badge badge-danger";
            case "REVIEW":
                return "badge badge-warning text-dark";
            case "SYSTEM":
            default:
                return "badge badge-info";
        }
    }

    /**
     * Localized label for notification type.
     */
    public String getTypeLabel() {
        if (type == null) return "Hệ thống";
        switch (type.toUpperCase()) {
            case "BOOKING":
                return "Đặt phòng";
            case "PROMOTION":
                return "Khuyến mãi";
            case "REVIEW":
                return "Đánh giá";
            case "SYSTEM":
            default:
                return "Hệ thống";
        }
    }
}