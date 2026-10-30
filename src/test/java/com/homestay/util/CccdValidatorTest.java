package com.homestay.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class CccdValidatorTest {

    @Test
    @DisplayName("Valid CCCD 001204000006 from Hanoi, Male, born 2004")
    public void testValidCccd1() {
        String cccd = "001204000006";
        assertTrue(CccdValidator.isValidCccd(cccd));
        assertNull(CccdValidator.getValidationError(cccd));
        assertEquals("Hà Nội", CccdValidator.getProvinceName(cccd));
        assertEquals("Nam", CccdValidator.getGender(cccd));
        assertEquals(Integer.valueOf(2004), CccdValidator.getBirthYear(cccd));
    }

    @Test
    @DisplayName("Valid CCCD 079195123456 from TPHCM, Female, born 1995")
    public void testValidCccd2() {
        String cccd = "079195123456";
        assertTrue(CccdValidator.isValidCccd(cccd));
        assertNull(CccdValidator.getValidationError(cccd));
        assertEquals("TP. Hồ Chí Minh", CccdValidator.getProvinceName(cccd));
        assertEquals("Nữ", CccdValidator.getGender(cccd));
        assertEquals(Integer.valueOf(1995), CccdValidator.getBirthYear(cccd));
    }

    @Test
    @DisplayName("Invalid CCCD: incorrect length or non-numeric")
    public void testInvalidLengthAndChars() {
        assertFalse(CccdValidator.isValidCccd("123456789"));
        assertNotNull(CccdValidator.getValidationError("123456789"));

        assertFalse(CccdValidator.isValidCccd("0012040000067"));
        assertNotNull(CccdValidator.getValidationError("0012040000067"));

        assertFalse(CccdValidator.isValidCccd("001204A00006"));
        assertNotNull(CccdValidator.getValidationError("001204A00006"));

        assertFalse(CccdValidator.isValidCccd(""));
        assertFalse(CccdValidator.isValidCccd(null));
    }

    @Test
    @DisplayName("Invalid CCCD: invalid province code or 000000 random suffix")
    public void testInvalidProvinceAndSuffix() {
        assertFalse(CccdValidator.isValidCccd("999204000006"));
        assertTrue(CccdValidator.getValidationError("999204000006").contains("Mã tỉnh"));

        assertFalse(CccdValidator.isValidCccd("001204000000"));
        assertTrue(CccdValidator.getValidationError("001204000000").contains("ngẫu nhiên"));
    }
}

