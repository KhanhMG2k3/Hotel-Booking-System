package com.homestay.model;

import java.io.Serializable;

/**
 * Province Model - Represents administrative provinces/cities for homestay locations.
 */
public class Province implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int countryId;
    private String provinceName;

    public Province() {
    }

    public Province(int id, int countryId, String provinceName) {
        this.id = id;
        this.countryId = countryId;
        this.provinceName = provinceName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCountryId() {
        return countryId;
    }

    public void setCountryId(int countryId) {
        this.countryId = countryId;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }

    @Override
    public String toString() {
        return "Province{" +
                "id=" + id +
                ", provinceName='" + provinceName + '\'' +
                '}';
    }
}
