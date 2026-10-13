package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Room Model - Represents homestay rooms and their details.
 */
public class Room implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int typeId;
    private RoomType roomType;
    private String roomNumber;
    private String roomName;
    private String location;
    private BigDecimal pricePerNight;
    private int capacity;
    private Double size;
    private String bedType;
    private String imageUrl;
    private List<String> images = new ArrayList<>();
    private List<String> amenities = new ArrayList<>();
    private String description;
    private String status;
    private boolean isFeatured;
    private double rating = 5.0;
    private int reviewCount = 10;
    private Integer provinceId;
    private String provinceName;
    private String propertyName;
    private String address;
    private Timestamp createdAt;

    public Room() {
    }

    public Room(int id, int typeId, String roomNumber, String roomName, BigDecimal pricePerNight, int capacity, String imageUrl, String description, String status, boolean isFeatured, Timestamp createdAt) {
        this.id = id;
        this.typeId = typeId;
        this.roomNumber = roomNumber;
        this.roomName = roomName;
        this.pricePerNight = pricePerNight;
        this.capacity = capacity;
        this.imageUrl = imageUrl;
        this.description = description;
        this.status = status;
        this.isFeatured = isFeatured;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public RoomType getRoomType() {
        return roomType;
    }

    public void setRoomType(RoomType roomType) {
        this.roomType = roomType;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public BigDecimal getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(BigDecimal pricePerNight) {
        this.pricePerNight = pricePerNight;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public Double getSize() {
        return size;
    }

    public void setSize(Double size) {
        this.size = size;
    }

    public String getBedType() {
        return bedType;
    }

    public void setBedType(String bedType) {
        this.bedType = bedType;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }

    public List<String> getAmenities() {
        return amenities;
    }

    public void setAmenities(List<String> amenities) {
        this.amenities = amenities;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isFeatured() {
        return isFeatured;
    }

    public void setFeatured(boolean featured) {
        isFeatured = featured;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public Integer getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(Integer provinceId) {
        this.provinceId = provinceId;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }

    public String getPropertyName() {
        return propertyName;
    }

    public void setPropertyName(String propertyName) {
        this.propertyName = propertyName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "Room{" +
                "id=" + id +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomName='" + roomName + '\'' +
                ", pricePerNight=" + pricePerNight +
                ", capacity=" + capacity +
                ", status='" + status + '\'' +
                '}';
    }
}
