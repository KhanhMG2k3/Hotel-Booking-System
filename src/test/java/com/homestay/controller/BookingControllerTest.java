package com.homestay.controller;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class BookingControllerTest {

    private final BookingController controller = new BookingController();

    @Test
    @DisplayName("Parses bootstrap-datepicker 'd MM, yyyy' format (e.g. '4 October, 2026')")
    void testParseDatepickerFullMonthFormat() {
        LocalDate date = controller.parseBookingDate("4 October, 2026");

        assertNotNull(date);
        assertEquals(2026, date.getYear());
        assertEquals(10, date.getMonthValue());
        assertEquals(4, date.getDayOfMonth());

        LocalDate date2 = controller.parseBookingDate("15 November, 2026");
        assertEquals(2026, date2.getYear());
        assertEquals(11, date2.getMonthValue());
        assertEquals(15, date2.getDayOfMonth());
    }

    @Test
    @DisplayName("Parses short month format 'd MMM, yyyy' (e.g. '4 Oct, 2026')")
    void testParseDatepickerShortMonthFormat() {
        LocalDate date = controller.parseBookingDate("4 Oct, 2026");

        assertNotNull(date);
        assertEquals(2026, date.getYear());
        assertEquals(10, date.getMonthValue());
        assertEquals(4, date.getDayOfMonth());
    }

    @Test
    @DisplayName("Parses Vietnamese format 'dd/MM/yyyy' or 'd/M/yyyy' (e.g. '30/10/2026')")
    void testParseVietnameseFormat() {
        LocalDate date = controller.parseBookingDate("30/10/2026");

        assertNotNull(date);
        assertEquals(2026, date.getYear());
        assertEquals(10, date.getMonthValue());
        assertEquals(30, date.getDayOfMonth());

        LocalDate dateSingleDigit = controller.parseBookingDate("5/6/2026");
        assertEquals(2026, dateSingleDigit.getYear());
        assertEquals(6, dateSingleDigit.getMonthValue());
        assertEquals(5, dateSingleDigit.getDayOfMonth());
    }

    @Test
    @DisplayName("Parses standard ISO / HTML5 format 'yyyy-MM-dd' (e.g. '2026-10-30')")
    void testParseIsoFormat() {
        LocalDate date = controller.parseBookingDate("2026-10-30");

        assertNotNull(date);
        assertEquals(2026, date.getYear());
        assertEquals(10, date.getMonthValue());
        assertEquals(30, date.getDayOfMonth());
    }

    @Test
    @DisplayName("Parses dash format 'dd-MM-yyyy' (e.g. '30-10-2026')")
    void testParseDashFormat() {
        LocalDate date = controller.parseBookingDate("30-10-2026");

        assertNotNull(date);
        assertEquals(2026, date.getYear());
        assertEquals(10, date.getMonthValue());
        assertEquals(30, date.getDayOfMonth());
    }

    @Test
    @DisplayName("Throws DateTimeParseException when date string is null, empty or invalid")
    void testParseInvalidDateThrowsException() {
        assertThrows(DateTimeParseException.class, () -> controller.parseBookingDate(null));
        assertThrows(DateTimeParseException.class, () -> controller.parseBookingDate("   "));
        assertThrows(DateTimeParseException.class, () -> controller.parseBookingDate("invalid-date-string"));
        assertThrows(DateTimeParseException.class, () -> controller.parseBookingDate("32/13/2026"));
    }
}

