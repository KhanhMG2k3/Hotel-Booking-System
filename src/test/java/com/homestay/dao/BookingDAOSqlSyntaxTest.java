package com.homestay.dao;

import com.homestay.model.Booking;
import org.junit.jupiter.api.Test;

import java.sql.SQLException;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertNotNull;

public class BookingDAOSqlSyntaxTest {

    @Test
    public void testFindBookingsByHostQuery() {
        BookingDAO dao = new BookingDAO();
        try {
            List<Booking> list = dao.findBookingsByHost(1, 10, 0);
            assertNotNull(list);
        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().contains("SQL syntax")) {
                org.junit.jupiter.api.Assertions.fail("SQL syntax error in findBookingsByHost: " + e.getMessage());
            }
        }
    }

    @Test
    public void testFindByBookingCodeQuery() {
        BookingDAO dao = new BookingDAO();
        try {
            dao.findByBookingCode("TEST-CODE");
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains("SQL syntax")) {
                org.junit.jupiter.api.Assertions.fail("SQL syntax error in findByBookingCode: " + e.getMessage());
            }
        }
    }
}
