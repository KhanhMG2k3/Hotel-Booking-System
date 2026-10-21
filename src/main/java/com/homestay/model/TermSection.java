package com.homestay.model;

import java.io.Serializable;

public class TermSection implements Serializable {
    private int id;
    private int sectionOrder;
    private String sidebarTitle;
    private String contentTitle;
    private String contentType;
    private String contentText;
    private String tableJson;
    private String calloutText;
    private String calloutType;

    public TermSection() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSectionOrder() { return sectionOrder; }
    public void setSectionOrder(int sectionOrder) { this.sectionOrder = sectionOrder; }

    public String getSidebarTitle() { return sidebarTitle; }
    public void setSidebarTitle(String sidebarTitle) { this.sidebarTitle = sidebarTitle; }

    public String getContentTitle() { return contentTitle; }
    public void setContentTitle(String contentTitle) { this.contentTitle = contentTitle; }

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }

    public String getContentText() { return contentText; }
    public void setContentText(String contentText) { this.contentText = contentText; }

    public String getTableJson() { return tableJson; }
    public void setTableJson(String tableJson) { this.tableJson = tableJson; }

    public String getCalloutText() { return calloutText; }
    public void setCalloutText(String calloutText) { this.calloutText = calloutText; }

    public String getCalloutType() { return calloutType; }
    public void setCalloutType(String calloutType) { this.calloutType = calloutType; }
}