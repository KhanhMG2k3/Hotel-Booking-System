package com.homestay.dao;

import com.homestay.model.Voucher;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.logging.Level;

public class VoucherDAO extends BaseDAO
        implements GenericDAO<Voucher, Integer> {

    /**
     * Find a voucher by ID.
     * Host-facing code must use findByIdAndHostId().
     */
    @Override
    public Optional<Voucher> findById(Integer id) {
        if (id == null || id <= 0) {
            return Optional.empty();
        }

        String sql = "SELECT * FROM vouchers WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToVoucher(rs));
                }
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error finding voucher id: " + id, e);
        }

        return Optional.empty();
    }

    /**
     * List all vouchers.
     * Do not expose this method directly to a Host.
     */
    @Override
    public List<Voucher> findAll() {
        List<Voucher> vouchers = new ArrayList<>();

        String sql = "SELECT * FROM vouchers ORDER BY id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                vouchers.add(mapResultSetToVoucher(rs));
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error listing vouchers", e);
        }

        return vouchers;
    }

    /**
     * List vouchers belonging to a specific Host.
     */
    public List<Voucher> findByHostId(int hostId) {
        List<Voucher> vouchers = new ArrayList<>();

        if (hostId <= 0) {
            return vouchers;
        }

        String sql = "SELECT * FROM vouchers "
                + "WHERE host_id = ? ORDER BY id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hostId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    vouchers.add(mapResultSetToVoucher(rs));
                }
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error listing vouchers for Host: " + hostId, e);
        }

        return vouchers;
    }

    /**
     * Find a voucher only if it belongs to the given Host.
     */
    public Optional<Voucher> findByIdAndHostId(
            int id, int hostId) {

        if (id <= 0 || hostId <= 0) {
            return Optional.empty();
        }

        String sql = "SELECT * FROM vouchers "
                + "WHERE id = ? AND host_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, hostId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToVoucher(rs));
                }
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error finding Host voucher", e);
        }

        return Optional.empty();
    }

    /**
     * Find a voucher by its unique coupon code.
     */
    public Optional<Voucher> findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return Optional.empty();
        }

        String sql = "SELECT * FROM vouchers WHERE UPPER(TRIM(code)) = UPPER(?) AND status = 'ACTIVE' LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, code.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToVoucher(rs));
                }
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error finding voucher by code: " + code, e);
        }

        return Optional.empty();
    }

    /**
     * Create a new voucher.
     * hostId must be assigned by the Controller from session.
     */
    @Override
    public boolean insert(Voucher voucher) {
        if (!isValid(voucher)) {
            return false;
        }

        String sql = "INSERT INTO vouchers "
                + "(host_id, code, discount_type, discount_value, "
                + "start_date, end_date, usage_limit, "
                + "used_count, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, voucher.getHostId());
            ps.setString(2, voucher.getCode().trim()
                    .toUpperCase(Locale.ROOT));
            ps.setString(3, voucher.getDiscountType());
            ps.setBigDecimal(4, voucher.getDiscountValue());
            ps.setDate(5, voucher.getStartDate());
            ps.setDate(6, voucher.getEndDate());
            ps.setInt(7, voucher.getUsageLimit());
            ps.setInt(8, voucher.getUsedCount());
            ps.setString(9, voucher.getStatus());

            if (ps.executeUpdate() == 0) {
                return false;
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    voucher.setId(keys.getInt(1));
                }
            }

            return true;

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error inserting voucher", e);
            return false;
        }
    }

    /**
     * Generic update.
     * Keep this for compatibility with GenericDAO.
     * Host-facing code must use updateForHost().
     */
    @Override
    public boolean update(Voucher voucher) {
        if (!isValid(voucher) || voucher.getId() <= 0) {
            return false;
        }

        String sql = "UPDATE vouchers SET "
                + "code = ?, "
                + "discount_type = ?, "
                + "discount_value = ?, "
                + "start_date = ?, "
                + "end_date = ?, "
                + "usage_limit = ?, "
                + "used_count = ?, "
                + "status = ? "
                + "WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            bindUpdateFields(ps, voucher);
            ps.setInt(9, voucher.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error updating voucher", e);
            return false;
        }
    }

    /**
     * Update voucher information for its owner.
     *
     * Important:
     * - Do not overwrite used_count.
     * - Only update vouchers belonging to this Host.
     * - Reject usage_limit lower than the current used_count.
     */
    public boolean updateForHost(Voucher voucher, int hostId) {
        if (!isValid(voucher)
                || voucher.getId() <= 0
                || hostId <= 0
                || voucher.getHostId() != hostId) {
            return false;
        }

        String sql = "UPDATE vouchers SET "
                + "code = ?, "
                + "discount_type = ?, "
                + "discount_value = ?, "
                + "start_date = ?, "
                + "end_date = ?, "
                + "usage_limit = ?, "
                + "status = ? "
                + "WHERE id = ? AND host_id = ? "
                + "AND used_count <= ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, voucher.getCode().trim()
                    .toUpperCase(Locale.ROOT));
            ps.setString(2, voucher.getDiscountType());
            ps.setBigDecimal(3, voucher.getDiscountValue());
            ps.setDate(4, voucher.getStartDate());
            ps.setDate(5, voucher.getEndDate());
            ps.setInt(6, voucher.getUsageLimit());
            ps.setString(7, voucher.getStatus());

            ps.setInt(8, voucher.getId());
            ps.setInt(9, hostId);
            ps.setInt(10, voucher.getUsageLimit());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error updating Host voucher", e);
            return false;
        }
    }

    /**
     * Toggle voucher status atomically.
     * Only the status column is modified.
     */
    public boolean toggleStatusForHost(int id, int hostId) {
        if (id <= 0 || hostId <= 0) {
            return false;
        }

        String sql = "UPDATE vouchers SET status = "
                + "CASE "
                + "WHEN status = 'ACTIVE' THEN 'INACTIVE' "
                + "WHEN status = 'INACTIVE' THEN 'ACTIVE' "
                + "ELSE status END "
                + "WHERE id = ? AND host_id = ? "
                + "AND status IN ('ACTIVE', 'INACTIVE')";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, hostId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error toggling Host voucher status", e);
            return false;
        }
    }

    /**
     * Generic delete.
     * Host-facing code must use deleteForHost().
     */
    @Override
    public boolean delete(Integer id) {
        if (id == null || id <= 0) {
            return false;
        }

        String sql = "DELETE FROM vouchers WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error deleting voucher", e);
            return false;
        }
    }

    /**
     * Delete a voucher only if it belongs to this Host.
     *
     * This is a hard delete, preserving current behavior.
     * Consider soft delete if vouchers are referenced by bookings.
     */
    public boolean deleteForHost(int id, int hostId) {
        if (id <= 0 || hostId <= 0) {
            return false;
        }

        String sql = "DELETE FROM vouchers "
                + "WHERE id = ? AND host_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, hostId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.log(Level.SEVERE,
                    "Error deleting Host voucher", e);
            return false;
        }
    }

    /**
     * Bind fields for the generic update method.
     */
    private void bindUpdateFields(
            PreparedStatement ps,
            Voucher voucher) throws SQLException {

        ps.setString(1, voucher.getCode().trim()
                .toUpperCase(Locale.ROOT));
        ps.setString(2, voucher.getDiscountType());
        ps.setBigDecimal(3, voucher.getDiscountValue());
        ps.setDate(4, voucher.getStartDate());
        ps.setDate(5, voucher.getEndDate());
        ps.setInt(6, voucher.getUsageLimit());
        ps.setInt(7, voucher.getUsedCount());
        ps.setString(8, voucher.getStatus());
    }

    /**
     * Validate voucher data before database operations.
     */
    private boolean isValid(Voucher voucher) {
        if (voucher == null
                || voucher.getHostId() <= 0
                || voucher.getCode() == null
                || voucher.getCode().trim().isEmpty()
                || voucher.getCode().trim().length() > 50
                || voucher.getDiscountType() == null
                || voucher.getDiscountValue() == null
                || voucher.getStartDate() == null
                || voucher.getEndDate() == null
                || voucher.getUsageLimit() <= 0
                || voucher.getUsedCount() < 0
                || voucher.getUsedCount() > voucher.getUsageLimit()
                || voucher.getStatus() == null) {
            return false;
        }

        Date start = voucher.getStartDate();
        Date end = voucher.getEndDate();

        if (end.before(start)
                || voucher.getDiscountValue().signum() <= 0) {
            return false;
        }

        if (!"PERCENTAGE".equals(voucher.getDiscountType())
                && !"FIXED_AMOUNT".equals(
                        voucher.getDiscountType())) {
            return false;
        }

        if ("PERCENTAGE".equals(voucher.getDiscountType())
                && voucher.getDiscountValue()
                        .compareTo(
                                new java.math.BigDecimal("100")) > 0) {
            return false;
        }

        return "ACTIVE".equals(voucher.getStatus())
                || "INACTIVE".equals(voucher.getStatus());
    }

    /**
     * Convert a database row to a Voucher object.
     */
    private Voucher mapResultSetToVoucher(ResultSet rs)
            throws SQLException {

        Voucher voucher = new Voucher();

        voucher.setId(rs.getInt("id"));
        voucher.setHostId(rs.getInt("host_id"));
        voucher.setCode(rs.getString("code"));
        voucher.setDiscountType(rs.getString("discount_type"));
        voucher.setDiscountValue(
                rs.getBigDecimal("discount_value"));
        voucher.setStartDate(rs.getDate("start_date"));
        voucher.setEndDate(rs.getDate("end_date"));
        voucher.setUsageLimit(rs.getInt("usage_limit"));
        voucher.setUsedCount(rs.getInt("used_count"));
        voucher.setStatus(rs.getString("status"));
        voucher.setCreatedAt(rs.getTimestamp("created_at"));

        return voucher;
    }
}
