package com.homestay.dao;

import com.homestay.model.PartnerApplicationRoom;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit test suite verifying room validation rules including price limits,
 * guest capacities, bed counts, and amenities.
 */
public class PartnerApplicationRoomValidationTest {

    private PartnerApplicationRoomDAO roomDAO;

    @BeforeEach
    public void setUp() {
        roomDAO = new PartnerApplicationRoomDAO();
    }

    private PartnerApplicationRoom createValidRoom() {
        PartnerApplicationRoom room = new PartnerApplicationRoom();
        room.setRoomName("Deluxe Ocean View");
        room.setRoomType("DOUBLE");
        room.setPricePerNight(new BigDecimal("500000.00"));
        room.setMaxGuests(2);
        room.setBedCount(1);
        room.setBathroomCount(1);
        room.setSortOrder(0);
        List<String> amenities = new ArrayList<>();
        amenities.add("Wi-Fi");
        amenities.add("Air conditioning");
        room.setAmenities(amenities);
        return room;
    }

    @Test
    @DisplayName("Valid room should have no validation errors")
    public void testValidRoom() {
        PartnerApplicationRoom room = createValidRoom();
        String error = roomDAO.getValidationError(room);
        assertNull(error, "Valid room should return null validation error");
    }

    @Test
    @DisplayName("Room name must be present and <= 120 chars")
    public void testRoomNameValidation() {
        PartnerApplicationRoom room = createValidRoom();
        
        room.setRoomName(null);
        assertEquals("Enter a room name between 1 and 120 characters.", roomDAO.getValidationError(room));

        room.setRoomName("   ");
        assertEquals("Enter a room name between 1 and 120 characters.", roomDAO.getValidationError(room));

        room.setRoomName("A".repeat(121));
        assertEquals("Enter a room name between 1 and 120 characters.", roomDAO.getValidationError(room));

        room.setRoomName("Standard Double Room");
        assertNull(roomDAO.getValidationError(room));
    }

    @Test
    @DisplayName("Room type must be one of allowed types")
    public void testRoomTypeValidation() {
        PartnerApplicationRoom room = createValidRoom();

        room.setRoomType("INVALID_TYPE");
        assertEquals("Choose a valid room type.", roomDAO.getValidationError(room));

        room.setRoomType("TWIN");
        assertNull(roomDAO.getValidationError(room));
    }

    @Test
    @DisplayName("Price per night must be > 0 and have at most 2 decimal places")
    public void testPricePerNightValidation() {
        PartnerApplicationRoom room = createValidRoom();

        room.setPricePerNight(BigDecimal.ZERO);
        assertEquals("Enter a nightly price greater than 0, with no more than 2 decimal places.", roomDAO.getValidationError(room));

        room.setPricePerNight(new BigDecimal("-100.00"));
        assertEquals("Enter a nightly price greater than 0, with no more than 2 decimal places.", roomDAO.getValidationError(room));

        // 3 decimal places should be rejected
        room.setPricePerNight(new BigDecimal("500000.123"));
        assertEquals("Enter a nightly price greater than 0, with no more than 2 decimal places.", roomDAO.getValidationError(room));

        // Integer price or 2 decimal places should be accepted
        room.setPricePerNight(new BigDecimal("750000"));
        assertNull(roomDAO.getValidationError(room));

        room.setPricePerNight(new BigDecimal("1200000.50"));
        assertNull(roomDAO.getValidationError(room));
    }

    @Test
    @DisplayName("Guest, bed, and bathroom counts must be >= 1")
    public void testCapacityCountsValidation() {
        PartnerApplicationRoom room = createValidRoom();

        room.setMaxGuests(0);
        assertEquals("Maximum guests must be between 1 and 65,535.", roomDAO.getValidationError(room));

        room.setMaxGuests(2);
        room.setBedCount(0);
        assertEquals("Number of beds must be between 1 and 65,535.", roomDAO.getValidationError(room));

        room.setBedCount(1);
        room.setBathroomCount(0);
        assertEquals("Bathrooms must be between 1 and 65,535.", roomDAO.getValidationError(room));
    }
}
