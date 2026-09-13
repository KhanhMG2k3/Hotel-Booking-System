package com.homestay.model;

import java.io.Serializable;

/**
 * RoomType Model - Represents types/categories of homestay rooms.
 */
public class RoomType implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String typeName;
    private String description;

    public RoomType() {
    }

    public RoomType(int id, String typeName, String description) {
        this.id = id;
        this.typeName = typeName;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "RoomType{" +
                "id=" + id +
                ", typeName='" + typeName + '\'' +
                ", description='" + description + '\'' +
                '}';
    }
}
