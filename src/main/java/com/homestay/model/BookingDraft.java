package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * BookingDraft - Represents the in-progress multi-room booking state in session.
 */
public class BookingDraft implements Serializable {
    private static final long serialVersionUID = 1L;

    private List<BookingRoomItem> rooms = new ArrayList<>();
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private String notes;
    private String specialRequests;
    private String voucherCode;
    private BigDecimal discountAmount = BigDecimal.ZERO;

    public BookingDraft() {
    }

    public List<BookingRoomItem> getRooms() {
        return rooms;
    }

    public void setRooms(List<BookingRoomItem> rooms) {
        this.rooms = rooms != null ? rooms : new ArrayList<>();
    }

    public void addRoom(BookingRoomItem item) {
        if (item == null) return;
        // Check if room is already added
        for (int i = 0; i < rooms.size(); i++) {
            if (rooms.get(i).getRoomId() == item.getRoomId()) {
                rooms.set(i, item); // Update with latest dates/guests
                return;
            }
        }
        rooms.add(item);
    }

    public boolean removeRoom(int roomId) {
        return rooms.removeIf(r -> r.getRoomId() == roomId);
    }

    public boolean hasRoom(int roomId) {
        return rooms.stream().anyMatch(r -> r.getRoomId() == roomId);
    }

    public BookingRoomItem getPrimaryRoom() {
        return rooms.isEmpty() ? null : rooms.get(0);
    }

    public BigDecimal getSubtotal() {
        BigDecimal sum = BigDecimal.ZERO;
        for (BookingRoomItem r : rooms) {
            if (r.getSubtotal() != null) {
                sum = sum.add(r.getSubtotal());
            }
        }
        return sum;
    }

    public BigDecimal getTotalPrice() {
        BigDecimal total = getSubtotal().subtract(discountAmount != null ? discountAmount : BigDecimal.ZERO);
        return total.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : total;
    }

    public int getTotalRooms() {
        return rooms.size();
    }

    public int getTotalGuests() {
        int total = 0;
        for (BookingRoomItem r : rooms) {
            total += r.getTotalGuests();
        }
        return total;
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

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
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

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount != null ? discountAmount : BigDecimal.ZERO;
    }
}
