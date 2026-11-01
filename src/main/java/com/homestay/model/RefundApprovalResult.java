package com.homestay.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * RefundApprovalResult - Value object returned when attempting to approve a refund with wallet balance check.
 */
public class RefundApprovalResult implements Serializable {

    private static final long serialVersionUID = 1L;

    private final boolean success;
    private final String message;
    private final boolean insufficientBalance;
    private final BigDecimal currentBalance;
    private final BigDecimal requiredAmount;

    private RefundApprovalResult(boolean success, String message, boolean insufficientBalance,
                                 BigDecimal currentBalance, BigDecimal requiredAmount) {
        this.success = success;
        this.message = message;
        this.insufficientBalance = insufficientBalance;
        this.currentBalance = currentBalance;
        this.requiredAmount = requiredAmount;
    }

    public static RefundApprovalResult success(String message, BigDecimal newBalance) {
        return new RefundApprovalResult(true, message, false, newBalance, BigDecimal.ZERO);
    }

    public static RefundApprovalResult insufficientBalance(BigDecimal currentBalance, BigDecimal requiredAmount) {
        String msg = String.format("Số dư ví Host không đủ để duyệt hoàn tiền (Số dư hiện tại: %,.0f VNĐ, Cần hoàn: %,.0f VNĐ). Vui lòng nạp thêm tiền vào ví!",
                currentBalance, requiredAmount);
        return new RefundApprovalResult(false, msg, true, currentBalance, requiredAmount);
    }

    public static RefundApprovalResult failure(String message) {
        return new RefundApprovalResult(false, message, false, BigDecimal.ZERO, BigDecimal.ZERO);
    }

    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public boolean isInsufficientBalance() {
        return insufficientBalance;
    }

    public BigDecimal getCurrentBalance() {
        return currentBalance;
    }

    public BigDecimal getRequiredAmount() {
        return requiredAmount;
    }
}
