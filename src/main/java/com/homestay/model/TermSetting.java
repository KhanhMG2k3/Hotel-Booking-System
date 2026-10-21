package com.homestay.model;

import java.io.Serializable;

public class TermSetting implements Serializable {
    private int id;
    private String mainTitle;
    private String lastUpdated;

    public TermSetting() {}

    public TermSetting(String mainTitle, String lastUpdated) {
        this.mainTitle = mainTitle;
        this.lastUpdated = lastUpdated;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getMainTitle() { return mainTitle; }
    public void setMainTitle(String mainTitle) { this.mainTitle = mainTitle; }

    public String getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(String lastUpdated) { this.lastUpdated = lastUpdated; }
}