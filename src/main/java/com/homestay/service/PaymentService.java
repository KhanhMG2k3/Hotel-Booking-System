package com.homestay.service;

import com.homestay.context.DBContext;
import com.homestay.dao.BookingDAO;
import com.homestay.dao.PaymentDAO;
import com.homestay.model.Booking;
import com.homestay.model.Payment;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

/**
 * Coordinates creation of pending payments for room bookings.
 *
 * Does not communicate with a payment gateway or confirm payment success.
 */
public class PaymentService {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    /**
     * Creates or reuses a pending payment for an eligible booking.
     *
     * Locks the booking first to serialize concurrent requests
     * for the same booking.
     */
    public Payment createPendingPayment(
            long bookingId,
            long userId,
            String paymentMethod) throws SQLException {

        if (bookingId <= 0 || userId <= 0) {
            throw new IllegalArgumentException(
                    "Invalid booking or user ID"
            );
        }

        if (!"VNPAY".equals(paymentMethod)
                && !"MOMO".equals(paymentMethod)
                && !"VIETQR".equals(paymentMethod)
                && !"BANK_TRANSFER".equals(paymentMethod)) {
            throw new IllegalArgumentException(
                    "Unsupported payment method: " + paymentMethod
            );
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try {
                Booking booking = bookingDAO.findByIdForUpdate(
                        conn,
                        bookingId
                );

                if (booking == null) {
                    throw new IllegalArgumentException(
                            "Booking not found"
                    );
                }

                if (booking.getUserId() == null
                        || booking.getUserId().longValue() != userId) {
                    throw new SecurityException(
                            "Booking does not belong to the user"
                    );
                }

                if (!isBookingPending(conn, bookingId)) {
                    throw new IllegalStateException(
                            "Booking is not pending"
                    );
                }

                BigDecimal amount = booking.getTotalAmount();

                if (amount == null || amount.signum() <= 0) {
                    throw new IllegalStateException(
                            "Booking amount must be positive"
                    );
                }

                // Prevent creating another payment after this booking
                // has already been paid or refunded.
                if (hasCompletedPayment(conn, bookingId)) {
                    throw new IllegalStateException(
                            "Booking already has a completed payment"
                    );
                }

                Payment existing = paymentDAO.findPendingByBookingId(
                        conn,
                        bookingId
                );

                if (existing != null) {
                    if (existing.getAmount() == null
                            || existing.getAmount().compareTo(amount) != 0) {
                        throw new IllegalStateException(
                                "Existing pending payment does not match amount"
                        );
                    }

                    conn.commit();
                    return existing;
                }

                Payment payment = new Payment();
                payment.setPaymentCode(
                        "PAY-" + UUID.randomUUID()
                );
                payment.setUserId(userId);
                payment.setBookingId(bookingId);
                payment.setAmount(amount);
                payment.setPaymentMethod(paymentMethod);

                paymentDAO.insertPending(conn, payment);

                conn.commit();
                return payment;

            } catch (SQLException | RuntimeException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }

                throw e;
            }
        }
    }

    /**
     * Checks the authoritative booking_status column.
     */
    private boolean isBookingPending(
            Connection conn,
            long bookingId) throws SQLException {

        String sql = """
                SELECT booking_status
                FROM bookings
                WHERE booking_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        && "PENDING".equals(
                                rs.getString("booking_status")
                        );
            }
        }
    }

    /**
     * Blocks new payments when an earlier payment succeeded
     * or has already been refunded.
     */
    private boolean hasCompletedPayment(
            Connection conn,
            long bookingId) throws SQLException {

        String sql = """
                SELECT payment_id
                FROM payments
                WHERE booking_id = ?
                  AND status IN ('SUCCESS', 'REFUNDED')
                LIMIT 1
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
