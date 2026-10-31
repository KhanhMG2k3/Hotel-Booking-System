package com.homestay.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PasswordUtilTest {

    @Test
    @DisplayName("Hashes plain password and verifies successfully with correct password")
    void testHashAndVerifyPasswordSuccess() {
        String plain = "Secret@2026";
        String hashed = PasswordUtil.hashPassword(plain);

        assertNotNull(hashed);
        assertTrue(hashed.startsWith("$2a$") || hashed.startsWith("$2b$"));
        assertTrue(PasswordUtil.verifyPassword(plain, hashed));
    }

    @Test
    @DisplayName("Rejects incorrect password against hash")
    void testVerifyPasswordFailsWithWrongPassword() {
        String plain = "Secret@2026";
        String wrong = "WrongPassword123";
        String hashed = PasswordUtil.hashPassword(plain);

        assertFalse(PasswordUtil.verifyPassword(wrong, hashed));
    }

    @Test
    @DisplayName("Returns false when plain or hash is null or empty")
    void testVerifyPasswordNullOrEmpty() {
        assertFalse(PasswordUtil.verifyPassword(null, "someHash"));
        assertFalse(PasswordUtil.verifyPassword("password", null));
        assertFalse(PasswordUtil.verifyPassword("password", ""));
    }

    @Test
    @DisplayName("Throws IllegalArgumentException when hashing null or empty password")
    void testHashPasswordNullOrEmptyThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(""));
    }
}

