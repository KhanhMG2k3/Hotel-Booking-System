package com.homestay.dao;

import com.homestay.context.DBContext;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class CreateBookingRoomsTableTest {

    @Test
    public void ensureBookingRoomsTableExists() {
        String createSql = "CREATE TABLE IF NOT EXISTS `bookingrooms` (" +
                           "  `booking_room_id` INT NOT NULL AUTO_INCREMENT," +
                           "  `booking_id` INT NOT NULL," +
                           "  `room_id` INT NOT NULL," +
                           "  `price_per_night` DECIMAL(18, 2) NOT NULL DEFAULT 0.00," +
                           "  `number_of_nights` INT NOT NULL DEFAULT 1," +
                           "  `subtotal` DECIMAL(18, 2) NOT NULL DEFAULT 0.00," +
                           "  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                           "  PRIMARY KEY (`booking_room_id`)," +
                           "  KEY `idx_bookingrooms_booking` (`booking_id`)," +
                           "  KEY `idx_bookingrooms_room` (`room_id`)," +
                           "  CONSTRAINT `fk_bookingrooms_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE," +
                           "  CONSTRAINT `fk_bookingrooms_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE" +
                           ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;";

        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createSql);
            System.out.println("Table bookingrooms executed successfully!");

            try (ResultSet rs = stmt.executeQuery("SHOW TABLES LIKE 'bookingrooms'")) {
                assertTrue(rs.next(), "Table bookingrooms should exist now");
                System.out.println("Verified table bookingrooms exists: " + rs.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
            org.junit.jupiter.api.Assertions.fail("Failed to verify/create bookingrooms: " + e.getMessage());
        }
    }
}
