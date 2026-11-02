package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AboutUs implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * Class đại diện cho 1 Thẻ Lý Do / Cam Kết động
     */
    public static class CommitCard implements Serializable {
        private static final long serialVersionUID = 1L;
        private String icon;
        private String title;
        private String description;

        public CommitCard() {}

        public CommitCard(String icon, String title, String description) {
            this.icon = icon;
            this.title = title;
            this.description = description;
        }

        public String getIcon() { return icon; }
        public void setIcon(String icon) { this.icon = icon; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
    }

    private int id;
    private String title;
    private String introContent;
    private String btnExploreText;
    private String btnBookText;
    private String commitTitle;
    private List<CommitCard> commitCards = new ArrayList<>();
    private String teamTitle;
    private List<Integer> teamUserIds = new ArrayList<>();
    private List<User> teamMembers = new ArrayList<>();
    private Timestamp updatedAt;

    public AboutUs() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getIntroContent() { return introContent; }
    public void setIntroContent(String introContent) { this.introContent = introContent; }

    public String getBtnExploreText() { return btnExploreText; }
    public void setBtnExploreText(String btnExploreText) { this.btnExploreText = btnExploreText; }

    public String getBtnBookText() { return btnBookText; }
    public void setBtnBookText(String btnBookText) { this.btnBookText = btnBookText; }

    public String getCommitTitle() { return commitTitle; }
    public void setCommitTitle(String commitTitle) { this.commitTitle = commitTitle; }

    public List<CommitCard> getCommitCards() { return commitCards; }
    public void setCommitCards(List<CommitCard> commitCards) { this.commitCards = commitCards; }

    public String getTeamTitle() { return teamTitle; }
    public void setTeamTitle(String teamTitle) { this.teamTitle = teamTitle; }

    public List<Integer> getTeamUserIds() { return teamUserIds; }
    public void setTeamUserIds(List<Integer> teamUserIds) { this.teamUserIds = teamUserIds; }

    public List<User> getTeamMembers() { return teamMembers; }
    public void setTeamMembers(List<User> teamMembers) { this.teamMembers = teamMembers; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}