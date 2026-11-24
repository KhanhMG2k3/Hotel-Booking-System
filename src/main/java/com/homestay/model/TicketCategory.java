package com.homestay.model;

/**
 * TicketCategory - Standard categorization for support and contact requests.
 */
public enum TicketCategory {
    BOOKING_INQUIRY("Hỗ trợ đặt phòng", "Các vấn đề về tìm phòng, lịch đặt, thay đổi thông tin đặt phòng"),
    PAYMENT_PRICING("Thanh toán & Giá cả", "Các thắc mắc về thanh toán, phụ phí, hóa đơn hoặc hoàn tiền"),
    HOST_ASSISTANCE("Hỗ trợ Chủ nhà (Host)", "Hỗ trợ đăng ký homestay, duyệt phòng, quản lý vận hành đối tác"),
    ACCOUNT_SECURITY("Tài khoản & Bảo mật", "Hỗ trợ thông tin cá nhân, mật khẩu, đăng nhập, xác thực 2FA"),
    TECHNICAL_ISSUE("Sự cố kỹ thuật", "Báo cáo lỗi hiển thị, sự cố khi sử dụng trang web"),
    GENERAL_FEEDBACK("Góp ý & Khiếu nại", "Đóng góp ý kiến nâng cao chất lượng dịch vụ hoặc phản ánh dịch vụ");

    private final String displayName;
    private final String description;

    TicketCategory(String displayName, String description) {
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
     * Checks if the given code matches a known category.
     */
    public static boolean isValid(String code) {
        return fromCode(code) != null;
    }

    /**
     * Safely parses a string into TicketCategory.
     */
    public static TicketCategory fromCode(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }
        try {
            return TicketCategory.valueOf(code.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
