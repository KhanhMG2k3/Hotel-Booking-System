package com.homestay.model;

import java.io.Serializable;
import java.sql.Date;
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
    private String displayName;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String avatarUrl;
    private String status = "ACTIVE";
    private boolean twoFactorEnabled = false;
    private Timestamp createdAt;
    private String googleId;
    private String authProvider = "local";
    private Date dateOfBirth;
    private String gender;
    private String address;

    public User() {
    }

    public User(int id, int roleId, String username, String password, String fullName, String email, String phone, String status, Timestamp createdAt) {
        this.id = id;
        this.roleId = roleId;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.displayName = fullName;
        this.email = email;
        this.phone = phone;
        this.status = status;
        this.createdAt = createdAt;
    }

    public User(String username, String password) {
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
        if (role != null) {
            this.roleId = role.getId();
        }
    }

    public void setRole(UserRole userRole) {
        if (userRole != null) {
            Role r = new Role();
            r.setId(userRole.getId());
            r.setRoleName(userRole.getName());
            this.role = r;
            this.roleId = userRole.getId();
        }
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getDisplayName() {
        if (displayName != null && !displayName.isBlank()) {
            return displayName;
        }
        return fullName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
        if (this.fullName == null || this.fullName.isBlank()) {
            this.fullName = displayName;
        }
    }

    public String getFullName() {
        if (fullName != null && !fullName.isBlank()) {
            return fullName;
        }
        return displayName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
        if (this.displayName == null || this.displayName.isBlank()) {
            this.displayName = fullName;
        }
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isTwoFactorEnabled() {
        return twoFactorEnabled;
    }

    public void setTwoFactorEnabled(boolean twoFactorEnabled) {
        this.twoFactorEnabled = twoFactorEnabled;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

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

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
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
