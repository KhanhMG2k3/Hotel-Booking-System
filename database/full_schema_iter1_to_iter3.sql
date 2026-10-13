-- =============================================================================
-- SOGO HOMESTAY BOOKING SYSTEM - COMPREHENSIVE DATABASE SCRIPT
-- =============================================================================
-- Target Database: MySQL 8.0+
-- Character Set  : utf8mb4 (utf8mb4_0900_ai_ci / utf8mb4_unicode_ci)
-- Scope          : Complete Iteration 1 -> Iteration 3
-- Modules        : 
--   1. Core System & Authentication (Roles, Users, UserRoles)
--   2. Geography & Catalog (Countries, Provinces, Destinations, Properties, Rooms, Amenities)
--   3. Booking Lifecycle (Bookings, BookingRooms, BookingGuests)
--   4. QR Code & Payments (SystemBankAccounts, Payments, PaymentQRCodes)
--   5. Marketing & Support (Coupons, Wishlists, Notifications, FAQs, ContactMessages)
--   6. Reviews & Tours (Reviews, Replies, Tours, Itineraries, Schedules, Bookings)
--   7. AI Assistant & Loyalty (Conversations, Messages, LoyaltyPoints, Recommendations)
--   8. Role Dashboards (AdminLogs, PlatformConfigs, HostPayouts, DailyAnalytics, Announcements, Views)
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

-- =============================================================================
-- 0. TẠO & CHỌN DATABASE
-- =============================================================================
CREATE DATABASE IF NOT EXISTS `homestaybooking`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE `homestaybooking`;

-- =============================================================================
-- DROP VIEWS & TABLES THEO THỨ TỰ AN TOÀN
-- =============================================================================
DROP VIEW IF EXISTS `v_customer_dashboard_summary`;
DROP VIEW IF EXISTS `v_host_dashboard_summary`;
DROP VIEW IF EXISTS `v_admin_dashboard_summary`;
DROP VIEW IF EXISTS `room_types`;

DROP TABLE IF EXISTS `dashboard_announcements`;
DROP TABLE IF EXISTS `host_daily_analytics`;
DROP TABLE IF EXISTS `host_payouts`;
DROP TABLE IF EXISTS `admin_activity_logs`;
DROP TABLE IF EXISTS `platform_configs`;
DROP TABLE IF EXISTS `payment_qr_codes`;
DROP TABLE IF EXISTS `system_bank_accounts`;
DROP TABLE IF EXISTS `recommendations`;
DROP TABLE IF EXISTS `usersegments`;
DROP TABLE IF EXISTS `userpreferences`;
DROP TABLE IF EXISTS `userbehaviors`;
DROP TABLE IF EXISTS `searchhistories`;
DROP TABLE IF EXISTS `chatmessages`;
DROP TABLE IF EXISTS `conversationmembers`;
DROP TABLE IF EXISTS `conversations`;
DROP TABLE IF EXISTS `tourbookingguests`;
DROP TABLE IF EXISTS `tourbookings`;
DROP TABLE IF EXISTS `tourschedules`;
DROP TABLE IF EXISTS `touritineraries`;
DROP TABLE IF EXISTS `tourimages`;
DROP TABLE IF EXISTS `tours`;
DROP TABLE IF EXISTS `loyaltytransactions`;
DROP TABLE IF EXISTS `reviewreplies`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `faqs`;
DROP TABLE IF EXISTS `contactmessages`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `wishlists`;
DROP TABLE IF EXISTS `couponusages`;
DROP TABLE IF EXISTS `coupons`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `bookingguests`;
DROP TABLE IF EXISTS `bookingrooms`;
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `roomtypeamenities`;
DROP TABLE IF EXISTS `roomimages`;
DROP TABLE IF EXISTS `rooms`;
DROP TABLE IF EXISTS `roomtypes`;
DROP TABLE IF EXISTS `propertyamenities`;
DROP TABLE IF EXISTS `propertyimages`;
DROP TABLE IF EXISTS `properties`;
DROP TABLE IF EXISTS `host_profiles`;
DROP TABLE IF EXISTS `destinations`;
DROP TABLE IF EXISTS `provinces`;
DROP TABLE IF EXISTS `countries`;
DROP TABLE IF EXISTS `amenities`;
DROP TABLE IF EXISTS `userroles`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

-- =============================================================================
-- PHẦN 1: CORE SYSTEM, AUTHENTICATION, GEOGRAPHY & CATALOG
-- =============================================================================

