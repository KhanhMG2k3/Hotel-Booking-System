package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Booking Model - Represents room reservation records.
 */
public class Booking implements Serializable {
    private static final long serialVersionUID = 1L;

    public enum Status {
        PENDING,
        CONFIRMED,
        COMPLETED,
        CANCELLED
    }

    private int id;
    private String bookingCode;
    private Integer userId;
    private User user;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private int roomId;
    private Room room;
    private Date checkInDate;
    private Date checkOutDate;
    private int adults = 1;
    private int children = 0;
    private int guestCount = 1;
    private BigDecimal totalPrice;
    private String notes;
    private String specialRequests;
    private String status = "CONFIRMED";
    private Timestamp createdAt;

    // Presentation attributes
    private String roomName;
    private String propertyName;
    private String roomImageUrl;
    private java.util.List<BookingRoomItem> bookingRooms = new java.util.ArrayList<>();

    public Booking() {
    }

    public Booking(int id, Integer userId, String customerName, String customerEmail, String customerPhone,
                   int roomId, Date checkInDate, Date checkOutDate, int adults, int children,
                   BigDecimal totalPrice, String notes, String status, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.roomId = roomId;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.adults = adults;
        this.children = children;
        this.guestCount = adults + children;
        this.totalPrice = totalPrice;
        this.notes = notes;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public void setEmail(String email) {
        this.customerEmail = email;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getEmail() {
        return customerEmail;
    }

    public String getName() {
        return customerName;
    }

    public String getPhone() {
        return customerPhone;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public Date getCheckInDate() {
        return checkInDate;
    }

    public void setCheckInDate(Date checkInDate) {
        this.checkInDate = checkInDate;
    }

    public Date getCheckOutDate() {
        return checkOutDate;
    }

    public void setCheckOutDate(Date checkOutDate) {
        this.checkOutDate = checkOutDate;
    }

    public int getAdults() {
        return adults;
    }

    public void setAdults(int adults) {
        this.adults = adults;
        this.guestCount = this.adults + this.children;
    }

    public int getChildren() {
        return children;
    }

    public void setChildren(int children) {
        this.children = children;
        this.guestCount = this.adults + this.children;
    }

    public int getGuestCount() {
        return guestCount > 0 ? guestCount : (adults + children);
    }

    public void setGuestCount(int guestCount) {
        this.guestCount = guestCount;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getNotes() {
        return notes != null ? notes : specialRequests;
    }

    public void setNotes(String notes) {
        this.notes = notes;
        if (this.specialRequests == null) {
            this.specialRequests = notes;
        }
    }

    public String getSpecialRequests() {
        return specialRequests != null ? specialRequests : notes;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
        if (this.notes == null) {
            this.notes = specialRequests;
        }
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setStatus(Status status) {
        this.status = status != null ? status.name() : "CONFIRMED";
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getPropertyName() {
        return propertyName;
    }

    public void setPropertyName(String propertyName) {
        this.propertyName = propertyName;
    }

    public java.util.List<BookingRoomItem> getBookingRooms() {
        return bookingRooms;
    }

    public void setBookingRooms(java.util.List<BookingRoomItem> bookingRooms) {
        this.bookingRooms = bookingRooms != null ? bookingRooms : new java.util.ArrayList<>();
    }

    public String getRoomImageUrl() {
        return roomImageUrl != null && !roomImageUrl.isEmpty() ? roomImageUrl : "images/img_1.jpg";
    }

    public void setRoomImageUrl(String roomImageUrl) {
        this.roomImageUrl = roomImageUrl;
    }

    public int getNumberOfNights() {
        if (checkInDate != null && checkOutDate != null) {
            long diff = checkOutDate.getTime() - checkInDate.getTime();
            return (int) Math.max(1, diff / (1000 * 60 * 60 * 24));
        }
        return 1;
    }

    public String getFormattedCheckInDate() {
        if (checkInDate == null) return "";
        return new java.text.SimpleDateFormat("dd/MM/yyyy").format(checkInDate);
    }

    public String getFormattedCheckOutDate() {
        if (checkOutDate == null) return "";
        return new java.text.SimpleDateFormat("dd/MM/yyyy").format(checkOutDate);
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
    }

    public String getFormattedTotalPrice() {
        if (totalPrice == null) return "0";
        return java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi", "VN")).format(totalPrice);
    }

    @Override
    public String toString() {
        return "Booking{" +
                "id=" + id +
                ", customerName='" + customerName + '\'' +
                ", roomId=" + roomId +
                ", checkInDate=" + checkInDate +
                ", checkOutDate=" + checkOutDate +
                ", totalPrice=" + totalPrice +
                ", status='" + status + '\'' +
                '}';
    }
}
