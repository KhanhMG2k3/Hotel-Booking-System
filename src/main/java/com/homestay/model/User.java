package com.homestay.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * User Model - Represents user accounts in the homestay system.
 */
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int roleId;
    private Role role;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String phone;
    private String status;
    private Timestamp createdAt;
    // Cập nhật User.java — thêm 3 field còn thiếu. Thêm vào ngay sau createdAt
    private String googleId;
    private String authProvider = "local"; // mặc định local nếu không set
    private String avatarUrl;

    public User() {
    }

    public User(int id, int roleId, String username, String password, String fullName, String email, String phone, String status, Timestamp createdAt) {
        this.id = id;
        this.roleId = roleId;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.status = status;
        this.createdAt = createdAt;
    }
    
    public User(String username, String password){
        this.username = username;
        this.password = password;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
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

    // Và thêm getter/setter tương ứng (đặt sau getCreatedAt()/setCreatedAt()):
    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getAuthProvider() {
        return authProvider;
    }

    public void setAuthProvider(String authProvider) {
        this.authProvider = authProvider;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    @Override
    public String toString() {
        return "User{"
                + "id=" + id
                + ", username='" + username + '\''
                + ", fullName='" + fullName + '\''
                + ", email='" + email + '\''
                + ", phone='" + phone + '\''
                + ", status='" + status + '\''
                + '}';
    }
}
