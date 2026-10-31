package com.homestay.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.awt.image.BufferedImage;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class VietQrGeneratorTest {

    @Test
    @DisplayName("Generates valid QR image with default dimensions (400x400)")
    void testGenerateImageDefaultDimensions() throws Exception {
        String payload = "00020101021238540010A00000072701240006970423011003719999990208QRIBFTTA530370454061000005802VN62180814HOMESTAY1236304ABCD";

        BufferedImage image = VietQrGenerator.generateImage(payload);

        assertNotNull(image, "Generated QR image must not be null");
        assertEquals(400, image.getWidth(), "QR image width must be 400");
        assertEquals(400, image.getHeight(), "QR image height must be 400");
    }

    @Test
    @DisplayName("Generates valid QR image with custom dimensions (250x250)")
    void testGenerateImageCustomDimensions() throws Exception {
        String payload = "https://example.com/pay/bk123456";

        BufferedImage image = VietQrGenerator.generateImage(payload, 250, 250);

        assertNotNull(image);
        assertEquals(250, image.getWidth());
        assertEquals(250, image.getHeight());
    }

    @Test
    @DisplayName("Throws IllegalArgumentException when payload is null or blank")
    void testNullOrBlankPayloadThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> VietQrGenerator.generateImage(null));
        assertThrows(IllegalArgumentException.class, () -> VietQrGenerator.generateImage("   "));
    }

    @Test
    @DisplayName("Throws IllegalArgumentException when dimensions are out of bounds")
    void testInvalidDimensionsThrowsException() {
        String payload = "sample-payload";

        // Size < 100
        assertThrows(IllegalArgumentException.class, () -> VietQrGenerator.generateImage(payload, 50, 50));

        // Size > 1000
        assertThrows(IllegalArgumentException.class, () -> VietQrGenerator.generateImage(payload, 1500, 1500));
    }
}

