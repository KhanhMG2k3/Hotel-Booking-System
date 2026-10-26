package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

/**
 * Review Model - Represents customer ratings and feedback for completed stays.
 */
public class Review implements Serializable {

    private static final long serialVersionUID = 1L;

    // Database mapped attributes
    private int id;
    private int bookingId;
    private int userId;
    private int roomId;
    private int propertyId;
    private int rating;
    private String title;
    private String comment;
    private String status = "APPROVED";
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Presentation helper attributes
    private String userName;
    private String userDisplayName;
    private String userAvatar;
    private String roomName;
    private String roomNumber;
    private String propertyName;
    private String bookingCode;
    private ReviewReply reply; // Host's public reply, null while unanswered

    public Review() {
    }

    public Review(int id, int bookingId, int userId, int roomId, int propertyId,
            int rating, String title, String comment, String status,
            Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.bookingId = bookingId;
        this.userId = userId;
        this.roomId = roomId;
        this.propertyId = propertyId;
        this.rating = rating;
        this.title = title;
        this.comment = comment;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public int getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(int propertyId) {
        this.propertyId = propertyId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserDisplayName() {
        return userDisplayName;
    }

    public void setUserDisplayName(String userDisplayName) {
        this.userDisplayName = userDisplayName;
    }

    public String getUserAvatar() {
        return userAvatar;
    }

    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getPropertyName() {
        return propertyName;
    }

    public void setPropertyName(String propertyName) {
        this.propertyName = propertyName;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public ReviewReply getReply() {
        return reply;
    }

    public void setReply(ReviewReply reply) {
        this.reply = reply;
    }

    public String getReviewerInitial() {
        String name = userDisplayName != null ? userDisplayName.trim() : "";
        return name.isEmpty() ? "?" : name.substring(0, 1).toUpperCase();
    }

    public String getFormattedDate() {
        if (createdAt == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy").format(createdAt);
    }
}
