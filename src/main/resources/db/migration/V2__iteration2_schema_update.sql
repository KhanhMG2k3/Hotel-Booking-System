-- =============================================================================
-- V2__iteration2_schema_update.sql
-- Flyway Migration: Iteration 2 Database Updates
-- Modules: Payment, VietQR, Vouchers, Booking Enhancements, Auth Roles
-- =============================================================================

-- 1. USERS & ROLES EXTENSIONS
-- Đảm bảo tương thích giữa V1 (users.id) và DAO (users.user_id, password_hash)
ALTER TABLE `users`
    ADD COLUMN IF NOT EXISTS `user_id` INT AS (`id`) VIRTUAL,
    ADD COLUMN IF NOT EXISTS `password_hash` VARCHAR(255) NULL AFTER `password`,
    ADD COLUMN IF NOT EXISTS `email_verified` TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `date_of_birth` DATE NULL,
    ADD COLUMN IF NOT EXISTS `gender` VARCHAR(20) NULL,
    ADD COLUMN IF NOT EXISTS `address` VARCHAR(255) NULL,
    ADD COLUMN IF NOT EXISTS `loyalty_points` INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Cập nhật password_hash cho các user hiện có
UPDATE `users` SET `password_hash` = `password` WHERE `password_hash` IS NULL;

