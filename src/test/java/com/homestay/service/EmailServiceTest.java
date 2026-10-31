package com.homestay.service;

import com.homestay.model.Booking;
import com.homestay.model.Payment;
import com.homestay.model.Room;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.concurrent.CompletableFuture;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class EmailServiceTest {

    private EmailService emailService;

    @BeforeEach
    void setUp() {
        emailService = EmailService.getInstance();
    }

    @Test
    @DisplayName("sendBookingConfirmationEmail returns false when booking is null")
    void testBookingNull() {
        boolean result = emailService.sendBookingConfirmationEmail(null, null, null);
        assertFalse(result, "Should return false for null booking");
    }

    @Test
    @DisplayName("sendBookingConfirmationEmail returns false when customer email is blank")
    void testEmailBlank() {
        Booking booking = new Booking();
        booking.setCustomerEmail("");
        boolean result = emailService.sendBookingConfirmationEmail(booking, null, null);
        assertFalse(result, "Should return false for empty recipient email");
    }

    @Test
    @DisplayName("sendBookingConfirmationEmail dispatches successfully in simulated mode")
    void testSuccessfulSimulation() {
        Booking booking = new Booking();
        booking.setId(99);
        booking.setBookingCode("BK-TEST9999");
        booking.setCustomerName("Nguyen Van A");
        booking.setCustomerEmail("tester@gmail.com");
        booking.setCheckInDate(Date.valueOf(LocalDate.now()));
        booking.setCheckOutDate(Date.valueOf(LocalDate.now().plusDays(2)));
        booking.setAdults(2);
        booking.setChildren(1);
        booking.setTotalAmount(new BigDecimal("500000"));

        Payment payment = new Payment();
        payment.setTransactionId("TRX-TEST-12345");

        Room room = new Room();
        room.setRoomName("Deluxe River View");
        room.setPropertyName("Sogo Riverside Homestay");
        room.setAddress("123 Bach Dang, Da Nang");

        boolean result = emailService.sendBookingConfirmationEmail(booking, payment, room);
        assertTrue(result, "Simulated email dispatch should succeed");
    }

    @Test
    @DisplayName("sendBookingConfirmationEmailAsync runs without blocking or exception")
    void testAsyncDispatch() throws Exception {
        Booking booking = new Booking();
        booking.setId(100);
        booking.setBookingCode("BK-ASYNC-100");
        booking.setCustomerName("Tran Thi B");
        booking.setCustomerEmail("customer@example.com");
        booking.setCheckInDate(Date.valueOf(LocalDate.now()));
        booking.setCheckOutDate(Date.valueOf(LocalDate.now().plusDays(1)));
        booking.setAdults(1);
        booking.setTotalAmount(new BigDecimal("200000"));

        CompletableFuture<Boolean> future = emailService.sendBookingConfirmationEmailAsync(booking, null, null);
        assertNotNull(future, "Async future should not be null");
        Boolean result = future.get();
        assertTrue(result, "Async execution should complete successfully");
    }
}

