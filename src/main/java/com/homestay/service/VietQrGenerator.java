package com.homestay.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.EnumMap;
import java.util.Map;

/**
 * Generates QR images from an already constructed transfer payload.
 */
public final class VietQrGenerator {

    private static final int DEFAULT_WIDTH = 400;
    private static final int DEFAULT_HEIGHT = 400;
    private static final int MIN_SIZE = 100;
    private static final int MAX_SIZE = 1000;

    private VietQrGenerator() {
        // Utility class
    }

    /**
     * Generates a QR image from the supplied payload.
     *
     * @param payload non-empty QR payload
     * @return generated QR image
     */
    public static BufferedImage generateImage(String payload)
            throws WriterException {

        return generateImage(
                payload,
                DEFAULT_WIDTH,
                DEFAULT_HEIGHT
        );
    }

    /**
     * Generates a QR image with custom dimensions.
     *
     * @param payload non-empty QR payload
     * @param width image width
     * @param height image height
     * @return generated QR image
     */
    public static BufferedImage generateImage(
            String payload,
            int width,
            int height) throws WriterException {

        if (payload == null || payload.isBlank()) {
            throw new IllegalArgumentException(
                    "QR payload must not be empty"
            );
        }

        if (width < MIN_SIZE || width > MAX_SIZE
                || height < MIN_SIZE || height > MAX_SIZE) {
            throw new IllegalArgumentException(
                    "QR image dimensions must be between "
                    + MIN_SIZE + " and " + MAX_SIZE
            );
        }

        Map<EncodeHintType, Object> hints =
                new EnumMap<>(EncodeHintType.class);

        hints.put(
                EncodeHintType.ERROR_CORRECTION,
                ErrorCorrectionLevel.M
        );

        hints.put(
                EncodeHintType.MARGIN,
                2
        );

        hints.put(
                EncodeHintType.CHARACTER_SET,
                "UTF-8"
        );

        QRCodeWriter writer = new QRCodeWriter();

        BitMatrix matrix = writer.encode(
                payload,
                BarcodeFormat.QR_CODE,
                width,
                height,
                hints
        );

        return MatrixToImageWriter.toBufferedImage(matrix);
    }

    /**
     * Generates a base64 encoded PNG data URL from the QR payload.
     *
     * @param payload QR payload
     * @param width image width
     * @param height image height
     * @return base64 data URL string (e.g. data:image/png;base64,...)
     */
    public static String generateBase64(String payload, int width, int height)
            throws WriterException, IOException {

        BufferedImage image = generateImage(payload, width, height);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "PNG", baos);
        return "data:image/png;base64," + Base64.getEncoder().encodeToString(baos.toByteArray());
    }

    /**
     * Generates a base64 encoded PNG data URL with default dimensions.
     */
    public static String generateBase64(String payload)
            throws WriterException, IOException {

        return generateBase64(payload, DEFAULT_WIDTH, DEFAULT_HEIGHT);
    }
}
