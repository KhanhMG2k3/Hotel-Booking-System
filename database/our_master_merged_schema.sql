-- =============================================================================
-- SOGO HOMESTAY BOOKING SYSTEM - MASTER MERGED DATABASE SCHEMA
-- =============================================================================
-- Bản hợp nhất toàn diện 100% từ 4 thành viên & Baseline hiện tại:
--   - Baseline (Bạn) : Homestay Catalog, Rich Details, Search & Filters, Pagination, Wishlists
--   - Member 1      : Host Application (Partner Onboarding), 2FA Email OTP, Password Reset
--   - Member 2      : Core Authentication & Standard Booking Flow
--   - Member 3      : Voucher & Discount Management
--   - Member 4      : FAQs & Static Pages (Về chúng tôi, Điều khoản dịch vụ)
--
-- Tương thích: MySQL 8.0+ / 9.0+ | Character Set: utf8mb4 | Collation: utf8mb4_unicode_ci
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

-- 1. Tạo và chọn database
CREATE DATABASE IF NOT EXISTS `homestay_iter1_test`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `homestay_iter1_test`;

-- =============================================================================
-- DỌN DẸP VIEW VÀ BẢNG CŨ
-- =============================================================================
DROP VIEW IF EXISTS `room_types`;
DROP VIEW IF EXISTS `room_images`;
DROP VIEW IF EXISTS `room_amenities`;

DROP TABLE IF EXISTS `vouchers`;
DROP TABLE IF EXISTS `partner_application_staged_media`;
DROP TABLE IF EXISTS `partner_application_room_images`;
DROP TABLE IF EXISTS `partner_application_room_amenities`;
DROP TABLE IF EXISTS `partner_application_rooms`;
DROP TABLE IF EXISTS `host_applications`;
DROP TABLE IF EXISTS `host_profiles`;
DROP TABLE IF EXISTS `email_otps`;
DROP TABLE IF EXISTS `password_resets`;

DROP TABLE IF EXISTS `wishlists`;
DROP TABLE IF EXISTS `userbehaviors`;
DROP TABLE IF EXISTS `searchhistories`;
DROP TABLE IF EXISTS `contactmessages`;
DROP TABLE IF EXISTS `faqs`;
DROP TABLE IF EXISTS `static_pages`;

DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `roomimages`;
DROP TABLE IF EXISTS `roomtypeamenities`;
DROP TABLE IF EXISTS `rooms`;
DROP TABLE IF EXISTS `roomtypes`;

DROP TABLE IF EXISTS `propertyamenities`;
DROP TABLE IF EXISTS `propertyimages`;
DROP TABLE IF EXISTS `properties`;
DROP TABLE IF EXISTS `destinations`;
DROP TABLE IF EXISTS `provinces`;
DROP TABLE IF EXISTS `countries`;
DROP TABLE IF EXISTS `amenities`;

DROP TABLE IF EXISTS `tourreviews`;
DROP TABLE IF EXISTS `tourschedules`;
DROP TABLE IF EXISTS `touritineraries`;
DROP TABLE IF EXISTS `tourimages`;
DROP TABLE IF EXISTS `tours`;

DROP TABLE IF EXISTS `userroles`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

-- =============================================================================
-- 1. TÀI KHOẢN, PHÂN QUYỀN & BẢO MẬT (AUTH & SECURITY)
-- =============================================================================

