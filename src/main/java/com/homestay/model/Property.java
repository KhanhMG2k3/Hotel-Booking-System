package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Property Model - Represents a rental property (Homestay).
 */
public class Property implements Serializable {

    private static final long serialVersionUID = 1L;

    public enum Status {
        ACTIVE,
        INACTIVE,
        DRAFT
    }

    private int id;
    private int hostId;
    private int applicationId;
    private String name;
    private String propertyType;
    private String description;
    private String address;
    private String city;
    private String district;
    private String ward;
    private String country = "Vietnam";
    private Double latitude;
    private Double longitude;
    private int roomCount;
    private int maxGuests;
    private String status = "ACTIVE";
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<Room> rooms = new ArrayList<>();

    public Property() {
    }

    public Property(int hostId, String name, String description, String propertyType, String address, String city, String country) {
        this.hostId = hostId;
        this.name = name;
        this.description = description;
        this.propertyType = propertyType;
        this.address = address;
        this.city = city;
        this.country = country;
        this.status = "DRAFT";
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getHostId() {
        return hostId;
    }

    public void setHostId(int hostId) {
        this.hostId = hostId;
    }

    public int getOwnerId() {
        return hostId;
    }

    public void setOwnerId(int ownerId) {
        this.hostId = ownerId;
    }

    public int getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(int applicationId) {
        this.applicationId = applicationId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPropertyName() {
        return name;
    }

    public void setPropertyName(String propertyName) {
        this.name = propertyName;
    }

    public String getPropertyType() {
        return propertyType;
    }

    public void setPropertyType(String propertyType) {
        this.propertyType = propertyType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getWard() {
        return ward;
    }

    public void setWard(String ward) {
        this.ward = ward;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public int getRoomCount() {
        return roomCount;
    }

    public void setRoomCount(int roomCount) {
        this.roomCount = roomCount;
    }

    public int getMaxGuests() {
        return maxGuests;
    }

    public void setMaxGuests(int maxGuests) {
        this.maxGuests = maxGuests;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setStatus(Status status) {
        this.status = status != null ? status.name() : "ACTIVE";
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<Room> getRooms() {
        return rooms;
    }

    public void setRooms(List<Room> rooms) {
        this.rooms = rooms == null ? new ArrayList<>() : new ArrayList<>(rooms);
    }
}
