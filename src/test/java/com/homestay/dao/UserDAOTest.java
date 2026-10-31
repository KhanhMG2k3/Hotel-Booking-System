package com.homestay.dao;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class UserDAOTest {

    @Test
    @DisplayName("Verify default role IDs match database seed (Customer = 2, Admin = 1, Host = 3)")
    void testRoleConstantsMatchDatabaseSeed() {
        assertEquals(1, UserDAO.ROLE_ADMIN_ID, "Admin role ID must be 1");
        assertEquals(2, UserDAO.ROLE_CUSTOMER_ID, "Customer role ID must be 2");
        assertEquals(3, UserDAO.ROLE_HOST_ID, "Host role ID must be 3");
    }
}

