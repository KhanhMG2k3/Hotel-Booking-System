package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Wishlist Model - Represents a user's saved favorite rooms and properties.
 */
public class Wishlist implements Serializable {
    private static final long serialVersionUID = 1L;

    private long wishlistId;
    private int userId;
    private Integer roomId;
    private Integer propertyId;
    private Integer tourId;
    private String notes;
    private Timestamp createdAt;

    // Joined object models for display
    private Room room;
    private Property property;

    public Wishlist() {
    }

    public Wishlist(long wishlistId, int userId, Integer roomId, Timestamp createdAt) {
        this.wishlistId = wishlistId;
        this.userId = userId;
        this.roomId = roomId;
        this.createdAt = createdAt;
    }

    public long getWishlistId() {
        return wishlistId;
    }

    public void setWishlistId(long wishlistId) {
        this.wishlistId = wishlistId;
    }

    public long getId() {
        return wishlistId;
    }

    public void setId(long id) {
        this.wishlistId = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public Integer getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(Integer propertyId) {
        this.propertyId = propertyId;
    }

    public Integer getTourId() {
        return tourId;
    }

    public void setTourId(Integer tourId) {
        this.tourId = tourId;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public Property getProperty() {
        return property;
    }

    public void setProperty(Property property) {
        this.property = property;
    }

    @Override
    public String toString() {
        return "Wishlist{" +
                "wishlistId=" + wishlistId +
                ", userId=" + userId +
                ", roomId=" + roomId +
                ", propertyId=" + propertyId +
                ", createdAt=" + createdAt +
                '}';
    }
}
