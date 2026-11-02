package com.homestay.dao;

import com.homestay.model.TermSection;
import com.homestay.model.TermSetting;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

/**
 * TermDAO kế thừa BaseDAO chuẩn của Sogo Homestay
 */
public class TermDAO extends BaseDAO {

    /**
     * Lấy tiêu đề chính và ngày cập nhật
     */
    public TermSetting getSetting() {
        String sql = "SELECT * FROM terms_setting LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                TermSetting s = new TermSetting();
                s.setId(rs.getInt("id"));
                s.setMainTitle(rs.getString("main_title"));
                s.setLastUpdated(rs.getString("last_updated"));
                return s;
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Chưa lấy được terms_setting từ DB. Dùng dữ liệu mặc định.", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return new TermSetting("Điều Khoản Dịch Vụ & Quy Định Lưu Trú - Sogo Homestay", "14/10/2026 00:23");
    }

    /**
     * Lấy danh sách các mục điều khoản (Tự động nạp 5 mục mẫu nếu DB đang trống)
     */
    /**
     * Lấy danh sách các mục điều khoản (Tự động khôi phục nội dung cũ nếu CSDL bị rỗng)
     */
    public List<TermSection> getAllSections() {
        List<TermSection> list = new ArrayList<>();
        String sql = "SELECT * FROM term_sections ORDER BY section_order ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                TermSection sec = new TermSection();
                sec.setId(rs.getInt("id"));
                sec.setSectionOrder(rs.getInt("section_order"));
                sec.setSidebarTitle(rs.getString("sidebar_title"));
                sec.setContentTitle(rs.getString("content_title"));
                sec.setContentType(rs.getString("content_type"));
                sec.setContentText(rs.getString("content_text"));
                sec.setTableJson(rs.getString("table_json"));
                sec.setCalloutText(rs.getString("callout_text"));
                sec.setCalloutType(rs.getString("callout_type"));
                list.add(sec);
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Lỗi lấy term_sections từ DB.", e);
        } finally {
            closeResources(conn, ps, rs);
        }

        List<TermSection> defaultList = getDefaultSections();

        // NẾU DATABASE RỖNG HOẶC MỤC BỊ MẤT NỘI DUNG -> TỰ ĐỘNG KHÔI PHỤC LẠI NỘI DUNG CŨ
        if (list.isEmpty()) {
            return defaultList;
        }

        // Kiểm tra từng mục, nếu contentText bị rỗng thì khôi phục từ default
        for (int i = 0; i < list.size(); i++) {
            TermSection sec = list.get(i);
            boolean isBlank = sec.getContentText() == null || sec.getContentText().trim().isEmpty() || sec.getContentText().trim().equals("[]");
            if (isBlank && i < defaultList.size()) {
                TermSection def = defaultList.get(i);
                sec.setContentText(def.getContentText());
                sec.setTableJson(def.getTableJson());
                sec.setCalloutText(def.getCalloutText());
                sec.setCalloutType(def.getCalloutType());
            }
        }

