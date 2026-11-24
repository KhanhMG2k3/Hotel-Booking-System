package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;

/**
 * BookingRoomItem - Represents an individual room item in a multi-room booking.
 */
public class BookingRoomItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int bookingRoomId;
    private int bookingId;
    private int roomId;
    private String roomName;
    private String roomTypeName;
    private String imageUrl;
    private String propertyName;
    private Date checkInDate;
    private Date checkOutDate;
    private int adults = 1;
    private int children = 0;
    private int capacity = 2;
    private int numberOfNights = 1;
    private BigDecimal pricePerNight = BigDecimal.ZERO;
    private BigDecimal subtotal = BigDecimal.ZERO;

    public BookingRoomItem() {
    }

    public BookingRoomItem(int roomId, String roomName, String roomTypeName, String imageUrl,
                           String propertyName, Date checkInDate, Date checkOutDate,
                           int adults, int children, int capacity, int numberOfNights,
                           BigDecimal pricePerNight, BigDecimal subtotal) {
        this.roomId = roomId;
        this.roomName = roomName;
        this.roomTypeName = roomTypeName;
        this.imageUrl = imageUrl;
        this.propertyName = propertyName;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.adults = adults;
        this.children = children;
        this.capacity = capacity;
        this.numberOfNights = numberOfNights;
        this.pricePerNight = pricePerNight;
        this.subtotal = subtotal;
    }

    public int getBookingRoomId() {
        return bookingRoomId;
    }

    public void setBookingRoomId(int bookingRoomId) {
        this.bookingRoomId = bookingRoomId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomTypeName() {
        return roomTypeName;
    }

    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getPropertyName() {
        return propertyName;
    }

    public void setPropertyName(String propertyName) {
        this.propertyName = propertyName;
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

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getNumberOfNights() {
        return numberOfNights;
    }

    public void setNumberOfNights(int numberOfNights) {
        this.numberOfNights = numberOfNights;
    }

    public BigDecimal getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(BigDecimal pricePerNight) {
        this.pricePerNight = pricePerNight;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public int getTotalGuests() {
        return adults + children;
    }
}
