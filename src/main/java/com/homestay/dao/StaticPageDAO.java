package com.homestay.dao;

import com.homestay.model.StaticPage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.logging.Level;

public class StaticPageDAO extends BaseDAO {

    /**
     * Tìm kiếm nội dung trang theo slug ('about-us', 'terms-and-conditions')
     */
    public StaticPage getPageBySlug(String slug) {
        String sql = "SELECT id, slug, title, meta_description, content, updated_at " +
                     "FROM static_pages WHERE slug = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, slug);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new StaticPage(
                    rs.getInt("id"),
                    rs.getString("slug"),
                    rs.getString("title"),
                    rs.getString("meta_description"),
                    rs.getString("content"),
                    rs.getTimestamp("updated_at")
                );
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Không thể lấy StaticPage từ DB (slug: " + slug + "). Sử dụng dữ liệu fallback mặc định.", e);
        } finally {
            closeResources(conn, ps, rs);
        }

        // Dữ liệu Fallback tự động khi chưa chạy script DB
        return createFallbackPage(slug);
    }

    /**
     * Cập nhật nội dung trang (dành cho Admin sau này)
     */
    public boolean updatePage(String slug, String title, String metaDescription, String content) {
        String sql = "UPDATE static_pages SET title = ?, meta_description = ?, content = ? WHERE slug = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, title);
            ps.setString(2, metaDescription);
            ps.setString(3, content);
            ps.setString(4, slug);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi khi cập nhật StaticPage slug: " + slug, e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private StaticPage createFallbackPage(String slug) {
        StaticPage page = new StaticPage();
        page.setSlug(slug);
        page.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

        if ("about-us".equalsIgnoreCase(slug)) {
            page.setTitle("Về Chúng Tôi - Sogo Homestay");
            page.setMetaDescription("Giới thiệu không gian nghỉ dưỡng ấm cúng và tiện nghi tại Sogo Homestay.");
            page.setContent("Sogo Homestay mang đến trải nghiệm lưu trú thân thiện, tiện nghi và trọn vẹn tại thành phố biển.");
        } else if ("terms-and-conditions".equalsIgnoreCase(slug)) {
            page.setTitle("Điều Khoản & Quy Định Lưu Trú - Sogo Homestay");
            page.setMetaDescription("Quy định nhận phòng, hủy đặt phòng và bảo vệ quyền lợi khách hàng.");
            page.setContent("Điều khoản sử dụng dịch vụ và quy định lưu trú chính thức tại Sogo Homestay.");
        }
        return page;
    }
}