        return list;
    }

    /**
     * Lưu toàn bộ các mục và tự động đánh lại số thứ tự (Re-index 1..N)
     */
    public boolean saveAllTerms(TermSetting setting, List<TermSection> sections) {
        ensureTablesExist();

        String updateSettingSql = "INSERT INTO terms_setting (id, main_title, last_updated) VALUES (1, ?, ?) "
                                + "ON DUPLICATE KEY UPDATE main_title = VALUES(main_title), last_updated = VALUES(last_updated)";
        String clearSectionsSql = "DELETE FROM term_sections";
        String insertSectionSql = "INSERT INTO term_sections (section_order, sidebar_title, content_title, content_type, content_text, table_json, callout_text, callout_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psSet = null;
        PreparedStatement psClear = null;
        PreparedStatement psIns = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Cập nhật tiêu đề chính
            psSet = conn.prepareStatement(updateSettingSql);
            psSet.setString(1, setting.getMainTitle());
            psSet.setString(2, setting.getLastUpdated());
            psSet.executeUpdate();

            // 2. Xóa các mục cũ
            psClear = conn.prepareStatement(clearSectionsSql);
            psClear.executeUpdate();

            // 3. Insert lại và re-index thứ tự liên tiếp 1..N
            psIns = conn.prepareStatement(insertSectionSql);
            for (int i = 0; i < sections.size(); i++) {
                TermSection s = sections.get(i);
                psIns.setInt(1, i + 1);
                psIns.setString(2, s.getSidebarTitle());
                psIns.setString(3, s.getContentTitle());
                psIns.setString(4, s.getContentType());
                psIns.setString(5, s.getContentText());
                psIns.setString(6, s.getTableJson());
                psIns.setString(7, s.getCalloutText());
                psIns.setString(8, s.getCalloutType());
                psIns.addBatch();
            }
            psIns.executeBatch();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            logger.log(Level.SEVERE, "Lỗi khi lưu terms", e);
            return false;
        } finally {
            if (psSet != null) try { psSet.close(); } catch (SQLException ignored) {}
            if (psClear != null) try { psClear.close(); } catch (SQLException ignored) {}
            if (psIns != null) try { psIns.close(); } catch (SQLException ignored) {}
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    private void ensureTablesExist() {
        String sql1 = "CREATE TABLE IF NOT EXISTS terms_setting (id INT PRIMARY KEY AUTO_INCREMENT, main_title VARCHAR(255) NOT NULL, last_updated VARCHAR(50) NOT NULL)";
        String sql2 = "CREATE TABLE IF NOT EXISTS term_sections ("
                    + "id INT PRIMARY KEY AUTO_INCREMENT, section_order INT NOT NULL, "
                    + "sidebar_title VARCHAR(255) NOT NULL, content_title VARCHAR(255) NOT NULL, "
                    + "content_type VARCHAR(20) NOT NULL, content_text MEDIUMTEXT NOT NULL, "
                    + "table_json MEDIUMTEXT NULL, callout_text MEDIUMTEXT NULL, callout_type VARCHAR(50) DEFAULT 'info')";
        Connection conn = null;
        try {
            conn = getConnection();
            try (Statement st = conn.createStatement()) {
                st.execute(sql1);
                st.execute(sql2);
            }
        } catch (Exception e) {
            logger.log(Level.WARNING, "Không thể tự động tạo bảng (có thể bảng đã có sẵn)", e);
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * Dữ liệu mặc định 5 mục đúng 100% theo 3 ảnh của Sogo Homestay
     */
    private List<TermSection> getDefaultSections() {
        List<TermSection> list = new ArrayList<>();

        TermSection s1 = new TermSection();
        s1.setSectionOrder(1);
        s1.setSidebarTitle("Nhận & Trả Phòng (Check-in/out)");
        s1.setContentTitle("Quy Định Nhận Phòng & Trả Phòng");
        s1.setContentType("list");
        s1.setContentText("• Giờ nhận phòng (Check-in): từ 14:00 của ngày bắt đầu lưu trú.\n• Giờ trả phòng (Check-out): trước 12:00 trưa của ngày kết thúc lưu trú.\n• Nhận phòng sớm / Trả phòng trễ: Tùy thuộc vào tình trạng phòng trống tại thời điểm đó và có thể áp dụng phụ phí theo quy định:\n    - Trả phòng trễ từ 12:00 đến 18:00: Phụ thu 50% tiền phòng 1 đêm.\n    - Trả phòng sau 18:00: Tính 100% tiền phòng 1 đêm.\n• Khách vui lòng xuất trình CCCD/Hộ chiếu hợp lệ của tất cả các khách lưu trú để hoàn tất thủ tục đăng ký tạm trú với cơ quan quản lý.");
        list.add(s1);

        TermSection s2 = new TermSection();
        s2.setSectionOrder(2);
        s2.setSidebarTitle("Thanh Toán & Đặt Cọc");
        s2.setContentTitle("Quy Định Thanh Toán & Đặt Cọc");
        s2.setContentType("mixed");
        s2.setContentText("Nhằm đảm bảo việc giữ phòng, khách hàng cần thực hiện đặt cọc theo tỷ lệ sau:\n\n• Đặt cọc giữ chỗ: Tối thiểu 50% tổng giá trị đơn đặt phòng trong vòng 24 giờ kể từ khi gửi yêu cầu.\n• Thanh toán số tiền còn lại: 50% còn lại được thanh toán trực tiếp tại quầy lễ tân khi làm thủ tục Check-in.\n• Phương thức chấp nhận: Chuyển khoản ngân hàng trực tuyến (QR Pay), thẻ tín dụng/ghi nợ nội địa và tiền mặt.");
        s2.setCalloutText("Đơn đặt phòng sẽ chỉ được coi là XÁC NHẬN (CONFIRMED) khi chúng tôi nhận đủ số tiền cọc hợp lệ.");
        s2.setCalloutType("info");
        list.add(s2);

        TermSection s3 = new TermSection();
        s3.setSectionOrder(3);
        s3.setSidebarTitle("Chính Sách Hoàn Hủy Phòng");
        s3.setContentTitle("Chính Sách Hoàn Tiền & Hủy Đặt Phòng");
        s3.setContentType("table");
        s3.setContentText("* Trường hợp bất khả kháng (thiên tai, dịch bệnh theo công bố của nhà nước), quý khách được hỗ trợ đổi ngày miễn phí trong vòng 30 ngày.");
        s3.setTableJson("[{\"col1\":\"Trước 07 ngày so với ngày nhận phòng\",\"col2\":\"Hoàn 100% tiền đặt cọc (trừ phí chuyển khoản nếu có)\",\"status\":\"success\"},{\"col1\":\"Từ 03 đến 06 ngày trước ngày nhận phòng\",\"col2\":\"Hoàn 50% tiền đặt cọc\",\"status\":\"warning\"},{\"col1\":\"Dưới 03 ngày hoặc Không đến (No-show)\",\"col2\":\"Không hoàn lại tiền cọc\",\"status\":\"danger\"}]");
        list.add(s3);

        TermSection s4 = new TermSection();
        s4.setSectionOrder(4);
        s4.setSidebarTitle("Quy Định Lưu Trú & An Ninh");
        s4.setContentTitle("Nội Quy Lưu Trú & An Ninh Homestay");
        s4.setContentType("list");
        s4.setContentText("• Không hút thuốc lá: Tuyệt đối không hút thuốc trong phòng ngủ. Khách có thể hút thuốc tại khu vực sân vườn hoặc ban công mở.\n• Giờ yên tĩnh: Từ 22:30 đến 06:00 sáng hôm sau nhằm đảm bảo sự riêng tư và giấc ngủ của các phòng xung quanh.\n• Chất cấm & Vũ khí: Nghiêm cấm mang theo các chất gây cháy nổ, vũ khí, chất kích thích hoặc thực hiện các hành vi vi phạm pháp luật Việt Nam trong khuôn viên homestay.\n• Vật nuôi (Thú cưng): Vui lòng thông báo trước với quản lý homestay. Phí dọn dẹp vệ sinh phòng thú cưng có thể được áp dụng.\n• Bảo quản tài sản: Quý khách có trách nhiệm giữ gìn trang thiết bị và đồ dùng trong phòng. Nếu xảy ra hư hỏng, mất mát sẽ bồi thường theo bảng giá niêm yết của homestay.");
        list.add(s4);

        TermSection s5 = new TermSection();
        s5.setSectionOrder(5);
        s5.setSidebarTitle("Bảo Mật & Quyền Riêng Tư");
        s5.setContentTitle("Chính Sách Bảo Mật Quyền Riêng Tư");
        s5.setContentType("mixed");
        s5.setContentText("Sogo Homestay cam kết bảo mật tuyệt đối các thông tin cá nhân của quý khách (họ tên, số điện thoại, email, thông tin thanh toán). Mọi dữ liệu chỉ được sử dụng cho mục đích liên hệ xác nhận đơn đặt phòng và đăng ký tạm trú theo luật định.");
        s5.setCalloutText("Nếu bạn cần thêm thông tin giải đáp về các điều khoản trên, xin vui lòng gọi đến hotline (+84) 090 123 4567 hoặc gửi email tới support@sogohomestay.com.");
        s5.setCalloutType("note");
        list.add(s5);

        return list;
    }
}