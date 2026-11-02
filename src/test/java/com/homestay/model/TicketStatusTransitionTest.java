package com.homestay.model;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests verifying lifecycle status transitions and validation rules for support tickets.
 */
class TicketStatusTransitionTest {

    @Test
    @DisplayName("Admin transitions: NEW -> PROCESSING should be permitted")
    void testAdminNewToProcessing() {
        assertTrue(TicketStatus.NEW.canTransitionTo(TicketStatus.PROCESSING, true, false));
    }

    @Test
    @DisplayName("Admin transitions: PROCESSING -> RESOLVED should be permitted")
    void testAdminProcessingToResolved() {
        assertTrue(TicketStatus.PROCESSING.canTransitionTo(TicketStatus.RESOLVED, true, false));
    }

    @Test
    @DisplayName("Admin transitions: RESOLVED -> PROCESSING should be permitted (reopen)")
    void testAdminResolvedToProcessing() {
        assertTrue(TicketStatus.RESOLVED.canTransitionTo(TicketStatus.PROCESSING, true, false));
    }

    @Test
    @DisplayName("Admin transitions: Direct NEW -> RESOLVED must be rejected")
    void testAdminNewToResolvedRejected() {
        assertFalse(TicketStatus.NEW.canTransitionTo(TicketStatus.RESOLVED, true, false));
    }

    @Test
    @DisplayName("Transitions to same status or null must be rejected")
    void testTransitionToSelfOrNullRejected() {
        assertFalse(TicketStatus.PROCESSING.canTransitionTo(TicketStatus.PROCESSING, true, false));
        assertFalse(TicketStatus.PROCESSING.canTransitionTo(null, true, false));
    }

    @Test
    @DisplayName("Sender transitions: direct status changes by Customer/Host must be rejected")
    void testSenderDirectStatusChangesRejected() {
        assertFalse(TicketStatus.NEW.canTransitionTo(TicketStatus.RESOLVED, false, true));
        assertFalse(TicketStatus.PROCESSING.canTransitionTo(TicketStatus.RESOLVED, false, true));
        assertFalse(TicketStatus.NEW.canTransitionTo(TicketStatus.PROCESSING, false, true));
    }

    @Test
    @DisplayName("Sender follow-up reply: RESOLVED -> PROCESSING is the only sender-triggered reopening")
    void testSenderReopenFromResolvedAllowed() {
        assertTrue(TicketStatus.RESOLVED.canTransitionTo(TicketStatus.PROCESSING, false, true));
    }

    @Test
    @DisplayName("Guest/anonymous: any status transition must be rejected")
    void testAnonymousTransitionsRejected() {
        assertFalse(TicketStatus.NEW.canTransitionTo(TicketStatus.PROCESSING, false, false));
        assertFalse(TicketStatus.RESOLVED.canTransitionTo(TicketStatus.PROCESSING, false, false));
    }

    @Test
    @DisplayName("fromCode: safely parses valid and invalid codes")
    void testFromCode() {
        assertEquals(TicketStatus.NEW, TicketStatus.fromCode("new"));
        assertEquals(TicketStatus.PROCESSING, TicketStatus.fromCode("PROCESSING"));
        assertEquals(TicketStatus.RESOLVED, TicketStatus.fromCode("  resolved  "));
        assertNull(TicketStatus.fromCode("UNKNOWN"));
        assertNull(TicketStatus.fromCode(""));
        assertNull(TicketStatus.fromCode(null));
    }
}