-- Bảng liên kết userroles
CREATE TABLE IF NOT EXISTS `userroles` (
    `user_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    CONSTRAINT `fk_userroles_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed vai trò mặc định cho userroles từ users hiện có
INSERT IGNORE INTO `userroles` (`user_id`, `role_id`)
SELECT `id`, `role_id` FROM `users`;

-- 2. ĐỊA DANH (GEOGRAPHY CATALOG)
CREATE TABLE IF NOT EXISTS `countries` (
    `country_id` INT NOT NULL AUTO_INCREMENT,
    `country_name` VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `provinces` (
    `province_id` INT NOT NULL AUTO_INCREMENT,
    `country_id` INT NOT NULL DEFAULT 1,
    `province_name` VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (`province_id`),
    CONSTRAINT `fk_provinces_countries` FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `destinations` (
    `destination_id` INT NOT NULL AUTO_INCREMENT,
    `province_id` INT NOT NULL,
    `destination_name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    PRIMARY KEY (`destination_id`),
    CONSTRAINT `fk_destinations_provinces` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`province_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. CƠ SỞ LƯU TRÚ (PROPERTIES EXTENSIONS)
ALTER TABLE `properties`
    ADD COLUMN IF NOT EXISTS `property_id` INT AS (`id`) VIRTUAL,
    ADD COLUMN IF NOT EXISTS `property_name` VARCHAR(150) AS (`name`) VIRTUAL,
    ADD COLUMN IF NOT EXISTS `destination_id` INT NULL,
    ADD COLUMN IF NOT EXISTS `average_rating` DECIMAL(3, 2) DEFAULT 4.5,
    ADD COLUMN IF NOT EXISTS `review_count` INT DEFAULT 10;

-- 4. LOẠI PHÒNG (ROOMTYPES) & HÌNH ẢNH (ROOMIMAGES)
CREATE TABLE IF NOT EXISTS `roomtypes` (
    `room_type_id` INT NOT NULL AUTO_INCREMENT,
    `property_id` INT NOT NULL,
    `room_name` VARCHAR(100) NOT NULL,
    `description` TEXT NULL,
    `bed_type` VARCHAR(50) DEFAULT 'King Bed',
    `max_guests` INT NOT NULL DEFAULT 2,
    `base_price` DECIMAL(12, 2) NOT NULL,
    `size_m2` DECIMAL(5, 2) DEFAULT 30.00,
    `rating` DECIMAL(3, 2) DEFAULT 4.5,
    `review_count` INT DEFAULT 10,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    PRIMARY KEY (`room_type_id`),
    CONSTRAINT `fk_roomtypes_properties` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `roomimages` (
    `image_id` BIGINT NOT NULL AUTO_INCREMENT,
    `room_type_id` INT NOT NULL,
    `image_url` VARCHAR(500) NOT NULL,
    `is_primary` TINYINT(1) DEFAULT 0,
    `display_order` INT DEFAULT 0,
    PRIMARY KEY (`image_id`),
    CONSTRAINT `fk_roomimages_roomtypes` FOREIGN KEY (`room_type_id`) REFERENCES `roomtypes` (`room_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đồng bộ bảng rooms với room_id và room_type_id
ALTER TABLE `rooms`
    ADD COLUMN IF NOT EXISTS `room_id` INT AS (`id`) VIRTUAL,
    ADD COLUMN IF NOT EXISTS `room_type_id` INT AS (`type_id`) VIRTUAL;

-- 5. ĐẶT PHÒNG (BOOKINGS EXTENSIONS)
ALTER TABLE `bookings`
    ADD COLUMN IF NOT EXISTS `booking_id` INT AS (`id`) VIRTUAL,
    ADD COLUMN IF NOT EXISTS `booking_code` VARCHAR(50) NULL AFTER `id`,
    ADD COLUMN IF NOT EXISTS `property_id` INT DEFAULT 1 AFTER `user_id`,
    ADD COLUMN IF NOT EXISTS `check_in` DATE NULL AFTER `customer_phone`,
    ADD COLUMN IF NOT EXISTS `check_out` DATE NULL AFTER `check_in_date`,
    ADD COLUMN IF NOT EXISTS `rooms_count` INT NOT NULL DEFAULT 1,
    ADD COLUMN IF NOT EXISTS `subtotal` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    ADD COLUMN IF NOT EXISTS `discount_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    ADD COLUMN IF NOT EXISTS `total_amount` DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    ADD COLUMN IF NOT EXISTS `booking_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    ADD COLUMN IF NOT EXISTS `cancellation_reason` VARCHAR(500) NULL;

-- Đồng bộ dữ liệu cũ
UPDATE `bookings` SET `check_in` = `check_in_date` WHERE `check_in` IS NULL AND `check_in_date` IS NOT NULL;
UPDATE `bookings` SET `check_out` = `check_out_date` WHERE `check_out` IS NULL AND `check_out_date` IS NOT NULL;
UPDATE `bookings` SET `booking_status` = `status` WHERE `booking_status` = 'PENDING' AND `status` IS NOT NULL;
UPDATE `bookings` SET `subtotal` = `total_price` WHERE `subtotal` = 0.00 AND `total_price` > 0;
UPDATE `bookings` SET `total_amount` = `total_price` WHERE `total_amount` = 0.00 AND `total_price` > 0;

-- 6. TÀI KHOẢN NGÂN HÀNG HỆ THỐNG (SYSTEM BANK ACCOUNTS)
CREATE TABLE IF NOT EXISTS `system_bank_accounts` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. GIAO DỊCH THANH TOÁN (PAYMENTS)
CREATE TABLE IF NOT EXISTS `payments` (
    `payment_id` BIGINT NOT NULL AUTO_INCREMENT,
    `payment_code` VARCHAR(50) NOT NULL,
    `user_id` INT NOT NULL,
    `booking_id` INT DEFAULT NULL,
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
    KEY `ix_payments_user` (`user_id`),
    KEY `ix_payments_status` (`status`),
    CONSTRAINT `fk_payments_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_payments_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. CHI TIẾT MÃ QR THANH TOÁN (PAYMENT QR CODES)
CREATE TABLE IF NOT EXISTS `payment_qr_codes` (
    `qr_id` BIGINT NOT NULL AUTO_INCREMENT,
    `payment_id` BIGINT NOT NULL,
    `booking_id` INT DEFAULT NULL,
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
    CONSTRAINT `fk_payment_qr_codes_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. BẢNG VOUCHERS (Hỗ trợ VoucherDAO và quản lý khuyến mãi của Host)
CREATE TABLE IF NOT EXISTS `vouchers` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `host_id` INT NOT NULL,
    `code` VARCHAR(50) NOT NULL UNIQUE,
    `discount_type` VARCHAR(20) NOT NULL,
    `discount_value` DECIMAL(12, 2) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `usage_limit` INT NOT NULL DEFAULT 100,
    `used_count` INT NOT NULL DEFAULT 0,
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    CONSTRAINT `ck_vouchers_discount_type` CHECK (`discount_type` IN ('PERCENTAGE', 'FIXED_AMOUNT', 'PERCENT', 'FIXED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. BẢNG COUPONS & COUPONUSAGES (Khuyến mãi toàn sàn)
CREATE TABLE IF NOT EXISTS `coupons` (
    `coupon_id` BIGINT NOT NULL AUTO_INCREMENT,
    `coupon_code` VARCHAR(50) NOT NULL UNIQUE,
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
    PRIMARY KEY (`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `couponusages` (
    `usage_id` BIGINT NOT NULL AUTO_INCREMENT,
    `coupon_id` BIGINT NOT NULL,
    `user_id` INT NOT NULL,
    `booking_id` INT DEFAULT NULL,
    `used_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`usage_id`),
    CONSTRAINT `fk_couponusages_coupons` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`coupon_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

