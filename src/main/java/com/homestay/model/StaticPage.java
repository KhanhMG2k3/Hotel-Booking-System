package com.homestay.model;

import java.sql.Timestamp;

/**
 * Model đại diện cho nội dung trang tĩnh (About Us, Terms & Conditions,...)
 */
public class StaticPage {
    private int id;
    private String slug;
    private String title;
    private String metaDescription;
    private String content;
    private Timestamp updatedAt;

    public StaticPage() {
    }

    public StaticPage(int id, String slug, String title, String metaDescription, String content, Timestamp updatedAt) {
        this.id = id;
        this.slug = slug;
        this.title = title;
        this.metaDescription = metaDescription;
        this.content = content;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMetaDescription() {
        return metaDescription;
    }

    public void setMetaDescription(String metaDescription) {
        this.metaDescription = metaDescription;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}