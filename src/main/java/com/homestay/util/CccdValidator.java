package com.homestay.util;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * CccdValidator - Kiểm tra và giải mã Số Căn cước công dân (CCCD) 12 chữ số
 * theo quy chuẩn của Bộ Công an Việt Nam.
 *
 * Cấu trúc CCCD 12 số:
 * - 3 số đầu: Mã tỉnh/thành phố trực thuộc TW (001 - 096, 63 tỉnh thành)
 * - 1 số tiếp theo: Mã thế kỷ sinh và giới tính (0-9)
 *   + Thế kỷ 20 (sinh 1900-1999): Nam 0, Nữ 1
 *   + Thế kỷ 21 (sinh 2000-2099): Nam 2, Nữ 3
 *   + Thế kỷ 22 (sinh 2100-2199): Nam 4, Nữ 5
 *   + Thế kỷ 23 (sinh 2200-2299): Nam 6, Nữ 7
 *   + Thế kỷ 24 (sinh 2300-2399): Nam 8, Nữ 9
 * - 2 số tiếp theo: 2 số cuối năm sinh (00-99)
 * - 6 số cuối: Dãy số định danh ngẫu nhiên (000001 - 999999)
 */
public final class CccdValidator {

    private static final Map<String, String> PROVINCE_MAP;

    static {
        Map<String, String> map = new HashMap<>();
        map.put("001", "Hà Nội");
        map.put("002", "Hà Giang");
        map.put("004", "Cao Bằng");
        map.put("006", "Bắc Kạn");
        map.put("008", "Tuyên Quang");
        map.put("010", "Lào Cai");
        map.put("011", "Điện Biên");
        map.put("012", "Lai Châu");
        map.put("014", "Sơn La");
        map.put("015", "Yên Bái");
        map.put("017", "Hòa Bình");
        map.put("019", "Thái Nguyên");
        map.put("020", "Lạng Sơn");
        map.put("022", "Quảng Ninh");
        map.put("024", "Bắc Giang");
        map.put("025", "Phú Thọ");
        map.put("026", "Vĩnh Phúc");
        map.put("027", "Bắc Ninh");
        map.put("030", "Hải Dương");
        map.put("031", "Hải Phòng");
        map.put("033", "Hưng Yên");
        map.put("034", "Thái Bình");
        map.put("035", "Hà Nam");
        map.put("036", "Nam Định");
        map.put("037", "Ninh Bình");
        map.put("038", "Thanh Hóa");
        map.put("040", "Nghệ An");
        map.put("042", "Hà Tĩnh");
        map.put("044", "Quảng Bình");
        map.put("045", "Quảng Trị");
        map.put("046", "Thừa Thiên Huế");
        map.put("048", "Đà Nẵng");
        map.put("049", "Quảng Nam");
        map.put("051", "Quảng Ngãi");
        map.put("052", "Bình Định");
        map.put("054", "Phú Yên");
        map.put("056", "Khánh Hòa");
        map.put("058", "Ninh Thuận");
        map.put("060", "Bình Thuận");
        map.put("062", "Kon Tum");
        map.put("064", "Gia Lai");
        map.put("066", "Đắk Lắk");
        map.put("067", "Đắk Nông");
        map.put("068", "Lâm Đồng");
        map.put("070", "Bình Phước");
        map.put("072", "Tây Ninh");
        map.put("074", "Bình Dương");
        map.put("075", "Đồng Nai");
        map.put("077", "Bà Rịa - Vũng Tàu");
        map.put("079", "TP. Hồ Chí Minh");
        map.put("080", "Long An");
        map.put("082", "Tiền Giang");
        map.put("083", "Bến Tre");
        map.put("084", "Trà Vinh");
        map.put("086", "Vĩnh Long");
        map.put("087", "Đồng Tháp");
        map.put("089", "An Giang");
        map.put("091", "Kiên Giang");
        map.put("092", "Cần Thơ");
        map.put("093", "Hậu Giang");
        map.put("094", "Sóc Trăng");
        map.put("095", "Bạc Liêu");
        map.put("096", "Cà Mau");
        PROVINCE_MAP = Collections.unmodifiableMap(map);
    }

    private CccdValidator() {
    }

    /**
     * Kiểm tra tính hợp lệ của số CCCD 12 chữ số.
     * @param cccd Chuỗi số CCCD cần kiểm tra
     * @return true nếu hợp lệ, ngược lại false
     */
    public static boolean isValidCccd(String cccd) {
        return getValidationError(cccd) == null;
    }

    /**
     * Trả về thông báo lỗi cụ thể nếu số CCCD không hợp lệ, hoặc null nếu hợp lệ.
     * @param cccd Chuỗi số CCCD cần kiểm tra
     * @return Chuỗi mô tả lỗi hoặc null nếu hợp lệ
     */
    public static String getValidationError(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return "Số CCCD không được để trống.";
        }
        String clean = cccd.trim();
        if (!clean.matches("^\\d+$")) {
            return "Số CCCD chỉ được chứa các chữ số (0-9).";
        }
        if (clean.length() != 12) {
            return "Số CCCD phải bao gồm đúng 12 chữ số (hiện tại: " + clean.length() + " số).";
        }
        String provinceCode = clean.substring(0, 3);
        if (!PROVINCE_MAP.containsKey(provinceCode)) {
            return "Mã tỉnh/thành phố (" + provinceCode + ") không tồn tại trên hệ thống CCCD Việt Nam.";
        }
        char genderDigit = clean.charAt(3);
        if (genderDigit < '0' || genderDigit > '9') {
            return "Ký tự giới tính/thế kỷ sinh không hợp lệ.";
        }
        String randomDigits = clean.substring(6);
        if ("000000".equals(randomDigits)) {
            return "Dãy số định danh ngẫu nhiên không hợp lệ.";
        }
        return null;
    }

    /**
     * Lấy tên tỉnh/thành phố cấp theo 3 chữ số đầu của số CCCD.
     * @param cccd Chuỗi số CCCD
     * @return Tên tỉnh thành hoặc null nếu không xác định
     */
    public static String getProvinceName(String cccd) {
        if (cccd == null || cccd.trim().length() < 3) return null;
        return PROVINCE_MAP.get(cccd.trim().substring(0, 3));
    }

    /**
     * Lấy giới tính (Nam / Nữ) từ số CCCD.
     * @param cccd Chuỗi số CCCD
     * @return "Nam", "Nữ" hoặc null nếu không xác định
     */
    public static String getGender(String cccd) {
        if (cccd == null || cccd.trim().length() < 4) return null;
        String clean = cccd.trim();
        int digit = clean.charAt(3) - '0';
        if (digit < 0 || digit > 9) return null;
        return (digit % 2 == 0) ? "Nam" : "Nữ";
    }

    /**
     * Lấy năm sinh từ số CCCD.
     * @param cccd Chuỗi số CCCD
     * @return Năm sinh (Integer) hoặc null nếu không hợp lệ
     */
    public static Integer getBirthYear(String cccd) {
        if (cccd == null || cccd.trim().length() < 6) return null;
        try {
            String clean = cccd.trim();
            int digit = clean.charAt(3) - '0';
            int centuryBase = 1900 + (digit / 2) * 100;
            int twoDigitYear = Integer.parseInt(clean.substring(4, 6));
            return centuryBase + twoDigitYear;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}

