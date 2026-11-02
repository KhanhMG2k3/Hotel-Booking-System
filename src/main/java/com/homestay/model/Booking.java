package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Booking Model - Represents room reservation records.
 * Integrates Multi-room bookings, Vouchers, Payments, Refunds, and Host Wallet Payouts.
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
    private Long propertyId;

    private Date checkInDate;
    private Date checkOutDate;
    private int adults = 1;
    private int children = 0;
    private int guestCount = 1;

    private BigDecimal totalPrice;
    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;

    private String notes;
    private String specialRequests;
    private String status = "PENDING";
    private String cancellationReason;
    private Timestamp createdAt;

    // Presentation attributes
    private String roomName;
    private String roomNumber;
    private String propertyName;
    private String propertyAddress;
    private String roomImageUrl;
    private List<BookingRoomItem> bookingRooms = new ArrayList<>();

    // Finance & Wallet Payout tracking
    private Refund refund;
    private Payment payment;
    private String payoutStatus = "UNPAID";

    public Booking() {
    }

    public Booking(
            int id,
            Integer userId,
            String customerName,
            String customerEmail,
            String customerPhone,
            int roomId,
            Date checkInDate,
            Date checkOutDate,
            int adults,
            int children,
            BigDecimal totalPrice,
            String notes,
            String status,
            Timestamp createdAt) {

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
        this.totalAmount = totalPrice;
        this.subtotal = totalPrice;
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

    public int getBookingId() {
        return id;
    }

    public void setBookingId(int bookingId) {
        this.id = bookingId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
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

    public String getEmail() {
        return customerEmail;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public Long getPropertyId() {
        return propertyId;
    }

    public void setPropertyId(Long propertyId) {
        this.propertyId = propertyId;
    }

    public void setPropertyId(int propertyId) {
        this.propertyId = (long) propertyId;
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
    }

    public int getChildren() {
        return children;
    }

    public void setChildren(int children) {
        this.children = children;
    }

    public int getGuestCount() {
        return guestCount > 0 ? guestCount : (adults + children);
    }

    public void setGuestCount(int guestCount) {
        this.guestCount = guestCount;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice != null ? totalPrice : totalAmount;
    }

    public void setTotalPrice(BigDecimal totalPrice) {
        this.totalPrice = totalPrice;
        if (this.totalAmount == null) {
            this.totalAmount = totalPrice;
        }
    }

    public BigDecimal getSubtotal() {
        return subtotal != null ? subtotal : totalPrice;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount != null ? discountAmount : BigDecimal.ZERO;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount != null ? totalAmount : totalPrice;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
        if (this.totalPrice == null) {
            this.totalPrice = totalAmount;
        }
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getSpecialRequests() {
        return specialRequests;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setStatus(Status status) {
        this.status = status != null ? status.name() : "PENDING";
    }

    public String getCancellationReason() {
        return cancellationReason;
    }

    public void setCancellationReason(String cancellationReason) {
        this.cancellationReason = cancellationReason;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
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

    public String getPropertyAddress() {
        return propertyAddress;
    }

    public void setPropertyAddress(String propertyAddress) {
        this.propertyAddress = propertyAddress;
    }

    public String getRoomImageUrl() {
        return roomImageUrl != null && !roomImageUrl.isEmpty() ? roomImageUrl : "images/img_1.jpg";
    }

    public void setRoomImageUrl(String roomImageUrl) {
        this.roomImageUrl = roomImageUrl;
    }

    public List<BookingRoomItem> getBookingRooms() {
        return bookingRooms;
    }

    public void setBookingRooms(List<BookingRoomItem> bookingRooms) {
        this.bookingRooms = bookingRooms != null ? bookingRooms : new ArrayList<>();
    }

    public Refund getRefund() {
        return refund;
    }

    public void setRefund(Refund refund) {
        this.refund = refund;
    }

    public Payment getPayment() {
        return payment;
    }

    public void setPayment(Payment payment) {
        this.payment = payment;
    }

    public String getPayoutStatus() {
        return payoutStatus != null ? payoutStatus : "UNPAID";
    }

    public void setPayoutStatus(String payoutStatus) {
        this.payoutStatus = payoutStatus;
    }

    public boolean isWithdrawn() {
        return "WITHDRAWN".equalsIgnoreCase(payoutStatus);
    }

    public boolean canWithdraw() {
        return ("CONFIRMED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status)) && !isWithdrawn();
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
        BigDecimal p = getTotalPrice();
        if (p == null) return "0";
        return java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi", "VN")).format(p);
    }

    @Override
    public String toString() {
        return "Booking{"
                + "id=" + id
                + ", bookingCode='" + bookingCode + '\''
                + ", userId=" + userId
                + ", customerName='" + customerName + '\''
                + ", roomId=" + roomId
                + ", checkInDate=" + checkInDate
                + ", checkOutDate=" + checkOutDate
                + ", status='" + status + '\''
                + '}';
    }
}
