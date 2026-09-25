package com.homestay.security;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class CsrfTokenTest {

    @Test
    void generatesUniqueUrlSafeTokens() {
        String first = CsrfToken.generate();
        String second = CsrfToken.generate();

        assertNotEquals(first, second);
        assertTrue(first.matches("[A-Za-z0-9_-]{43}"));
    }

    @Test
    void matchesOnlyEqualNonNullTokens() {
        String token = CsrfToken.generate();

        assertTrue(CsrfToken.matches(token, token));
        assertFalse(CsrfToken.matches(token, token + "x"));
        assertFalse(CsrfToken.matches(null, token));
        assertFalse(CsrfToken.matches(token, null));
    }
}