-- 1. BẢNG ROLES (Vai trò người dùng)
CREATE TABLE `roles` (
    `role_id` INT NOT NULL AUTO_INCREMENT,
    `role_name` VARCHAR(50) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`role_id`),
    UNIQUE KEY `uq_roles_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. BẢNG USERS (Tài khoản người dùng)
CREATE TABLE `users` (
    `user_id` BIGINT NOT NULL AUTO_INCREMENT,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `password_hash` VARCHAR(255) DEFAULT NULL,
    `password` VARCHAR(255) DEFAULT NULL,
    `phone` VARCHAR(30) DEFAULT NULL,
    `avatar_url` VARCHAR(500) DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    `email_verified` TINYINT(1) NOT NULL DEFAULT 0,
    `date_of_birth` DATE DEFAULT NULL,
    `gender` VARCHAR(20) DEFAULT NULL,
    `address` VARCHAR(255) DEFAULT NULL,
    `loyalty_points` INT NOT NULL DEFAULT 0,
    `google_id` VARCHAR(100) DEFAULT NULL,
    `auth_provider` VARCHAR(50) NOT NULL DEFAULT 'local',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uq_users_email` (`email`),
    UNIQUE KEY `uq_users_google_id` (`google_id`),
    CONSTRAINT `ck_users_loyalty` CHECK (`loyalty_points` >= 0),
    CONSTRAINT `ck_users_status` CHECK (`status` IN ('ACTIVE', 'INACTIVE', 'BANNED', 'PENDING'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. BẢNG USERROLES (Liên kết User - Role)
CREATE TABLE `userroles` (
    `user_id` BIGINT NOT NULL,
    `role_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    KEY `fk_userroles_roles` (`role_id`),
    CONSTRAINT `fk_userroles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_userroles_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. BẢNG COUNTRIES (Quốc gia)
CREATE TABLE `countries` (
    `country_id` INT NOT NULL AUTO_INCREMENT,
    `country_name` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`country_id`),
    UNIQUE KEY `uq_countries_name` (`country_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. BẢNG PROVINCES (Tỉnh / Thành phố)
CREATE TABLE `provinces` (
    `province_id` INT NOT NULL AUTO_INCREMENT,
    `country_id` INT NOT NULL,
    `province_name` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`province_id`),
    UNIQUE KEY `uq_provinces_country_name` (`country_id`, `province_name`),
    CONSTRAINT `fk_provinces_countries` FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. BẢNG DESTINATIONS (Điểm đến du lịch)
CREATE TABLE `destinations` (
    `destination_id` INT NOT NULL AUTO_INCREMENT,
    `province_id` INT NOT NULL,
    `destination_name` VARCHAR(150) NOT NULL,
    `description` LONGTEXT DEFAULT NULL,
    `image_url` VARCHAR(500) DEFAULT NULL,
    `latitude` DECIMAL(10, 7) DEFAULT NULL,
    `longitude` DECIMAL(10, 7) DEFAULT NULL,
    PRIMARY KEY (`destination_id`),
    KEY `fk_destinations_provinces` (`province_id`),
    CONSTRAINT `fk_destinations_provinces` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`province_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. BẢNG HOST_PROFILES (Hồ sơ chủ nhà Homestay)
CREATE TABLE `host_profiles` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `business_name` VARCHAR(150) NOT NULL,
    `business_type` VARCHAR(50) DEFAULT 'HOMESTAY',
    `phone` VARCHAR(30) DEFAULT NULL,
    `verification_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `rejection_reason` VARCHAR(500) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_host_profiles_user` (`user_id`),
    CONSTRAINT `fk_host_profiles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_host_profiles_status` CHECK (`verification_status` IN ('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. BẢNG PROPERTIES (Cơ sở Homestay / Chỗ nghỉ)
CREATE TABLE `properties` (
    `property_id` BIGINT NOT NULL AUTO_INCREMENT,
    `id` BIGINT DEFAULT NULL,
    `owner_id` BIGINT NOT NULL,
    `host_id` BIGINT DEFAULT NULL,
    `destination_id` INT DEFAULT NULL,
    `property_name` VARCHAR(200) NOT NULL,
    `name` VARCHAR(200) DEFAULT NULL,
    `property_type` VARCHAR(50) NOT NULL DEFAULT 'HOMESTAY',
    `description` LONGTEXT DEFAULT NULL,
    `address` VARCHAR(500) NOT NULL,
    `city` VARCHAR(100) DEFAULT NULL,
    `country` VARCHAR(100) NOT NULL DEFAULT 'Vietnam',
    `star_rating` DECIMAL(2, 1) DEFAULT NULL,
    `review_count` INT NOT NULL DEFAULT 0,
    `average_rating` DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    `status` VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
    `latitude` DECIMAL(10, 7) DEFAULT NULL,
    `longitude` DECIMAL(10, 7) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`property_id`),
    KEY `ix_properties_destination` (`destination_id`),
    KEY `ix_properties_owner` (`owner_id`),
    KEY `ix_properties_host` (`host_id`),
    KEY `ix_properties_rating` (`average_rating`),
    KEY `ix_properties_status` (`status`),
    CONSTRAINT `fk_properties_destination` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_properties_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `ck_properties_rating` CHECK (`average_rating` >= 0 AND `average_rating` <= 5),
    CONSTRAINT `ck_properties_review_count` CHECK (`review_count` >= 0),
    CONSTRAINT `ck_properties_star` CHECK (`star_rating` IS NULL OR (`star_rating` >= 0 AND `star_rating` <= 5)),
    CONSTRAINT `ck_properties_status` CHECK (`status` IN ('PENDING', 'APPROVED', 'REJECTED', 'INACTIVE', 'DRAFT', 'PUBLISHED', 'SUSPENDED')),
    CONSTRAINT `ck_properties_type` CHECK (`property_type` IN ('HOTEL', 'RESORT', 'HOMESTAY', 'VILLA', 'APARTMENT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 9. BẢNG PROPERTYIMAGES (Hình ảnh Property)
CREATE TABLE `propertyimages` (
    `image_id` BIGINT NOT NULL AUTO_INCREMENT,
    `property_id` BIGINT NOT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `is_thumbnail` TINYINT(1) NOT NULL DEFAULT 0,
    `display_order` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`image_id`),
    KEY `fk_propertyimages_properties` (`property_id`),
    CONSTRAINT `fk_propertyimages_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 10. BẢNG AMENITIES (Tiện nghi / Tiện ích)
CREATE TABLE `amenities` (
    `amenity_id` INT NOT NULL AUTO_INCREMENT,
    `amenity_name` VARCHAR(100) NOT NULL,
    `category` VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (`amenity_id`),
    UNIQUE KEY `uq_amenities_name` (`amenity_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 11. BẢNG PROPERTYAMENITIES (Tiện ích theo Property)
CREATE TABLE `propertyamenities` (
    `property_id` BIGINT NOT NULL,
    `amenity_id` INT NOT NULL,
    PRIMARY KEY (`property_id`, `amenity_id`),
    KEY `fk_propamenities_amenities` (`amenity_id`),
    CONSTRAINT `fk_propamenities_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_propamenities_amenities` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`amenity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 12. BẢNG ROOMTYPES (Loại phòng homestay)
CREATE TABLE `roomtypes` (
    `room_type_id` BIGINT NOT NULL AUTO_INCREMENT,
    `property_id` BIGINT NOT NULL,
    `room_name` VARCHAR(150) NOT NULL,
    `description` LONGTEXT DEFAULT NULL,
    `bed_type` VARCHAR(100) DEFAULT NULL,
    `max_guests` INT NOT NULL DEFAULT 2,
    `base_price` DECIMAL(18, 2) NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    `size_m2` DECIMAL(10, 2) DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    `rating` DECIMAL(2, 1) DEFAULT 4.5,
    `review_count` INT DEFAULT 10,
    PRIMARY KEY (`room_type_id`),
    KEY `ix_roomtypes_property` (`property_id`),
    KEY `ix_roomtypes_price` (`base_price`),
    CONSTRAINT `fk_roomtypes_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_roomtypes_guests` CHECK (`max_guests` > 0),
    CONSTRAINT `ck_roomtypes_price` CHECK (`base_price` >= 0),
    CONSTRAINT `ck_roomtypes_quantity` CHECK (`quantity` > 0),
    CONSTRAINT `ck_roomtypes_size` CHECK (`size_m2` IS NULL OR `size_m2` > 0),
    CONSTRAINT `ck_roomtypes_status` CHECK (`status` IN ('ACTIVE', 'INACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Compatibility VIEW cho legacy room_types
CREATE OR REPLACE VIEW `room_types` AS
SELECT
    `room_type_id` AS `id`,
    `room_type_id`,
    `property_id`,
    `room_name` AS `type_name`,
    `room_name`,
    `description`,
    `bed_type`,
    `max_guests`,
    `base_price`,
    `quantity`,
    `size_m2`,
    `status`,
    `rating`,
    `review_count`
FROM `roomtypes`;

-- 13. BẢNG ROOMS (Phòng cụ thể)
CREATE TABLE `rooms` (
    `room_id` BIGINT NOT NULL AUTO_INCREMENT,
    `room_type_id` BIGINT NOT NULL,
    `room_number` VARCHAR(30) NOT NULL,
    `room_name` VARCHAR(100) DEFAULT NULL,
    `price_per_night` DECIMAL(12, 2) DEFAULT NULL,
    `capacity` INT DEFAULT NULL,
    `image_url` VARCHAR(255) DEFAULT NULL,
    `description` TEXT DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    `is_featured` TINYINT(1) DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`room_id`),
    UNIQUE KEY `uq_rooms_type_number` (`room_type_id`, `room_number`),
    KEY `ix_rooms_roomtype` (`room_type_id`),
    CONSTRAINT `fk_rooms_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_rooms_status` CHECK (`status` IN ('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'INACTIVE', 'BOOKED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 14. BẢNG ROOMIMAGES (Ảnh phòng)
CREATE TABLE `roomimages` (
    `image_id` BIGINT NOT NULL AUTO_INCREMENT,
    `room_type_id` BIGINT NOT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `display_order` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`image_id`),
    KEY `fk_roomimages_roomtypes` (`room_type_id`),
    CONSTRAINT `fk_roomimages_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 15. BẢNG ROOMTYPEAMENITIES (Tiện nghi theo Loại phòng)
CREATE TABLE `roomtypeamenities` (
    `room_type_id` BIGINT NOT NULL,
    `amenity_id` INT NOT NULL,
    PRIMARY KEY (`room_type_id`, `amenity_id`),
    KEY `fk_roomamenities_amenities` (`amenity_id`),
    CONSTRAINT `fk_roomamenities_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_roomamenities_amenities` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`amenity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =============================================================================
-- PHẦN 2: BOOKINGS, QR CODE & PAYMENT GATEWAYS, PROMOTIONS
-- =============================================================================

-- 16. BẢNG BOOKINGS (Đơn đặt phòng)
CREATE TABLE `bookings` (
    `booking_id` BIGINT NOT NULL AUTO_INCREMENT,
    `id` BIGINT DEFAULT NULL,
    `booking_code` VARCHAR(50) NOT NULL,
    `user_id` BIGINT DEFAULT NULL,
    `property_id` BIGINT NOT NULL,
    `room_id` BIGINT DEFAULT NULL,
    `customer_name` VARCHAR(100) DEFAULT NULL,
    `customer_email` VARCHAR(150) DEFAULT NULL,
    `customer_phone` VARCHAR(30) DEFAULT NULL,
    `check_in` DATE NOT NULL,
    `check_in_date` DATE DEFAULT NULL,
    `check_out` DATE NOT NULL,
    `check_out_date` DATE DEFAULT NULL,
    `adults` INT NOT NULL DEFAULT 1,
    `children` INT NOT NULL DEFAULT 0,
    `rooms_count` INT NOT NULL DEFAULT 1,
    `subtotal` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `discount_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `total_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `total_price` DECIMAL(18, 2) DEFAULT 0.00,
    `notes` TEXT DEFAULT NULL,
    `booking_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `status` VARCHAR(20) DEFAULT NULL,
    `cancellation_reason` VARCHAR(500) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`booking_id`),
    UNIQUE KEY `uq_bookings_code` (`booking_code`),
    KEY `ix_bookings_user` (`user_id`),
    KEY `ix_bookings_property` (`property_id`),
    KEY `ix_bookings_room` (`room_id`),
    KEY `ix_bookings_dates` (`property_id`, `check_in`, `check_out`),
    KEY `ix_bookings_status` (`booking_status`),
    CONSTRAINT `fk_bookings_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_bookings_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    CONSTRAINT `fk_bookings_rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE SET NULL,
    CONSTRAINT `ck_bookings_amounts` CHECK (`subtotal` >= 0 AND `discount_amount` >= 0 AND `total_amount` >= 0),
    CONSTRAINT `ck_bookings_date` CHECK (`check_out` > `check_in`),
    CONSTRAINT `ck_bookings_guests` CHECK (`adults` > 0 AND `children` >= 0),
    CONSTRAINT `ck_bookings_rooms` CHECK (`rooms_count` > 0),
    CONSTRAINT `ck_bookings_status` CHECK (`booking_status` IN ('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED', 'REFUNDED', 'COMPLETED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 17. BẢNG BOOKINGROOMS (Chi tiết loại phòng trong đơn đặt)
CREATE TABLE `bookingrooms` (
    `booking_room_id` BIGINT NOT NULL AUTO_INCREMENT,
    `booking_id` BIGINT NOT NULL,
    `room_type_id` BIGINT NOT NULL,
    `quantity` INT NOT NULL,
    `price_per_night` DECIMAL(18, 2) NOT NULL,
    `number_of_nights` INT NOT NULL,
    `subtotal` DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (`booking_room_id`),
    KEY `fk_bookingrooms_bookings` (`booking_id`),
    KEY `fk_bookingrooms_roomtypes` (`room_type_id`),
    CONSTRAINT `fk_bookingrooms_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_bookingrooms_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`),
    CONSTRAINT `ck_bookingrooms_nights` CHECK (`number_of_nights` > 0),
    CONSTRAINT `ck_bookingrooms_price` CHECK (`price_per_night` >= 0),
    CONSTRAINT `ck_bookingrooms_quantity` CHECK (`quantity` > 0),
    CONSTRAINT `ck_bookingrooms_subtotal` CHECK (`subtotal` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 18. BẢNG BOOKINGGUESTS (Thông tin khách đi cùng trong đơn đặt)
CREATE TABLE `bookingguests` (
    `guest_id` BIGINT NOT NULL AUTO_INCREMENT,
    `booking_id` BIGINT NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(30) DEFAULT NULL,
    `email` VARCHAR(150) DEFAULT NULL,
    `special_request` VARCHAR(1000) DEFAULT NULL,
    PRIMARY KEY (`guest_id`),
    KEY `fk_bookingguests_bookings` (`booking_id`),
    CONSTRAINT `fk_bookingguests_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 19. BẢNG SYSTEM_BANK_ACCOUNTS (Tài khoản ngân hàng VietQR của hệ thống / doanh nghiệp)
CREATE TABLE `system_bank_accounts` (
    `account_id` INT NOT NULL AUTO_INCREMENT,
    `bank_code` VARCHAR(20) NOT NULL,
    `bank_name` VARCHAR(100) NOT NULL,
    `account_number` VARCHAR(50) NOT NULL,
    `account_holder` VARCHAR(150) NOT NULL,
    `branch` VARCHAR(100) DEFAULT NULL,
    `bin_code` VARCHAR(10) NOT NULL,
    `qr_template` VARCHAR(30) NOT NULL DEFAULT 'compact2',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `is_default` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`account_id`),
    UNIQUE KEY `uq_bank_account_number` (`bank_code`, `account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 20. BẢNG PAYMENTS (Giao dịch thanh toán - Hỗ trợ QR Code / VietQR / Cổng thanh toán)
CREATE TABLE `payments` (
    `payment_id` BIGINT NOT NULL AUTO_INCREMENT,
    `payment_code` VARCHAR(50) NOT NULL,
    `user_id` BIGINT NOT NULL,
    `booking_id` BIGINT DEFAULT NULL,
    `tour_booking_id` BIGINT DEFAULT NULL,
    `amount` DECIMAL(18, 2) NOT NULL,
    `payment_method` VARCHAR(30) NOT NULL,
    `transaction_id` VARCHAR(150) DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `qr_code_url` VARCHAR(1000) DEFAULT NULL,
    `qr_content` VARCHAR(500) DEFAULT NULL,
    `bank_code` VARCHAR(30) DEFAULT NULL,
    `account_number` VARCHAR(50) DEFAULT NULL,
    `account_holder` VARCHAR(150) DEFAULT NULL,
    `transfer_content` VARCHAR(100) DEFAULT NULL,
    `qr_expired_at` DATETIME DEFAULT NULL,
    `paid_at` DATETIME DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`payment_id`),
    UNIQUE KEY `uq_payments_code` (`payment_code`),
    KEY `fk_payments_bookings` (`booking_id`),
    KEY `fk_payments_tourbookings` (`tour_booking_id`),
    KEY `ix_payments_user` (`user_id`),
    KEY `ix_payments_status` (`status`),
    CONSTRAINT `fk_payments_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `fk_payments_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    CONSTRAINT `fk_payments_tourbookings` FOREIGN KEY (`tour_booking_id`) REFERENCES `tourbookings` (`tour_booking_id`),
    CONSTRAINT `ck_payments_amount` CHECK (`amount` >= 0),
    CONSTRAINT `ck_payments_method` CHECK (`payment_method` IN ('VNPAY', 'MOMO', 'CASH', 'BANK_TRANSFER', 'VIETQR', 'QR_CODE', 'VNPAY_QR', 'MOMO_QR')),
    CONSTRAINT `ck_payments_status` CHECK (`status` IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
    CONSTRAINT `ck_payments_target` CHECK (((`booking_id` IS NOT NULL) AND (`tour_booking_id` IS NULL)) OR ((`booking_id` IS NULL) AND (`tour_booking_id` IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 21. BẢNG PAYMENT_QR_CODES (Chi tiết tạo mã QR thanh toán động cho từng giao dịch)
CREATE TABLE `payment_qr_codes` (
    `qr_id` BIGINT NOT NULL AUTO_INCREMENT,
    `payment_id` BIGINT NOT NULL,
    `booking_id` BIGINT DEFAULT NULL,
    `bank_code` VARCHAR(20) NOT NULL,
    `account_number` VARCHAR(50) NOT NULL,
    `account_holder` VARCHAR(150) NOT NULL,
    `amount` DECIMAL(18, 2) NOT NULL,
    `transfer_content` VARCHAR(100) NOT NULL,
    `qr_data_url` VARCHAR(1000) NOT NULL,
    `qr_raw_string` LONGTEXT DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `expires_at` DATETIME NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `paid_at` DATETIME DEFAULT NULL,
    PRIMARY KEY (`qr_id`),
    KEY `fk_qr_payments` (`payment_id`),
    KEY `fk_qr_bookings` (`booking_id`),
    CONSTRAINT `fk_qr_payments` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_qr_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_qr_status` CHECK (`status` IN ('PENDING', 'SCANNED', 'PAID', 'EXPIRED', 'CANCELLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 22. BẢNG COUPONS (Mã giảm giá / Khuyến mãi)
CREATE TABLE `coupons` (
    `coupon_id` BIGINT NOT NULL AUTO_INCREMENT,
    `coupon_code` VARCHAR(50) NOT NULL,
    `description` VARCHAR(500) DEFAULT NULL,
    `discount_type` VARCHAR(20) NOT NULL,
    `discount_value` DECIMAL(18, 2) NOT NULL,
    `minimum_order_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `maximum_discount` DECIMAL(18, 2) DEFAULT NULL,
    `usage_limit` INT DEFAULT NULL,
    `used_count` INT NOT NULL DEFAULT 0,
    `start_at` DATETIME NOT NULL,
    `end_at` DATETIME NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    PRIMARY KEY (`coupon_id`),
    UNIQUE KEY `uq_coupons_code` (`coupon_code`),
    CONSTRAINT `ck_coupons_date` CHECK (`end_at` > `start_at`),
    CONSTRAINT `ck_coupons_max` CHECK (`maximum_discount` IS NULL OR `maximum_discount` >= 0),
    CONSTRAINT `ck_coupons_min` CHECK (`minimum_order_amount` >= 0),
    CONSTRAINT `ck_coupons_status` CHECK (`status` IN ('ACTIVE', 'INACTIVE', 'EXPIRED')),
    CONSTRAINT `ck_coupons_type` CHECK (`discount_type` IN ('PERCENTAGE', 'FIXED')),
    CONSTRAINT `ck_coupons_limit` CHECK (`usage_limit` IS NULL OR `usage_limit` > 0),
    CONSTRAINT `ck_coupons_used` CHECK (`used_count` >= 0),
    CONSTRAINT `ck_coupons_value` CHECK (`discount_value` >= 0 AND (`discount_type` <> 'PERCENTAGE' OR `discount_value` <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 23. BẢNG COUPONUSAGES (Lịch sử sử dụng mã giảm giá)
CREATE TABLE `couponusages` (
    `usage_id` BIGINT NOT NULL AUTO_INCREMENT,
    `coupon_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `booking_id` BIGINT DEFAULT NULL,
    `tour_booking_id` BIGINT DEFAULT NULL,
    `discount_amount` DECIMAL(18, 2) NOT NULL,
    `used_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`usage_id`),
    KEY `fk_couponusages_coupons` (`coupon_id`),
    KEY `fk_couponusages_users` (`user_id`),
    KEY `fk_couponusages_bookings` (`booking_id`),
    KEY `fk_couponusages_tourbookings` (`tour_booking_id`),
    CONSTRAINT `fk_couponusages_coupons` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`coupon_id`),
    CONSTRAINT `fk_couponusages_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `fk_couponusages_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    CONSTRAINT `fk_couponusages_tourbookings` FOREIGN KEY (`tour_booking_id`) REFERENCES `tourbookings` (`tour_booking_id`),
    CONSTRAINT `ck_couponusages_discount` CHECK (`discount_amount` >= 0),
    CONSTRAINT `ck_couponusages_target` CHECK (((`booking_id` IS NOT NULL) AND (`tour_booking_id` IS NULL)) OR ((`booking_id` IS NULL) AND (`tour_booking_id` IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 24. BẢNG WISHLISTS (Danh sách yêu thích)
CREATE TABLE `wishlists` (
    `wishlist_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `property_id` BIGINT DEFAULT NULL,
    `tour_id` BIGINT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`wishlist_id`),
    KEY `fk_wishlists_users` (`user_id`),
    KEY `fk_wishlists_properties` (`property_id`),
    KEY `fk_wishlists_tours` (`tour_id`),
    CONSTRAINT `fk_wishlists_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_wishlists_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    CONSTRAINT `fk_wishlists_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`),
    CONSTRAINT `ck_wishlists_target` CHECK (((`property_id` IS NOT NULL) AND (`tour_id` IS NULL)) OR ((`property_id` IS NULL) AND (`tour_id` IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 25. BẢNG NOTIFICATIONS (Thông báo hệ thống cho người dùng)
CREATE TABLE `notifications` (
    `notification_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `title` VARCHAR(200) NOT NULL,
    `message` LONGTEXT NOT NULL,
    `notification_type` VARCHAR(30) NOT NULL,
    `reference_id` BIGINT DEFAULT NULL,
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`notification_id`),
    KEY `ix_notifications_user_read` (`user_id`, `is_read`, `created_at`),
    CONSTRAINT `fk_notifications_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_notifications_type` CHECK (`notification_type` IN ('BOOKING', 'PAYMENT', 'PROMOTION', 'REMINDER', 'SYSTEM', 'RECOMMENDATION'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 26. BẢNG CONTACTMESSAGES (Tin nhắn liên hệ từ khách hàng)
CREATE TABLE `contactmessages` (
    `message_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT DEFAULT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `subject` VARCHAR(255) NOT NULL,
    `message` LONGTEXT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'NEW',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`message_id`),
    KEY `fk_contactmessages_users` (`user_id`),
    CONSTRAINT `fk_contactmessages_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
    CONSTRAINT `ck_contactmessages_status` CHECK (`status` IN ('NEW', 'PROCESSING', 'RESOLVED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 27. BẢNG FAQS (Câu hỏi thường gặp)
CREATE TABLE `faqs` (
    `faq_id` INT NOT NULL AUTO_INCREMENT,
    `question` VARCHAR(500) NOT NULL,
    `answer` LONGTEXT NOT NULL,
    `category` VARCHAR(100) DEFAULT NULL,
    `display_order` INT NOT NULL DEFAULT 0,
    `status` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`faq_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =============================================================================
-- PHẦN 3: REVIEWS, TOURS, AI ASSISTANT, PERSONALIZATION & LOYALTY
-- =============================================================================

-- 28. BẢNG REVIEWS (Đánh giá của khách hàng cho Property hoặc Tour)
CREATE TABLE `reviews` (
    `review_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `property_id` BIGINT DEFAULT NULL,
    `tour_id` BIGINT DEFAULT NULL,
    `booking_id` BIGINT DEFAULT NULL,
    `tour_booking_id` BIGINT DEFAULT NULL,
    `rating` INT NOT NULL,
    `title` VARCHAR(200) DEFAULT NULL,
    `comment` LONGTEXT DEFAULT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`review_id`),
    KEY `fk_reviews_users` (`user_id`),
    KEY `fk_reviews_properties` (`property_id`),
    KEY `fk_reviews_tours` (`tour_id`),
    KEY `fk_reviews_bookings` (`booking_id`),
    KEY `fk_reviews_tourbookings` (`tour_booking_id`),
    CONSTRAINT `fk_reviews_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `fk_reviews_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    CONSTRAINT `fk_reviews_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`),
    CONSTRAINT `fk_reviews_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    CONSTRAINT `fk_reviews_tourbookings` FOREIGN KEY (`tour_booking_id`) REFERENCES `tourbookings` (`tour_booking_id`),
    CONSTRAINT `ck_reviews_rating` CHECK (`rating` BETWEEN 1 AND 5),
    CONSTRAINT `ck_reviews_status` CHECK (`status` IN ('PENDING', 'APPROVED', 'HIDDEN')),
    CONSTRAINT `ck_reviews_target` CHECK (((`property_id` IS NOT NULL) AND (`tour_id` IS NULL) AND (`booking_id` IS NOT NULL) AND (`tour_booking_id` IS NULL)) OR ((`property_id` IS NULL) AND (`tour_id` IS NOT NULL) AND (`booking_id` IS NULL) AND (`tour_booking_id` IS NOT NULL)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 29. BẢNG REVIEWREPLIES (Phản hồi đánh giá từ chủ nhà / host)
CREATE TABLE `reviewreplies` (
    `reply_id` BIGINT NOT NULL AUTO_INCREMENT,
    `review_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `reply_content` LONGTEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`reply_id`),
    KEY `fk_reviewreplies_reviews` (`review_id`),
    KEY `fk_reviewreplies_users` (`user_id`),
    CONSTRAINT `fk_reviewreplies_reviews` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`review_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_reviewreplies_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 30. BẢNG TOURS (Tour & Trải nghiệm du lịch địa phương)
CREATE TABLE `tours` (
    `tour_id` BIGINT NOT NULL AUTO_INCREMENT,
    `operator_id` BIGINT NOT NULL,
    `destination_id` INT NOT NULL,
    `tour_name` VARCHAR(200) NOT NULL,
    `description` LONGTEXT DEFAULT NULL,
    `duration_days` INT NOT NULL,
    `duration_nights` INT NOT NULL DEFAULT 0,
    `base_price` DECIMAL(18, 2) NOT NULL,
    `max_participants` INT NOT NULL,
    `average_rating` DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    `review_count` INT NOT NULL DEFAULT 0,
    `status` VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`tour_id`),
    KEY `ix_tours_destination` (`destination_id`),
    KEY `ix_tours_operator` (`operator_id`),
    CONSTRAINT `fk_tours_destination` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`),
    CONSTRAINT `fk_tours_operator` FOREIGN KEY (`operator_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `ck_tours_duration` CHECK (`duration_days` > 0 AND `duration_nights` >= 0),
    CONSTRAINT `ck_tours_participants` CHECK (`max_participants` > 0),
    CONSTRAINT `ck_tours_price` CHECK (`base_price` >= 0),
    CONSTRAINT `ck_tours_rating` CHECK (`average_rating` >= 0 AND `average_rating` <= 5),
    CONSTRAINT `ck_tours_status` CHECK (`status` IN ('PENDING', 'APPROVED', 'REJECTED', 'INACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 31. BẢNG TOURIMAGES (Hình ảnh Tour)
CREATE TABLE `tourimages` (
    `image_id` BIGINT NOT NULL AUTO_INCREMENT,
    `tour_id` BIGINT NOT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `is_thumbnail` TINYINT(1) NOT NULL DEFAULT 0,
    `display_order` INT NOT NULL DEFAULT 0,
    PRIMARY KEY (`image_id`),
    KEY `fk_tourimages_tours` (`tour_id`),
    CONSTRAINT `fk_tourimages_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 32. BẢNG TOURITINERARIES (Lịch trình chi tiết từng ngày của Tour)
CREATE TABLE `touritineraries` (
    `itinerary_id` BIGINT NOT NULL AUTO_INCREMENT,
    `tour_id` BIGINT NOT NULL,
    `day_number` INT NOT NULL,
    `title` VARCHAR(200) NOT NULL,
    `description` LONGTEXT DEFAULT NULL,
    PRIMARY KEY (`itinerary_id`),
    KEY `fk_touritineraries_tours` (`tour_id`),
    CONSTRAINT `fk_touritineraries_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_touritineraries_day` CHECK (`day_number` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 33. BẢNG TOURSCHEDULES (Lịch khởi hành Tour)
CREATE TABLE `tourschedules` (
    `schedule_id` BIGINT NOT NULL AUTO_INCREMENT,
    `tour_id` BIGINT NOT NULL,
    `departure_datetime` DATETIME NOT NULL,
    `return_datetime` DATETIME NOT NULL,
    `available_slots` INT NOT NULL,
    `booked_slots` INT NOT NULL DEFAULT 0,
    `price` DECIMAL(18, 2) NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    PRIMARY KEY (`schedule_id`),
    KEY `fk_tourschedules_tours` (`tour_id`),
    KEY `ix_tourschedules_date` (`departure_datetime`),
    CONSTRAINT `fk_tourschedules_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_tourschedules_date` CHECK (`return_datetime` > `departure_datetime`),
    CONSTRAINT `ck_tourschedules_price` CHECK (`price` >= 0),
    CONSTRAINT `ck_tourschedules_slots` CHECK (`available_slots` > 0 AND `booked_slots` >= 0 AND `booked_slots` <= `available_slots`),
    CONSTRAINT `ck_tourschedules_status` CHECK (`status` IN ('OPEN', 'FULL', 'CANCELLED', 'COMPLETED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 34. BẢNG TOURBOOKINGS (Đơn đặt Tour)
CREATE TABLE `tourbookings` (
    `tour_booking_id` BIGINT NOT NULL AUTO_INCREMENT,
    `booking_code` VARCHAR(50) NOT NULL,
    `user_id` BIGINT NOT NULL,
    `schedule_id` BIGINT NOT NULL,
    `participants` INT NOT NULL,
    `price_per_person` DECIMAL(18, 2) NOT NULL,
    `subtotal` DECIMAL(18, 2) NOT NULL,
    `discount_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `total_amount` DECIMAL(18, 2) NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`tour_booking_id`),
    UNIQUE KEY `uq_tourbookings_code` (`booking_code`),
    KEY `fk_tourbookings_schedules` (`schedule_id`),
    KEY `ix_tourbookings_user` (`user_id`),
    CONSTRAINT `fk_tourbookings_schedules` FOREIGN KEY (`schedule_id`) REFERENCES `tourschedules` (`schedule_id`),
    CONSTRAINT `fk_tourbookings_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `ck_tourbookings_amounts` CHECK (`price_per_person` >= 0 AND `subtotal` >= 0 AND `discount_amount` >= 0 AND `total_amount` >= 0),
    CONSTRAINT `ck_tourbookings_participants` CHECK (`participants` > 0),
    CONSTRAINT `ck_tourbookings_status` CHECK (`status` IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'REFUNDED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 35. BẢNG TOURBOOKINGGUESTS (Khách tham gia Tour)
CREATE TABLE `tourbookingguests` (
    `guest_id` BIGINT NOT NULL AUTO_INCREMENT,
    `tour_booking_id` BIGINT NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(30) DEFAULT NULL,
    `email` VARCHAR(150) DEFAULT NULL,
    PRIMARY KEY (`guest_id`),
    KEY `fk_tourbookingguests_tourbookings` (`tour_booking_id`),
    CONSTRAINT `fk_tourbookingguests_tourbookings` FOREIGN KEY (`tour_booking_id`) REFERENCES `tourbookings` (`tour_booking_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 36. BẢNG LOYALTYTRANSACTIONS (Lịch sử tích / tiêu điểm thưởng thành viên)
CREATE TABLE `loyaltytransactions` (
    `loyalty_transaction_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `booking_id` BIGINT DEFAULT NULL,
    `tour_booking_id` BIGINT DEFAULT NULL,
    `points` INT NOT NULL,
    `transaction_type` VARCHAR(20) NOT NULL,
    `description` VARCHAR(500) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`loyalty_transaction_id`),
    KEY `fk_loyalty_users` (`user_id`),
    KEY `fk_loyalty_bookings` (`booking_id`),
    KEY `fk_loyalty_tourbookings` (`tour_booking_id`),
    CONSTRAINT `fk_loyalty_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `fk_loyalty_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    CONSTRAINT `fk_loyalty_tourbookings` FOREIGN KEY (`tour_booking_id`) REFERENCES `tourbookings` (`tour_booking_id`),
    CONSTRAINT `ck_loyalty_type` CHECK (`transaction_type` IN ('EARN', 'REDEEM', 'ADJUST'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 37. BẢNG CONVERSATIONS (Cuộc trò chuyện hỗ trợ / AI Assistant)
CREATE TABLE `conversations` (
    `conversation_id` BIGINT NOT NULL AUTO_INCREMENT,
    `conversation_type` VARCHAR(20) NOT NULL,
    `created_by` BIGINT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'OPEN',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`conversation_id`),
    KEY `fk_conversations_createdby` (`created_by`),
    CONSTRAINT `fk_conversations_createdby` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
    CONSTRAINT `ck_conversations_status` CHECK (`status` IN ('OPEN', 'CLOSED')),
    CONSTRAINT `ck_conversations_type` CHECK (`conversation_type` IN ('SUPPORT', 'AI_CHAT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 38. BẢNG CONVERSATIONMEMBERS (Thành viên tham gia hội thoại)
CREATE TABLE `conversationmembers` (
    `conversation_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `joined_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`conversation_id`, `user_id`),
    KEY `fk_convmembers_users` (`user_id`),
    CONSTRAINT `fk_convmembers_conversations` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`conversation_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_convmembers_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 39. BẢNG CHATMESSAGES (Tin nhắn trò chuyện)
CREATE TABLE `chatmessages` (
    `message_id` BIGINT NOT NULL AUTO_INCREMENT,
    `conversation_id` BIGINT NOT NULL,
    `sender_id` BIGINT DEFAULT NULL,
    `sender_type` VARCHAR(10) NOT NULL,
    `message` LONGTEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`message_id`),
    KEY `fk_chatmessages_sender` (`sender_id`),
    KEY `ix_chatmessages_conv_date` (`conversation_id`, `created_at`),
    CONSTRAINT `fk_chatmessages_conversations` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`conversation_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_chatmessages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
    CONSTRAINT `ck_chatmessages_sendertype` CHECK (`sender_type` IN ('USER', 'STAFF', 'AI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 40. BẢNG SEARCHHISTORIES (Lịch sử tìm kiếm phòng / tour)
CREATE TABLE `searchhistories` (
    `search_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT DEFAULT NULL,
    `session_id` VARCHAR(100) DEFAULT NULL,
    `keyword` VARCHAR(255) DEFAULT NULL,
    `destination_id` INT DEFAULT NULL,
    `check_in` DATE DEFAULT NULL,
    `check_out` DATE DEFAULT NULL,
    `adults` INT NOT NULL DEFAULT 1,
    `children` INT NOT NULL DEFAULT 0,
    `rooms` INT NOT NULL DEFAULT 1,
    `min_price` DECIMAL(18, 2) DEFAULT NULL,
    `max_price` DECIMAL(18, 2) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`search_id`),
    KEY `fk_searchhistories_destinations` (`destination_id`),
    KEY `ix_searchhistories_user` (`user_id`, `created_at`),
    CONSTRAINT `fk_searchhistories_destinations` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_searchhistories_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
    CONSTRAINT `ck_searchhistories_date` CHECK (`check_out` IS NULL OR `check_in` IS NULL OR `check_out` > `check_in`),
    CONSTRAINT `ck_searchhistories_guests` CHECK (`adults` > 0 AND `children` >= 0 AND `rooms` > 0),
    CONSTRAINT `ck_searchhistories_price` CHECK (`min_price` IS NULL OR `max_price` IS NULL OR `min_price` <= `max_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 41. BẢNG USERBEHAVIORS (Hành vi người dùng: click, view, filter, book)
CREATE TABLE `userbehaviors` (
    `behavior_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT DEFAULT NULL,
    `session_id` VARCHAR(100) DEFAULT NULL,
    `behavior_type` VARCHAR(30) NOT NULL,
    `property_id` BIGINT DEFAULT NULL,
    `room_type_id` BIGINT DEFAULT NULL,
    `tour_id` BIGINT DEFAULT NULL,
    `search_keyword` VARCHAR(255) DEFAULT NULL,
    `price_min` DECIMAL(18, 2) DEFAULT NULL,
    `price_max` DECIMAL(18, 2) DEFAULT NULL,
    `metadata` LONGTEXT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`behavior_id`),
    KEY `ix_userbehaviors_type_date` (`user_id`, `behavior_type`, `created_at`),
    KEY `ix_userbehaviors_property` (`property_id`),
    KEY `ix_userbehaviors_roomtype` (`room_type_id`),
    KEY `ix_userbehaviors_tour` (`tour_id`),
    CONSTRAINT `fk_userbehaviors_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `fk_userbehaviors_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    CONSTRAINT `fk_userbehaviors_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`),
    CONSTRAINT `fk_userbehaviors_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`),
    CONSTRAINT `ck_userbehaviors_price` CHECK (`price_min` IS NULL OR `price_max` IS NULL OR `price_min` <= `price_max`),
    CONSTRAINT `ck_userbehaviors_type` CHECK (`behavior_type` IN ('SEARCH', 'VIEW_PROPERTY', 'VIEW_ROOM', 'VIEW_TOUR', 'CLICK_PROPERTY', 'CLICK_TOUR', 'FILTER', 'SORT', 'BOOKING', 'ADD_WISHLIST', 'REMOVE_WISHLIST'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 42. BẢNG USERPREFERENCES (Sở thích cá nhân của khách hàng)
CREATE TABLE `userpreferences` (
    `preference_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `preferred_budget_min` DECIMAL(18, 2) DEFAULT NULL,
    `preferred_budget_max` DECIMAL(18, 2) DEFAULT NULL,
    `preferred_room_type` VARCHAR(20) DEFAULT NULL,
    `homestay_style` VARCHAR(20) DEFAULT NULL,
    `preferred_destination` VARCHAR(150) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`preference_id`),
    UNIQUE KEY `uq_userpreferences_user` (`user_id`),
    CONSTRAINT `fk_userpreferences_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_userpref_budget` CHECK (`preferred_budget_min` IS NULL OR `preferred_budget_max` IS NULL OR `preferred_budget_min` <= `preferred_budget_max`),
    CONSTRAINT `ck_userpref_style` CHECK (`homestay_style` IS NULL OR `homestay_style` IN ('BUDGET', 'MID_RANGE', 'LUXURY')),
    CONSTRAINT `ck_userpref_roomtype` CHECK (`preferred_room_type` IS NULL OR `preferred_room_type` IN ('SINGLE', 'DOUBLE', 'TWIN', 'FAMILY', 'SUITE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 43. BẢNG USERSEGMENTS (Phân khúc khách hàng phục vụ gợi ý AI)
CREATE TABLE `usersegments` (
    `segment_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `segment` VARCHAR(20) NOT NULL,
    `average_booking_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `total_spending` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `total_bookings` INT NOT NULL DEFAULT 0,
    `confidence` DECIMAL(5, 4) DEFAULT NULL,
    `calculated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`segment_id`),
    UNIQUE KEY `uq_usersegments_user` (`user_id`),
    CONSTRAINT `fk_usersegments_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `ck_usersegments_amounts` CHECK (`average_booking_amount` >= 0 AND `total_spending` >= 0 AND `total_bookings` >= 0),
    CONSTRAINT `ck_usersegments_confidence` CHECK (`confidence` IS NULL OR (`confidence` >= 0 AND `confidence` <= 1)),
    CONSTRAINT `ck_usersegments_segment` CHECK (`segment` IN ('BUDGET', 'MID_RANGE', 'LUXURY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 44. BẢNG RECOMMENDATIONS (Kết quả gợi ý thông minh từ AI / Recommender)
CREATE TABLE `recommendations` (
    `recommendation_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `property_id` BIGINT DEFAULT NULL,
    `room_type_id` BIGINT DEFAULT NULL,
    `tour_id` BIGINT DEFAULT NULL,
    `recommendation_type` VARCHAR(30) NOT NULL,
    `score` DECIMAL(10, 6) NOT NULL,
    `reason` VARCHAR(500) DEFAULT NULL,
    `is_displayed` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`recommendation_id`),
    KEY `fk_recommendations_properties` (`property_id`),
    KEY `fk_recommendations_roomtypes` (`room_type_id`),
    KEY `fk_recommendations_tours` (`tour_id`),
    KEY `ix_recommendations_userscore` (`user_id`, `score` DESC),
    CONSTRAINT `fk_recommendations_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    CONSTRAINT `fk_recommendations_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    CONSTRAINT `fk_recommendations_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`),
    CONSTRAINT `fk_recommendations_tours` FOREIGN KEY (`tour_id`) REFERENCES `tours` (`tour_id`),
    CONSTRAINT `ck_recommendations_target` CHECK (((`property_id` IS NOT NULL) AND (`room_type_id` IS NULL) AND (`tour_id` IS NULL)) OR ((`property_id` IS NULL) AND (`room_type_id` IS NOT NULL) AND (`tour_id` IS NULL)) OR ((`property_id` IS NULL) AND (`room_type_id` IS NULL) AND (`tour_id` IS NOT NULL))),
    CONSTRAINT `ck_recommendations_type` CHECK (`recommendation_type` IN ('CONTENT_BASED', 'BUDGET_MATCH', 'BEHAVIOR_BASED', 'POPULAR'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =============================================================================
-- PHẦN 4: ROLE DASHBOARDS (ADMIN, HOST, CUSTOMER)
-- =============================================================================

-- 45. BẢNG PLATFORM_CONFIGS (Cấu hình hệ thống dành cho Admin Dashboard)
CREATE TABLE `platform_configs` (
    `config_id` INT NOT NULL AUTO_INCREMENT,
    `config_key` VARCHAR(100) NOT NULL,
    `config_value` TEXT NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `category` VARCHAR(50) NOT NULL DEFAULT 'GENERAL',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`config_id`),
    UNIQUE KEY `uq_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 46. BẢNG ADMIN_ACTIVITY_LOGS (Nhật ký kiểm toán / Audit Log cho Admin Dashboard)
CREATE TABLE `admin_activity_logs` (
    `log_id` BIGINT NOT NULL AUTO_INCREMENT,
    `admin_id` BIGINT NOT NULL,
    `action_type` VARCHAR(50) NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` BIGINT DEFAULT NULL,
    `description` TEXT NOT NULL,
    `ip_address` VARCHAR(50) DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`log_id`),
    KEY `fk_admin_logs_users` (`admin_id`),
    CONSTRAINT `fk_admin_logs_users` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 47. BẢNG HOST_PAYOUTS (Quản lý Doanh thu & Yêu cầu rút tiền cho Host Dashboard)
CREATE TABLE `host_payouts` (
    `payout_id` BIGINT NOT NULL AUTO_INCREMENT,
    `payout_code` VARCHAR(50) NOT NULL,
    `host_id` INT NOT NULL,
    `amount` DECIMAL(18, 2) NOT NULL,
    `bank_code` VARCHAR(20) NOT NULL,
    `account_number` VARCHAR(50) NOT NULL,
    `account_holder` VARCHAR(150) NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `notes` VARCHAR(500) DEFAULT NULL,
    `requested_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `processed_at` DATETIME DEFAULT NULL,
    `processed_by` BIGINT DEFAULT NULL,
    PRIMARY KEY (`payout_id`),
    UNIQUE KEY `uq_payout_code` (`payout_code`),
    KEY `fk_payouts_host` (`host_id`),
    KEY `fk_payouts_admin` (`processed_by`),
    CONSTRAINT `fk_payouts_host` FOREIGN KEY (`host_id`) REFERENCES `host_profiles` (`id`),
    CONSTRAINT `fk_payouts_admin` FOREIGN KEY (`processed_by`) REFERENCES `users` (`user_id`),
    CONSTRAINT `ck_payouts_amount` CHECK (`amount` > 0),
    CONSTRAINT `ck_payouts_status` CHECK (`status` IN ('PENDING', 'PROCESSING', 'COMPLETED', 'REJECTED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 48. BẢNG HOST_DAILY_ANALYTICS (Thống kê hiệu suất kinh doanh cho Host Dashboard)
CREATE TABLE `host_daily_analytics` (
    `analytics_id` BIGINT NOT NULL AUTO_INCREMENT,
    `host_id` INT NOT NULL,
    `property_id` BIGINT NOT NULL,
    `stat_date` DATE NOT NULL,
    `view_count` INT NOT NULL DEFAULT 0,
    `click_count` INT NOT NULL DEFAULT 0,
    `booking_count` INT NOT NULL DEFAULT 0,
    `revenue` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `occupancy_rate` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`analytics_id`),
    UNIQUE KEY `uq_host_property_date` (`host_id`, `property_id`, `stat_date`),
    KEY `fk_analytics_host` (`host_id`),
    KEY `fk_analytics_property` (`property_id`),
    CONSTRAINT `fk_analytics_host` FOREIGN KEY (`host_id`) REFERENCES `host_profiles` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_analytics_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 49. BẢNG DASHBOARD_ANNOUNCEMENTS (Thông báo / Bảng tin trên Dashboard phân quyền theo Role)
CREATE TABLE `dashboard_announcements` (
    `announcement_id` INT NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `target_role` VARCHAR(30) NOT NULL DEFAULT 'ALL',
    `priority` VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `start_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `end_at` DATETIME DEFAULT NULL,
    `created_by` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`announcement_id`),
    KEY `fk_announcements_creator` (`created_by`),
    CONSTRAINT `fk_announcements_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
    CONSTRAINT `ck_announcements_role` CHECK (`target_role` IN ('ALL', 'ROLE_ADMIN', 'ROLE_HOST', 'ROLE_CUSTOMER')),
    CONSTRAINT `ck_announcements_priority` CHECK (`priority` IN ('LOW', 'NORMAL', 'HIGH', 'URGENT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =============================================================================
-- CÁC VIEW TỔNG HỢP DASHBOARD REALTIME CHO CẢ 3 ROLES
-- =============================================================================

-- VIEW ADMIN DASHBOARD SUMMARY
CREATE OR REPLACE VIEW `v_admin_dashboard_summary` AS
SELECT
    (SELECT COUNT(*) FROM `users` WHERE `status` = 'ACTIVE') AS `total_active_users`,
    (SELECT COUNT(*) FROM `host_profiles` WHERE `verification_status` = 'APPROVED') AS `total_active_hosts`,
    (SELECT COUNT(*) FROM `host_profiles` WHERE `verification_status` = 'PENDING') AS `pending_hosts`,
    (SELECT COUNT(*) FROM `properties` WHERE `status` = 'APPROVED') AS `total_active_properties`,
    (SELECT COUNT(*) FROM `properties` WHERE `status` = 'PENDING') AS `pending_properties`,
    (SELECT COUNT(*) FROM `bookings`) AS `total_bookings`,
    (SELECT COUNT(*) FROM `bookings` WHERE `booking_status` = 'CONFIRMED' OR `booking_status` = 'COMPLETED') AS `successful_bookings`,
    (SELECT COALESCE(SUM(`total_amount`), 0.00) FROM `bookings` WHERE `booking_status` IN ('CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'COMPLETED')) AS `total_revenue`,
    (SELECT COALESCE(SUM(`amount`), 0.00) FROM `payments` WHERE `status` = 'SUCCESS') AS `total_paid_amount`,
    (SELECT COUNT(*) FROM `payment_qr_codes` WHERE `status` = 'PAID') AS `total_qr_payments_completed`,
    (SELECT COUNT(*) FROM `host_payouts` WHERE `status` = 'PENDING') AS `pending_payouts`;

-- VIEW HOST DASHBOARD SUMMARY (Thống kê theo từng Host)
CREATE OR REPLACE VIEW `v_host_dashboard_summary` AS
SELECT
    hp.`id` AS `host_id`,
    hp.`user_id`,
    hp.`business_name`,
    hp.`verification_status`,
    COUNT(DISTINCT p.`property_id`) AS `total_properties`,
    COUNT(DISTINCT r.`room_id`) AS `total_rooms`,
    COUNT(DISTINCT b.`booking_id`) AS `total_bookings`,
    COALESCE(SUM(CASE WHEN b.`booking_status` IN ('CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'COMPLETED') THEN b.`total_amount` ELSE 0.00 END), 0.00) AS `gross_revenue`,
    COALESCE(AVG(p.`average_rating`), 0.00) AS `avg_rating`,
    COALESCE(SUM(p.`review_count`), 0) AS `total_reviews`,
    (SELECT COALESCE(SUM(`amount`), 0.00) FROM `host_payouts` WHERE `host_id` = hp.`id` AND `status` = 'COMPLETED') AS `total_withdrawn`,
    (SELECT COALESCE(SUM(`amount`), 0.00) FROM `host_payouts` WHERE `host_id` = hp.`id` AND `status` = 'PENDING') AS `pending_withdrawal`
FROM `host_profiles` hp
LEFT JOIN `properties` p ON hp.`id` = p.`host_id` OR hp.`user_id` = p.`owner_id`
LEFT JOIN `roomtypes` rt ON p.`property_id` = rt.`property_id`
LEFT JOIN `rooms` r ON rt.`room_type_id` = r.`room_type_id`
LEFT JOIN `bookings` b ON p.`property_id` = b.`property_id`
GROUP BY hp.`id`, hp.`user_id`, hp.`business_name`, hp.`verification_status`;

-- VIEW CUSTOMER DASHBOARD SUMMARY (Thống kê theo từng Khách hàng)
CREATE OR REPLACE VIEW `v_customer_dashboard_summary` AS
SELECT
    u.`user_id`,
    u.`full_name`,
    u.`email`,
    u.`loyalty_points`,
    COUNT(DISTINCT b.`booking_id`) AS `total_bookings`,
    COUNT(DISTINCT CASE WHEN b.`booking_status` IN ('CONFIRMED', 'CHECKED_IN') AND b.`check_out` >= CURDATE() THEN b.`booking_id` END) AS `upcoming_trips`,
    COUNT(DISTINCT CASE WHEN b.`booking_status` = 'COMPLETED' THEN b.`booking_id` END) AS `completed_trips`,
    COUNT(DISTINCT CASE WHEN b.`booking_status` = 'CANCELLED' THEN b.`booking_id` END) AS `cancelled_bookings`,
    COALESCE(SUM(CASE WHEN b.`booking_status` IN ('CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'COMPLETED') THEN b.`total_amount` ELSE 0.00 END), 0.00) AS `total_spent`,
    (SELECT COUNT(*) FROM `wishlists` w WHERE w.`user_id` = u.`user_id`) AS `wishlist_count`,
    (SELECT COUNT(*) FROM `notifications` n WHERE n.`user_id` = u.`user_id` AND n.`is_read` = 0) AS `unread_notifications`,
    (SELECT COUNT(*) FROM `coupons` c WHERE c.`status` = 'ACTIVE' AND c.`end_at` > NOW()) AS `available_coupons`
FROM `users` u
LEFT JOIN `bookings` b ON u.`user_id` = b.`user_id`
GROUP BY u.`user_id`, u.`full_name`, u.`email`, u.`loyalty_points`;

-- =============================================================================
-- PHẦN 5: DUAL-COMPATIBILITY TRIGGERS (Đồng bộ hai chiều các trường dữ liệu)
-- =============================================================================

DELIMITER //

-- Đồng bộ users (password <-> password_hash)
DROP TRIGGER IF EXISTS `trg_users_before_insert`//
CREATE TRIGGER `trg_users_before_insert`
BEFORE INSERT ON `users`
FOR EACH ROW
BEGIN
    IF NEW.password_hash IS NULL OR NEW.password_hash = '' THEN
        SET NEW.password_hash = NEW.password;
    END IF;
    IF NEW.password IS NULL OR NEW.password = '' THEN
        SET NEW.password = NEW.password_hash;
    END IF;
END//

DROP TRIGGER IF EXISTS `trg_users_before_update`//
CREATE TRIGGER `trg_users_before_update`
BEFORE UPDATE ON `users`
FOR EACH ROW
BEGIN
    IF NEW.password_hash IS NOT NULL AND NEW.password IS NULL THEN
        SET NEW.password = NEW.password_hash;
    ELSEIF NEW.password IS NOT NULL AND NEW.password_hash IS NULL THEN
        SET NEW.password_hash = NEW.password;
    END IF;
END//

-- Đồng bộ bookings (check_in <-> check_in_date, total_amount <-> total_price, v.v.)
DROP TRIGGER IF EXISTS `trg_bookings_before_insert`//
CREATE TRIGGER `trg_bookings_before_insert`
BEFORE INSERT ON `bookings`
FOR EACH ROW
BEGIN
    IF NEW.booking_code IS NULL OR NEW.booking_code = '' THEN
        SET NEW.booking_code = CONCAT('BK', DATE_FORMAT(NOW(), '%y%m%d'), LPAD(FLOOR(RAND()*10000), 4, '0'));
    END IF;
    IF NEW.check_in IS NULL THEN
        SET NEW.check_in = NEW.check_in_date;
    END IF;
    IF NEW.check_in_date IS NULL THEN
        SET NEW.check_in_date = NEW.check_in;
    END IF;
    IF NEW.check_out IS NULL THEN
        SET NEW.check_out = NEW.check_out_date;
    END IF;
    IF NEW.check_out_date IS NULL THEN
        SET NEW.check_out_date = NEW.check_out;
    END IF;
    IF NEW.total_amount = 0.00 AND NEW.total_price > 0.00 THEN
        SET NEW.total_amount = NEW.total_price;
    END IF;
    IF NEW.total_price = 0.00 AND NEW.total_amount > 0.00 THEN
        SET NEW.total_price = NEW.total_amount;
    END IF;
    IF NEW.subtotal = 0.00 THEN
        SET NEW.subtotal = NEW.total_amount;
    END IF;
    IF NEW.status IS NOT NULL AND (NEW.booking_status IS NULL OR NEW.booking_status = 'PENDING') THEN
        SET NEW.booking_status = NEW.status;
    END IF;
    IF NEW.status IS NULL THEN
        SET NEW.status = NEW.booking_status;
    END IF;
    IF (NEW.property_id IS NULL OR NEW.property_id = 0) AND NEW.room_id IS NOT NULL THEN
        SELECT rt.property_id INTO @found_property_id
        FROM rooms r
        JOIN roomtypes rt ON r.room_type_id = rt.room_type_id
        WHERE r.room_id = NEW.room_id
        LIMIT 1;
        IF @found_property_id IS NOT NULL THEN
            SET NEW.property_id = @found_property_id;
        ELSE
            SET NEW.property_id = 1;
        END IF;
    END IF;
END//

DELIMITER ;

-- =============================================================================
-- PHẦN 6: SEED DATA TOÀN DIỆN CHO CẢ 3 ITERATION & ROLE DASHBOARDS & QR PAYMENTS
-- =============================================================================

-- 1. SEED ROLES
INSERT INTO `roles` (`role_id`, `role_name`, `description`) VALUES
(1, 'ROLE_ADMIN', 'Quản trị viên hệ thống toàn quyền'),
(2, 'ROLE_CUSTOMER', 'Khách hàng sử dụng dịch vụ đặt phòng và tour'),
(3, 'ROLE_HOST', 'Chủ nhà quản lý cơ sở lưu trú và tour trải nghiệm');

-- 2. SEED USERS (Mật khẩu BCrypt: admin123 cho admin, 123456 cho các tài khoản khác)
INSERT INTO `users` (
    `user_id`, `full_name`, `email`, `password_hash`, `password`, `phone`, `avatar_url`, `status`,
    `email_verified`, `date_of_birth`, `gender`, `address`, `loyalty_points`, `google_id`, `auth_provider`
) VALUES
(1, 'System Administrator', 'admin@homestay.com', '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC', '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC', '0901234567', 'images/person_1.jpg', 'ACTIVE', 1, '1995-05-15', 'MALE', 'Hoàn Kiếm, Hà Nội', 500, NULL, 'local'),
(2, 'Khanh MG', 'khanhmg2k3@gmail.com', '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a', '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a', '0987654321', 'images/person_2.jpg', 'ACTIVE', 1, '2003-08-20', 'MALE', 'Hải Châu, Đà Nẵng', 1200, NULL, 'local'),
(3, 'Demo Host', 'host@homestay.com', '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a', '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a', '0912345678', 'images/person_3.jpg', 'ACTIVE', 1, '1990-10-10', 'FEMALE', 'Sơn Trà, Đà Nẵng', 300, NULL, 'local'),
(4, 'Nguyễn Văn An', 'an.nguyen@gmail.com', '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a', '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a', '0933112233', 'images/person_4.jpg', 'ACTIVE', 1, '1998-12-01', 'MALE', 'Quận 1, TP. Hồ Chí Minh', 150, NULL, 'local');

-- 3. SEED USERROLES
INSERT INTO `userroles` (`user_id`, `role_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 2);

-- 4. SEED COUNTRIES
INSERT INTO `countries` (`country_id`, `country_name`) VALUES
(1, 'Việt Nam'),
(2, 'Thái Lan'),
(3, 'Singapore'),
(4, 'Nhật Bản');

-- 5. SEED PROVINCES
INSERT INTO `provinces` (`province_id`, `country_id`, `province_name`) VALUES
(1, 1, 'Đà Nẵng'),
(2, 1, 'Hà Nội'),
(3, 1, 'Hồ Chí Minh'),
(4, 1, 'Lâm Đồng'),
(5, 1, 'Khánh Hòa'),
(6, 1, 'Kiên Giang');

-- 6. SEED DESTINATIONS
INSERT INTO `destinations` (`destination_id`, `province_id`, `destination_name`, `description`, `image_url`, `latitude`, `longitude`) VALUES
(1, 1, 'Bán đảo Sơn Trà & Biển Mỹ Khê', 'Điểm đến du lịch biển hàng đầu với bờ cát trắng mịn và rừng nguyên sinh Sơn Trà.', 'images/img_1.jpg', 16.0544070, 108.2021670),
(2, 2, 'Phố Cổ Hà Nội', 'Khu 36 phố phường nghìn năm văn hiến, ẩm thực phong phú và đậm đà bản sắc.', 'images/img_2.jpg', 21.0285110, 105.8048170),
(3, 4, 'Đà Lạt Mộng Mơ', 'Xứ sở ngàn hoa với khí hậu se lạnh quanh năm và cảnh quan rừng thông lãng mạn.', 'images/img_3.jpg', 11.9404190, 108.4583130),
(4, 3, 'Trung tâm Sài Gòn sôi động', 'Trung tâm kinh tế sầm uất với các di tích lịch sử và cuộc sống về đêm rực rỡ.', 'images/slider-1.jpg', 10.7768890, 106.7008060),
(5, 5, 'Vịnh Biển Nha Trang', 'Thành phố biển ngập tràn ánh nắng cùng hệ sinh thái biển và đảo ngọc đa dạng.', 'images/slider-2.jpg', 12.2387910, 109.1967490),
(6, 6, 'Đảo Ngọc Phú Quốc', 'Thiên đường nghỉ dưỡng với hoàng hôn tuyệt đẹp và các resort cao cấp ven biển.', 'images/slider-3.jpg', 10.2898790, 103.9840200);

-- 7. SEED HOST_PROFILES
INSERT INTO `host_profiles` (`id`, `user_id`, `business_name`, `business_type`, `phone`, `verification_status`, `rejection_reason`) VALUES
(1, 3, 'Sogo Hospitality Group', 'HOMESTAY', '0912345678', 'APPROVED', NULL),
(2, 1, 'Sogo Master Host Service', 'HOTEL', '0901234567', 'APPROVED', NULL);

-- 8. SEED PROPERTIES
INSERT INTO `properties` (
    `property_id`, `owner_id`, `host_id`, `destination_id`, `property_name`, `name`, `property_type`,
    `description`, `address`, `city`, `country`, `star_rating`, `review_count`, `average_rating`, `status`,
    `latitude`, `longitude`
) VALUES
(1, 3, 1, 1, 'Sogo Riverside Homestay Đà Nẵng', 'Sogo Riverside Homestay Đà Nẵng', 'HOMESTAY',
 'Homestay ven sông Hàn ngắm cầu Rồng phun lửa, không gian ấm cúng, thiết kế hiện đại hòa quyện thiên nhiên.',
 '123 Trần Hưng Đạo, P. An Hải Tây, Q. Sơn Trà', 'Đà Nẵng', 'Vietnam', 4.5, 48, 4.85, 'APPROVED', 16.0610000, 108.2320000),

(2, 3, 1, 3, 'Sogo Pine Hill Homestay Đà Lạt', 'Sogo Pine Hill Homestay Đà Lạt', 'HOMESTAY',
 'Homestay trên đồi thông thơ mộng ngắm sương mù buổi sớm, có sân BBQ và quán cà phê riêng biệt.',
 '45 Khởi Nghĩa Bắc Sơn, Phường 10', 'Đà Lạt', 'Vietnam', 4.0, 32, 4.70, 'APPROVED', 11.9350000, 108.4510000),

(3, 1, 2, 2, 'Sogo Heritage Boutique Hà Nội', 'Sogo Heritage Boutique Hà Nội', 'HOMESTAY',
 'Ngôi nhà cổ giữa lòng phố cổ Hà Nội, đầy đủ tiện nghi tiêu chuẩn quốc tế và nét văn hóa Tràng An.',
 '12 Hàng Bè, P. Hàng Bạc, Q. Hoàn Kiếm', 'Hà Nội', 'Vietnam', 5.0, 20, 4.90, 'APPROVED', 21.0330000, 105.8540000);

-- 9. SEED PROPERTYIMAGES
INSERT INTO `propertyimages` (`image_id`, `property_id`, `image_url`, `is_thumbnail`, `display_order`) VALUES
(1, 1, 'images/img_1.jpg', 1, 1),
(2, 1, 'images/img_2.jpg', 0, 2),
(3, 1, 'images/img_3.jpg', 0, 3),
(4, 2, 'images/slider-1.jpg', 1, 1),
(5, 2, 'images/slider-2.jpg', 0, 2),
(6, 3, 'images/slider-3.jpg', 1, 1);

-- 10. SEED AMENITIES
INSERT INTO `amenities` (`amenity_id`, `amenity_name`, `category`) VALUES
(1, 'Wi-Fi tốc độ cao', 'Công nghệ'),
(2, 'Điều hòa nhiệt độ', 'Tiện nghi phòng'),
(3, 'Hồ bơi vô cực', 'Giải trí'),
(4, 'Bếp nấu ăn gia đình', 'Ăn uống'),
(5, 'Bãi đỗ xe miễn phí', 'Tiện ích chung'),
(6, 'Bồn tắm nước nóng', 'Phòng tắm'),
(7, 'Máy giặt & sấy', 'Dịch vụ'),
(8, 'Sân nướng BBQ ngoài trời', 'Giải trí');

-- 11. SEED PROPERTYAMENITIES
INSERT INTO `propertyamenities` (`property_id`, `amenity_id`) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 8),
(2, 1), (2, 2), (2, 4), (2, 5), (2, 7), (2, 8),
(3, 1), (3, 2), (3, 6), (3, 7);

-- 12. SEED ROOMTYPES
INSERT INTO `roomtypes` (
    `room_type_id`, `property_id`, `room_name`, `description`, `bed_type`,
    `max_guests`, `base_price`, `quantity`, `size_m2`, `status`, `rating`, `review_count`
) VALUES
(1, 1, 'Single Cozy Room', 'Phòng đơn tiêu chuẩn ấm cúng, view thành phố lãng mạn, phù hợp du lịch một mình hoặc công tác.', '1 Giường đơn (Single Bed)', 1, 90.00, 3, 22.00, 'ACTIVE', 4.8, 18),
(2, 1, 'Family Sweet Suite', 'Phòng gia đình rộng rãi, có phòng khách phụ và ban công view sông Hàn tuyệt đẹp.', '2 Giường đôi lớn (King Size)', 4, 120.00, 2, 45.00, 'ACTIVE', 4.9, 25),
(3, 1, 'Presidential Suite Room', 'Căn suite hoàng gia thượng hạng với nội thất cao cấp và bồn sục jacuzzi riêng.', '1 Giường King siêu lớn', 2, 250.00, 1, 65.00, 'ACTIVE', 5.0, 12),
(4, 2, 'Deluxe Garden Room', 'Phòng Deluxe phong cách mộc nhìn thẳng ra vườn hoa cẩm tú cầu và đồi thông xanh.', '1 Giường Queen Size', 2, 150.00, 4, 32.00, 'ACTIVE', 4.7, 15),
(5, 2, 'Cozy Wooden Studio', 'Căn studio ốp gỗ thông ngát hương, đầy đủ bếp mini tự nấu nướng.', '1 Giường Queen Size', 2, 110.00, 2, 28.00, 'ACTIVE', 4.6, 9),
(6, 3, 'Old Quarter Classic Room', 'Phòng lưu trú phong cách Indochine hoài niệm giữa trung tâm phố cổ.', '1 Giường King Size', 2, 130.00, 3, 35.00, 'ACTIVE', 4.9, 14);

-- 13. SEED ROOMS
INSERT INTO `rooms` (
    `room_id`, `room_type_id`, `room_number`, `room_name`, `price_per_night`,
    `capacity`, `image_url`, `description`, `status`, `is_featured`
) VALUES
(1, 1, 'HOMESTAY-101', 'Single Cozy Room 101', 90.00, 1, 'images/img_1.jpg', 'Phòng đơn tầng 1, ban công đón gió mát mẻ.', 'AVAILABLE', 1),
(2, 1, 'HOMESTAY-102', 'Single Cozy Room 102', 90.00, 1, 'images/slider-2.jpg', 'Phòng đơn tầng 2, không gian yên tĩnh thư giãn.', 'AVAILABLE', 0),
(3, 2, 'HOMESTAY-201', 'Family Sweet Suite 201', 120.00, 4, 'images/img_2.jpg', 'Phòng gia đình tầng 2 đầy đủ tiện ích và bếp nhỏ.', 'AVAILABLE', 1),
(4, 2, 'HOMESTAY-202', 'Grand Family Room 202', 120.00, 4, 'images/slider-3.jpg', 'Phòng đại gia đình có sofa bed và ban công ngắm sông.', 'AVAILABLE', 0),
(5, 3, 'HOMESTAY-301', 'Presidential Suite Room 301', 250.00, 2, 'images/img_3.jpg', 'Phòng tổng thống VIP nhất hệ thống Sogo.', 'AVAILABLE', 1),
(6, 4, 'HOMESTAY-401', 'Deluxe Garden Room 401', 150.00, 2, 'images/slider-1.jpg', 'Phòng Deluxe view đồi thông Đà Lạt mộng mơ.', 'AVAILABLE', 0);

-- 14. SEED ROOMIMAGES
INSERT INTO `roomimages` (`image_id`, `room_type_id`, `image_url`, `display_order`) VALUES
(1, 1, 'images/img_1.jpg', 1),
(2, 1, 'images/slider-2.jpg', 2),
(3, 2, 'images/img_2.jpg', 1),
(4, 2, 'images/slider-3.jpg', 2),
(5, 3, 'images/img_3.jpg', 1),
(6, 4, 'images/slider-1.jpg', 1),
(7, 5, 'images/img_2.jpg', 1),
(8, 6, 'images/img_1.jpg', 1);

-- 15. SEED ROOMTYPEAMENITIES
INSERT INTO `roomtypeamenities` (`room_type_id`, `amenity_id`) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2), (2, 4),
(3, 1), (3, 2), (3, 6),
(4, 1), (4, 2), (4, 8),
(5, 1), (5, 4),
(6, 1), (6, 2), (6, 6);

-- 16. SEED TOURS
INSERT INTO `tours` (
    `tour_id`, `operator_id`, `destination_id`, `tour_name`, `description`, `duration_days`,
    `duration_nights`, `base_price`, `max_participants`, `average_rating`, `review_count`, `status`
) VALUES
(1, 3, 1, 'Khám Phá Bán Đảo Sơn Trà & Lặn Ngắm San Hô Cù Lao Chàm',
 'Hành trình 1 ngày trải nghiệm chèo SUP ngắm bình minh biển Mỹ Khê và lặn biển san hô tuyệt đẹp.',
 1, 0, 45.00, 15, 4.90, 24, 'APPROVED'),

(2, 3, 3, 'Săn Mây Cầu Đất & Cắm Trại Rừng Thông Đà Lạt',
 'Tour dã ngoại săn mây lúc 5h sáng, tiệc BBQ đốt lửa trại giữa thung lũng thông reo.',
 2, 1, 85.00, 10, 4.85, 18, 'APPROVED');

-- 17. SEED TOURSOUNDS & SCHEDULES
INSERT INTO `tourschedules` (
    `schedule_id`, `tour_id`, `departure_datetime`, `return_datetime`, `available_slots`, `booked_slots`, `price`, `status`
) VALUES
(1, 1, '2026-10-01 07:00:00', '2026-10-01 17:00:00', 15, 3, 45.00, 'OPEN'),
(2, 2, '2026-10-05 05:00:00', '2026-10-06 12:00:00', 10, 2, 85.00, 'OPEN');

-- 18. SEED TOURITINERARIES
INSERT INTO `touritineraries` (`itinerary_id`, `tour_id`, `day_number`, `title`, `description`) VALUES
(1, 1, 1, 'Buổi sáng: Chèo SUP Mỹ Khê & Chùa Linh Ứng', 'Xe đón khách tại homestay lúc 7:00, trải nghiệm thể thao nước và tham quan tượng Phật Bà.'),
(2, 1, 1, 'Buổi chiều: Lặn biển ngắm rạn san hô Bãi Bụt', 'Dùng bữa trưa hải sản tươi sống và thưởng thức hoàng hôn trên đỉnh Sơn Trà.'),
(3, 2, 1, 'Săn biển mây Cầu Đất & Cắm trại đồi thông', 'Check-in cánh đồng điện gió, di chuyển đến khu lều trại và thưởng thức tiệc BBQ.'),
(4, 2, 2, 'Đón bình minh & Thưởng thức cà phê mộc', 'Nhâm nhi cà phê Arabica đặc sản Đà Lạt trước khi khởi hành về homestay.');

-- 19. SEED COUPONS
INSERT INTO `coupons` (
    `coupon_id`, `coupon_code`, `description`, `discount_type`, `discount_value`,
    `minimum_order_amount`, `maximum_discount`, `usage_limit`, `used_count`, `start_at`, `end_at`, `status`
) VALUES
(1, 'WELCOME2026', 'Giảm 15% cho khách hàng mới đặt phòng lần đầu tiên tại Sogo', 'PERCENTAGE', 15.00, 50.00, 30.00, 500, 12, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 'ACTIVE'),
(2, 'SUMMER20', 'Giảm ngay 20 USD cho các đơn đặt phòng từ 3 đêm trở lên', 'FIXED', 20.00, 100.00, 20.00, 200, 8, '2026-05-01 00:00:00', '2026-10-31 23:59:59', 'ACTIVE'),
(3, 'SOGOVIP', 'Giảm 25% đặc quyền dành cho thành viên thân thiết', 'PERCENTAGE', 25.00, 150.00, 50.00, 100, 5, '2026-01-01 00:00:00', '2026-12-31 23:59:59', 'ACTIVE');

-- 20. SEED SAMPLE BOOKINGS
INSERT INTO `bookings` (
    `booking_id`, `booking_code`, `user_id`, `property_id`, `room_id`, `customer_name`,
    `customer_email`, `customer_phone`, `check_in`, `check_in_date`, `check_out`, `check_out_date`,
    `adults`, `children`, `rooms_count`, `subtotal`, `discount_amount`, `total_amount`, `total_price`,
    `notes`, `booking_status`, `status`, `created_at`
) VALUES
(1, 'BK260901001', 2, 1, 1, 'Khanh MG', 'khanhmg2k3@gmail.com', '0987654321',
 '2026-10-10', '2026-10-10', '2026-10-12', '2026-10-12', 1, 0, 1, 180.00, 27.00, 153.00, 153.00,
 'Khách yêu cầu nhận phòng sớm lúc 12:00 nếu có thể.', 'CONFIRMED', 'CONFIRMED', '2026-09-20 10:30:00'),

(2, 'BK260901002', 4, 1, 3, 'Nguyễn Văn An', 'an.nguyen@gmail.com', '0933112233',
 '2026-10-15', '2026-10-15', '2026-10-17', '2026-10-17', 2, 1, 1, 240.00, 0.00, 240.00, 240.00,
 'Cần chuẩn bị thêm 1 nôi trẻ em.', 'PENDING', 'PENDING', '2026-09-24 15:45:00');

-- 21. SEED BOOKINGROOMS & BOOKINGGUESTS
INSERT INTO `bookingrooms` (`booking_room_id`, `booking_id`, `room_type_id`, `quantity`, `price_per_night`, `number_of_nights`, `subtotal`) VALUES
(1, 1, 1, 1, 90.00, 2, 180.00),
(2, 2, 2, 1, 120.00, 2, 240.00);

INSERT INTO `bookingguests` (`guest_id`, `booking_id`, `full_name`, `phone`, `email`, `special_request`) VALUES
(1, 1, 'Khanh MG', '0987654321', 'khanhmg2k3@gmail.com', 'Nhận phòng sớm'),
(2, 2, 'Nguyễn Văn An', '0933112233', 'an.nguyen@gmail.com', 'Thêm nôi em bé');

-- 22. SEED SYSTEM_BANK_ACCOUNTS (Tài khoản thụ hưởng VietQR)
INSERT INTO `system_bank_accounts` (
    `account_id`, `bank_code`, `bank_name`, `account_number`, `account_holder`, `branch`, `bin_code`, `qr_template`, `is_active`, `is_default`
) VALUES
(1, 'MB', 'Ngân hàng Quân Đội (MBBank)', '0987654321', 'CONG TY TNHH SOGO HOMESTAY', 'Chi nhánh Đà Nẵng', '970422', 'compact2', 1, 1),
(2, 'VCB', 'Ngân hàng Ngoại Thương Việt Nam (Vietcombank)', '1023456789', 'CONG TY TNHH SOGO HOMESTAY', 'Chi nhánh Ba Đình Hà Nội', '970436', 'compact2', 1, 0);

-- 23. SEED PAYMENTS (Bao gồm phương thức VIETQR & VNPAY)
INSERT INTO `payments` (
    `payment_id`, `payment_code`, `user_id`, `booking_id`, `tour_booking_id`, `amount`,
    `payment_method`, `transaction_id`, `status`, `qr_code_url`, `transfer_content`,
    `bank_code`, `account_number`, `account_holder`, `qr_expired_at`, `paid_at`
) VALUES
(1, 'PAY-BK260901001', 2, 1, NULL, 153.00, 'VIETQR', 'VQR2026092010351234', 'SUCCESS',
 'https://img.vietqr.io/image/MB-0987654321-compact2.png?amount=153&addInfo=SOGO%20BK260901001&accountName=CONG%20TY%20TNHH%20SOGO%20HOMESTAY',
 'SOGO BK260901001', 'MB', '0987654321', 'CONG TY TNHH SOGO HOMESTAY', '2026-09-20 10:45:00', '2026-09-20 10:35:00'),

(2, 'PAY-BK260901002', 4, 2, NULL, 240.00, 'VIETQR', NULL, 'PENDING',
 'https://img.vietqr.io/image/MB-0987654321-compact2.png?amount=240&addInfo=SOGO%20BK260901002&accountName=CONG%20TY%20TNHH%20SOGO%20HOMESTAY',
 'SOGO BK260901002', 'MB', '0987654321', 'CONG TY TNHH SOGO HOMESTAY', '2026-10-15 16:00:00', NULL);

-- 24. SEED PAYMENT_QR_CODES
INSERT INTO `payment_qr_codes` (
    `qr_id`, `payment_id`, `booking_id`, `bank_code`, `account_number`, `account_holder`,
    `amount`, `transfer_content`, `qr_data_url`, `status`, `expires_at`, `created_at`, `paid_at`
) VALUES
(1, 1, 1, 'MB', '0987654321', 'CONG TY TNHH SOGO HOMESTAY', 153.00, 'SOGO BK260901001',
 'https://img.vietqr.io/image/MB-0987654321-compact2.png?amount=153&addInfo=SOGO%20BK260901001&accountName=CONG%20TY%20TNHH%20SOGO%20HOMESTAY',
 'PAID', '2026-09-20 10:45:00', '2026-09-20 10:30:00', '2026-09-20 10:35:00'),

(2, 2, 2, 'MB', '0987654321', 'CONG TY TNHH SOGO HOMESTAY', 240.00, 'SOGO BK260901002',
 'https://img.vietqr.io/image/MB-0987654321-compact2.png?amount=240&addInfo=SOGO%20BK260901002&accountName=CONG%20TY%20TNHH%20SOGO%20HOMESTAY',
 'PENDING', '2026-10-15 16:00:00', '2026-09-24 15:45:00', NULL);

-- 25. SEED REVIEWS & REVIEWREPLIES
INSERT INTO `reviews` (
    `review_id`, `user_id`, `property_id`, `tour_id`, `booking_id`, `tour_booking_id`,
    `rating`, `title`, `comment`, `status`, `created_at`
) VALUES
(1, 2, 1, NULL, 1, NULL, 5, 'Trải nghiệm tuyệt vời hơn cả mong đợi!',
 'Phòng sạch sẽ tinh tươm, view sông Hàn tuyệt đẹp. Chủ nhà nhiệt tình hỗ trợ thuê xe máy và chỉ chỗ ăn ngon.', 'APPROVED', '2026-09-22 09:15:00');

INSERT INTO `reviewreplies` (`reply_id`, `review_id`, `user_id`, `reply_content`, `created_at`) VALUES
(1, 1, 3, 'Cảm ơn bạn Khanh rất nhiều vì đã ghé thăm Sogo! Chúc bạn luôn có những chuyến đi thật trọn vẹn và hẹn sớm gặp lại.', '2026-09-22 10:00:00');

-- 26. SEED FAQS
INSERT INTO `faqs` (`faq_id`, `question`, `answer`, `category`, `display_order`, `status`) VALUES
(1, 'Thời gian nhận phòng (Check-in) và trả phòng (Check-out) là mấy giờ?', 'Thời gian nhận phòng tiêu chuẩn từ 14:00 và trả phòng trước 12:00 trưa hôm sau. Quý khách có thể yêu cầu nhận phòng sớm tùy vào tình trạng phòng sẵn có.', 'Đặt phòng', 1, 1),
(2, 'Chính sách hủy phòng và hoàn tiền của Sogo Homestay như thế nào?', 'Hủy phòng trước 7 ngày so với ngày nhận phòng sẽ được hoàn tiền 100%. Hủy trước 3 ngày được hoàn 50%. Quý khách có thể xem chi tiết trong đơn đặt.', 'Thanh toán & Hủy phòng', 2, 1),
(3, 'Tôi có thể thanh toán qua mã QR VietQR không?', 'Có, Sogo hỗ trợ thanh toán tự động qua mã VietQR của tất cả các ứng dụng ngân hàng và ví điện tử, tiền vào ngay và đơn đặt tự động xác nhận.', 'Thanh toán', 3, 1);

-- 27. SEED CONTACTMESSAGES
INSERT INTO `contactmessages` (`message_id`, `user_id`, `name`, `email`, `subject`, `message`, `status`) VALUES
(1, 4, 'Nguyễn Văn An', 'an.nguyen@gmail.com', 'Tư vấn đặt phòng nhóm đông người', 'Tôi muốn đặt 4 phòng cho đoàn gia đình vào tháng 11, Sogo có ưu đãi đặc biệt không?', 'NEW');

-- 28. SEED NOTIFICATIONS
INSERT INTO `notifications` (`notification_id`, `user_id`, `title`, `message`, `notification_type`, `reference_id`, `is_read`) VALUES
(1, 2, 'Đặt phòng thành công #BK260901001', 'Đơn đặt phòng Single Cozy Room của bạn tại Sogo Riverside Đà Nẵng đã được xác nhận qua VietQR!', 'BOOKING', 1, 1),
(2, 2, 'Ưu đãi mùa thu dành riêng cho bạn', 'Tặng bạn mã SUMMER20 giảm 20 USD cho chuyến vi vu Đà Lạt tiếp theo!', 'PROMOTION', 2, 0);

-- 29. SEED AI CONVERSATIONS & CHATMESSAGES
INSERT INTO `conversations` (`conversation_id`, `conversation_type`, `created_by`, `status`) VALUES
(1, 'AI_CHAT', 2, 'OPEN');

INSERT INTO `chatmessages` (`message_id`, `conversation_id`, `sender_id`, `sender_type`, `message`) VALUES
(1, 1, 2, 'USER', 'Xin chào, tôi muốn tìm homestay yên tĩnh ở Đà Lạt cho 2 người, ngân sách khoảng 100 USD/đêm.'),
(2, 1, NULL, 'AI', 'Chào bạn Khanh! Sogo gợi ý cho bạn căn "Deluxe Garden Room" tại Sogo Pine Hill Homestay Đà Lạt. Căn phòng view đồi thông thanh bình, giá chỉ 150 USD/đêm và có sân vườn BBQ cực kỳ lãng mạn.');

-- 30. SEED USERPREFERENCES & USERSEGMENTS
INSERT INTO `userpreferences` (
    `preference_id`, `user_id`, `preferred_budget_min`, `preferred_budget_max`,
    `preferred_room_type`, `homestay_style`, `preferred_destination`
) VALUES
(1, 2, 80.00, 200.00, 'SINGLE', 'MID_RANGE', 'Đà Nẵng');

INSERT INTO `usersegments` (
    `segment_id`, `user_id`, `segment`, `average_booking_amount`, `total_spending`, `total_bookings`, `confidence`
) VALUES
(1, 2, 'MID_RANGE', 153.00, 153.00, 1, 0.9200);

-- 31. SEED RECOMMENDATIONS
INSERT INTO `recommendations` (
    `recommendation_id`, `user_id`, `property_id`, `room_type_id`, `tour_id`,
    `recommendation_type`, `score`, `reason`, `is_displayed`
) VALUES
(1, 2, 2, NULL, NULL, 'BUDGET_MATCH', 0.950000, 'Phù hợp với tầm giá và sở thích homestay nghỉ dưỡng lãng mạn của bạn', 1);

-- 32. SEED PLATFORM_CONFIGS (Cấu hình cho Admin Dashboard)
INSERT INTO `platform_configs` (`config_id`, `config_key`, `config_value`, `description`, `category`) VALUES
(1, 'PLATFORM_COMMISSION_RATE', '10.0', 'Tỷ lệ hoa hồng nền tảng thu từ mỗi đơn đặt phòng thành công (%)', 'FINANCE'),
(2, 'BOOKING_QR_EXPIRATION_MINUTES', '15', 'Thời gian mã QR thanh toán có hiệu lực trước khi tự động hủy (phút)', 'PAYMENT'),
(3, 'AUTO_APPROVE_HOMESTAY', 'false', 'Tự động duyệt homestay mới đăng ký mà không cần Admin kiểm tra', 'SYSTEM'),
(4, 'MIN_HOST_PAYOUT_AMOUNT', '50.0', 'Số tiền tối thiểu Host có thể yêu cầu rút về tài khoản ngân hàng (USD)', 'FINANCE');

-- 33. SEED ADMIN_ACTIVITY_LOGS (Nhật ký hành động cho Admin Dashboard)
INSERT INTO `admin_activity_logs` (
    `log_id`, `admin_id`, `action_type`, `target_type`, `target_id`, `description`, `ip_address`
) VALUES
(1, 1, 'APPROVE_HOST', 'HOST_PROFILE', 1, 'Phê duyệt hồ sơ chủ nhà đối tác Sogo Hospitality Group', '127.0.0.1'),
(2, 1, 'APPROVE_PROPERTY', 'PROPERTY', 1, 'Phê duyệt xuất bản cơ sở Sogo Riverside Homestay Đà Nẵng lên trang chủ', '127.0.0.1'),
(3, 1, 'UPDATE_CONFIG', 'PLATFORM_CONFIG', 1, 'Cập nhật tỷ lệ chiết khấu sàn homestay về mức 10%', '127.0.0.1');

-- 34. SEED HOST_PAYOUTS (Yêu cầu rút tiền cho Host Dashboard)
INSERT INTO `host_payouts` (
    `payout_id`, `payout_code`, `host_id`, `amount`, `bank_code`, `account_number`,
    `account_holder`, `status`, `notes`, `requested_at`, `processed_at`, `processed_by`
) VALUES
(1, 'PO-202609001', 1, 137.70, 'MB', '0987654321', 'DEMO HOST SOGO', 'COMPLETED',
 'Doanh thu đơn BK260901001 sau khi trừ 10% phí nền tảng', '2026-09-22 14:00:00', '2026-09-22 16:30:00', 1);

-- 35. SEED HOST_DAILY_ANALYTICS (Số liệu thống kê lượt xem, doanh thu cho Host Dashboard)
INSERT INTO `host_daily_analytics` (
    `analytics_id`, `host_id`, `property_id`, `stat_date`, `view_count`, `click_count`, `booking_count`, `revenue`, `occupancy_rate`
) VALUES
(1, 1, 1, '2026-09-20', 142, 38, 1, 153.00, 50.00),
(2, 1, 1, '2026-09-21', 165, 45, 0, 0.00, 50.00),
(3, 1, 1, '2026-09-22', 198, 52, 1, 120.00, 75.00),
(4, 1, 2, '2026-09-22', 88, 20, 0, 0.00, 33.33);

-- 36. SEED DASHBOARD_ANNOUNCEMENTS (Bảng tin thông báo cho các Role)
INSERT INTO `dashboard_announcements` (
    `announcement_id`, `title`, `content`, `target_role`, `priority`, `is_active`, `created_by`
) VALUES
(1, 'Chào mừng đến với Cổng quản trị Sogo Homestay', 'Hệ thống đã nâng cấp toàn diện các công cụ hỗ trợ báo cáo doanh thu, duyệt hồ sơ và giám sát giao dịch.', 'ROLE_ADMIN', 'HIGH', 1, 1),
(2, 'Chính sách ưu đãi hoa hồng 0% trong tháng đầu dành cho Host mới', 'Tất cả các cơ sở lưu trú mới được phê duyệt trong tháng 9 sẽ được miễn 100% phí dịch vụ sàn.', 'ROLE_HOST', 'HIGH', 1, 1),
(3, 'Thanh toán tức thì và nhận phòng nhanh chóng qua mã VietQR', 'Từ nay bạn có thể quét mã QR ngân hàng hoặc ví MoMo để hoàn tất thanh toán trong 5 giây và nhận voucher 15%!', 'ROLE_CUSTOMER', 'NORMAL', 1, 1);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- HOÀN TẤT KHỞI TẠO CƠ SỞ DỮ LIỆU ĐẦY ĐỦ (QR PAYMENT & MULTI-ROLE DASHBOARDS)
-- =============================================================================
