package com.homestay.model;

import java.sql.Timestamp;

/**
 * Represents an incoming payment gateway event.
 *
 * Storing an event does not mean that the payment
 * has been verified or completed.
 */
public class PaymentEvent {

    private Long paymentEventId;
    private Long paymentId;

    private String gateway;
    private String gatewayEventId;
    private String eventType;

    private String verificationStatus;
    private String processingStatus;

    private String payloadSha256;

    private Timestamp receivedAt;
    private Timestamp processedAt;

    public PaymentEvent() {
    }

    public Long getPaymentEventId() {
        return paymentEventId;
    }

    public void setPaymentEventId(Long paymentEventId) {
        this.paymentEventId = paymentEventId;
    }

    public Long getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(Long paymentId) {
        this.paymentId = paymentId;
    }

    public String getGateway() {
        return gateway;
    }

    public void setGateway(String gateway) {
        this.gateway = gateway;
    }

    public String getGatewayEventId() {
        return gatewayEventId;
    }

    public void setGatewayEventId(String gatewayEventId) {
        this.gatewayEventId = gatewayEventId;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public String getProcessingStatus() {
        return processingStatus;
    }

    public void setProcessingStatus(String processingStatus) {
        this.processingStatus = processingStatus;
    }

    public String getPayloadSha256() {
        return payloadSha256;
    }

    public void setPayloadSha256(String payloadSha256) {
        this.payloadSha256 = payloadSha256;
    }

    public Timestamp getReceivedAt() {
        return receivedAt;
    }

    public void setReceivedAt(Timestamp receivedAt) {
        this.receivedAt = receivedAt;
    }

    public Timestamp getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(Timestamp processedAt) {
        this.processedAt = processedAt;
    }
}