package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Faq implements Serializable {
    private int id;
    private String category;
    private String question;
    private String answer;
    private int orderIndex;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Faq() {}

    public Faq(int id, String category, String question, String answer, int orderIndex, String status) {
        this.id = id;
        this.category = category;
        this.question = question;
        this.answer = answer;
        this.orderIndex = orderIndex;
        this.status = status;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}