-- 1.1 Bảng Roles
CREATE TABLE `roles` (
    `role_id` INT NOT NULL AUTO_INCREMENT,
    `role_name` VARCHAR(50) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `roles` (`role_id`, `role_name`, `description`) VALUES
    (1, 'ROLE_ADMIN', 'Quản trị viên toàn hệ thống Sogo Homestay'),
    (2, 'ROLE_CUSTOMER', 'Khách hàng đặt phòng lưu trú'),
    (3, 'ROLE_HOST', 'Chủ nhà homestay / Đối tác kinh doanh');

-- 1.2 Bảng Users
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

-- 1.3 Bảng UserRoles (Mapping User - Role)
CREATE TABLE `userroles` (
    `user_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    CONSTRAINT `fk_userroles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_userroles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1.4 Bảng Password Resets (Member 1 - Đặt lại mật khẩu qua Token)
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

-- 1.5 Bảng Email OTPs (Member 1 - Xác thực 2 bước 2FA)
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
-- 2. ĐỊA ĐIỂM & ĐỐI TÁC HOMESTAY (LOCATIONS & HOST APPLICATIONS)
-- =============================================================================

CREATE TABLE `countries` (
    `country_id` INT NOT NULL AUTO_INCREMENT,
    `country_name` VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `countries` (`country_id`, `country_name`) VALUES (1, 'Việt Nam');

CREATE TABLE `provinces` (
    `province_id` INT NOT NULL AUTO_INCREMENT,
    `country_id` INT NOT NULL DEFAULT 1,
    `province_name` VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (`province_id`),
    CONSTRAINT `fk_provinces_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `provinces` (`province_id`, `province_name`) VALUES
    (1, 'Đà Nẵng'),
    (2, 'Hà Nội'),
    (3, 'Đà Lạt'),
    (4, 'TP. Hồ Chí Minh'),
    (5, 'Nha Trang'),
    (6, 'Phú Quốc');

CREATE TABLE `destinations` (
    `destination_id` INT NOT NULL AUTO_INCREMENT,
    `province_id` INT NOT NULL,
    `destination_name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    PRIMARY KEY (`destination_id`),
    CONSTRAINT `fk_destinations_province` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`province_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `destinations` (`destination_id`, `province_id`, `destination_name`, `description`) VALUES
    (1, 1, 'Biển Mỹ Khê & Bán Đảo Sơn Trà', 'Khu vực bãi biển quyến rũ bậc nhất hành tinh'),
    (2, 2, 'Phố Cổ Hà Nội & Hồ Hoàn Kiếm', 'Trung tâm văn hóa ngàn năm văn hiến'),
    (3, 3, 'Hồ Xuân Hương & Rừng Thông Đà Lạt', 'Xứ sở ngàn hoa sương mù lãng mạn'),
    (4, 4, 'Trung Tâm Quận 1 & Bến Bạch Đằng', 'Đô thị sầm uất hoa lệ'),
    (5, 5, 'Vịnh Biển Nha Trang', 'Thành phố biển sôi động cát trắng'),
    (6, 6, 'Bãi Sao & Hoàng Hôn Sunset Sanato', 'Đảo ngọc thiên đường nhiệt đới');

-- 2.1 Bảng Host Applications (Member 1 - Đơn đăng ký làm Host)
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

-- 2.2 Bảng Host Profiles (Hồ sơ Host cho Admin duyệt)
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

-- 2.3 Phòng & media đính kèm đơn đăng ký Host (Member 1)
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
-- 3. BẢNG PROPERTIES & TIỆN NGHI (HOMESTAYS & AMENITIES)
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

INSERT INTO `amenities` (`amenity_id`, `amenity_name`, `icon_class`, `category`) VALUES
    (1, 'Wi-Fi Tốc Độ Cao', 'fa-wifi', 'Tiện ích chung'),
    (2, 'Điều Hòa Nhiệt Độ', 'fa-snowflake-o', 'Phòng ngủ'),
    (3, 'Máy Nước Nóng Lạnh', 'fa-bath', 'Phòng tắm'),
    (4, 'Bếp & Dụng Cụ Nấu Ăn', 'fa-cutlery', 'Bếp'),
    (5, 'Smart TV & Netflix', 'fa-television', 'Giải trí'),
    (6, 'Ban Công Ngắm Cảnh', 'fa-sun-o', 'Không gian'),
    (7, 'Hồ Bơi Vô Cực', 'fa-tint', 'Tiện ích chung'),
    (8, 'Chỗ Để Xe Miễn Phí', 'fa-car', 'Tiện ích chung');

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

-- =============================================================================
-- 4. BẢNG LOẠI PHÒNG, PHÒNG & HÌNH ẢNH (ROOMTYPES & ROOMS)
-- =============================================================================

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

-- View tương thích Member 2 (room_types: id, type_name, description)
CREATE OR REPLACE VIEW `room_types` AS 
SELECT 
    `room_type_id` AS `id`,
    `room_name` AS `type_name`,
    `description`
FROM `roomtypes`;

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

-- View tương thích Member 1 (room_images: id, room_id, stored_name, media_type, content_type, sort_order)
CREATE OR REPLACE VIEW `room_images` AS
SELECT 
    `image_id` AS `id`,
    COALESCE(`room_id`, `room_type_id`) AS `room_id`,
    `image_url` AS `stored_name`,
    `media_type`,
    `content_type`,
    `display_order` AS `sort_order`
FROM `roomimages`;

CREATE TABLE `roomtypeamenities` (
    `room_type_id` INT NOT NULL,
    `amenity_id` INT NOT NULL,
    PRIMARY KEY (`room_type_id`, `amenity_id`),
    CONSTRAINT `fk_roomamenities_roomtype` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_roomamenities_amenity` FOREIGN KEY (`amenity_id`) REFERENCES `amenities` (`amenity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 5. ĐẶT PHÒNG & MÃ GIẢM GIÁ (BOOKINGS & VOUCHERS)
-- =============================================================================

-- 5.1 Bảng Bookings (Tổng hợp 100% cột từ Member 1, Member 2 và BookingDAO)
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

-- 5.2 Bảng Vouchers (Member 3 - Mã giảm giá của Host)
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

-- =============================================================================
-- 6. WISHLIST, BEHAVIORS, FAQS & STATIC PAGES
-- =============================================================================

-- 6.1 Bảng Wishlists (Danh sách phòng yêu thích)
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

-- 6.2 Bảng UserBehaviors (Thu thập hành vi người dùng)
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

-- 6.3 Bảng FAQs (Member 4 - Câu hỏi thường gặp)
CREATE TABLE `faqs` (
    `faq_id` INT NOT NULL AUTO_INCREMENT,
    `question` VARCHAR(500) NOT NULL,
    `answer` LONGTEXT NOT NULL,
    `category` VARCHAR(100) NULL,
    `order_index` INT DEFAULT 0,
    `status` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`faq_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6.4 Bảng Static Pages (Member 4 - Về chúng tôi, Điều khoản dịch vụ)
CREATE TABLE `static_pages` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `meta_description` VARCHAR(500) NULL,
    `content` LONGTEXT NOT NULL,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6.5 Bảng ContactMessages (Tin nhắn liên hệ)
CREATE TABLE `contactmessages` (
    `message_id` INT NOT NULL AUTO_INCREMENT,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `phone` VARCHAR(30) NULL,
    `subject` VARCHAR(200) NOT NULL,
    `message` TEXT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'UNREAD',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 7. SEED DATA TỔNG HỢP (DỮ LIỆU MẪU ĐẦY ĐỦ CHO TẤT CẢ TÍNH NĂNG)
-- =============================================================================

-- 7.1 Người dùng mẫu
-- Mật khẩu cho admin@homestay.com: admin123
-- Mật khẩu cho khanhmg2k3@gmail.com: 123456 hoặc admin123
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

-- 7.2 Hồ sơ Host & Đơn đăng ký mẫu
INSERT INTO `host_profiles` (`profile_id`, `user_id`, `id_card_number`, `approval_status`, `applied_at`, `reviewed_at`, `reviewed_by`) VALUES
    (1, 3, '048098001234', 'APPROVED', '2026-09-01 08:00:00', '2026-09-02 10:00:00', 1);

INSERT INTO `host_applications` (`id`, `user_id`, `application_note`, `status`, `submitted_at`, `reviewed_by`, `reviewed_at`, `applicant_name`, `applicant_email`, `applicant_phone`, `property_name`, `property_type`, `property_city`, `room_count`, `max_guests`, `document_status`) VALUES
    (1, 3, 'Đăng ký chuỗi Homestay Sogo Riverside Đà Nẵng', 'APPROVED', '2026-09-01 08:00:00', 1, '2026-09-02 10:00:00', 'Nguyễn Văn Host Demo', 'hostdemo@gmail.com', '0912345678', 'Sogo Riverside Homestay', 'Villa', 'Đà Nẵng', 3, 10, 'VERIFIED');

-- 7.3 Homestay Properties mẫu
INSERT INTO `properties` (`property_id`, `host_id`, `destination_id`, `application_id`, `property_name`, `property_type`, `description`, `address`, `city`, `district`, `ward`, `room_count`, `max_guests`, `status`) VALUES
    (1, 3, 1, 1, 'Sogo Riverside Homestay Đà Nẵng', 'Villa', 'Khu nghỉ dưỡng ven sông Hàn thơ mộng với tầm nhìn ngắm pháo hoa và cầu Rồng.', '123 Đường Bạch Đằng, Quận Hải Châu', 'Đà Nẵng', 'Hải Châu', 'Hải Châu 1', 3, 12, 'ACTIVE'),
    (2, 3, 2, NULL, 'Sogo Old Quarter Retreat Hà Nội', 'Nhà Cổ Phố Cổ', 'Homestay mang đậm phong cách kiến trúc Pháp cổ kính giữa lòng Hà Nội 36 phố phường.', '45 Hàng Gai, Quận Hoàn Kiếm', 'Hà Nội', 'Hoàn Kiếm', 'Hàng Gai', 3, 8, 'ACTIVE'),
    (3, 3, 3, NULL, 'Sogo Pine Hill Wooden Villa Đà Lạt', 'Bungalow Gỗ', 'Biệt thự gỗ mộc mạc nép mình bên sườn đồi thông lộng gió, săn mây mỗi sớm mai.', '88 Khe Sanh, Phường 10', 'Đà Lạt', 'Đà Lạt', 'Phường 10', 3, 10, 'ACTIVE'),
    (4, 3, 4, NULL, 'Sogo Saigon Riverfront Oasis', 'Căn Hộ Cao Cấp', 'Căn hộ homestay hiện đại với ban công rộng nhìn bao trọn sông Sài Gòn và Landmark 81.', '208 Nguyễn Hữu Cảnh, Quận Bình Thạnh', 'TP. Hồ Chí Minh', 'Bình Thạnh', 'Phường 22', 3, 8, 'ACTIVE'),
    (5, 3, 5, NULL, 'Sogo Blue Ocean Beachfront Nha Trang', 'Biệt Thự Biển', 'Bước chân vài bước ra bãi cát vàng biển Nha Trang, hồ bơi vô cực ngắm bình minh.', '02 Trần Phú, Phường Lộc Thọ', 'Nha Trang', 'Nha Trang', 'Lộc Thọ', 3, 10, 'ACTIVE'),
    (6, 3, 6, NULL, 'Sogo Sunset Pearl Bungalow Phú Quốc', 'Resort Bungalow', 'Khu nghỉ dưỡng bungalow mái lá nhiệt đới, nơi ngắm hoàng hôn đỏ rực đẹp nhất đảo ngọc.', 'Bãi Trường, Xã Dương Tơ', 'Phú Quốc', 'Phú Quốc', 'Dương Tơ', 3, 12, 'ACTIVE');

-- 7.4 Room Types & Rooms (18 phòng phân trang 6 phòng/trang)
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

-- 18 phòng vật lý
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

-- Hình ảnh phòng
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

-- 7.5 Đơn đặt phòng mẫu (Bookings)
INSERT INTO `bookings` (`id`, `booking_code`, `user_id`, `customer_name`, `customer_email`, `customer_phone`, `room_id`, `check_in_date`, `check_out_date`, `adults`, `children`, `guest_count`, `total_price`, `notes`, `status`) VALUES
    (1, 'BK-SOGO-1001', 2, 'Khanh MG', 'khanhmg2k3@gmail.com', '0987654321', 2, '2026-10-15', '2026-10-18', 2, 1, 3, 3450000.00, 'Khách đến nhận phòng lúc 14:00, yêu cầu chuẩn bị thêm 1 nệm phụ.', 'CONFIRMED'),
    (2, 'BK-SOGO-1002', 4, 'Nguyễn Văn An', 'an.nguyen@gmail.com', '0933112233', 5, '2026-10-20', '2026-10-22', 2, 0, 2, 2500000.00, 'Check-in muộn lúc 19:00.', 'PENDING');

-- 7.6 Mã giảm giá mẫu (Vouchers - Member 3)
INSERT INTO `vouchers` (`id`, `host_id`, `code`, `discount_type`, `discount_value`, `start_date`, `end_date`, `usage_limit`, `used_count`, `status`) VALUES
    (1, 3, 'TESTHOST10', 'PERCENTAGE', 15.00, '2026-10-12', '2026-12-31', 100, 0, 'ACTIVE'),
    (2, 3, 'SOGOCHAOHE', 'PERCENTAGE', 10.00, '2026-10-01', '2026-12-31', 50, 5, 'ACTIVE'),
    (3, 3, 'GIAM100K', 'FIXED_AMOUNT', 100000.00, '2026-10-01', '2026-12-31', 200, 12, 'ACTIVE');

-- 7.7 Danh sách yêu thích mẫu (Wishlist)
INSERT INTO `wishlists` (`wishlist_id`, `user_id`, `room_id`, `created_at`) VALUES
    (1, 2, 2, '2026-09-28 10:00:00'),
    (2, 2, 5, '2026-09-29 14:30:00'),
    (3, 2, 9, '2026-09-30 08:15:00');

-- 7.8 FAQs (Member 4)
INSERT INTO `faqs` (`faq_id`, `question`, `answer`, `category`, `order_index`, `status`) VALUES
    (1, 'Thời gian nhận phòng (Check-in) và trả phòng (Check-out) là mấy giờ?', 'Thời gian nhận phòng tiêu chuẩn từ 14:00 và trả phòng trước 12:00 trưa hôm sau. Quý khách có thể yêu cầu nhận phòng sớm tùy vào tình trạng phòng sẵn có.', 'Đặt phòng', 1, 1),
    (2, 'Chính sách hủy phòng và hoàn tiền của Sogo Homestay như thế nào?', 'Hủy phòng trước 7 ngày so với ngày nhận phòng sẽ được hoàn tiền 100%. Hủy trước 3 ngày được hoàn 50%. Quý khách có thể xem chi tiết trong đơn đặt.', 'Thanh toán & Hủy phòng', 2, 1),
    (3, 'Tôi có thể thanh toán qua mã QR VietQR không?', 'Có, Sogo hỗ trợ thanh toán tự động qua mã VietQR của tất cả các ứng dụng ngân hàng và ví điện tử, tiền vào ngay và đơn đặt tự động xác nhận.', 'Thanh toán', 3, 1);

-- 7.9 Trang tĩnh (Member 4)
INSERT INTO `static_pages` (`id`, `slug`, `title`, `meta_description`, `content`) VALUES
    (1, 'about-us', 'Về Sogo Homestay - Nơi Lưu Trữ Khoảnh Khắc Bình Yên', 'Khám phá câu chuyện hình thành, sứ mệnh và không gian nghỉ dưỡng tuyệt vời tại Sogo Homestay.', 'Sogo Homestay ra đời từ niềm đam mê mang lại không gian lưu trú ấm cúng, thư thái và gắn kết cho mọi du khách.'),
    (2, 'terms-and-conditions', 'Điều Khoản Dịch Vụ & Quy Định Lưu Trú - Sogo Homestay', 'Các quy định về đặt phòng, nhận/trả phòng, chính sách hủy phòng và trách nhiệm của khách hàng tại Sogo Homestay.', 'Chào mừng bạn đến với Sogo Homestay. Vui lòng đọc kỹ các điều khoản dưới đây trước khi đặt phòng và sử dụng dịch vụ của chúng tôi.');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- KẾT THÚC MASTER MERGED SCHEMA THÀNH CÔNG
-- =============================================================================
SELECT otp_code, purpose, expires_at, used FROM email_otps 
    WHERE user_id = (SELECT id FROM users WHERE email = 'hungjohn2004@gmail.com')
    ORDER BY id DESC LIMIT 1;