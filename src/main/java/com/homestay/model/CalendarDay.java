package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Represents a single day in the Host Booking Calendar month view.
 * Encapsulates booked vs. available status for a single room or across all rooms.
 */
public class CalendarDay implements Serializable {
    private static final long serialVersionUID = 1L;

    private LocalDate date;
    private int dayOfMonth;
    private int dayOfWeek; // 1 = Monday ... 7 = Sunday
    private boolean today;
    private boolean past;
    private boolean currentMonth;

    // Single room view details
    private boolean booked;
    private boolean available;
    private boolean checkIn;
    private boolean checkOut;
    private Booking booking;
    private BigDecimal price;

    // All rooms view details
    private int totalRooms;
    private int bookedRoomsCount;
    private int availableRoomsCount;
    private List<RoomStatusItem> roomStatuses = new ArrayList<>();

    public CalendarDay() {
    }

    public CalendarDay(LocalDate date, boolean currentMonth) {
        this.date = date;
        this.dayOfMonth = date.getDayOfMonth();
        this.dayOfWeek = date.getDayOfWeek().getValue();
        this.currentMonth = currentMonth;
        LocalDate now = LocalDate.now();
        this.today = date.equals(now);
        this.past = date.isBefore(now);
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public int getDayOfMonth() {
        return dayOfMonth;
    }

    public void setDayOfMonth(int dayOfMonth) {
        this.dayOfMonth = dayOfMonth;
    }

    public int getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(int dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public boolean isToday() {
        return today;
    }

    public void setToday(boolean today) {
        this.today = today;
    }

    public boolean isPast() {
        return past;
    }

    public void setPast(boolean past) {
        this.past = past;
    }

    public boolean isCurrentMonth() {
        return currentMonth;
    }

    public void setCurrentMonth(boolean currentMonth) {
        this.currentMonth = currentMonth;
    }

    public boolean isBooked() {
        return booked;
    }

    public void setBooked(boolean booked) {
        this.booked = booked;
    }

    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }

    public boolean isCheckIn() {
        return checkIn;
    }

    public void setCheckIn(boolean checkIn) {
        this.checkIn = checkIn;
    }

    public boolean isCheckOut() {
        return checkOut;
    }

    public void setCheckOut(boolean checkOut) {
        this.checkOut = checkOut;
    }

    public Booking getBooking() {
        return booking;
    }

    public void setBooking(Booking booking) {
        this.booking = booking;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getTotalRooms() {
        return totalRooms;
    }

    public void setTotalRooms(int totalRooms) {
        this.totalRooms = totalRooms;
    }

    public int getBookedRoomsCount() {
        return bookedRoomsCount;
    }

    public void setBookedRoomsCount(int bookedRoomsCount) {
        this.bookedRoomsCount = bookedRoomsCount;
    }

    public int getAvailableRoomsCount() {
        return availableRoomsCount;
    }

    public void setAvailableRoomsCount(int availableRoomsCount) {
        this.availableRoomsCount = availableRoomsCount;
    }

    public List<RoomStatusItem> getRoomStatuses() {
        return roomStatuses;
    }

    public void setRoomStatuses(List<RoomStatusItem> roomStatuses) {
        this.roomStatuses = roomStatuses;
    }

    /** Status item for each room in all-rooms mode. */
    public static class RoomStatusItem implements Serializable {
        private static final long serialVersionUID = 1L;

        private Room room;
        private boolean booked;
        private boolean checkIn;
        private boolean checkOut;
        private Booking booking;

        public RoomStatusItem() {
        }

        public RoomStatusItem(Room room, boolean booked, Booking booking, boolean checkIn, boolean checkOut) {
            this.room = room;
            this.booked = booked;
            this.booking = booking;
            this.checkIn = checkIn;
            this.checkOut = checkOut;
        }

        public Room getRoom() {
            return room;
        }

        public void setRoom(Room room) {
            this.room = room;
        }

        public boolean isBooked() {
            return booked;
        }

        public void setBooked(boolean booked) {
            this.booked = booked;
        }

        public boolean isCheckIn() {
            return checkIn;
        }

        public void setCheckIn(boolean checkIn) {
            this.checkIn = checkIn;
        }

        public boolean isCheckOut() {
            return checkOut;
        }

        public void setCheckOut(boolean checkOut) {
            this.checkOut = checkOut;
        }

        public Booking getBooking() {
            return booking;
        }

        public void setBooking(Booking booking) {
            this.booking = booking;
        }
    }
}

