package com.homestay.util;

import jakarta.servlet.http.Part;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.nio.file.attribute.PosixFilePermission;
import java.util.EnumSet;
import java.util.Set;
import java.util.UUID;

/** Stores and safely serves private Host application documents and room media. */
public final class PartnerDocumentStorage {
    public static final long MAX_FILE_SIZE = 5L * 1024 * 1024;
    public static final long MAX_MEDIA_FILE_SIZE = 50L * 1024 * 1024;

    private static final Path STORAGE_ROOT = getStorageRoot();

    private PartnerDocumentStorage() {
    }

    /** Validates and stores a private PDF or image document; returns its stored reference. */
    public static StoredDocument store(Part part) throws IOException {
        if (part == null || part.getSize() <= 0 || part.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("Document size must be between 1 byte and 5 MB.");
        }

        Files.createDirectories(STORAGE_ROOT);
        restrictPermissions(STORAGE_ROOT, true);
        // Write to a restricted temporary file, then atomically publish the validated content.
        Path temporaryFile = Files.createTempFile(STORAGE_ROOT, "partner-", ".upload");
        try {
            restrictPermissions(temporaryFile, false);
            try (InputStream input = part.getInputStream();
                 OutputStream output = Files.newOutputStream(temporaryFile,
                         StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING)) {
                // Detect type from file bytes rather than trusting the client-supplied MIME value.
                byte[] header = input.readNBytes(8);
                String contentType = detectContentType(header);
                if (contentType == null) {
                    throw new IllegalArgumentException(
                            "Only PDF, PNG, or JPEG documents are accepted.");
                }
                output.write(header);
                input.transferTo(output);

                String extension = switch (contentType) {
                    case "application/pdf" -> ".pdf";
                    case "image/png" -> ".png";
                    default -> ".jpg";
                };
                String storedName = UUID.randomUUID().toString().replace("-", "") + extension;
                Path target = STORAGE_ROOT.resolve(storedName);
                Files.move(temporaryFile, target, StandardCopyOption.ATOMIC_MOVE);
                return new StoredDocument(storedName, contentType);
            }
        } catch (IOException | RuntimeException e) {
            Files.deleteIfExists(temporaryFile);
            throw e;
        }
    }

    /** Validates and stores room images or videos; returns the generated file reference. */
    public static StoredDocument storeMedia(Part part) throws IOException {
        if (part == null || part.getSize() <= 0 || part.getSize() > MAX_MEDIA_FILE_SIZE) {
            throw new IllegalArgumentException("Media size must be between 1 byte and 50 MB.");
        }

        Files.createDirectories(STORAGE_ROOT);
        restrictPermissions(STORAGE_ROOT, true);
        // Keep uploads private until signature validation succeeds and the final move completes.
        Path temporaryFile = Files.createTempFile(STORAGE_ROOT, "room-media-", ".upload");
        try {
            restrictPermissions(temporaryFile, false);
            try (InputStream input = part.getInputStream();
                 OutputStream output = Files.newOutputStream(temporaryFile,
                         StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING)) {
                // Check the file signature before accepting media regardless of its claimed type.
                byte[] header = input.readNBytes(12);
                String contentType = detectMediaType(header);
                if (contentType == null) {
                    throw new IllegalArgumentException(
                            "Choose a JPG, PNG, MP4, or WebM file.");
                }
                output.write(header);
                input.transferTo(output);

                String extension = switch (contentType) {
                    case "image/jpeg" -> ".jpg";
                    case "image/png" -> ".png";
                    case "video/mp4" -> ".mp4";
                    default -> ".webm";
                };
                String storedName = UUID.randomUUID().toString().replace("-", "") + extension;
                Files.move(temporaryFile, STORAGE_ROOT.resolve(storedName),
                        StandardCopyOption.ATOMIC_MOVE);
                return new StoredDocument(storedName, contentType);
            }
        } catch (IOException | RuntimeException e) {
            Files.deleteIfExists(temporaryFile);
            throw e;
        }
    }

    /** Resolves a generated filename under the storage root or rejects invalid references. */
    public static Path resolve(String storedName) throws IOException {
        if (storedName == null
                || !storedName.matches("^[0-9a-f]{32}\\.(pdf|png|jpg|mp4|webm)$")) {
            throw new IOException("Invalid stored document reference.");
        }

        Path root = STORAGE_ROOT.toAbsolutePath().normalize();
        Path file = root.resolve(storedName).normalize();
        if (!file.getParent().equals(root) || !Files.isRegularFile(file, LinkOption.NOFOLLOW_LINKS)) {
            throw new IOException("Stored document was not found.");
        }
        return file;
    }

