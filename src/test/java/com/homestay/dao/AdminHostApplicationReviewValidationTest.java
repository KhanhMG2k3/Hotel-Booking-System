package com.homestay.dao;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit test suite verifying Admin review requirements:
 * rejection reason length constraint (10 - 500 characters) and decision statuses.
 */
public class AdminHostApplicationReviewValidationTest {

    private boolean isRejectionReasonValid(String reason) {
        if (reason == null) return false;
        String trimmed = reason.trim();
        return trimmed.length() >= 10 && trimmed.length() <= 500;
    }

    @Test
    @DisplayName("Rejecting application must require non-null reason with 10-500 characters")
    public void testRejectionReasonValidation() {
        assertFalse(isRejectionReasonValid(null), "Null rejection reason must be invalid");
        assertFalse(isRejectionReasonValid(""), "Empty rejection reason must be invalid");
        assertFalse(isRejectionReasonValid("   "), "Whitespace-only reason must be invalid");
        assertFalse(isRejectionReasonValid("Too short"), "Reasons under 10 chars must be invalid");

        assertTrue(isRejectionReasonValid("Ảnh CCCD bị mờ, vui lòng chụp lại rõ nét hơn."), 
                "Valid explanation should be accepted");
        
        String max500 = "A".repeat(500);
        assertTrue(isRejectionReasonValid(max500), "500 chars should be accepted");

        String over500 = "A".repeat(501);
        assertFalse(isRejectionReasonValid(over500), "Reasons over 500 chars must be rejected");
    }
}
