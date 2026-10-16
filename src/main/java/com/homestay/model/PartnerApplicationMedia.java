package com.homestay.model;

import java.sql.Timestamp;

// --- START: PartnerApplicationMedia Model Definition ---
/**
 * Purpose: Represents media staged for a Host application before room submission.
 * This entity holds image/video metadata for rooms being proposed by a Partner.
 */
public class PartnerApplicationMedia {
    // Model Attributes
    private int id; // Primary key for media record
    private int applicationId; // Foreign key linking to HostApplication
    private String clientRoomKey; // Temporary identifier used by the client UI
    private String storedName; // Name of the file as saved on disk/storage
    private String mediaType; // E.g., IMAGE, VIDEO
    private String contentType; // MIME type (e.g., image/jpeg)
    private int sortOrder; // Order of display
    private Timestamp createdAt; // When the media was uploaded

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(int applicationId) {
        this.applicationId = applicationId;
    }

    public String getClientRoomKey() {
        return clientRoomKey;
    }

    public void setClientRoomKey(String clientRoomKey) {
        this.clientRoomKey = clientRoomKey;
    }

    public String getStoredName() {
        return storedName;
    }

    public void setStoredName(String storedName) {
        this.storedName = storedName;
    }

    public String getMediaType() {
        return mediaType;
    }

    public void setMediaType(String mediaType) {
        this.mediaType = mediaType;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
// --- END: PartnerApplicationMedia Model Definition ---
