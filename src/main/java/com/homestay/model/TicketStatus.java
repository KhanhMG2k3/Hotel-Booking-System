package com.homestay.model;

/**
 * TicketStatus - Lifecycle states for Contact and Support tickets.
 * Supported states: NEW, PROCESSING, RESOLVED.
 */
public enum TicketStatus {
    NEW("Mới tiếp nhận", "Chờ quản trị viên tiếp nhận"),
    PROCESSING("Đang xử lý", "Đang được quản trị viên xử lý và phản hồi"),
    RESOLVED("Đã giải quyết", "Yêu cầu đã được xử lý xong");

    private final String displayName;
    private final String description;

    TicketStatus(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }

    /**
     * Checks whether a status transition is permitted based on business rules.
     *
     * @param target the target status
     * @param isAdmin whether the actor is an Admin
     * @param isSender whether the actor is the original ticket sender (Customer/Host)
     * @return true if the transition is allowed
     */
    public boolean canTransitionTo(TicketStatus target, boolean isAdmin, boolean isSender) {
        if (target == null || target == this) {
            return false;
        }

        // Customer/Host cannot directly execute state transitions via requests
        if (!isAdmin && !isSender) {
            return false;
        }

        if (isSender) {
            // Senders can only trigger reopening from RESOLVED to PROCESSING by sending a follow-up reply
            return this == RESOLVED && target == PROCESSING;
        }

        // Admin transitions
        if (isAdmin) {
            switch (this) {
                case NEW:
                    // Admin can accept/claim a NEW ticket to PROCESSING
                    return target == PROCESSING;
                case PROCESSING:
                    // Admin can resolve a ticket
                    return target == RESOLVED;
                case RESOLVED:
                    // Admin can explicitly reopen if further investigation is needed
                    return target == PROCESSING;
                default:
                    return false;
            }
        }

        return false;
    }

    /**
     * Safely parses a string into TicketStatus.
     *
     * @param code string representation (case-insensitive)
     * @return TicketStatus or null if invalid
     */
    public static TicketStatus fromCode(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }
        try {
            return TicketStatus.valueOf(code.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
