package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Represents an individual attempt to process a payment.
 *
 * Database table: payment_attempts
 */
public class PaymentAttempt implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long paymentAttemptId;
    private Long paymentId;

    private String gateway;
    private String idempotencyKey;
    private String gatewayRequestId;
    private String gatewayTransactionId;

    private BigDecimal expectedAmount;
    private String currency;
    private String status;

    private Timestamp createdAt;
    private Timestamp updatedAt;

    public PaymentAttempt() {
    }

    public Long getPaymentAttemptId() {
        return paymentAttemptId;
    }

    public void setPaymentAttemptId(Long paymentAttemptId) {
        this.paymentAttemptId = paymentAttemptId;
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

    public String getIdempotencyKey() {
        return idempotencyKey;
    }

    public void setIdempotencyKey(String idempotencyKey) {
        this.idempotencyKey = idempotencyKey;
    }

    public String getGatewayRequestId() {
        return gatewayRequestId;
    }

    public void setGatewayRequestId(String gatewayRequestId) {
        this.gatewayRequestId = gatewayRequestId;
    }

    public String getGatewayTransactionId() {
        return gatewayTransactionId;
    }

    public void setGatewayTransactionId(String gatewayTransactionId) {
        this.gatewayTransactionId = gatewayTransactionId;
    }

    public BigDecimal getExpectedAmount() {
        return expectedAmount;
    }

    public void setExpectedAmount(BigDecimal expectedAmount) {
        this.expectedAmount = expectedAmount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
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

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}