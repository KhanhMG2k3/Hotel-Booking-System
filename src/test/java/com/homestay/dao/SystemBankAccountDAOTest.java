package com.homestay.dao;

import com.homestay.model.SystemBankAccount;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class SystemBankAccountDAOTest {

    private Connection connection;
    private PreparedStatement statement;
    private ResultSet resultSet;

    private TestSystemBankAccountDAO dao;

    @BeforeEach
    void setUp() throws Exception {
        connection = mock(Connection.class);
        statement = mock(PreparedStatement.class);
        resultSet = mock(ResultSet.class);

        when(connection.prepareStatement(anyString()))
                .thenReturn(statement);

        when(statement.executeQuery())
                .thenReturn(resultSet);

        dao = new TestSystemBankAccountDAO(connection);
    }

    @Test
    void findActiveDefaultAccountShouldReturnEmptyWhenNoAccountExists()
            throws Exception {

        when(resultSet.next()).thenReturn(false);

        Optional<SystemBankAccount> result =
                dao.findActiveDefaultAccount();

        assertTrue(result.isEmpty());
        verify(connection).prepareStatement(contains("is_default = 1"));
    }

    @Test
    void findActiveDefaultAccountShouldMapAccountCorrectly()
            throws Exception {

        when(resultSet.next()).thenReturn(true, false);
        mockAccountRow(1, "TPB", "TPBank", "123456789",
                "NGUYEN VAN A", true, true);

        Optional<SystemBankAccount> result =
                dao.findActiveDefaultAccount();

        assertTrue(result.isPresent());

        SystemBankAccount account = result.orElseThrow();

        assertEquals(1, account.getAccountId());
        assertEquals("TPB", account.getBankCode());
        assertEquals("TPBank", account.getBankName());
        assertEquals("123456789", account.getAccountNumber());
        assertEquals("NGUYEN VAN A", account.getAccountHolder());
        assertTrue(account.isActive());
        assertTrue(account.isDefaultAccount());
    }

    @Test
    void findActiveDefaultAccountShouldRejectMultipleDefaultAccounts()
            throws Exception {

        when(resultSet.next()).thenReturn(true, true);
        mockAccountRow(1, "TPB", "TPBank", "123456789",
                "NGUYEN VAN A", true, true);

        assertThrows(
                SQLException.class,
                () -> dao.findActiveDefaultAccount()
        );
    }

    @Test
    void findAllActiveAccountsShouldReturnMappedAccounts()
            throws Exception {

        when(resultSet.next()).thenReturn(true, true, false);

        when(resultSet.getInt("account_id"))
                .thenReturn(1, 2);

        when(resultSet.getString("bank_code"))
                .thenReturn("TPB", "VCB");

        when(resultSet.getString("bank_name"))
                .thenReturn("TPBank", "Vietcombank");

        when(resultSet.getString("account_number"))
                .thenReturn("123456789", "987654321");

        when(resultSet.getString("account_holder"))
                .thenReturn("NGUYEN VAN A", "NGUYEN VAN B");

        when(resultSet.getBoolean("is_active"))
                .thenReturn(true, true);

        when(resultSet.getBoolean("is_default"))
                .thenReturn(true, false);

        List<SystemBankAccount> accounts =
                dao.findAllActiveAccounts();

        assertEquals(2, accounts.size());
        assertEquals("TPB", accounts.get(0).getBankCode());
        assertEquals("VCB", accounts.get(1).getBankCode());

        verify(connection).prepareStatement(
                contains("WHERE is_active = 1")
        );
    }

    private void mockAccountRow(
            int accountId,
            String bankCode,
            String bankName,
            String accountNumber,
            String accountHolder,
            boolean active,
            boolean defaultAccount
    ) throws Exception {

        when(resultSet.getInt("account_id"))
                .thenReturn(accountId);

        when(resultSet.getString("bank_code"))
                .thenReturn(bankCode);

        when(resultSet.getString("bank_name"))
                .thenReturn(bankName);

        when(resultSet.getString("account_number"))
                .thenReturn(accountNumber);

        when(resultSet.getString("account_holder"))
                .thenReturn(accountHolder);

        when(resultSet.getString("branch"))
                .thenReturn("Ha Noi");

        when(resultSet.getString("bin_code"))
                .thenReturn("970000");

        when(resultSet.getString("qr_template"))
                .thenReturn("compact2");

        when(resultSet.getBoolean("is_active"))
                .thenReturn(active);

        when(resultSet.getBoolean("is_default"))
                .thenReturn(defaultAccount);

        when(resultSet.getTimestamp("created_at"))
                .thenReturn(Timestamp.valueOf("2026-10-30 10:00:00"));
    }

    private static class TestSystemBankAccountDAO
            extends SystemBankAccountDAO {

        private final Connection testConnection;

        private TestSystemBankAccountDAO(Connection connection) {
            this.testConnection = connection;
        }

        @Override
        protected Connection getConnection() {
            return testConnection;
        }
    }
}