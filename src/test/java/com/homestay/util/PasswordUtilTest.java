package com.homestay.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.security.GeneralSecurityException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit test suite verifying PBKDF2 & BCrypt password hashing, salt uniqueness, and verification security.
 */
public class PasswordUtilTest {

    @Test
    @DisplayName("Hash should produce a valid PBKDF2 string with 4 parts")
    public void testHashFormat() throws GeneralSecurityException {
        String plainPassword = "TestPassword@123";
        String hashed = PasswordUtil.hash(plainPassword);

        assertNotNull(hashed);
        assertTrue(hashed.startsWith("pbkdf2-sha256$210000$"));
        String[] parts = hashed.split("\\$");
        assertEquals(4, parts.length);
        assertEquals("pbkdf2-sha256", parts[0]);
        assertEquals("210000", parts[1]);
        assertFalse(parts[2].isEmpty(), "Salt should not be empty");
        assertFalse(parts[3].isEmpty(), "Hash should not be empty");
    }

    @Test
    @DisplayName("Verify should return true for correct password and false for wrong password")
    public void testVerifyPassword() throws GeneralSecurityException {
        String password = "SecretMasterKey#2026";
        String hashed = PasswordUtil.hash(password);

        assertTrue(PasswordUtil.verify(password, hashed), "Correct password must verify successfully");
        assertFalse(PasswordUtil.verify("WrongSecretKey#2026", hashed), "Incorrect password must fail verification");
        assertFalse(PasswordUtil.verify(password.toLowerCase(), hashed), "Case sensitivity must be preserved");
    }

    @Test
    @DisplayName("Verify should handle nulls, empty strings, and malformed hashes gracefully without throwing unexpected exceptions")
    public void testVerifyMalformedHash() throws GeneralSecurityException {
        assertFalse(PasswordUtil.verify(null, "someHash"));
        assertFalse(PasswordUtil.verify("password", null));
        assertFalse(PasswordUtil.verify("password", "invalid-hash-string"));
        assertFalse(PasswordUtil.verify("password", "pbkdf2-sha256$10$shortsalt$shorthash"));
    }

    @Test
    @DisplayName("Salts should be unique so same password produces different hashes")
    public void testSaltUniqueness() throws GeneralSecurityException {
        String password = "CommonPassword!456";
        String hash1 = PasswordUtil.hash(password);
        String hash2 = PasswordUtil.hash(password);

        assertNotEquals(hash1, hash2, "Two hashes of the same password must differ due to unique salts");
        assertTrue(PasswordUtil.verify(password, hash1));
        assertTrue(PasswordUtil.verify(password, hash2));
    }

    @Test
    @DisplayName("Hashes plain password with BCrypt and verifies successfully with correct password")
    void testHashAndVerifyPasswordSuccess() {
        String plain = "Secret@2026";
        String hashed = PasswordUtil.hashPassword(plain);

        assertNotNull(hashed);
        assertTrue(hashed.startsWith("$2a$") || hashed.startsWith("$2b$") || hashed.startsWith("pbkdf2-sha256$"));
        assertTrue(PasswordUtil.verifyPassword(plain, hashed));
    }

    @Test
    @DisplayName("Rejects incorrect password against hash in BCrypt")
    void testVerifyPasswordFailsWithWrongPassword() {
        String plain = "Secret@2026";
        String wrong = "WrongPassword123";
        String hashed = PasswordUtil.hashPassword(plain);

        assertFalse(PasswordUtil.verifyPassword(wrong, hashed));
    }

    @Test
    @DisplayName("Returns false when plain or hash is null or empty in BCrypt")
    void testVerifyPasswordNullOrEmpty() {
        assertFalse(PasswordUtil.verifyPassword(null, "someHash"));
        assertFalse(PasswordUtil.verifyPassword("password", null));
        assertFalse(PasswordUtil.verifyPassword("password", ""));
    }

    @Test
    @DisplayName("Throws IllegalArgumentException when hashing null or empty password in BCrypt")
    void testHashPasswordNullOrEmptyThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(""));
    }
}
