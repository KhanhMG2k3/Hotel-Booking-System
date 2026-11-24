-- =============================================================================
-- SOGO HOMESTAY BOOKING SYSTEM - MASTER DATABASE HỢP NHẤT 4 THÀNH VIÊN
-- =============================================================================
-- Database: homestay_iter1_test
-- Đã hợp nhất đầy đủ 100% cấu trúc, khóa ngoại và dữ liệu mẫu từ:
--   1. Schema 1 (Thành viên 1) : Đánh giá & Phản hồi (reviews, review_replies),
--                                Thông báo (notifications), Hỗ trợ (contactmessages, support_replies),
--                                Quy định chi tiết (term_sections, terms, terms_setting),
--                                Tiện ích phòng trực tiếp (room_amenities).
--   2. Schema 2 (Thành viên 2) : Core Platform, Identity & Phân quyền đa vai trò (roles, users, userroles),
--                                Xác thực 2FA OTP, Reset Password, Đối tác (host_applications, partner_app_*),
--                                Danh mục Homestay & Phòng (properties, roomtypes, rooms, roomimages),
--                                Wishlists, FAQs, Static Pages.
--   3. Schema 3 (Thành viên 3) : Hệ thống Tài chính, Ví tiền & Sổ cái giao dịch (wallet_accounts,
--                                ledger_entries, ledger_lines, payment_configs, payment_fee_snapshots,
--                                payment_attempts, payment_events, payment_allocations, payouts,
--                                refunds, tax_records, finance_audit_logs).
--   4. Schema của Bạn (Thành viên 4) : Gợi ý phòng thông minh AI (recommendations - POPULAR/AI_HYBRID),
--                                     Lịch phòng Host (Host Booking Calendar), Bộ lọc & Tìm kiếm.
--
-- Tương thích: MySQL 8.0+ / 9.0+ | Character Set: utf8mb4 | Collation: utf8mb4_unicode_ci
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

-- 1. TẠO & CHỌN DATABASE
CREATE DATABASE IF NOT EXISTS `homestay_iter1_test`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `homestay_iter1_test`;

-- =============================================================================
-- DỌN DẸP VIEW VÀ BẢNG CŨ (CLEANUP)
-- =============================================================================
DROP VIEW IF EXISTS `room_types`;
DROP VIEW IF EXISTS `room_images`;
DROP VIEW IF EXISTS `v_customer_dashboard_summary`;
DROP VIEW IF EXISTS `v_host_dashboard_summary`;
DROP VIEW IF EXISTS `v_admin_dashboard_summary`;

DROP TABLE IF EXISTS `finance_audit_logs`;
DROP TABLE IF EXISTS `tax_records`;
DROP TABLE IF EXISTS `refunds`;
DROP TABLE IF EXISTS `payouts`;
DROP TABLE IF EXISTS `payment_allocations`;
DROP TABLE IF EXISTS `payment_events`;
DROP TABLE IF EXISTS `payment_attempts`;
DROP TABLE IF EXISTS `payment_fee_snapshots`;
DROP TABLE IF EXISTS `payment_configs`;
DROP TABLE IF EXISTS `ledger_lines`;
DROP TABLE IF EXISTS `ledger_entries`;
DROP TABLE IF EXISTS `wallet_accounts`;

DROP TABLE IF EXISTS `recommendations`;

DROP TABLE IF EXISTS `support_replies`;
DROP TABLE IF EXISTS `review_replies`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `term_sections`;
DROP TABLE IF EXISTS `terms_setting`;
DROP TABLE IF EXISTS `terms`;

DROP TABLE IF EXISTS `wishlists`;
DROP TABLE IF EXISTS `vouchers`;
DROP TABLE IF EXISTS `bookingrooms`;
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `contactmessages`;
DROP TABLE IF EXISTS `static_pages`;
DROP TABLE IF EXISTS `faqs`;
DROP TABLE IF EXISTS `userbehaviors`;

DROP TABLE IF EXISTS `room_amenities`;
DROP TABLE IF EXISTS `roomimages`;
DROP TABLE IF EXISTS `roomtypeamenities`;
DROP TABLE IF EXISTS `rooms`;
DROP TABLE IF EXISTS `roomtypes`;

DROP TABLE IF EXISTS `propertyamenities`;
DROP TABLE IF EXISTS `propertyimages`;
DROP TABLE IF EXISTS `properties`;
DROP TABLE IF EXISTS `amenities`;

DROP TABLE IF EXISTS `partner_application_staged_media`;
DROP TABLE IF EXISTS `partner_application_room_images`;
DROP TABLE IF EXISTS `partner_application_room_amenities`;
DROP TABLE IF EXISTS `partner_application_rooms`;
DROP TABLE IF EXISTS `host_applications`;
DROP TABLE IF EXISTS `host_profiles`;

DROP TABLE IF EXISTS `destinations`;
DROP TABLE IF EXISTS `provinces`;
DROP TABLE IF EXISTS `countries`;

DROP TABLE IF EXISTS `email_otps`;
DROP TABLE IF EXISTS `password_resets`;
DROP TABLE IF EXISTS `userroles`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

