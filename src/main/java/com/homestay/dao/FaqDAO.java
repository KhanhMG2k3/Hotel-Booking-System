package com.homestay.dao;

import com.homestay.model.Faq;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

public class FaqDAO extends BaseDAO {

    /**
     * Dành cho Khách hàng: Lấy danh sách câu hỏi đang ACTIVE (status = 1) theo từ khóa và danh mục
     */
    public List<Faq> getActiveFaqs(String keyword, String category) {
        List<Faq> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT faq_id AS id, category, question, answer, order_index, " +
            "CASE WHEN status = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END AS status " +
            "FROM faqs WHERE status = 1"
        );

        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
        boolean hasCategory = (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category) && !"Tất cả".equalsIgnoreCase(category));

        if (hasKeyword) {
            sql.append(" AND (LOWER(question) LIKE LOWER(?) OR LOWER(answer) LIKE LOWER(?))");
        }
        if (hasCategory) {
            sql.append(" AND category = ?");
        }
        sql.append(" ORDER BY order_index ASC, faq_id ASC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            int paramIndex = 1;
            if (hasKeyword) {
                String search = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, search);
                ps.setString(paramIndex++, search);
            }
            if (hasCategory) {
                ps.setString(paramIndex++, category.trim());
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Faq(
                    rs.getInt("id"),
                    rs.getString("category"),
                    rs.getString("question"),
                    rs.getString("answer"),
                    rs.getInt("order_index"),
                    rs.getString("status")
                ));
            }
            // Trả về danh sách thực tế tìm được từ database
            return list;
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Lỗi kết nối database khi lấy FAQ, dùng dữ liệu fallback có lọc", e);
            // Nếu lỗi DB mới dùng fallback, nhưng fallback cũng phải lọc theo từ khóa!
            return filterFallbackFaqs(keyword, category);
        } finally {
            closeResources(conn, ps, rs);
        }
    }

    /**
     * Dành cho Admin: Lấy toàn bộ danh sách FAQ
     */
    public List<Faq> getAllFaqsForAdmin() {
        List<Faq> list = new ArrayList<>();
        String sql = "SELECT faq_id AS id, category, question, answer, order_index, " +
                     "CASE WHEN status = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END AS status " +
                     "FROM faqs ORDER BY category, order_index ASC, faq_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Faq(
                    rs.getInt("id"),
                    rs.getString("category"),
                    rs.getString("question"),
                    rs.getString("answer"),
                    rs.getInt("order_index"),
                    rs.getString("status")
                ));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi lấy toàn bộ FAQ cho Admin", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Admin: Thêm mới câu hỏi
     */
    public boolean insertFaq(Faq faq) {
        String sql = "INSERT INTO faqs (category, question, answer, order_index, status) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, faq.getCategory());
            ps.setString(2, faq.getQuestion());
            ps.setString(3, faq.getAnswer());
            ps.setInt(4, faq.getOrderIndex());
            int statusInt = "ACTIVE".equalsIgnoreCase(faq.getStatus()) ? 1 : 0;
            ps.setInt(5, statusInt);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi thêm FAQ mới", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Admin: Cập nhật câu hỏi
     */
    public boolean updateFaq(Faq faq) {
        String sql = "UPDATE faqs SET category = ?, question = ?, answer = ?, order_index = ?, status = ? WHERE faq_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, faq.getCategory());
            ps.setString(2, faq.getQuestion());
            ps.setString(3, faq.getAnswer());
            ps.setInt(4, faq.getOrderIndex());
            int statusInt = "ACTIVE".equalsIgnoreCase(faq.getStatus()) ? 1 : 0;
            ps.setInt(5, statusInt);
            ps.setInt(6, faq.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi cập nhật FAQ", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Admin: Nút bật/tắt hiển thị lên trang khách
     */
    public boolean toggleStatus(int id) {
        String sql = "UPDATE faqs SET status = CASE WHEN status = 1 THEN 0 ELSE 1 END WHERE faq_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi toggle trạng thái FAQ", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Admin: Xóa cả câu hỏi
     */
    public boolean deleteFaq(int id) {
        String sql = "DELETE FROM faqs WHERE faq_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi xóa FAQ", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Hàm fallback có hỗ trợ lọc từ khóa nếu database gặp sự cố
     */
    private List<Faq> filterFallbackFaqs(String keyword, String category) {
        List<Faq> all = new ArrayList<>();
        all.add(new Faq(1, "Đặt phòng", "Thời gian nhận phòng (Check-in) và trả phòng (Check-out) là mấy giờ?", "Thời gian nhận phòng tiêu chuẩn từ 14:00 và trả phòng trước 12:00 trưa hôm sau. Quý khách có thể yêu cầu nhận phòng sớm tùy vào tình trạng phòng sẵn có.", 1, "ACTIVE"));
        all.add(new Faq(2, "Thanh toán & Hủy phòng", "Chính sách hủy phòng và hoàn tiền của Sogo Homestay như thế nào?", "Hủy phòng trước 7 ngày so với ngày nhận phòng sẽ được hoàn tiền 100%. Hủy trước 3 ngày được hoàn 50%. Quý khách có thể xem chi tiết trong đơn đặt.", 2, "ACTIVE"));
        all.add(new Faq(3, "Thanh toán", "Tôi có thể thanh toán qua mã QR VietQR không?", "Có, Sogo hỗ trợ thanh toán tự động qua mã VietQR của tất cả các ngân hàng và ví điện tử, tiền vào ngay và đơn đặt tự động xác nhận.", 3, "ACTIVE"));

        List<Faq> filtered = new ArrayList<>();
        String kw = (keyword != null) ? keyword.trim().toLowerCase() : "";
        for (Faq f : all) {
            boolean matchKw = kw.isEmpty() || f.getQuestion().toLowerCase().contains(kw) || f.getAnswer().toLowerCase().contains(kw);
            boolean matchCat = (category == null || category.trim().isEmpty() || "ALL".equalsIgnoreCase(category) || "Tất cả".equalsIgnoreCase(category) || f.getCategory().equalsIgnoreCase(category.trim()));
            if (matchKw && matchCat) {
                filtered.add(f);
            }
        }
        return filtered;
    }
}