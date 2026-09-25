package com.homestay.model;

import java.sql.Timestamp;

public class Property {

    private int id;
    private int hostId;
    private String name;
    private String description;
    private String propertyType;
    private String address;
    private String city;
    private String country;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Property() {
    }

    public Property(
            int hostId,
            String name,
            String description,
            String propertyType,
            String address,
            String city,
            String country) {
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPropertyType() {
        return propertyType;
    }

    public void setPropertyType(String propertyType) {
        this.propertyType = propertyType;
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

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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
}