-- =============================================================================
-- PHẦN 1: TÀI KHOẢN, PHÂN QUYỀN & BẢO MẬT (AUTH & SECURITY - TỪ SCHEMA 2)
-- =============================================================================
CREATE TABLE `roles` (
    `role_id` INT NOT NULL AUTO_INCREMENT,
    `role_name` VARCHAR(50) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `users` (
    `user_id` INT NOT NULL AUTO_INCREMENT,
    `role_id` INT NOT NULL DEFAULT 2,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `display_name` VARCHAR(100) NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NULL,
    `password` VARCHAR(255) NULL,
    `phone` VARCHAR(30) NULL,
    `avatar_url` VARCHAR(500) NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    `two_factor_enabled` BOOLEAN NOT NULL DEFAULT FALSE,
    `email_verified` TINYINT(1) NOT NULL DEFAULT 0,
    `date_of_birth` DATE NULL,
    `gender` VARCHAR(20) NULL,
    `address` VARCHAR(255) NULL,
    `loyalty_points` INT NOT NULL DEFAULT 0,
    `google_id` VARCHAR(100) NULL UNIQUE,
    `auth_provider` VARCHAR(50) NOT NULL DEFAULT 'local',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `userroles` (
    `user_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    CONSTRAINT `fk_userroles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_userroles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `password_resets` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `token` VARCHAR(64) NOT NULL UNIQUE,
    `expires_at` TIMESTAMP NOT NULL,
    `used` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_password_resets_token` (`token`),
    CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `email_otps` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `otp_code` VARCHAR(6) NOT NULL,
    `purpose` ENUM('LOGIN_2FA', 'ENABLE_2FA') NOT NULL DEFAULT 'LOGIN_2FA',
    `expires_at` TIMESTAMP NOT NULL,
    `used` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_email_otps_user` (`user_id`),
    CONSTRAINT `fk_email_otps_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 2: ĐỊA LÝ, HỒ SƠ HOST & ĐỐI TÁC (TỪ SCHEMA 2)
-- =============================================================================
CREATE TABLE `countries` (
    `country_id` INT NOT NULL AUTO_INCREMENT,
    `country_name` VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `provinces` (
    `province_id` INT NOT NULL AUTO_INCREMENT,
    `country_id` INT NOT NULL DEFAULT 1,
    `province_name` VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (`province_id`),
    CONSTRAINT `fk_provinces_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `destinations` (
    `destination_id` INT NOT NULL AUTO_INCREMENT,
    `province_id` INT NOT NULL,
    `destination_name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    PRIMARY KEY (`destination_id`),
    CONSTRAINT `fk_destinations_province` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`province_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `host_applications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `application_note` VARCHAR(1000) NOT NULL DEFAULT '',
    `status` ENUM('DRAFT', 'PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'DRAFT',
    `submitted_at` TIMESTAMP NULL,
    `reviewed_by` INT NULL,
    `reviewed_at` TIMESTAMP NULL,
    `rejection_reason` VARCHAR(500) NULL,
    `applicant_name` VARCHAR(150) NULL,
    `applicant_email` VARCHAR(254) NULL,
    `applicant_phone` VARCHAR(30) NULL,
    `identification_type` ENUM('NATIONAL_ID', 'PASSPORT', 'OTHER') NULL,
    `identification_number` VARCHAR(100) NULL,
    `property_name` VARCHAR(150) NULL,
    `property_type` VARCHAR(50) NULL,
    `property_description` TEXT NULL,
    `property_address` VARCHAR(255) NULL,
    `property_city` VARCHAR(100) NULL,
    `property_district` VARCHAR(100) NULL,
    `property_ward` VARCHAR(100) NULL,
    `latitude` DECIMAL(10, 8) NULL,
    `longitude` DECIMAL(11, 8) NULL,
    `room_count` SMALLINT UNSIGNED NULL,
    `max_guests` SMALLINT UNSIGNED NULL,
    `identity_document_url` VARCHAR(1000) NULL,
    `ownership_document_url` VARCHAR(1000) NULL,
    `business_document_url` VARCHAR(1000) NULL,
    `supersedes_application_id` INT NULL,
    `document_status` ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    INDEX `ix_host_app_status` (`status`, `submitted_at`),
    CONSTRAINT `fk_host_app_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_host_app_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_host_app_supersedes` FOREIGN KEY (`supersedes_application_id`) REFERENCES `host_applications` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `host_profiles` (
    `profile_id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL UNIQUE,
    `id_card_number` VARCHAR(50) NOT NULL,
    `id_card_front_url` VARCHAR(500) NULL,
    `id_card_back_url` VARCHAR(500) NULL,
    `business_license_url` VARCHAR(500) NULL,
    `approval_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `rejection_reason` VARCHAR(500) NULL,
    `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `reviewed_at` DATETIME NULL,
    `reviewed_by` INT NULL,
    PRIMARY KEY (`profile_id`),
    CONSTRAINT `fk_hostprofiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_hostprofiles_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `partner_application_rooms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `application_id` INT NOT NULL,
    `room_name` VARCHAR(120) NOT NULL,
    `room_type` VARCHAR(50) NOT NULL,
    `price_per_night` DECIMAL(10, 2) NOT NULL,
    `max_guests` SMALLINT UNSIGNED NOT NULL,
    `bed_count` SMALLINT UNSIGNED NOT NULL,
    `bathroom_count` SMALLINT UNSIGNED NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT `fk_partner_rooms_app` FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `partner_application_room_amenities` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `amenity_name` VARCHAR(80) NOT NULL,
    UNIQUE KEY `uq_partner_room_amenity` (`room_id`, `amenity_name`),
    CONSTRAINT `fk_partner_amenities_room` FOREIGN KEY (`room_id`) REFERENCES `partner_application_rooms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `partner_application_room_images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `stored_name` VARCHAR(255) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL DEFAULT 'IMAGE',
    `content_type` VARCHAR(50) NOT NULL DEFAULT 'image/jpeg',
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT `fk_partner_images_room` FOREIGN KEY (`room_id`) REFERENCES `partner_application_rooms` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `partner_application_staged_media` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `application_id` INT NOT NULL,
    `client_room_key` VARCHAR(64) NOT NULL,
    `stored_name` VARCHAR(255) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL,
    `content_type` VARCHAR(50) NOT NULL DEFAULT 'image/jpeg',
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_partner_staged_app` FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 3: CƠ SỞ HOMESTAY, LOẠI PHÒNG, PHÒNG & TIỆN ÍCH (TỪ SCHEMA 2 & SCHEMA 1)
-- =============================================================================
CREATE TABLE `properties` (
    `property_id` INT NOT NULL AUTO_INCREMENT,
    `host_id` INT NOT NULL,
    `destination_id` INT NULL,
    `application_id` INT NULL UNIQUE,
    `property_name` VARCHAR(150) NOT NULL,
    `property_type` VARCHAR(50) NOT NULL DEFAULT 'Homestay',
    `description` TEXT NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `city` VARCHAR(100) NULL,
    `district` VARCHAR(100) NULL,
    `ward` VARCHAR(100) NULL,
    `latitude` DECIMAL(10, 8) NULL,
    `longitude` DECIMAL(11, 8) NULL,
    `room_count` SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    `max_guests` SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    `status` ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`property_id`),
    CONSTRAINT `fk_properties_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_properties_destination` FOREIGN KEY (`destination_id`) REFERENCES `destinations` (`destination_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_properties_app` FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `amenities` (
    `amenity_id` INT NOT NULL AUTO_INCREMENT,
    `amenity_name` VARCHAR(100) NOT NULL UNIQUE,
    `icon_class` VARCHAR(50) NULL,
    `category` VARCHAR(50) NULL,
    PRIMARY KEY (`amenity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `propertyamenities` (
    `property_id` INT NOT NULL,
    `amenity_id` INT NOT NULL,
    PRIMARY KEY (`property_id`, `amenity_id`),
    CONSTRAINT `fk_propamenities_prop` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_propamenities_amenity` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`amenity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `propertyimages` (
    `image_id` INT NOT NULL AUTO_INCREMENT,
    `property_id` INT NOT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `display_order` INT NOT NULL DEFAULT 0,
    `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`image_id`),
    CONSTRAINT `fk_propimages_prop` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `roomtypes` (
    `room_type_id` INT NOT NULL AUTO_INCREMENT,
    `property_id` INT NOT NULL,
    `room_name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `base_price` DECIMAL(12, 2) NOT NULL,
    `max_guests` INT NOT NULL DEFAULT 2,
    `size_m2` DOUBLE NOT NULL DEFAULT 25.0,
    `bed_type` VARCHAR(50) NOT NULL DEFAULT 'Giường Đôi King Size',
    `rating` DOUBLE NOT NULL DEFAULT 4.5,
    `review_count` INT NOT NULL DEFAULT 15,
    PRIMARY KEY (`room_type_id`),
    CONSTRAINT `fk_roomtypes_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `rooms` (
    `room_id` INT NOT NULL AUTO_INCREMENT,
    `property_id` INT NULL,
    `room_type_id` INT NOT NULL,
    `room_number` VARCHAR(50) NOT NULL UNIQUE,
    `room_name` VARCHAR(150) NULL,
    `price_per_night` DECIMAL(12, 2) NULL,
    `capacity` INT NULL,
    `bed_count` SMALLINT UNSIGNED NULL DEFAULT 1,
    `bathroom_count` SMALLINT UNSIGNED NULL DEFAULT 1,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `image_url` VARCHAR(500) NULL,
    `description` TEXT NULL,
    `status` ENUM('AVAILABLE', 'BOOKED', 'MAINTENANCE') NOT NULL DEFAULT 'AVAILABLE',
    `is_featured` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`room_id`),
    CONSTRAINT `fk_rooms_roomtype` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rooms_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `roomimages` (
    `image_id` INT NOT NULL AUTO_INCREMENT,
    `room_type_id` INT NOT NULL,
    `room_id` INT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL DEFAULT 'IMAGE',
    `content_type` VARCHAR(50) NOT NULL DEFAULT 'image/jpeg',
    `display_order` INT NOT NULL DEFAULT 0,
    `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`image_id`),
    CONSTRAINT `fk_roomimages_roomtype` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_roomimages_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `roomtypeamenities` (
    `room_type_id` INT NOT NULL,
    `amenity_id` INT NOT NULL,
    PRIMARY KEY (`room_type_id`, `amenity_id`),
    CONSTRAINT `fk_roomamenities_roomtype` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_roomamenities_amenity` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`amenity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Tiện ích phòng trực tiếp (room_amenities từ Schema 1 hỗ trợ PropertyDAO thao tác trực tiếp)
CREATE TABLE `room_amenities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `amenity_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_room_amenity` (`room_id`,`amenity_name`),
  KEY `idx_room_amenities_room` (`room_id`),
  CONSTRAINT `fk_room_amenities_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 4: ĐẶT PHÒNG, VOUCHER, WISHLIST & HÀNH VI (TỪ SCHEMA 2 & SCHEMA 1)
-- =============================================================================
CREATE TABLE `bookings` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `booking_code` VARCHAR(50) NULL UNIQUE,
    `user_id` INT NULL,
    `customer_name` VARCHAR(100) NULL,
    `customer_email` VARCHAR(150) NULL,
    `customer_phone` VARCHAR(30) NULL,
    `room_id` INT NOT NULL,
    `check_in_date` DATE NOT NULL,
    `check_out_date` DATE NOT NULL,
    `adults` INT NOT NULL DEFAULT 1,
    `children` INT NOT NULL DEFAULT 0,
    `guest_count` SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    `total_price` DECIMAL(12, 2) NOT NULL,
    `notes` TEXT NULL,
    `special_requests` VARCHAR(500) NULL,
    `status` ENUM('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_bookings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_bookings_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bookingrooms` (
    `booking_room_id` INT NOT NULL AUTO_INCREMENT,
    `booking_id` INT NOT NULL,
    `room_id` INT NOT NULL,
    `price_per_night` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `number_of_nights` INT NOT NULL DEFAULT 1,
    `subtotal` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`booking_room_id`),
    KEY `idx_bookingrooms_booking` (`booking_id`),
    KEY `idx_bookingrooms_room` (`room_id`),
    CONSTRAINT `fk_bookingrooms_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_bookingrooms_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `vouchers` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `host_id` INT NOT NULL,
    `code` VARCHAR(50) NOT NULL,
    `discount_type` ENUM('PERCENTAGE', 'FIXED_AMOUNT') NOT NULL,
    `discount_value` DECIMAL(12, 2) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `usage_limit` INT NOT NULL DEFAULT 100,
    `used_count` INT NOT NULL DEFAULT 0,
    `status` ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_vouchers_host_code` (`host_id`, `code`),
    CONSTRAINT `fk_vouchers_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `chk_vouchers_dates` CHECK (`end_date` >= `start_date`),
    CONSTRAINT `chk_vouchers_discount_value` CHECK (`discount_value` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `wishlists` (
    `wishlist_id` INT NOT NULL AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `room_id` INT NOT NULL,
    `property_id` INT NULL,
    `tour_id` INT NULL,
    `notes` VARCHAR(255) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`wishlist_id`),
    UNIQUE KEY `uk_wishlist_user_room` (`user_id`, `room_id`),
    CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_wishlist_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `userbehaviors` (
    `behavior_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` INT NULL,
    `action_type` VARCHAR(50) NOT NULL,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` BIGINT NOT NULL,
    `metadata` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`behavior_id`),
    CONSTRAINT `fk_userbehaviors_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 5: GỢI Ý PHÒNG THÔNG MINH AI (RECOMMENDATIONS - TỪ SCHEMA CỦA BẠN)
-- =============================================================================
CREATE TABLE `recommendations` (
    `recommendation_id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` INT DEFAULT NULL,
    `room_id` INT DEFAULT NULL,
    `property_id` INT DEFAULT NULL,
    `room_type_id` INT DEFAULT NULL,
    `tour_id` BIGINT DEFAULT NULL,
    `recommendation_type` VARCHAR(30) NOT NULL,
    `score` DECIMAL(10, 4) NOT NULL DEFAULT 0.8500,
    `reason` VARCHAR(500) DEFAULT NULL,
    `is_displayed` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`recommendation_id`),
    KEY `fk_recommendations_users` (`user_id`),
    KEY `fk_recommendations_rooms` (`room_id`),
    KEY `ix_recommendations_userscore` (`user_id`, `score` DESC),
    CONSTRAINT `fk_recommendations_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_recommendations_rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 6: ĐÁNH GIÁ, THÔNG BÁO, HỖ TRỢ, ĐIỀU KHOẢN & FAQS (TỪ SCHEMA 1 & SCHEMA 2)
-- =============================================================================
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `room_id` int NOT NULL,
  `property_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('APPROVED','PENDING','HIDDEN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'APPROVED',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  KEY `idx_reviews_room` (`room_id`,`status`),
  KEY `idx_reviews_user` (`user_id`),
  CONSTRAINT `fk_reviews_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`room_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `review_replies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `review_id` int NOT NULL,
  `host_id` int NOT NULL,
  `reply_content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `review_id` (`review_id`),
  KEY `idx_replies_host` (`host_id`),
  CONSTRAINT `fk_replies_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_replies_review` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('BOOKING','PROMOTION','REVIEW','SYSTEM') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM',
  `target_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_user` (`user_id`,`created_at` DESC),
  KEY `idx_notifications_unread` (`user_id`,`is_read`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `contactmessages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `ticket_code` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'GENERAL_FEEDBACK',
  `booking_id` int DEFAULT NULL,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UNREAD',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  UNIQUE KEY `uk_contact_ticket_code` (`ticket_code`),
  KEY `idx_contact_user` (`user_id`),
  KEY `idx_contact_status` (`status`),
  KEY `fk_contact_booking` (`booking_id`),
  CONSTRAINT `fk_contact_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_contact_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `support_replies` (
  `reply_id` int NOT NULL AUTO_INCREMENT,
  `ticket_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reply_id`),
  KEY `idx_replies_ticket` (`ticket_id`),
  KEY `idx_replies_sender` (`sender_id`),
  CONSTRAINT `fk_replies_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_replies_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `contactmessages` (`message_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `terms` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Điều Khoản Dịch Vụ & Quy Định Lưu Trú',
  `meta_description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `term_sections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_order` int NOT NULL,
  `sidebar_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_text` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_json` mediumtext COLLATE utf8mb4_unicode_ci,
  `callout_text` mediumtext COLLATE utf8mb4_unicode_ci,
  `callout_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'info',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `terms_setting` (
  `id` int NOT NULL AUTO_INCREMENT,
  `main_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `last_updated` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `faqs` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `question` VARCHAR(500) NOT NULL,
    `answer` LONGTEXT NOT NULL,
    `category` VARCHAR(100) NULL,
    `order_index` INT DEFAULT 0,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `static_pages` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `meta_description` VARCHAR(500) NULL,
    `content` LONGTEXT NOT NULL,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 7: TÀI CHÍNH, VÍ TIỀN & CỔNG THANH TOÁN (FINANCE ENGINE - TỪ SCHEMA 3)
-- =============================================================================
CREATE TABLE wallet_accounts (
 wallet_account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 owner_type VARCHAR(20) NOT NULL,
 owner_key VARCHAR(100) NOT NULL,
 owner_user_id INT NULL,
 account_type VARCHAR(40) NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_wallet_account(owner_type,owner_key,account_type,currency),
 FOREIGN KEY(owner_user_id) REFERENCES users(user_id),
 CHECK(owner_type IN ('HOST','PLATFORM')),
 CHECK(status IN ('ACTIVE','FROZEN','CLOSED')),
 CHECK(currency = UPPER(currency)),
 CHECK((owner_type='HOST' AND owner_user_id IS NOT NULL) OR (owner_type='PLATFORM' AND owner_user_id IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_entries (
 ledger_entry_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 entry_type VARCHAR(40) NOT NULL,
 reference_type VARCHAR(40) NOT NULL,
 reference_id BIGINT NOT NULL,
 idempotency_key VARCHAR(191) NOT NULL UNIQUE,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
 reversal_of_entry_id BIGINT NULL UNIQUE,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(reversal_of_entry_id) REFERENCES ledger_entries(ledger_entry_id),
 CHECK(status IN ('DRAFT','POSTED','REVERSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ledger_lines (
 ledger_line_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 ledger_entry_id BIGINT NOT NULL,
 wallet_account_id BIGINT NOT NULL,
 direction VARCHAR(6) NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 FOREIGN KEY(ledger_entry_id) REFERENCES ledger_entries(ledger_entry_id),
 FOREIGN KEY(wallet_account_id) REFERENCES wallet_accounts(wallet_account_id),
 CHECK(direction IN ('DEBIT','CREDIT')),
 CHECK(amount > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payment_configs (
 payment_config_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 config_type VARCHAR(40) NOT NULL,
 calculation_type VARCHAR(20) NOT NULL,
 config_value DECIMAL(18,6) NOT NULL,
 currency CHAR(3) NULL,
 country_code CHAR(2) NULL,
 listing_type VARCHAR(50) NULL,
 property_id INT NULL,
 effective_from DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 effective_to DATETIME NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(property_id) REFERENCES properties(property_id),
 CHECK(calculation_type IN ('PERCENTAGE','FIXED')),
 CHECK(config_value >= 0),
 CHECK(status IN ('ACTIVE','INACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payment_fee_snapshots (
 payment_fee_snapshot_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 payment_id BIGINT NOT NULL,
 payment_config_id BIGINT NULL,
 fee_type VARCHAR(40) NOT NULL,
 calculation_type VARCHAR(20) NOT NULL,
 applied_value DECIMAL(18,6) NOT NULL,
 base_amount DECIMAL(18,2) NOT NULL,
 fee_amount DECIMAL(18,2) NOT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(payment_config_id) REFERENCES payment_configs(payment_config_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payment_attempts (
 payment_attempt_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 payment_id BIGINT NOT NULL,
 gateway VARCHAR(40) NOT NULL,
 idempotency_key VARCHAR(191) NOT NULL,
 gateway_request_id VARCHAR(191) NULL,
 gateway_transaction_id VARCHAR(191) NULL,
 expected_amount DECIMAL(18,2) NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 status VARCHAR(30) NOT NULL DEFAULT 'INITIATED',
 error_code VARCHAR(80) NULL,
 error_message VARCHAR(500) NULL,
 initiated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 completed_at DATETIME NULL,
 UNIQUE KEY uq_attempt_idempotency(gateway,idempotency_key),
 CHECK(expected_amount > 0),
 CHECK(status IN ('INITIATED','PENDING_USER','PROCESSING','SUCCESS','FAILED','TIMEOUT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payment_events (
 payment_event_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 payment_id BIGINT NULL,
 gateway VARCHAR(40) NOT NULL,
 gateway_event_id VARCHAR(191) NOT NULL,
 event_type VARCHAR(80) NOT NULL,
 verification_status VARCHAR(20) NOT NULL DEFAULT 'RECEIVED',
 processing_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
 payload_sha256 CHAR(64) NOT NULL,
 raw_payload JSON NOT NULL,
 signature_header VARCHAR(500) NULL,
 processed_at DATETIME NULL,
 error_details VARCHAR(500) NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_gateway_event(gateway,gateway_event_id),
 CHECK(verification_status IN ('RECEIVED','VERIFIED','FAILED','SKIPPED')),
 CHECK(processing_status IN ('PENDING','PROCESSED','IGNORED','FAILED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payment_allocations (
 allocation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 payment_id BIGINT NOT NULL UNIQUE,
 booking_id INT NOT NULL,
 property_id INT NOT NULL,
 beneficiary_user_id INT NULL,
 gross_amount DECIMAL(18,2) NOT NULL,
 host_net_amount DECIMAL(18,2) NOT NULL,
 platform_fee_amount DECIMAL(18,2) NOT NULL,
 tax_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
 allocated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 settled_at DATETIME NULL,
 FOREIGN KEY(booking_id) REFERENCES bookings(id),
 FOREIGN KEY(property_id) REFERENCES properties(property_id),
 FOREIGN KEY(beneficiary_user_id) REFERENCES users(user_id),
 CHECK(gross_amount = host_net_amount + platform_fee_amount + tax_amount),
 CHECK(gross_amount > 0),
 CHECK(status IN ('PENDING','ALLOCATED','SETTLED','REVERSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payouts (
 payout_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 host_user_id INT NOT NULL,
 wallet_account_id BIGINT NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
 idempotency_key VARCHAR(191) NOT NULL UNIQUE,
 destination_token VARCHAR(255) NOT NULL,
 batch_id VARCHAR(100) NULL,
 gateway VARCHAR(40) NULL,
 gateway_payout_id VARCHAR(191) NULL,
 failure_code VARCHAR(80) NULL,
 failure_reason VARCHAR(500) NULL,
 requested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 processed_at DATETIME NULL,
 completed_at DATETIME NULL,
 FOREIGN KEY(host_user_id) REFERENCES users(user_id),
 FOREIGN KEY(wallet_account_id) REFERENCES wallet_accounts(wallet_account_id),
 CHECK(amount > 0),
 CHECK(status IN ('REQUESTED','APPROVED','IN_BATCH','PROCESSING','PAID','FAILED','CANCELLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE refunds (
 refund_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 payment_id BIGINT NOT NULL,
 booking_id INT NULL,
 amount DECIMAL(18,2) NOT NULL,
 currency CHAR(3) NOT NULL DEFAULT 'VND',
 reason VARCHAR(500) NOT NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
 idempotency_key VARCHAR(191) NOT NULL UNIQUE,
 gateway_refund_id VARCHAR(191) NULL,
 failure_reason VARCHAR(500) NULL,
 ledger_entry_id BIGINT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 processed_at DATETIME NULL,
 FOREIGN KEY(booking_id) REFERENCES bookings(id),
 FOREIGN KEY(ledger_entry_id) REFERENCES ledger_entries(ledger_entry_id),
 CHECK(amount > 0),
 CHECK(status IN ('REQUESTED','PROCESSING','COMPLETED','FAILED','REJECTED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tax_records (
 tax_record_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 payment_id BIGINT NOT NULL,
 booking_id INT NULL,
 payment_config_id BIGINT NULL,
 tax_type VARCHAR(50) NOT NULL,
 jurisdiction VARCHAR(150) NOT NULL,
 taxable_amount DECIMAL(18,2) NOT NULL,
 tax_rate DECIMAL(18,6) NOT NULL,
 tax_amount DECIMAL(18,2) NOT NULL,
 status VARCHAR(20) NOT NULL DEFAULT 'ACCRUED',
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(booking_id) REFERENCES bookings(id),
 FOREIGN KEY(payment_config_id) REFERENCES payment_configs(payment_config_id),
 CHECK(taxable_amount >= 0),
 CHECK(tax_amount >= 0),
 CHECK(status IN ('ACCRUED','REMITTED','EXEMPT','REVERSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE finance_audit_logs (
 finance_audit_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 actor_user_id INT NULL,
 action VARCHAR(100) NOT NULL,
 entity_type VARCHAR(50) NOT NULL,
 entity_id BIGINT NOT NULL,
 request_id VARCHAR(191) NULL,
 details_json JSON NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(actor_user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- PHẦN 8: VIEWS TƯƠNG THÍCH NGƯỢC (COMPATIBILITY VIEWS)
-- =============================================================================
CREATE OR REPLACE VIEW `room_types` AS 
SELECT 
    `room_type_id` AS `id`,
    `room_name` AS `type_name`,
    `description`
FROM `roomtypes`;

CREATE OR REPLACE VIEW `room_images` AS
SELECT 
    `image_id` AS `id`,
    COALESCE(`room_id`, `room_type_id`) AS `room_id`,
    `image_url` AS `stored_name`,
    `media_type`,
    `content_type`,
    `display_order` AS `sort_order`
FROM `roomimages`;

-- =============================================================================
-- PHẦN 9: DỮ LIỆU MẪU (SEED DATA ĐỒNG BỘ 100%)
-- =============================================================================

-- 9.1 Roles & Geography
INSERT INTO `roles` (`role_id`, `role_name`, `description`) VALUES
    (1, 'ROLE_ADMIN', 'Quản trị viên toàn hệ thống Sogo Homestay'),
    (2, 'ROLE_CUSTOMER', 'Khách hàng đặt phòng lưu trú'),
    (3, 'ROLE_HOST', 'Chủ nhà homestay / Đối tác kinh doanh');
INSERT INTO `countries` (`country_id`, `country_name`) VALUES (1, 'Việt Nam');
INSERT INTO `provinces` (`province_id`, `province_name`) VALUES
    (1, 'Đà Nẵng'),
    (2, 'Hà Nội'),
    (3, 'Đà Lạt'),
    (4, 'TP. Hồ Chí Minh'),
    (5, 'Nha Trang'),
    (6, 'Phú Quốc');
INSERT INTO `destinations` (`destination_id`, `province_id`, `destination_name`, `description`) VALUES
    (1, 1, 'Biển Mỹ Khê & Bán Đảo Sơn Trà', 'Khu vực bãi biển quyến rũ bậc nhất hành tinh'),
    (2, 2, 'Phố Cổ Hà Nội & Hồ Hoàn Kiếm', 'Trung tâm văn hóa ngàn năm văn hiến'),
    (3, 3, 'Hồ Xuân Hương & Rừng Thông Đà Lạt', 'Xứ sở ngàn hoa sương mù lãng mạn'),
    (4, 4, 'Trung Tâm Quận 1 & Bến Bạch Đằng', 'Đô thị sầm uất hoa lệ'),
    (5, 5, 'Vịnh Biển Nha Trang', 'Thành phố biển sôi động cát trắng'),
    (6, 6, 'Bãi Sao & Hoàng Hôn Sunset Sanato', 'Đảo ngọc thiên đường nhiệt đới');
INSERT INTO `amenities` (`amenity_id`, `amenity_name`, `icon_class`, `category`) VALUES
    (1, 'Wi-Fi Tốc Độ Cao', 'fa-wifi', 'Tiện ích chung'),
    (2, 'Điều Hòa Nhiệt Độ', 'fa-snowflake-o', 'Phòng ngủ'),
    (3, 'Máy Nước Nóng Lạnh', 'fa-bath', 'Phòng tắm'),
    (4, 'Bếp & Dụng Cụ Nấu Ăn', 'fa-cutlery', 'Bếp'),
    (5, 'Smart TV & Netflix', 'fa-television', 'Giải trí'),
    (6, 'Ban Công Ngắm Cảnh', 'fa-sun-o', 'Không gian'),
    (7, 'Hồ Bơi Vô Cực', 'fa-tint', 'Tiện ích chung'),
    (8, 'Chỗ Để Xe Miễn Phí', 'fa-car', 'Tiện ích chung');

-- 9.2 Users & Authentication (Password BCrypt chuẩn 123456)
INSERT INTO `users` (`user_id`, `role_id`, `username`, `display_name`, `full_name`, `email`, `password_hash`, `password`, `phone`, `avatar_url`, `status`, `address`) VALUES
    (1, 1, 'admin', 'Administrator', 'System Administrator', 'admin@homestay.com', '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC', 'admin123', '0901234567', 'images/person_1.jpg', 'ACTIVE', 'Trung tâm Điều hành Sogo, Đà Nẵng'),
    (2, 2, 'khanhmg', 'Khanh MG', 'Khanh MG', 'khanhmg2k3@gmail.com', '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC', 'admin123', '0987654321', 'images/person_2.jpg', 'ACTIVE', 'Liên Chiểu, Đà Nẵng'),
    (3, 3, 'hostdemo', 'Host Văn Demo', 'Nguyễn Văn Host Demo', 'hostdemo@gmail.com', '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC', 'admin123', '0912345678', 'images/person_3.jpg', 'ACTIVE', 'Sơn Trà, Đà Nẵng'),
    (4, 2, 'annguyen', 'An Nguyễn', 'Nguyễn Văn An', 'an.nguyen@gmail.com', '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC', 'admin123', '0933112233', 'images/person_4.jpg', 'ACTIVE', 'Quận 1, TP. Hồ Chí Minh');
INSERT INTO `userroles` (`user_id`, `role_id`) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 2);
INSERT INTO `host_profiles` (`profile_id`, `user_id`, `id_card_number`, `approval_status`, `applied_at`, `reviewed_at`, `reviewed_by`) VALUES
    (1, 3, '048098001234', 'APPROVED', '2026-09-01 08:00:00', '2026-09-02 10:00:00', 1);
INSERT INTO `host_applications` (`id`, `user_id`, `application_note`, `status`, `submitted_at`, `reviewed_by`, `reviewed_at`, `applicant_name`, `applicant_email`, `applicant_phone`, `property_name`, `property_type`, `property_city`, `room_count`, `max_guests`, `document_status`) VALUES
    (1, 3, 'Đăng ký chuỗi Homestay Sogo Riverside Đà Nẵng', 'APPROVED', '2026-09-01 08:00:00', 1, '2026-09-02 10:00:00', 'Nguyễn Văn Host Demo', 'hostdemo@gmail.com', '0912345678', 'Sogo Riverside Homestay', 'Villa', 'Đà Nẵng', 3, 10, 'VERIFIED');

-- 9.3 Homestay Properties, Room Types, Rooms & Images
INSERT INTO `properties` (`property_id`, `host_id`, `destination_id`, `application_id`, `property_name`, `property_type`, `description`, `address`, `city`, `district`, `ward`, `room_count`, `max_guests`, `status`) VALUES
    (1, 3, 1, 1, 'Sogo Riverside Homestay Đà Nẵng', 'Villa', 'Khu nghỉ dưỡng ven sông Hàn thơ mộng với tầm nhìn ngắm pháo hoa và cầu Rồng.', '123 Đường Bạch Đằng, Quận Hải Châu', 'Đà Nẵng', 'Hải Châu', 'Hải Châu 1', 3, 12, 'ACTIVE'),
    (2, 3, 2, NULL, 'Sogo Old Quarter Retreat Hà Nội', 'Nhà Cổ Phố Cổ', 'Homestay mang đậm phong cách kiến trúc Pháp cổ kính giữa lòng Hà Nội 36 phố phường.', '45 Hàng Gai, Quận Hoàn Kiếm', 'Hà Nội', 'Hoàn Kiếm', 'Hàng Gai', 3, 8, 'ACTIVE'),
    (3, 3, 3, NULL, 'Sogo Pine Hill Wooden Villa Đà Lạt', 'Bungalow Gỗ', 'Biệt thự gỗ mộc mạc nép mình bên sườn đồi thông lộng gió, săn mây mỗi sớm mai.', '88 Khe Sanh, Phường 10', 'Đà Lạt', 'Đà Lạt', 'Phường 10', 3, 10, 'ACTIVE'),
    (4, 3, 4, NULL, 'Sogo Saigon Riverfront Oasis', 'Căn Hộ Cao Cấp', 'Căn hộ homestay hiện đại với ban công rộng nhìn bao trọn sông Sài Gòn và Landmark 81.', '208 Nguyễn Hữu Cảnh, Quận Bình Thạnh', 'TP. Hồ Chí Minh', 'Bình Thạnh', 'Phường 22', 3, 8, 'ACTIVE'),
    (5, 3, 5, NULL, 'Sogo Blue Ocean Beachfront Nha Trang', 'Biệt Thự Biển', 'Bước chân vài bước ra bãi cát vàng biển Nha Trang, hồ bơi vô cực ngắm bình minh.', '02 Trần Phú, Phường Lộc Thọ', 'Nha Trang', 'Nha Trang', 'Lộc Thọ', 3, 10, 'ACTIVE'),
    (6, 3, 6, NULL, 'Sogo Sunset Pearl Bungalow Phú Quốc', 'Resort Bungalow', 'Khu nghỉ dưỡng bungalow mái lá nhiệt đới, nơi ngắm hoàng hôn đỏ rực đẹp nhất đảo ngọc.', 'Bãi Trường, Xã Dương Tơ', 'Phú Quốc', 'Phú Quốc', 'Dương Tơ', 3, 12, 'ACTIVE');
INSERT INTO `roomtypes` (`room_type_id`, `property_id`, `room_name`, `description`, `base_price`, `max_guests`, `size_m2`, `bed_type`, `rating`, `review_count`) VALUES
    -- Đà Nẵng (Property 1)
    (1, 1, 'Cozy Studio View Sông Hàn 101', 'Phòng studio ấm cúng cửa sổ lớn nhìn thẳng ra sông Hàn.', 450000.00, 2, 28.0, '1 Giường King', 4.8, 38),
    (2, 1, 'Family Sweet Suite Cầu Rồng 201', 'Phòng gia đình tầng 2 rộng rãi, ban công ngắm cầu Rồng phun lửa.', 1150000.00, 4, 50.0, '2 Giường đôi lớn', 4.5, 36),
    (3, 1, 'Penthouse Rooftop Panorama 301', 'Phòng cao cấp tầng thượng ngắm trọn toàn cảnh thành phố Đà Nẵng về đêm.', 2400000.00, 4, 75.0, '2 Giường King Size', 5.0, 52),

    -- Hà Nội (Property 2)
    (4, 2, 'Classic Old Quarter Deluxe 101', 'Phòng phong cách Indochine hoài niệm giữa lòng phố cổ Hoàn Kiếm.', 550000.00, 2, 30.0, '1 Giường đôi Queen', 4.2, 24),
    (5, 2, 'Heritage Balcony Suite 201', 'Phòng ban công thoáng đãng nhìn xuống nhịp sống phố cổ rộn ràng.', 1250000.00, 3, 45.0, '1 Giường King + 1 Đơn', 4.6, 41),
    (6, 2, 'Phố Cổ Grand Family Loft 301', 'Căn gác mái cao cấp đầy đủ tiện nghi cho cả gia đình hoặc nhóm bạn thân.', 2100000.00, 6, 65.0, '3 Giường đôi lớn', 4.9, 29),

    -- Đà Lạt (Property 3)
    (7, 3, 'Rustic Wooden Bungalow 101', 'Căn nhà gỗ thơm hương thông, sưởi ấm bằng lò sưởi cổ điển.', 600000.00, 2, 32.0, '1 Giường King', 4.7, 45),
    (8, 3, 'Pine Valley View Suite 201', 'Cửa kính Panorama đón sương mây bồng bềnh mỗi sớm mai Đà Lạt.', 1350000.00, 4, 52.0, '2 Giường đôi King', 4.4, 33),
    (9, 3, 'Villa Cloud Hunter Attic 301', 'Phòng áp mái lãng mạn, view thung lũng thông reo tuyệt mỹ.', 1850000.00, 3, 48.0, '1 Giường tròn King', 4.8, 48),

    -- TP. Hồ Chí Minh (Property 4)
    (10, 4, 'Modern Urban Studio 101', 'Căn hộ studio hiện đại tiện nghi, đầy đủ máy giặt, bếp từ.', 650000.00, 2, 35.0, '1 Giường King', 4.1, 19),
    (11, 4, 'Riverfront Executive Suite 201', 'Phòng cao cấp hướng sông Sài Gòn lộng gió, ngắm trọn Landmark 81 rực rỡ.', 1450000.00, 3, 55.0, '1 Giường đôi King', 4.6, 27),
    (12, 4, 'Landmark View Grand Suite 301', 'Căn suite thượng lưu ngắm hoàng hôn và pháo hoa rực rỡ bên sông.', 2650000.00, 4, 70.0, '2 Giường King Size', 5.0, 35),

    -- Nha Trang (Property 5)
    (13, 5, 'Ocean Breeze Standard 101', 'Phòng hướng vườn nhiệt đới xanh mát, đón gió biển trong lành.', 480000.00, 2, 30.0, '1 Giường đôi Queen', 3.8, 16),
    (14, 5, 'Sunrise Beachfront Suite 201', 'Mở cửa bước ra ngắm trọn bình minh vịnh biển Nha Trang thơ mộng.', 1200000.00, 3, 48.0, '1 Giường King + Ban công', 4.5, 38),
    (15, 5, 'VIP Coral Sea View Villa 301', 'Villa sát biển hạng sang, hồ bơi riêng tư đẳng cấp nghỉ dưỡng 5 sao.', 2800000.00, 5, 85.0, '2 Giường King Size', 4.9, 42),

    -- Phú Quốc (Property 6)
    (16, 6, 'Tropical Garden Bungalow 101', 'Bungalow ẩn mình giữa vườn dừa mát rượi, không gian yên bình tuyệt đối.', 520000.00, 2, 34.0, '1 Giường đôi lớn', 4.0, 22),
    (17, 6, 'Sunset Paradise Suite 201', 'Phòng hướng biển ngắm hoàng hôn trứ danh tuyệt đẹp đảo ngọc Phú Quốc.', 1500000.00, 4, 55.0, '2 Giường đôi King', 4.7, 39),
    (18, 6, 'Royal Oceanfront Pavilion 301', 'Biệt thự hướng biển cao cấp có bồn tắm sục Jacuzzi ngoài trời sang chảnh.', 3200000.00, 6, 95.0, '3 Giường King Size', 5.0, 56);
INSERT INTO `rooms` (`room_id`, `property_id`, `room_type_id`, `room_number`, `room_name`, `price_per_night`, `capacity`, `image_url`, `status`, `is_featured`) VALUES
    (1, 1, 1, 'HOMESTAY-DN101', 'Cozy Studio View Sông Hàn 101', 450000.00, 2, 'images/img_1.jpg', 'AVAILABLE', TRUE),
    (2, 1, 2, 'HOMESTAY-DN201', 'Family Sweet Suite Cầu Rồng 201', 1150000.00, 4, 'images/img_2.jpg', 'AVAILABLE', TRUE),
    (3, 1, 3, 'HOMESTAY-DN301', 'Penthouse Rooftop Panorama 301', 2400000.00, 4, 'images/img_3.jpg', 'AVAILABLE', TRUE),
    (4, 2, 4, 'HOMESTAY-HN101', 'Classic Old Quarter Deluxe 101', 550000.00, 2, 'images/img_4.jpg', 'AVAILABLE', TRUE),
    (5, 2, 5, 'HOMESTAY-HN201', 'Heritage Balcony Suite 201', 1250000.00, 3, 'images/img_5.jpg', 'AVAILABLE', TRUE),
    (6, 2, 6, 'HOMESTAY-HN301', 'Phố Cổ Grand Family Loft 301', 2100000.00, 6, 'images/slider-1.jpg', 'AVAILABLE', TRUE),
    (7, 3, 7, 'HOMESTAY-DL101', 'Rustic Wooden Bungalow 101', 600000.00, 2, 'images/slider-2.jpg', 'AVAILABLE', TRUE),
    (8, 3, 8, 'HOMESTAY-DL201', 'Pine Valley View Suite 201', 1350000.00, 4, 'images/slider-3.jpg', 'AVAILABLE', TRUE),
    (9, 3, 9, 'HOMESTAY-DL301', 'Villa Cloud Hunter Attic 301', 1850000.00, 3, 'images/slider-4.jpg', 'AVAILABLE', TRUE),
    (10, 4, 10, 'HOMESTAY-SG101', 'Modern Urban Studio 101', 650000.00, 2, 'images/slider-5.jpg', 'AVAILABLE', TRUE),
    (11, 4, 11, 'HOMESTAY-SG201', 'Riverfront Executive Suite 201', 1450000.00, 3, 'images/slider-6.jpg', 'AVAILABLE', TRUE),
    (12, 4, 12, 'HOMESTAY-SG301', 'Landmark View Grand Suite 301', 2650000.00, 4, 'images/slider-7.jpg', 'AVAILABLE', TRUE),
    (13, 5, 13, 'HOMESTAY-NT101', 'Ocean Breeze Standard 101', 480000.00, 2, 'images/img_1.jpg', 'AVAILABLE', TRUE),
    (14, 5, 14, 'HOMESTAY-NT201', 'Sunrise Beachfront Suite 201', 1200000.00, 3, 'images/img_2.jpg', 'AVAILABLE', TRUE),
    (15, 5, 15, 'HOMESTAY-NT301', 'VIP Coral Sea View Villa 301', 2800000.00, 5, 'images/img_3.jpg', 'AVAILABLE', TRUE),
    (16, 6, 16, 'HOMESTAY-PQ101', 'Tropical Garden Bungalow 101', 520000.00, 2, 'images/img_4.jpg', 'AVAILABLE', TRUE),
    (17, 6, 17, 'HOMESTAY-PQ201', 'Sunset Paradise Suite 201', 1500000.00, 4, 'images/img_5.jpg', 'AVAILABLE', TRUE),
    (18, 6, 18, 'HOMESTAY-PQ301', 'Royal Oceanfront Pavilion 301', 3200000.00, 6, 'images/slider-1.jpg', 'AVAILABLE', TRUE);
INSERT INTO `roomimages` (`room_type_id`, `room_id`, `image_url`, `display_order`, `is_primary`) VALUES
    (1, 1, 'images/img_1.jpg', 1, 1),
    (2, 2, 'images/img_2.jpg', 1, 1),
    (3, 3, 'images/img_3.jpg', 1, 1),
    (4, 4, 'images/img_4.jpg', 1, 1),
    (5, 5, 'images/img_5.jpg', 1, 1),
    (6, 6, 'images/slider-1.jpg', 1, 1),
    (7, 7, 'images/slider-2.jpg', 1, 1),
    (8, 8, 'images/slider-3.jpg', 1, 1),
    (9, 9, 'images/slider-4.jpg', 1, 1),
    (10, 10, 'images/slider-5.jpg', 1, 1),
    (11, 11, 'images/slider-6.jpg', 1, 1),
    (12, 12, 'images/slider-7.jpg', 1, 1),
    (13, 13, 'images/img_1.jpg', 1, 1),
    (14, 14, 'images/img_2.jpg', 1, 1),
    (15, 15, 'images/img_3.jpg', 1, 1),
    (16, 16, 'images/img_4.jpg', 1, 1),
    (17, 17, 'images/img_5.jpg', 1, 1),
    (18, 18, 'images/slider-1.jpg', 1, 1);

-- 9.4 Room Amenities (Tiện ích từng phòng từ Schema 1)
INSERT INTO `room_amenities` VALUES (4,1,'Ban Công Ngắm Cảnh'),(2,1,'Điều Hòa Nhiệt Độ'),(3,1,'Máy Nước Nóng Lạnh'),(1,1,'Wi-Fi Tốc Độ Cao'),(9,2,'Ban Công Ngắm Cảnh'),(6,2,'Điều Hòa Nhiệt Độ'),(7,2,'Máy Nước Nóng Lạnh'),(8,2,'Smart TV & Netflix'),(5,2,'Wi-Fi Tốc Độ Cao'),(15,3,'Ban Công Ngắm Cảnh'),(14,3,'Bếp & Dụng Cụ Nấu Ăn'),(11,3,'Điều Hòa Nhiệt Độ'),(16,3,'Hồ Bơi Vô Cực'),(12,3,'Máy Nước Nóng Lạnh'),(13,3,'Smart TV & Netflix'),(10,3,'Wi-Fi Tốc Độ Cao'),(18,4,'Điều Hòa Nhiệt Độ'),(19,4,'Máy Nước Nóng Lạnh'),(17,4,'Wi-Fi Tốc Độ Cao'),(24,5,'Ban Công Ngắm Cảnh'),(21,5,'Điều Hòa Nhiệt Độ'),(22,5,'Máy Nước Nóng Lạnh'),(23,5,'Smart TV & Netflix'),(20,5,'Wi-Fi Tốc Độ Cao'),(29,6,'Bếp & Dụng Cụ Nấu Ăn'),(26,6,'Điều Hòa Nhiệt Độ'),(27,6,'Máy Nước Nóng Lạnh'),(28,6,'Smart TV & Netflix'),(25,6,'Wi-Fi Tốc Độ Cao'),(33,7,'Ban Công Ngắm Cảnh'),(31,7,'Điều Hòa Nhiệt Độ'),(32,7,'Máy Nước Nóng Lạnh'),(30,7,'Wi-Fi Tốc Độ Cao'),(38,8,'Ban Công Ngắm Cảnh'),(35,8,'Điều Hòa Nhiệt Độ'),(36,8,'Máy Nước Nóng Lạnh'),(37,8,'Smart TV & Netflix'),(34,8,'Wi-Fi Tốc Độ Cao'),(43,9,'Bếp & Dụng Cụ Nấu Ăn'),(40,9,'Điều Hòa Nhiệt Độ'),(41,9,'Máy Nước Nóng Lạnh'),(42,9,'Smart TV & Netflix'),(39,9,'Wi-Fi Tốc Độ Cao'),(47,10,'Bếp & Dụng Cụ Nấu Ăn'),(45,10,'Điều Hòa Nhiệt Độ'),(46,10,'Máy Nước Nóng Lạnh'),(44,10,'Wi-Fi Tốc Độ Cao'),(52,11,'Ban Công Ngắm Cảnh'),(49,11,'Điều Hòa Nhiệt Độ'),(50,11,'Máy Nước Nóng Lạnh'),(51,11,'Smart TV & Netflix'),(48,11,'Wi-Fi Tốc Độ Cao'),(57,12,'Bếp & Dụng Cụ Nấu Ăn'),(54,12,'Điều Hòa Nhiệt Độ'),(58,12,'Hồ Bơi Vô Cực'),(55,12,'Máy Nước Nóng Lạnh'),(56,12,'Smart TV & Netflix'),(53,12,'Wi-Fi Tốc Độ Cao'),(60,13,'Điều Hòa Nhiệt Độ'),(61,13,'Máy Nước Nóng Lạnh'),(59,13,'Wi-Fi Tốc Độ Cao'),(66,14,'Ban Công Ngắm Cảnh'),(63,14,'Điều Hòa Nhiệt Độ'),(64,14,'Máy Nước Nóng Lạnh'),(65,14,'Smart TV & Netflix'),(62,14,'Wi-Fi Tốc Độ Cao'),(71,15,'Bếp & Dụng Cụ Nấu Ăn'),(68,15,'Điều Hòa Nhiệt Độ'),(72,15,'Hồ Bơi Vô Cực'),(69,15,'Máy Nước Nóng Lạnh'),(70,15,'Smart TV & Netflix'),(67,15,'Wi-Fi Tốc Độ Cao'),(74,16,'Điều Hòa Nhiệt Độ'),(75,16,'Máy Nước Nóng Lạnh'),(73,16,'Wi-Fi Tốc Độ Cao'),(80,17,'Ban Công Ngắm Cảnh'),(77,17,'Điều Hòa Nhiệt Độ'),(78,17,'Máy Nước Nóng Lạnh'),(79,17,'Smart TV & Netflix'),(76,17,'Wi-Fi Tốc Độ Cao'),(85,18,'Bếp & Dụng Cụ Nấu Ăn'),(82,18,'Điều Hòa Nhiệt Độ'),(86,18,'Hồ Bơi Vô Cực'),(83,18,'Máy Nước Nóng Lạnh'),(84,18,'Smart TV & Netflix'),(81,18,'Wi-Fi Tốc Độ Cao');

-- 9.5 Bookings (30 đơn đặt phòng đầy đủ từ Schema 1 để phục vụ cả lịch phòng và reviews)
INSERT INTO `bookings` VALUES (1,'BK-SOGO-1001',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',2,'2026-10-15','2026-10-18',2,1,3,3450000.00,'Khách đến nhận phòng lúc 14:00, yêu cầu chuẩn bị thêm 1 nệm phụ.',NULL,'CONFIRMED','2026-10-13 10:23:02'),(2,'BK-SOGO-1002',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',5,'2026-10-20','2026-10-22',2,0,2,2500000.00,'Check-in muộn lúc 19:00.',NULL,'PENDING','2026-10-13 10:23:02'),(101,'BK-TEST-101',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',1,'2026-10-10','2026-10-13',2,0,2,1350000.00,'Khách hoàn tất kỳ nghỉ phòng Cozy Studio 101. Chưa viết đánh giá.',NULL,'COMPLETED','2026-10-26 02:38:18'),(102,'BK-TEST-102',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',3,'2026-10-14','2026-10-17',2,1,3,4800000.00,'Khách đã trả phòng Penthouse Rooftop. Đã đánh giá 4 sao.',NULL,'COMPLETED','2026-10-26 02:38:18'),(103,'BK-TEST-103',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',4,'2026-10-12','2026-10-15',2,0,2,1650000.00,'Khách An Nguyễn hoàn thành lưu trú.',NULL,'COMPLETED','2026-10-26 09:38:18'),(104,'BK-TEST-104',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',5,'2026-10-01','2026-10-03',2,0,2,2500000.00,'Đã đánh giá 5 sao & Host đã phản hồi.',NULL,'COMPLETED','2026-10-26 03:09:16'),(105,'BK-TEST-105',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',8,'2026-10-05','2026-10-07',2,0,2,2700000.00,'Khách đánh giá 2 sao. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 03:09:16'),(106,'BK-TEST-106',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',12,'2026-10-08','2026-10-10',2,0,2,5300000.00,'Khách đánh giá 4 sao. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 03:09:16'),(107,'BK-TEST-107',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',2,'2026-10-20','2026-10-24',4,1,2,4600000.00,'Kỳ nghỉ hoàn thành tại Family Suite Cầu Rồng 201. Chưa viết review.',NULL,'COMPLETED','2026-10-26 04:00:00'),(108,'BK-TEST-108',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',7,'2026-10-22','2026-10-25',2,0,1,1800000.00,'Kỳ nghỉ hoàn thành tại Rustic Wooden Bungalow Đà Lạt. Chưa viết review.',NULL,'COMPLETED','2026-10-26 05:00:00'),(109,'BK-TEST-109',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',14,'2026-10-18','2026-10-21',2,0,2,3600000.00,'Khách hoàn thành kỳ nghỉ Sunrise Beachfront Suite tại Nha Trang. Chưa đánh giá.',NULL,'COMPLETED','2026-10-26 07:00:00'),(110,'BK-TEST-110',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',17,'2026-10-22','2026-10-25',2,1,3,4500000.00,'Khách hoàn thành kỳ nghỉ Sunset Paradise Suite tại Phú Quốc. Chưa đánh giá.',NULL,'COMPLETED','2026-10-26 08:00:00'),(111,'BK-TEST-111',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',10,'2026-10-25','2026-10-27',2,0,2,1300000.00,'Khách công tác lưu trú Modern Urban Studio tại TP.HCM. Chưa đánh giá.',NULL,'COMPLETED','2026-10-27 03:00:00'),(112,'BK-TEST-112',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',6,'2026-10-19','2026-10-23',4,2,6,8400000.00,'Gia đình lưu trú tại Phố Cổ Grand Family Loft Hà Nội. Chưa đánh giá.',NULL,'COMPLETED','2026-10-26 09:00:00'),(113,'BK-TEST-113',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',9,'2026-10-24','2026-10-27',2,0,2,5550000.00,'Cặp đôi lưu trú Villa Cloud Hunter Attic tại Đà Lạt. Chưa đánh giá.',NULL,'COMPLETED','2026-10-27 04:00:00'),(114,'BK-TEST-114',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',15,'2026-10-10','2026-10-14',4,1,5,11200000.00,'Khách đánh giá 5 sao VIP Coral Sea View Villa Nha Trang. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 10:00:00'),(115,'BK-TEST-115',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',18,'2026-10-12','2026-10-15',4,0,4,9600000.00,'Khách đánh giá 3 sao Royal Oceanfront Pavilion Phú Quốc. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-26 11:00:00'),(116,'BK-TEST-116',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',11,'2026-10-15','2026-10-17',2,0,2,2900000.00,'Khách đánh giá 5 sao Riverfront Executive Suite Sài Gòn. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 12:00:00'),(117,'BK-TEST-117',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',4,'2026-10-16','2026-10-18',2,0,2,1100000.00,'Khách đánh giá 1 sao Classic Old Quarter Deluxe Hà Nội. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-26 13:00:00'),(118,'BK-TEST-118',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',16,'2026-10-21','2026-10-23',2,0,2,1040000.00,'Khách đánh giá 4 sao Tropical Garden Bungalow Phú Quốc. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 14:00:00'),(119,'BK-TEST-119',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',13,'2026-10-25','2026-10-28',2,0,1,1440000.00,'Kỳ nghỉ hoàn thành tại Ocean Breeze Standard 101 Nha Trang. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-29 03:00:00'),(120,'BK-TEST-120',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',1,'2026-10-26','2026-10-29',2,0,1,1350000.00,'Kỳ nghỉ hoàn thành tại Cozy Studio View Sông Hàn 101. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-30 04:00:00'),(121,'BK-TEST-121',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',8,'2026-10-27','2026-10-30',2,1,2,4050000.00,'Kỳ nghỉ hoàn thành tại Pine Valley View Suite 201 Đà Lạt. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-30 07:00:00'),(122,'BK-TEST-122',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',3,'2026-10-27','2026-10-30',4,0,2,7200000.00,'Kỳ nghỉ hoàn thành tại Penthouse Rooftop Panorama 301. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-30 09:00:00'),(123,'BK-TEST-123',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',18,'2026-10-28','2026-10-31',4,2,3,9600000.00,'Kỳ nghỉ hoàn thành tại Royal Oceanfront Pavilion 301 Phú Quốc. Sẵn sàng viết review mới!',NULL,'COMPLETED','2026-10-31 03:00:00'),(124,'BK-TEST-124',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',13,'2026-10-20','2026-10-23',2,0,1,1440000.00,'Khách đánh giá 5 sao Ocean Breeze Standard. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-24 03:00:00'),(125,'BK-TEST-125',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',2,'2026-10-21','2026-10-24',3,0,1,3450000.00,'Khách đánh giá 2 sao Family Sweet Suite Cầu Rồng. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-25 04:00:00'),(126,'BK-TEST-126',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',5,'2026-10-22','2026-10-25',2,0,1,3750000.00,'Khách đánh giá 4 sao Heritage Balcony Suite Phố Cổ. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-26 05:00:00'),(127,'BK-TEST-127',4,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233',7,'2026-10-23','2026-10-26',2,0,1,1800000.00,'Khách đánh giá 1 sao Rustic Wooden Bungalow Đà Lạt. Chờ Host phản hồi (Low rating).',NULL,'COMPLETED','2026-10-27 08:00:00'),(128,'BK-TEST-128',2,'Khanh MG','khanhmg2k3@gmail.com','0987654321',12,'2026-10-24','2026-10-27',4,0,2,7950000.00,'Khách đánh giá 5 sao Landmark View Grand Suite. Chờ Host phản hồi.',NULL,'COMPLETED','2026-10-28 10:00:00');

-- 9.6 Vouchers & Wishlists
INSERT INTO `vouchers` (`id`, `host_id`, `code`, `discount_type`, `discount_value`, `start_date`, `end_date`, `usage_limit`, `used_count`, `status`) VALUES
    (1, 3, 'TESTHOST10', 'PERCENTAGE', 15.00, '2026-10-12', '2026-12-31', 100, 0, 'ACTIVE'),
    (2, 3, 'SOGOCHAOHE', 'PERCENTAGE', 10.00, '2026-10-01', '2026-12-31', 50, 5, 'ACTIVE'),
    (3, 3, 'GIAM100K', 'FIXED_AMOUNT', 100000.00, '2026-10-01', '2026-12-31', 200, 12, 'ACTIVE');
INSERT INTO `wishlists` (`wishlist_id`, `user_id`, `room_id`, `created_at`) VALUES
    (1, 2, 2, '2026-09-28 10:00:00'),
    (2, 2, 5, '2026-09-29 14:30:00'),
    (3, 2, 9, '2026-09-30 08:15:00');

-- 9.7 AI Room Recommendations (Gợi ý phòng thông minh của bạn)
INSERT INTO `recommendations` (`user_id`, `room_id`, `recommendation_type`, `score`, `reason`, `is_displayed`)
VALUES 
(NULL, 1, 'POPULAR', 0.9800, 'Homestay Cozy Studio Đà Nẵng được đánh giá xuất sắc 4.8 sao và được đặt nhiều nhất', 1),
(NULL, 3, 'POPULAR', 0.9600, 'Penthouse Rooftop Panorama với view triệu đô đạt điểm đánh giá tuyệt đối 5.0 sao', 1),
(NULL, 6, 'POPULAR', 0.9500, 'Phố Cổ Grand Family Loft trung tâm Hà Nội được khách gia đình yêu thích hàng đầu', 1),
(NULL, 9, 'POPULAR', 0.9400, 'Villa Cloud Hunter Attic săn mây Đà Lạt cực hot với đánh giá 4.8 sao', 1)
ON DUPLICATE KEY UPDATE `score` = VALUES(`score`);

-- 9.8 Reviews & Review Replies (Đánh giá khách hàng & Host phản hồi từ Schema 1)
INSERT INTO `reviews` VALUES (1,1,2,2,1,5,'Kỳ nghỉ tuyệt vời ngoài mong đợi!','Phòng rất sạch sẽ, view ban công ngắm cầu Rồng tuyệt đẹp. Chủ nhà nhiệt tình và chu đáo.','APPROVED','2026-10-21 23:37:27','2026-10-21 23:37:27'),(2,102,2,3,1,4,'Không gian thoáng mát, view đẹp','Phòng Penthouse tầng thượng rất rộng rãi, ngắm toàn cảnh sông Hàn lung linh về đêm. Sẽ quay lại!','APPROVED','2026-10-26 02:45:02','2026-10-26 03:13:40'),(3,104,4,5,2,5,'Phòng đẹp, chủ nhà rất nhiệt tình','Ban công nhìn xuống phố cổ rất thích. Chủ nhà hướng dẫn đường đi và gợi ý quán ăn ngon.','APPROVED','2026-10-26 03:09:16','2026-10-26 03:09:16'),(4,105,2,8,3,2,'Phòng hơi ẩm và nước nóng yếu','View đẹp nhưng phòng có mùi ẩm, vòi sen nước nóng chảy yếu vào buổi tối. Mong chủ nhà cải thiện chất lượng dịch vụ.','APPROVED','2026-10-26 03:09:16','2026-10-26 03:09:16'),(5,106,4,12,4,4,'Căn hộ hiện đại, view sông tuyệt vời','Căn hộ sạch sẽ, ban công ngắm sông Sài Gòn rất đẹp. Chỉ tiếc thang máy hơi đông vào giờ cao điểm.','APPROVED','2026-10-26 03:09:16','2026-10-26 03:09:16'),(6,114,4,15,5,5,'Biệt thự view biển tuyệt đẹp ngoài mong đợi!','Hồ bơi vô cực riêng tư hướng thẳng biển ngắm bình minh cực đỉnh. Phòng ngủ rộng rãi, gia đình mình ai cũng thích mê!','APPROVED','2026-10-27 01:30:00','2026-10-27 01:30:00'),(7,115,2,18,6,3,'View biển đẹp nhưng wifi tầng trệt hơi chập chờn','Không gian resort sang trọng, bồn tắm sục Jacuzzi ngoài trời rất xịn. Điểm trừ nhỏ là wifi ở phòng khách hơi yếu lúc buổi tối.','APPROVED','2026-10-27 02:15:00','2026-10-27 02:15:00'),(8,116,2,11,4,5,'Ngắm Landmark 81 cực chill bên sông Sài Gòn','Ban công tầng cao đón gió sông mát rượi, tối ngắm Landmark 81 lung linh tuyệt đẹp. Chủ nhà nhiệt tình hỗ trợ nhận phòng sớm.','APPROVED','2026-10-27 03:45:00','2026-10-27 03:45:00'),(9,117,4,4,2,1,'Máy lạnh nhỏ nước và cách âm chưa được tốt','Đêm đầu máy lạnh nhỏ nước ngay góc giường, cách âm chưa tốt nên nghe tiếng xe cộ ngoài phố. Mong chủ nhà sớm bảo trì khắc phục.','APPROVED','2026-10-27 04:20:00','2026-10-27 04:20:00'),(10,118,2,16,6,4,'Khu vườn nhiệt đới xanh mát và yên bình','Bungalow ẩn mình giữa vườn dừa mát mẻ, không khí trong lành yên tĩnh tuyệt đối. Rất phù hợp để nghỉ ngơi chữa lành sau chuỗi ngày bận rộn.','APPROVED','2026-10-27 07:00:00','2026-10-27 07:00:00'),(11,124,2,13,5,5,'Phòng thoáng mát, gần biển Nha Trang đi dạo rất thích!','Vị trí rất gần biển, sáng sớm mở cửa gió lùa mát rượi. Phòng ốc gọn gàng ngăn nắp, giá cả rất hợp lý cho kỳ nghỉ ngắn ngày.','APPROVED','2026-10-28 02:00:00','2026-10-28 02:00:00'),(12,125,4,2,1,2,'Ban đêm hơi ồn do tiếng còi xe bên cầu Rồng','Phòng rộng và nội thất đẹp nhưng ban đêm cách âm cửa kính ban công chưa tốt, nghe tiếng xe cộ qua cầu khá rõ. Mong chủ nhà lắp thêm rèm chống ồn.','APPROVED','2026-10-29 01:30:00','2026-10-29 01:30:00'),(13,126,2,5,2,4,'Không gian đậm chất Hà Nội xưa, ban công ngắm phố rất chill','Ban công nhìn xuống con phố cổ tấp nập, trà chiều ngồi ngắm mưa Hà Nội cực kỳ thích. Chủ nhà chu đáo gợi ý nhiều quán bún chả ngon.','APPROVED','2026-10-29 07:15:00','2026-10-29 07:15:00'),(14,127,4,7,3,1,'Lò sưởi bị khói và bình nước nóng chậm','Thời tiết Đà Lạt lạnh mà bình nóng lạnh chờ rất lâu mới có nước ấm, lò sưởi đốt lên bị khói ngộp phòng. Gia đình mình có trải nghiệm chưa được trọn vẹn.','APPROVED','2026-10-30 03:20:00','2026-10-30 03:20:00'),(15,128,2,12,4,5,'View ngắm Landmark 81 cực kỳ sang chảnh bên sông','Căn suite thượng lưu view ôm trọn sông Sài Gòn và Landmark 81 lung linh về đêm. Dịch vụ check-in nhanh gọn, chủ nhà hướng dẫn rất tận tình!','APPROVED','2026-10-30 09:45:00','2026-10-30 09:45:00');
INSERT INTO `review_replies` VALUES (1,3,3,'Cảm ơn bạn đã lựa chọn Sogo Homestay! Rất vui vì bạn hài lòng với kỳ nghỉ. Hẹn gặp lại bạn trong chuyến đi tới nhé.','2026-10-26 03:09:16','2026-10-26 03:09:16');

-- 9.9 Notifications (Thông báo hệ thống & khuyến mãi từ Schema 1)
INSERT INTO `notifications` VALUES (1,2,'Mời bạn đánh giá kỳ nghỉ tại Homestay Đà Lạt','Kỳ nghỉ của bạn tại Rustic Wooden Bungalow 101 đã hoàn thành! Hãy chia sẻ cảm nhận và hình ảnh trải nghiệm để nhận xu tích lũy nhé.','REVIEW','/write-review?bookingId=108',1,'2026-10-27 02:57:20'),(2,2,'Chủ nhà đã phản hồi đánh giá của bạn','Host Văn Demo đã phản hồi đánh giá của bạn: \"Cảm ơn bạn đã lựa chọn Sogo Homestay! Rất vui vì bạn hài lòng với kỳ nghỉ.\"','REVIEW','/write-review?bookingId=104',1,'2026-10-27 02:07:20'),(3,2,'Đặt phòng thành công! (Mã #BK-TEST-107)','Bạn đã đặt thành công phòng Family Sweet Suite Cầu Rồng 201. Chúc bạn có kỳ nghỉ thật tuyệt vời!','BOOKING','/my-bookings',1,'2026-10-27 00:07:20'),(4,2,'Ưu đãi đặc biệt: Giảm 15% cho phòng yêu thích','Phòng Penthouse Rooftop Panorama 301 trong danh sách yêu thích của bạn vừa có Voucher giảm 15%. Đặt ngay kẻo lỡ!','PROMOTION','/wishlist',1,'2026-10-26 03:07:20'),(5,2,'Nhắc nhở: Sắp đến giờ nhận phòng','Chỉ còn 24 giờ nữa là đến giờ nhận phòng tại Sogo Homestay Đà Nẵng. Chúc bạn có chuyến đi thật vui vẻ!','BOOKING','/my-bookings',1,'2026-10-25 03:07:20'),(6,3,'Khách hàng gửi đánh giá 2 sao cần phản hồi','Khách hàng Khanh MG vừa gửi đánh giá 2 sao cho phòng Pine Valley View Suite 201: \"Phòng hơi ẩm và nước nóng yếu...\". Hãy phản hồi để hỗ trợ khách hàng!','REVIEW','/host/reviews?filter=low',1,'2026-10-27 02:42:20'),(7,3,'Có đánh giá mới từ khách hàng','Khách hàng Khanh MG đã đánh giá 4 sao cho phòng Penthouse Rooftop Panorama 301. Hãy gửi lời cảm ơn đến khách hàng!','REVIEW','/host/reviews?filter=unreplied',1,'2026-10-27 01:07:20'),(8,3,'Có đơn đặt phòng mới cần chuẩn bị','Khách hàng Khanh MG vừa hoàn tất đặt phòng Cozy Studio 101. Kiểm tra chi tiết và chuẩn bị phòng đón tiếp khách!','BOOKING','/host/dashboard',1,'2026-10-26 22:07:20'),(9,3,'Báo cáo doanh thu tuần của các homestay','Doanh thu tuần qua của các homestay thuộc sở hữu của bạn đạt 12.500.000 VNĐ, tăng 15% so với tuần trước.','SYSTEM','/host/dashboard',1,'2026-10-26 03:07:20'),(10,3,'Khách hàng Khanh MG gửi đánh giá 1 sao cần xử lý khẩn cấp','Khách hàng Khanh MG vừa gửi đánh giá 1 sao cho phòng Classic Old Quarter Deluxe: \"Máy lạnh nhỏ nước...\". Hãy phản hồi để hỗ trợ khách!','REVIEW','/host/reviews?filter=low',1,'2026-10-29 06:18:24'),(11,3,'Khách hàng gửi đánh giá 3 sao cần phản hồi','Khách hàng Khanh MG gửi đánh giá 3 sao cho phòng Royal Oceanfront Pavilion: \"View biển đẹp nhưng wifi tầng trệt yếu...\".','REVIEW','/host/reviews?filter=low',1,'2026-10-29 06:06:24'),(12,3,'Có đánh giá 5 sao mới từ Khanh MG','Khách hàng Khanh MG vừa đánh giá 5 sao cho phòng VIP Coral Sea View Villa: \"Hồ bơi vô cực ngắm bình minh cực đỉnh...\".','REVIEW','/host/reviews?filter=unreplied',0,'2026-10-29 05:36:24'),(13,2,'Mời bạn đánh giá kỳ nghỉ tại Nha Trang','Kỳ nghỉ của bạn tại Sunrise Beachfront Suite 201 đã hoàn thành! Hãy chia sẻ cảm nhận để nhận xu ưu đãi nhé.','REVIEW','/write-review?bookingId=109',0,'2026-10-29 06:11:24'),(14,2,'Mời bạn đánh giá kỳ nghỉ tại Phú Quốc','Kỳ nghỉ của bạn tại Sunset Paradise Suite 201 đã hoàn thành! Hãy chia sẻ trải nghiệm hoàng hôn Phú Quốc cùng cộng đồng nhé.','REVIEW','/write-review?bookingId=110',0,'2026-10-29 04:26:24'),(15,2,'Mời bạn đánh giá kỳ nghỉ tại Ocean Breeze Nha Trang','Kỳ nghỉ của bạn tại Ocean Breeze Standard 101 (#BK-TEST-119) đã hoàn tất! Hãy viết đánh giá để nhận quà nhé.','REVIEW','/write-review?bookingId=119',0,'2026-10-31 16:22:47'),(16,2,'Mời bạn đánh giá kỳ nghỉ Cozy Studio Đà Nẵng','Kỳ nghỉ của bạn tại Cozy Studio (#BK-TEST-120) đã hoàn thành! Hãy chia sẻ trải nghiệm kỳ nghỉ của bạn.','REVIEW','/write-review?bookingId=120',0,'2026-10-31 15:57:47'),(17,3,'Khách hàng gửi đánh giá 1 sao lò sưởi Đà Lạt cần phản hồi','Khách hàng An Nguyễn vừa gửi đánh giá 1 sao phòng Rustic Wooden Bungalow (#BK-TEST-127): \"Lò sưởi bị khói...\". Hãy xử lý hỗ trợ khách!','REVIEW','/host/reviews?filter=low',0,'2026-10-31 16:15:47'),(18,3,'Khách hàng phản ánh ồn 2 sao tại Cầu Rồng','Khách hàng An Nguyễn vừa gửi đánh giá 2 sao phòng Family Sweet Suite (#BK-TEST-125): \"Ban đêm hơi ồn...\". Hãy gửi phản hồi giải thích và hỗ trợ khách.','REVIEW','/host/reviews?filter=low',0,'2026-10-31 15:42:47'),(19,3,'Có đánh giá 5 sao tuyệt vời tại Landmark 81','Khách hàng Khanh MG vừa gửi đánh giá 5 sao phòng Landmark View Grand Suite (#BK-TEST-128): \"View ngắm Landmark 81 cực sang chảnh...\". Hãy gửi lời cảm ơn khách!','REVIEW','/host/reviews?filter=unreplied',0,'2026-10-31 15:27:47'),(20,3,'Có đánh giá 4 sao mới cho phòng Phố Cổ Hà Nội','Khách hàng Khanh MG đánh giá 4 sao phòng Heritage Balcony Suite (#BK-TEST-126): \"Không gian đậm chất Hà Nội xưa...\". Hãy phản hồi lời cảm ơn khách!','REVIEW','/host/reviews?filter=unreplied',0,'2026-10-31 14:27:47'),(21,1,'Yêu cầu hỗ trợ mới [TK-20261101-H9T6]','Nguyễn Văn An vừa gửi yêu cầu hỗ trợ thuộc mục Hỗ trợ đặt phòng.','SYSTEM','/admin/support/detail?id=6',1,'2026-11-01 15:38:09'),(22,4,'Phản hồi mới cho yêu cầu [TK-20261101-H9T6]','Ban quản trị đã phản hồi yêu cầu hỗ trợ TK-20261101-H9T6 của bạn. Nhấn để xem chi tiết.','SYSTEM','/support/ticket?code=TK-20261101-H9T6#reply-9',1,'2026-11-01 15:38:46');

-- 9.10 Contact Messages & Support Replies (Hỗ trợ khách hàng từ Schema 1)
INSERT INTO `contactmessages` VALUES (1,3,'TK-20261031-KP38','HOST_ASSISTANCE',2,'Nguyễn Văn Host Demo','hostdemo@gmail.com','0912345678','111111111111','qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq','NEW','2026-10-31 18:15:50','2026-10-31 18:15:50'),(2,2,'TK-20261031-63S3','BOOKING_INQUIRY',111,'Khanh MG','khanhmg2k3@gmail.com','0987654321','Yêu cầu hỗ trợ nhận phòng sớm tại Homestay Đà Lạt','Chào Ban quản trị Sogo Homestay, tôi có chuyến bay hạ cánh sớm lúc 10:00 sáng. Đơn đặt phòng của tôi dự kiến nhận lúc 14:00. Tôi muốn nhờ Ban quản trị hỗ trợ liên hệ với chủ nhà xem tôi có thể gửi hành lý trước và nhận phòng sớm nếu phòng trống được không? Xin cảm ơn!','PROCESSING','2026-10-31 19:57:22','2026-10-31 21:23:57'),(3,4,'TK-20261031-RDDF','BOOKING_INQUIRY',113,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233','Yêu cầu hỗ trợ nhận phòng sớm tại Homestay Đà Lạt','Chào Ban quản trị Sogo Homestay, chuyến bay của tôi hạ cánh sớm lúc 10:00 sáng mai. Đơn đặt phòng của tôi dự kiến nhận lúc 14:00. Tôi muốn nhờ Ban quản trị liên hệ với chủ nhà xem tôi có thể gửi hành lý trước và nhận phòng sớm nếu phòng đang trống được không? Xin cảm ơn!','RESOLVED','2026-10-31 20:57:57','2026-10-31 21:22:20'),(4,8,'TK-20261031-X4TY','PAYMENT_PRICING',NULL,'Đặng Thùy Linh','thuylinh@gmail.com','0909777888','Hỏi về thời gian hoàn tiền và phương thức thanh toán qua thẻ','Tôi đã thực hiện thanh toán qua cổng trực tuyến nhưng hệ thống trừ tiền tài khoản ngân hàng 2 lần cho cùng một giao dịch. Tôi đã kiểm tra lịch sử biến động số dư. Nhờ bộ phận tài chính Sogo kiểm tra và hướng dẫn thủ tục tra soát đối soát hoàn tiền giúp tôi.','NEW','2026-10-31 22:11:15','2026-10-31 22:11:15'),(5,9,'TK-20261101-KE7W','HOST_ASSISTANCE',NULL,'Vũ Hoàng Nam','hoangnam@gmail.com','0988999000','Chào mày','Mày có biết bố mày là ai không','RESOLVED','2026-11-01 21:59:07','2026-11-01 22:01:32'),(6,4,'TK-20261101-H9T6','BOOKING_INQUIRY',127,'Nguyễn Văn An','an.nguyen@gmail.com','0933112233','Tao muốn đấm mày','Tao muốn đấm mày','PROCESSING','2026-11-01 22:38:09','2026-11-01 22:38:46');
INSERT INTO `support_replies` VALUES (1,2,1,'Chào bạn, Ban quản trị Sogo Homestay đã tiếp nhận yêu cầu của bạn. Chúng tôi đã liên hệ trực tiếp với chủ nhà homestay. Chủ nhà đồng ý hỗ trợ bạn gửi hành lý từ 10:30 sáng và sẽ ưu tiên dọn phòng sớm nếu khách trước trả phòng đúng giờ nhé.','2026-10-31 20:54:54'),(2,3,1,'Chào bạn, Ban quản trị Sogo Homestay đã tiếp nhận yêu cầu của bạn. Chúng tôi đã liên hệ trực tiếp với chủ nhà homestay. Chủ nhà đồng ý hỗ trợ bạn gửi hành lý từ 10:30 sáng và sẽ ưu tiên dọn phòng sớm nếu khách trước trả phòng đúng giờ nhé.','2026-10-31 20:59:31'),(3,3,4,'Em cám ơn ạ','2026-10-31 21:12:53'),(4,3,1,'Ok bạn','2026-10-31 21:13:58'),(5,2,1,'1111','2026-10-31 21:23:31'),(6,2,1,'Ai mà biết được bạn','2026-10-31 21:23:57'),(7,5,1,'Bố mày đây','2026-11-01 22:00:00'),(8,5,1,'Mày ăn cơm chưa','2026-11-01 22:00:36'),(9,6,1,'Chan bố mày đê','2026-11-01 22:38:46');

-- 9.11 Terms & Static Pages (Quy định chi tiết từ Schema 1 & Trang tĩnh từ Schema 2)
INSERT INTO `terms_setting` VALUES (1,'Điều Khoản Dịch Vụ & Quy Định Lưu Trú - FPT Homestay','31/10/2026 23:12');
INSERT INTO `term_sections` VALUES (34,1,'Quy Định Nhận Phòng & Trả Phòng','Quy Định Nhận Phòng & Trả Phòng','multi-block','[{\"type\":\"text\",\"text\":\"• Giờ nhận phòng (Check-in): từ 14:00 của ngày bắt đầu lưu trú.\\n• Giờ trả phòng (Check-out): trước 12:00 trưa của ngày kết thúc lưu trú.\\n• Nhận phòng sớm / Trả phòng trễ: Tùy thuộc vào tình trạng phòng trống tại thời điểm đó và có thể áp dụng phụ phí theo quy định:\\n    - Trả phòng trễ từ 12:00 đến 18:00: Phụ thu 50% tiền phòng 1 đêm.\\n    - Trả phòng sau 18:00: Tính 100% tiền phòng 1 đêm.\\n• Khách vui lòng xuất trình CCCD/Hộ chiếu hợp lệ của tất cả các khách lưu trú để hoàn tất thủ tục đăng ký tạm trú với cơ quan quản lý.\\n-Khách vui lòng cấm đi ỉa\"},{\"type\":\"table\",\"title\":\"Bảng Chính Sách Hoàn Tiền\",\"headers\":[\"11111111111\",\"1111111\"],\"rows\":[[\"111111111\",\"ưefwefwf\"],[\"ffwewefwef\",\"fwfwefwe\"]]},{\"type\":\"callout\",\"text\":\"Đậu xanh rau má\",\"calloutType\":\"note\"}]',NULL,NULL,NULL),(35,2,'Quy Định Thanh Toán & Đặt Cọc111','Quy Định Thanh Toán & Đặt Cọc111','multi-block','[{\"type\":\"text\",\"text\":\"Nhằm đảm bảo việc giữ phòng, khách hàng cần thực hiện đặt cọc theo tỷ lệ sau:\\n\\n• Đặt cọc giữ chỗ: Tối thiểu 50% tổng giá trị đơn đặt phòng trong vòng 24 giờ kể từ khi gửi yêu cầu.\\n• Thanh toán số tiền còn lại: 50% còn lại được thanh toán trực tiếp tại quầy lễ tân khi làm thủ tục Check-in.\\n• Phương thức chấp nhận: Chuyển khoản ngân hàng trực tuyến (QR Pay), thẻ tín dụng/ghi nợ nội địa và tiền mặt.\"}]',NULL,NULL,NULL),(36,3,'Nội Quy Lưu Trú & An Ninh Homestay','Nội Quy Lưu Trú & An Ninh Homestay','multi-block','[{\"type\":\"text\",\"text\":\"• Không hút thuốc lá: Tuyệt đối không hút thuốc trong phòng ngủ. Khách có thể hút thuốc tại khu vực sân vườn hoặc ban công mở.\\n• Giờ yên tĩnh: Từ 22:30 đến 06:00 sáng hôm sau nhằm đảm bảo sự riêng tư và giấc ngủ của các phòng xung quanh.\\n• Chất cấm & Vũ khí: Nghiêm cấm mang theo các chất gây cháy nổ, vũ khí, chất kích thích hoặc thực hiện các hành vi vi phạm pháp luật Việt Nam trong khuôn viên homestay.\\n• Vật nuôi (Thú cưng): Vui lòng thông báo trước với quản lý homestay. Phí dọn dẹp vệ sinh phòng thú cưng có thể được áp dụng.\\n• Bảo quản tài sản: Quý khách có trách nhiệm giữ gìn trang thiết bị và đồ dùng trong phòng. Nếu xảy ra hư hỏng, mất mát sẽ bồi thường theo bảng giá niêm yết của homestay.\"}]',NULL,NULL,NULL),(37,4,'alo abc','alo abc','multi-block','[{\"type\":\"text\",\"text\":\"anh là ai\"},{\"type\":\"table\",\"title\":\"Bảng Chính Sách Hoàn Tiền\",\"headers\":[\"aa\",\"bb\",\"cc\"],\"rows\":[[\"12\",\"14\",\"42\"],[\"à\",\"fwefe\",\"fwe\"],[\"ưefwe\",\"fweef\",\"ưefwe\"]]},{\"type\":\"callout\",\"text\":\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\",\"calloutType\":\"note\"}]',NULL,NULL,NULL),(38,5,'QUy định giờ giấc','QUy định giờ giấc','multi-block','[{\"type\":\"table\",\"title\":\"Bảng Chính Sách Hoàn Tiền\",\"headers\":[\"Thời Gian Thông Báo Hủy\",\"Chính Sách Hoàn Cọc\"],\"rows\":[[\"Trước 07 ngày so với ngày nhận phòng\",\"Hoàn 100% tiền đặt cọc (trừ phí chuyển khoản nếu có)\"],[\"Từ 03 đến 06 ngày trước ngày nhận phòng\",\"Hoàn 50% tiền đặt cọc\"],[\"Dưới 03 ngày hoặc Không đến (No-show)\",\"Không hoàn lại tiền cọc\"]]}]',NULL,NULL,NULL);
INSERT INTO `static_pages` (`id`, `slug`, `title`, `meta_description`, `content`) VALUES
    (1, 'about-us', 'Về Sogo Homestay - Nơi Lưu Trữ Khoảnh Khắc Bình Yên', 'Khám phá câu chuyện hình thành, sứ mệnh và không gian nghỉ dưỡng tuyệt vời tại Sogo Homestay.', 'Sogo Homestay ra đời từ niềm đam mê mang lại không gian lưu trú ấm cúng, thư thái và gắn kết cho mọi du khách.'),
    (2, 'terms-and-conditions', 'Điều Khoản Dịch Vụ & Quy Định Lưu Trú - Sogo Homestay', 'Các quy định về đặt phòng, nhận/trả phòng, chính sách hủy phòng và trách nhiệm của khách hàng tại Sogo Homestay.', 'Chào mừng bạn đến với Sogo Homestay. Vui lòng đọc kỹ các điều khoản dưới đây trước khi đặt phòng và sử dụng dịch vụ của chúng tôi.');
INSERT INTO `faqs` (`id`, `question`, `answer`, `category`, `order_index`, `status`) VALUES
    (1, 'Thời gian nhận phòng (Check-in) và trả phòng (Check-out) là mấy giờ?', 'Thời gian nhận phòng tiêu chuẩn từ 14:00 và trả phòng trước 12:00 trưa hôm sau. Quý khách có thể yêu cầu nhận phòng sớm tùy vào tình trạng phòng sẵn có.', 'Đặt phòng', 1, 'ACTIVE'),
    (2, 'Chính sách hủy phòng và hoàn tiền của Sogo Homestay như thế nào?', 'Hủy phòng trước 7 ngày so với ngày nhận phòng sẽ được hoàn tiền 100%. Hủy trước 3 ngày được hoàn 50%. Quý khách có thể xem chi tiết trong đơn đặt.', 'Thanh toán & Hủy phòng', 2, 'ACTIVE'),
    (3, 'Tôi có thể thanh toán qua mã QR VietQR không?', 'Có, Sogo hỗ trợ thanh toán tự động qua mã VietQR của tất cả các ứng dụng ngân hàng và ví điện tử, tiền vào ngay và đơn đặt tự động xác nhận.', 'Thanh toán', 3, 'ACTIVE');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- KẾT THÚC MASTER DATABASE HỢP NHẤT THÀNH CÔNG (4 THÀNH VIÊN)
-- =============================================================================
