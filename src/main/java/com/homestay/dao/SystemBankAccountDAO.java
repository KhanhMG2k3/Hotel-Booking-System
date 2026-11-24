package com.homestay.dao;

import com.homestay.model.SystemBankAccount;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;

public class SystemBankAccountDAO extends BaseDAO {

    /**
     * Finds the single active default receiving account.
     *
     * Returns empty if no active default account exists.
     * Throws SQLException if multiple active default accounts exist.
     */
    public Optional<SystemBankAccount> findActiveDefaultAccount()
            throws SQLException {

        String sql = """
                SELECT *
                FROM system_bank_accounts
                WHERE is_active = 1
                  AND is_default = 1
                ORDER BY account_id ASC
                LIMIT 2
                """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (!rs.next()) {
                return Optional.empty();
            }

            SystemBankAccount account = mapResultSet(rs);

            if (rs.next()) {
                throw new SQLException(
                        "Multiple active default bank accounts found");
            }

            return Optional.of(account);
        }
    }

    /**
     * Lists all active receiving accounts.
     */
    public List<SystemBankAccount> findAllActiveAccounts()
            throws SQLException {

        List<SystemBankAccount> accounts = new ArrayList<>();

        String sql = """
                SELECT *
                FROM system_bank_accounts
                WHERE is_active = 1
                ORDER BY is_default DESC, account_id ASC
                """;

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                accounts.add(mapResultSet(rs));
            }
        }

        return accounts;
    }

    /**
     * Maps a database row to SystemBankAccount.
     */
    private SystemBankAccount mapResultSet(ResultSet rs)
            throws SQLException {

        SystemBankAccount account = new SystemBankAccount();

        account.setAccountId(rs.getInt("account_id"));
        account.setBankCode(rs.getString("bank_code"));
        account.setBankName(rs.getString("bank_name"));
        account.setAccountNumber(rs.getString("account_number"));
        account.setAccountHolder(rs.getString("account_holder"));
        account.setBranch(rs.getString("branch"));
        account.setBinCode(rs.getString("bin_code"));
        account.setQrTemplate(rs.getString("qr_template"));
        account.setActive(rs.getBoolean("is_active"));
        account.setDefaultAccount(rs.getBoolean("is_default"));
        account.setCreatedAt(rs.getTimestamp("created_at"));

        return account;
    }
}