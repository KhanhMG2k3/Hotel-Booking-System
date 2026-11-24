package com.homestay.model;

import java.sql.Timestamp;

/** Represents an applicant's Host request, property details, and review state. */
public class HostApplication {
    /** Lists the lifecycle states used for a Host application. */
    public enum Status {
        DRAFT,
        PENDING,
        APPROVED,
        REJECTED
    }

    /** Lists the accepted identity document categories. */
    public enum IdentificationType {
        NATIONAL_ID,
        PASSPORT,
        OTHER
    }

    /** Lists the verification states for submitted documents. */
    public enum DocumentStatus {
        PENDING,
        VERIFIED,
        REJECTED
    }

    private int id;
    private int userId;
    private Integer supersedesApplicationId;
    private String applicationNote;
    private Status status;
    private Timestamp submittedAt;
    private Integer reviewedBy;
    private String reviewerName;
    private Timestamp reviewedAt;
    private String rejectionReason;
    private String applicantName;
    private String applicantEmail;
    private String applicantPhone;
    private IdentificationType identificationType;
    private String identificationNumber;
    private String propertyName;
    private String propertyType;
    private String propertyDescription;
    private String propertyAddress;
    private String propertyCity;
    private String propertyDistrict;
    private String propertyWard;
    private Double latitude;
    private Double longitude;
    private Integer roomCount;
    private Integer maxGuests;
    private String identityDocumentUrl;
    private String ownershipDocumentUrl;
    private String businessDocumentUrl;
    private DocumentStatus documentStatus;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getSupersedesApplicationId() {
        return supersedesApplicationId;
    }

    public void setSupersedesApplicationId(Integer supersedesApplicationId) {
        this.supersedesApplicationId = supersedesApplicationId;
    }

    public String getApplicationNote() {
        return applicationNote;
    }

    public void setApplicationNote(String applicationNote) {
        this.applicationNote = applicationNote;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    /** Returns whether this application is currently a draft. */
    public boolean isDraft() {
        return status == Status.DRAFT;
    }

    /** Returns whether this application was rejected by an administrator. */
    public boolean isRejected() {
        return status == Status.REJECTED;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Timestamp submittedAt) {
        this.submittedAt = submittedAt;
    }

    public Integer getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Integer reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }

    public Timestamp getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public String getApplicantName() {
        return applicantName;
    }

    public void setApplicantName(String applicantName) {
        this.applicantName = applicantName;
    }

    public String getApplicantEmail() {
        return applicantEmail;
    }

    public void setApplicantEmail(String applicantEmail) {
        this.applicantEmail = applicantEmail;
    }

    public String getApplicantPhone() {
        return applicantPhone;
    }

    public void setApplicantPhone(String applicantPhone) {
        this.applicantPhone = applicantPhone;
    }

    public IdentificationType getIdentificationType() {
        return identificationType;
    }

    public void setIdentificationType(IdentificationType identificationType) {
        this.identificationType = identificationType;
    }

    public String getIdentificationNumber() {
        return identificationNumber;
    }

    public void setIdentificationNumber(String identificationNumber) {
        this.identificationNumber = identificationNumber;
    }

    public String getPropertyName() {
        return propertyName;
    }

    public void setPropertyName(String propertyName) {
        this.propertyName = propertyName;
    }

    public String getPropertyType() {
        return propertyType;
    }

    public void setPropertyType(String propertyType) {
        this.propertyType = propertyType;
    }

    public String getPropertyDescription() {
        return propertyDescription;
    }

    public void setPropertyDescription(String propertyDescription) {
        this.propertyDescription = propertyDescription;
    }

    public String getPropertyAddress() {
        return propertyAddress;
    }

    public void setPropertyAddress(String propertyAddress) {
        this.propertyAddress = propertyAddress;
    }

    public String getPropertyCity() {
        return propertyCity;
    }

    public void setPropertyCity(String propertyCity) {
        this.propertyCity = propertyCity;
    }

    public String getPropertyDistrict() {
        return propertyDistrict;
    }

    public void setPropertyDistrict(String propertyDistrict) {
        this.propertyDistrict = propertyDistrict;
    }

    public String getPropertyWard() {
        return propertyWard;
    }

    public void setPropertyWard(String propertyWard) {
        this.propertyWard = propertyWard;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Integer getRoomCount() {
        return roomCount;
    }

    public void setRoomCount(Integer roomCount) {
        this.roomCount = roomCount;
    }

    public Integer getMaxGuests() {
        return maxGuests;
    }

    public void setMaxGuests(Integer maxGuests) {
        this.maxGuests = maxGuests;
    }

    public String getIdentityDocumentUrl() {
        return identityDocumentUrl;
    }

    public void setIdentityDocumentUrl(String identityDocumentUrl) {
        this.identityDocumentUrl = identityDocumentUrl;
    }

    public String getOwnershipDocumentUrl() {
        return ownershipDocumentUrl;
    }

    public void setOwnershipDocumentUrl(String ownershipDocumentUrl) {
        this.ownershipDocumentUrl = ownershipDocumentUrl;
    }

    public String getBusinessDocumentUrl() {
        return businessDocumentUrl;
    }

    public void setBusinessDocumentUrl(String businessDocumentUrl) {
        this.businessDocumentUrl = businessDocumentUrl;
    }

    public DocumentStatus getDocumentStatus() {
        return documentStatus;
    }

    public void setDocumentStatus(DocumentStatus documentStatus) {
        this.documentStatus = documentStatus;
    }
}
