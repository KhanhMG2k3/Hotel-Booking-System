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
     * Dành cho Khách hàng: Lấy danh sách câu hỏi đang ACTIVE, sắp xếp theo order_index
     */
    public List<Faq> getActiveFaqs(String keyword, String category) {
        List<Faq> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT faq_id AS id, category, question, answer, order_index, CASE WHEN status = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END AS status FROM faqs WHERE status = 1");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (question LIKE ? OR answer LIKE ?)");
        }
        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
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
            if (keyword != null && !keyword.trim().isEmpty()) {
                String search = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, search);
                ps.setString(paramIndex++, search);
            }
            if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
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
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Lỗi lấy danh sách FAQ active, kích hoạt fallback", e);
            return getFallbackFaqs();
        } finally {
            closeResources(conn, ps, rs);
        }
        return list.isEmpty() ? getFallbackFaqs() : list;
    }

    /**
     * Dành cho Admin: Lấy toàn bộ danh sách FAQ (kể cả INACTIVE)
     */
    public List<Faq> getAllFaqsForAdmin() {
        List<Faq> list = new ArrayList<>();
        String sql = "SELECT faq_id AS id, category, question, answer, order_index, CASE WHEN status = 1 THEN 'ACTIVE' ELSE 'INACTIVE' END AS status FROM faqs ORDER BY category, order_index ASC";
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
            ps.setString(5, faq.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi thêm FAQ", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    /**
     * Admin: Cập nhật câu hỏi
     */
    public boolean updateFaq(Faq faq) {
        String sql = "UPDATE faqs SET category = ?, question = ?, answer = ?, order_index = ?, status = CASE WHEN ? = 'ACTIVE' THEN 1 ELSE 0 END WHERE faq_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, faq.getCategory());
            ps.setString(2, faq.getQuestion());
            ps.setString(3, faq.getAnswer());
            ps.setInt(4, faq.getOrderIndex());
            ps.setString(5, faq.getStatus());
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
     * Admin: Xóa câu hỏi
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

    private List<Faq> getFallbackFaqs() {
        List<Faq> fallback = new ArrayList<>();
        fallback.add(new Faq(1, "Đặt phòng", "Giờ check-in và check-out của Sogo là mấy giờ?", "Giờ nhận phòng từ 14:00 và trả phòng trước 12:00 trưa hôm sau.", 1, "ACTIVE"));
        fallback.add(new Faq(2, "Thanh toán", "Tôi cần đặt cọc trước bao nhiêu?", "Homestay yêu cầu đặt cọc 50% để giữ phòng.", 2, "ACTIVE"));
        fallback.add(new Faq(3, "Quy định", "Có được mang theo vật nuôi không?", "Homestay cho phép mang thú cưng nhỏ nếu báo trước.", 3, "ACTIVE"));
        return fallback;
    }
}