    /** Returns the content type associated with a supported stored-file extension. */
    public static String getContentType(String storedName) {
        if (storedName != null && storedName.endsWith(".pdf")) {
            return "application/pdf";
        }
        if (storedName != null && storedName.endsWith(".png")) {
            return "image/png";
        }
        if (storedName != null && storedName.endsWith(".mp4")) {
            return "video/mp4";
        }
        if (storedName != null && storedName.endsWith(".webm")) {
            return "video/webm";
        }
        return "image/jpeg";
    }

    /** Deletes a previously validated stored file reference. */
    public static void delete(String storedName) throws IOException {
        Files.deleteIfExists(resolve(storedName));
    }

    /** Streams a private verification document as an attachment response. */
    public static void writeResponse(String storedName, HttpServletResponse response)
            throws IOException {
        Path file = resolve(storedName);
        response.setContentType(getContentType(storedName));
        response.setHeader("Content-Disposition", "attachment; filename=\"verification-document\"");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "no-store");
        response.setContentLengthLong(Files.size(file));
        // Stream from the validated path and close the file even if the client disconnects.
        try (InputStream input = Files.newInputStream(file)) {
            input.transferTo(response.getOutputStream());
        }
    }

    /** Streams authorized room media inline with private, no-cache response headers. */
    public static void writeMediaResponse(String storedName, HttpServletResponse response)
            throws IOException {
        Path file = resolve(storedName);
        response.setContentType(getContentType(storedName));
        response.setHeader("Content-Disposition", "inline");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, no-store");
        response.setContentLengthLong(Files.size(file));
        try (InputStream input = Files.newInputStream(file)) {
            input.transferTo(response.getOutputStream());
        }
    }

    /** Resolves the configured upload directory or uses the default user-home location. */
    private static Path getStorageRoot() {
        String configuredDirectory = System.getenv("PARTNER_UPLOAD_DIR");
        if (configuredDirectory == null || configuredDirectory.isBlank()) {
            configuredDirectory = System.getProperty("user.home")
                    + java.io.File.separator + ".homestaybooking"
                    + java.io.File.separator + "partner-documents";
        }
        return Path.of(configuredDirectory).toAbsolutePath().normalize();
    }

    /** Identifies accepted verification documents from their file signatures. */
    private static String detectContentType(byte[] header) {
        if (header.length >= 5 && header[0] == '%'
                && header[1] == 'P' && header[2] == 'D'
                && header[3] == 'F' && header[4] == '-') {
            return "application/pdf";
        }
        if (header.length >= 8 && (header[0] & 0xff) == 0x89
                && header[1] == 'P' && header[2] == 'N' && header[3] == 'G'
                && header[4] == 0x0d && header[5] == 0x0a
                && header[6] == 0x1a && header[7] == 0x0a) {
            return "image/png";
        }
        if (header.length >= 3 && (header[0] & 0xff) == 0xff
                && (header[1] & 0xff) == 0xd8 && (header[2] & 0xff) == 0xff) {
            return "image/jpeg";
        }
        return null;
    }

    /** Identifies supported room images or video from their file signatures. */
    private static String detectMediaType(byte[] header) {
        String imageType = detectContentType(header);
        if (imageType != null && !"application/pdf".equals(imageType)) {
            return imageType;
        }
        if (header.length >= 8 && header[4] == 'f' && header[5] == 't'
                && header[6] == 'y' && header[7] == 'p') {
            return "video/mp4";
        }
        if (header.length >= 4 && (header[0] & 0xff) == 0x1a
                && (header[1] & 0xff) == 0x45 && (header[2] & 0xff) == 0xdf
                && (header[3] & 0xff) == 0xa3) {
            return "video/webm";
        }
        return null;
    }

    /** Restricts filesystem permissions where the platform supports POSIX attributes. */
    private static void restrictPermissions(Path path, boolean directory) throws IOException {
        try {
            Set<PosixFilePermission> permissions = directory
                    ? EnumSet.of(PosixFilePermission.OWNER_READ, PosixFilePermission.OWNER_WRITE,
                    PosixFilePermission.OWNER_EXECUTE)
                    : EnumSet.of(PosixFilePermission.OWNER_READ, PosixFilePermission.OWNER_WRITE);
            Files.setPosixFilePermissions(path, permissions);
        } catch (UnsupportedOperationException ignored) {
            // Windows uses the storage directory's inherited access-control list.
        }
    }

    /** Holds the generated filename and detected content type for a stored upload. */
    public static final class StoredDocument {
        private final String storedName;
        private final String contentType;

        private StoredDocument(String storedName, String contentType) {
            this.storedName = storedName;
            this.contentType = contentType;
        }

        public String getStoredName() {
            return storedName;
        }

        public String getContentType() {
            return contentType;
        }
    }
}
