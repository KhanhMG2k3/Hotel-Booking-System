package com.homestay.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests validating support ticket category codes and mapping helpers.
 */
class TicketCategoryTest {

    @Test
    @DisplayName("Verify valid categories exist with display names")
    void testCategoriesExist() {
        assertNotNull(TicketCategory.BOOKING_INQUIRY.getDisplayName());
        assertNotNull(TicketCategory.PAYMENT_PRICING.getDisplayName());
        assertNotNull(TicketCategory.HOST_ASSISTANCE.getDisplayName());
        assertNotNull(TicketCategory.ACCOUNT_SECURITY.getDisplayName());
        assertNotNull(TicketCategory.TECHNICAL_ISSUE.getDisplayName());
        assertNotNull(TicketCategory.GENERAL_FEEDBACK.getDisplayName());
    }

    @Test
    @DisplayName("isValid: returns true for recognized categories")
    void testIsValid() {
        assertTrue(TicketCategory.isValid("BOOKING_INQUIRY"));
        assertTrue(TicketCategory.isValid("booking_inquiry"));
        assertTrue(TicketCategory.isValid("GENERAL_FEEDBACK"));
        assertFalse(TicketCategory.isValid("NON_EXISTING_CAT"));
        assertFalse(TicketCategory.isValid(""));
        assertFalse(TicketCategory.isValid(null));
    }

    @Test
    @DisplayName("fromCode: safely maps strings to category constants")
    void testFromCode() {
        assertEquals(TicketCategory.HOST_ASSISTANCE, TicketCategory.fromCode("host_assistance"));
        assertEquals(TicketCategory.TECHNICAL_ISSUE, TicketCategory.fromCode("  TECHNICAL_ISSUE "));
        assertNull(TicketCategory.fromCode("INVALID"));
        assertNull(TicketCategory.fromCode(null));
    }
}
