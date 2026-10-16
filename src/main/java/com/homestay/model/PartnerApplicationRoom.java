package com.homestay.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/** Represents a room and its media within a Host application. */
public class PartnerApplicationRoom {
    private int id;
    private int applicationId;
    private String roomName;
    private String roomType;
    private BigDecimal pricePerNight;
    private int maxGuests;
    private int bedCount;
    private int bathroomCount;
    private int sortOrder;
    private String clientRoomKey;
    private List<String> amenities = new ArrayList<>();
    private List<RoomImage> images = new ArrayList<>();

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

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public BigDecimal getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(BigDecimal pricePerNight) {
        this.pricePerNight = pricePerNight;
    }

    public int getMaxGuests() {
        return maxGuests;
    }

    public void setMaxGuests(int maxGuests) {
        this.maxGuests = maxGuests;
    }

    public int getBedCount() {
        return bedCount;
    }

    public void setBedCount(int bedCount) {
        this.bedCount = bedCount;
    }

    public int getBathroomCount() {
        return bathroomCount;
    }

    public void setBathroomCount(int bathroomCount) {
        this.bathroomCount = bathroomCount;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }

    public String getClientRoomKey() {
        return clientRoomKey;
    }

    public void setClientRoomKey(String clientRoomKey) {
        this.clientRoomKey = clientRoomKey;
    }

    public List<String> getAmenities() {
        return amenities;
    }

    public void setAmenities(List<String> amenities) {
        this.amenities = amenities == null ? new ArrayList<>() : new ArrayList<>(amenities);
    }

    public List<RoomImage> getImages() {
        return images;
    }

    public void setImages(List<RoomImage> images) {
        this.images = images == null ? new ArrayList<>() : new ArrayList<>(images);
    }

    /** Represents one image attached to an application room. */
    public static class RoomImage {
        private int id;
        private String mediaType;
        private String contentType;
        private int sortOrder;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
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
    }
}
