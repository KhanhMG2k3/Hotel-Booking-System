package com.homestay.controller;

import com.homestay.dao.BookingDAO;
import com.homestay.model.BookingDraft;
import com.homestay.model.BookingRoomItem;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import static org.junit.jupiter.api.Assertions.*;

public class BookingControllerTest {

    @Test
    public void testMinStayValidation() {
        LocalDate checkIn = LocalDate.now().plusDays(1);
        LocalDate checkOutSameDay = checkIn;
        long nights = ChronoUnit.DAYS.between(checkIn, checkOutSameDay);

        assertTrue(nights < BookingController.MIN_STAY_NIGHTS, "Same-day checkout should violate min stay");

        LocalDate checkOutValid = checkIn.plusDays(1);
        long validNights = ChronoUnit.DAYS.between(checkIn, checkOutValid);
        assertEquals(1, validNights);
        assertTrue(validNights >= BookingController.MIN_STAY_NIGHTS, "1 night should satisfy min stay");
    }

    @Test
    public void testMaxStayValidation() {
        LocalDate checkIn = LocalDate.now().plusDays(1);
        LocalDate checkOutExceed = checkIn.plusDays(31);
        long nightsExceed = ChronoUnit.DAYS.between(checkIn, checkOutExceed);

        assertTrue(nightsExceed > BookingController.MAX_STAY_NIGHTS, "31 nights should exceed max stay limit");

        LocalDate checkOutValid = checkIn.plusDays(30);
        long validNights = ChronoUnit.DAYS.between(checkIn, checkOutValid);
        assertEquals(30, validNights);
        assertTrue(validNights <= BookingController.MAX_STAY_NIGHTS, "30 nights should be within max stay limit");
    }

    @Test
    public void testBookingDraftMultiRoomCalculations() {
        BookingDraft draft = new BookingDraft();

        Date in = Date.valueOf(LocalDate.now().plusDays(2));
        Date out = Date.valueOf(LocalDate.now().plusDays(5));
        int nights = 3;

        // Room 1: 1,000,000 VNĐ x 3 nights = 3,000,000 VNĐ
        BookingRoomItem room1 = new BookingRoomItem(
                101, "Phòng Deluxe Hướng Biển", "Deluxe", "img1.jpg",
                "Sogo Đà Nẵng", in, out, 2, 0, 2, nights,
                BigDecimal.valueOf(1000000), BigDecimal.valueOf(3000000)
        );
        draft.addRoom(room1);

        assertEquals(1, draft.getTotalRooms());
        assertEquals(2, draft.getTotalGuests());
        assertEquals(new BigDecimal("3000000"), draft.getSubtotal());
        assertEquals(new BigDecimal("3000000"), draft.getTotalPrice());

        // Room 2: 1,500,000 VNĐ x 3 nights = 4,500,000 VNĐ
        BookingRoomItem room2 = new BookingRoomItem(
                102, "Phòng Suite Gia Đình", "Family Suite", "img2.jpg",
                "Sogo Đà Nẵng", in, out, 3, 1, 4, nights,
                BigDecimal.valueOf(1500000), BigDecimal.valueOf(4500000)
        );
        draft.addRoom(room2);

        assertEquals(2, draft.getTotalRooms());
        assertEquals(6, draft.getTotalGuests()); // 2 + 3 + 1
        assertEquals(new BigDecimal("7500000"), draft.getSubtotal());
        assertEquals(new BigDecimal("7500000"), draft.getTotalPrice());

        // Apply discount: 500,000 VNĐ
        draft.setDiscountAmount(BigDecimal.valueOf(500000));
        assertEquals(new BigDecimal("7000000"), draft.getTotalPrice());

        // Remove Room 1
        draft.removeRoom(101);
        assertEquals(1, draft.getTotalRooms());
        assertEquals(102, draft.getPrimaryRoom().getRoomId());
        assertEquals(new BigDecimal("4500000"), draft.getSubtotal());
        assertEquals(new BigDecimal("4000000"), draft.getTotalPrice());
    }

    @Test
    public void testBookingCodeGenerationFormat() {
        String code = BookingDAO.generateBookingCode();
        assertNotNull(code);
        assertTrue(code.startsWith("BK-"), "Booking code must start with BK- prefix");
        assertEquals(14, code.length(), "Booking code format should be BK-yyMMdd-XXXX");
    }
}
