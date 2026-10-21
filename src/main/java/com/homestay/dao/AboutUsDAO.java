package com.homestay.dao;

import com.homestay.model.AboutUs;
import com.homestay.model.AboutUs.CommitCard;
import com.homestay.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;

public class AboutUsDAO extends BaseDAO {

    private static final String CARD_SEP = "###CARD###";
    private static final String FIELD_SEP = "\\|\\|\\|";
    private static final String FIELD_JOIN = "|||";

    private final UserDAO userDAO = new UserDAO();

    /**
     * Đảm bảo bảng about_us đã có đủ 2 cột mới (commit_cards_data và team_user_ids)
     */
    private void ensureSchemaColumns(Connection conn) {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate("ALTER TABLE about_us ADD COLUMN commit_cards_data LONGTEXT NULL");
        } catch (SQLException ignored) {}
        try (Statement st = conn.createStatement()) {
            st.executeUpdate("ALTER TABLE about_us ADD COLUMN team_user_ids VARCHAR(500) NULL");
        } catch (SQLException ignored) {}
    }

    /**
     * Lấy thông tin trang About Us cùng danh sách thẻ lý do và nhân sự từ bảng users
     */
    public AboutUs getAboutUs() {
        String sql = "SELECT * FROM about_us ORDER BY id ASC LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ensureSchemaColumns(conn);
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                AboutUs a = new AboutUs();
                a.setId(rs.getInt("id"));
                a.setTitle(rs.getString("title"));
                a.setIntroContent(rs.getString("intro_content"));
                a.setBtnExploreText(rs.getString("btn_explore_text"));
                a.setBtnBookText(rs.getString("btn_book_text"));
                a.setCommitTitle(rs.getString("commit_title"));
                a.setTeamTitle(rs.getString("team_title"));
                a.setUpdatedAt(rs.getTimestamp("updated_at"));

                // 1. Giải mã danh sách thẻ lý do (Commit Cards)
                String rawCards = null;
                try { rawCards = rs.getString("commit_cards_data"); } catch (SQLException ignored) {}
                a.setCommitCards(parseCommitCards(rawCards));

                // 2. Giải mã danh sách nhân sự (User IDs) và tải thông tin từ bảng users
                String rawTeamIds = null;
                try { rawTeamIds = rs.getString("team_user_ids"); } catch (SQLException ignored) {}
                List<Integer> userIds = parseTeamUserIds(rawTeamIds);
                a.setTeamUserIds(userIds);
                a.setTeamMembers(loadUsersByIds(userIds));

                return a;
            }
        } catch (SQLException e) {
            logger.log(Level.WARNING, "Không thể đọc bảng about_us, dùng dữ liệu fallback.", e);
        } finally {
            closeResources(conn, ps, rs);
        }

        return createFallbackAboutUs();
    }

    /**
     * Cập nhật toàn bộ nội dung trang About Us
     */
    public boolean updateAboutUs(AboutUs a) {
        String cardsData = serializeCommitCards(a.getCommitCards());
        String teamIdsData = serializeTeamUserIds(a.getTeamUserIds());

        String sql = "UPDATE about_us SET " +
                     "title = ?, intro_content = ?, " +
                     "btn_explore_text = ?, btn_book_text = ?, " +
                     "commit_title = ?, commit_cards_data = ?, " +
                     "team_title = ?, team_user_ids = ? " +
                     "WHERE id = (SELECT id FROM (SELECT id FROM about_us ORDER BY id ASC LIMIT 1) AS tmp)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ensureSchemaColumns(conn);
            ps = conn.prepareStatement(sql);
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getIntroContent());
            ps.setString(3, a.getBtnExploreText());
            ps.setString(4, a.getBtnBookText());
            ps.setString(5, a.getCommitTitle());
            ps.setString(6, cardsData);
            ps.setString(7, a.getTeamTitle());
            ps.setString(8, teamIdsData);

            int affected = ps.executeUpdate();
            if (affected > 0) return true;

            return insertDefaultAboutUs(conn, a, cardsData, teamIdsData);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi cập nhật bảng about_us", e);
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    private boolean insertDefaultAboutUs(Connection conn, AboutUs a, String cardsData, String teamIdsData) {
        String sql = "INSERT INTO about_us (title, intro_content, btn_explore_text, btn_book_text, " +
                     "commit_title, commit_cards_data, team_title, team_user_ids) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getIntroContent());
            ps.setString(3, a.getBtnExploreText());
            ps.setString(4, a.getBtnBookText());
            ps.setString(5, a.getCommitTitle());
            ps.setString(6, cardsData);
            ps.setString(7, a.getTeamTitle());
            ps.setString(8, teamIdsData);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi insert bảng about_us", e);
            return false;
        }
    }

    /**
     * Lấy toàn bộ danh sách user từ bảng users để hiển thị trong Dropdown
     */
    public List<User> getAllAvailableUsers() {
        return userDAO.findAll();
    }

    private List<User> loadUsersByIds(List<Integer> userIds) {
        List<User> allUsers = userDAO.findAll();
        List<User> selected = new ArrayList<>();

        if (userIds != null && !userIds.isEmpty()) {
            for (Integer id : userIds) {
                for (User u : allUsers) {
                    if (u.getId() == id) {
                        selected.add(u);
                        break;
                    }
                }
            }
        } else {
            // Mặc định chọn 2 user đầu tiên trong bảng users nếu chưa cấu hình
            for (int i = 0; i < Math.min(2, allUsers.size()); i++) {
                selected.add(allUsers.get(i));
            }
        }
        return selected;
    }

    private String serializeCommitCards(List<CommitCard> cards) {
        if (cards == null || cards.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (CommitCard c : cards) {
            if (c.getTitle() == null || c.getTitle().trim().isEmpty()) continue;
            if (sb.length() > 0) sb.append(CARD_SEP);
            String icon = (c.getIcon() != null && !c.getIcon().trim().isEmpty()) ? c.getIcon().trim() : "ion-ios-home";
            String title = c.getTitle().trim().replace("|||", " ");
            String desc = (c.getDescription() != null ? c.getDescription().trim() : "").replace("|||", " ");
            sb.append(icon).append(FIELD_JOIN).append(title).append(FIELD_JOIN).append(desc);
        }
        return sb.toString();
    }

    private List<CommitCard> parseCommitCards(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return getDefaultCommitCards();
        }
        List<CommitCard> list = new ArrayList<>();
        String[] items = raw.split(CARD_SEP);
        for (String item : items) {
            String[] parts = item.split(FIELD_SEP, -1);
            if (parts.length >= 3 && !parts[1].trim().isEmpty()) {
                list.add(new CommitCard(parts[0].trim(), parts[1].trim(), parts[2].trim()));
            }
        }
        return list.isEmpty() ? getDefaultCommitCards() : list;
    }

    private List<CommitCard> getDefaultCommitCards() {
        List<CommitCard> cards = new ArrayList<>();
        cards.add(new CommitCard("ion-ios-home", "Không Gian Ấm Cúng",
                "Phòng nghỉ bài trí tinh tế, sạch sẽ tuyệt đối, mang lại cảm giác thân quen như chính ngôi nhà của bạn."));
        cards.add(new CommitCard("ion-ios-location", "Vị Trí Đắc Địa",
                "Thuận tiện di chuyển ra bãi biển, các danh lam thắng cảnh và khu phố ẩm thực sầm uất."));
        cards.add(new CommitCard("ion-ios-heart", "Phục Vụ Tận Tâm",
                "Đội ngũ hỗ trợ 24/7 sẵn sàng tư vấn lịch trình, gợi ý địa điểm ăn uống ngon và hỗ trợ thuê xe."));
        cards.add(new CommitCard("ion-ios-pricetag", "Giá Cả Minh Bạch",
                "Cam kết không phụ phí ẩn, chính sách đặt cọc và hoàn hủy linh hoạt, minh bạch rõ ràng."));
        return cards;
    }

    private String serializeTeamUserIds(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) return "";
        Set<Integer> uniqueIds = new LinkedHashSet<>(ids);
        StringBuilder sb = new StringBuilder();
        for (Integer id : uniqueIds) {
            if (id != null && id > 0) {
                if (sb.length() > 0) sb.append(",");
                sb.append(id);
            }
        }
        return sb.toString();
    }

    private List<Integer> parseTeamUserIds(String raw) {
        List<Integer> ids = new ArrayList<>();
        if (raw == null || raw.trim().isEmpty()) return ids;
        for (String s : raw.split(",")) {
            try {
                int id = Integer.parseInt(s.trim());
                if (id > 0) ids.add(id);
            } catch (NumberFormatException ignored) {}
        }
        return ids;
    }

    private AboutUs createFallbackAboutUs() {
        AboutUs a = new AboutUs();
        a.setId(1);
        a.setTitle("Chào mừng đến với Sogo Homestay");
        a.setIntroContent("Sogo Homestay ra đời từ niềm đam mê mang lại không gian lưu trú ấm cúng, thư thái và gắn kết cho mọi du khách.\n\nĐược thành lập với mong muốn tạo nên một điểm dừng chân mang phong cách kiến trúc mộc mạc kết hợp tiện nghi hiện đại, Sogo Homestay là nơi bạn tìm thấy sự bình yên giữa nhịp sống hối hả.");
        a.setBtnExploreText("Khám Phá Phòng");
        a.setBtnBookText("Đặt Phòng Ngay");
        a.setCommitTitle("Tại Sao Khách Hàng Chọn Sogo?");
        a.setCommitCards(getDefaultCommitCards());
        a.setTeamTitle("Đội Ngũ Quản Lý & Vận Hành");
        List<User> members = loadUsersByIds(new ArrayList<>());
        a.setTeamMembers(members);
        List<Integer> ids = new ArrayList<>();
        for (User u : members) ids.add(u.getId());
        a.setTeamUserIds(ids);
        a.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
        return a;
    }
}