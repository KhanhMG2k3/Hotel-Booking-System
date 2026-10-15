-- =============================================================================
-- SOGO HOMESTAY BOOKING SYSTEM - IDENTITY & SECURITY SUBSYSTEM SCHEMA
-- =============================================================================
-- Chịu trách nhiệm:
--   1. Xác thực & Tài khoản (Local Auth & Google OAuth)
--   2. Phân quyền đa vai trò (1 User vừa là Customer vừa là Host qua userroles)
--   3. Bảo mật tài khoản (Email OTP 2FA, Reset Password qua Token)
--   4. Đăng ký & Xét duyệt trở thành Host (Partner Onboarding Wizard & Staging)
--   5. Bảng Mock Catalog & Booking để kiểm thử luồng độc lập
--
-- Tương thích: MySQL 8.0+ / 9.0+ | Character Set: utf8mb4 | Collation: utf8mb4_unicode_ci
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `homestaybooking`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `homestaybooking`;

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- 1. PHÂN QUYỀN, TÀI KHOẢN & BẢO MẬT (AUTH & SECURITY)
-- =============================================================================

-- 1.1 Bảng Roles (Danh mục vai trò)
CREATE TABLE IF NOT EXISTS `roles` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO `roles` (`id`, `name`) VALUES
    (1, 'CUSTOMER'),
    (2, 'HOST'),
    (3, 'ADMIN')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- 1.2 Bảng Users (Tài khoản người dùng - Không dùng full_name dư thừa)
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `display_name` VARCHAR(100) NULL,
    `avatar_url` VARCHAR(500) NULL,
    `phone` VARCHAR(20) NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NULL,
    `google_id` VARCHAR(255) NULL UNIQUE,
    `role_id` TINYINT UNSIGNED NOT NULL DEFAULT 1,
    `status` ENUM('ACTIVE', 'INACTIVE', 'BANNED') NOT NULL DEFAULT 'ACTIVE',
    `two_factor_enabled` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_users_role`
        FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 1.3 Bảng UserRoles (Mapping Đa Quyền: Cho phép 1 User vừa làm Customer vừa làm Host)
CREATE TABLE IF NOT EXISTS `userroles` (
    `user_id` INT NOT NULL,
    `role_id` TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    CONSTRAINT `fk_userroles_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_userroles_role`
        FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 1.4 Bảng Password Resets (Đặt lại mật khẩu qua token có thời hạn)
CREATE TABLE IF NOT EXISTS `password_resets` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `token` VARCHAR(64) NOT NULL UNIQUE,
    `expires_at` TIMESTAMP NOT NULL,
    `used` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_password_resets_token` (`token`),
    INDEX `ix_password_resets_user` (`user_id`),
    CONSTRAINT `fk_password_resets_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 1.5 Bảng Email OTPs (Mã xác thực 6 số cho 2FA)
CREATE TABLE IF NOT EXISTS `email_otps` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `otp_code` VARCHAR(6) NOT NULL,
    `purpose` ENUM('LOGIN_2FA', 'ENABLE_2FA') NOT NULL DEFAULT 'LOGIN_2FA',
    `expires_at` TIMESTAMP NOT NULL,
    `used` BOOLEAN NOT NULL DEFAULT FALSE,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_email_otps_user` (`user_id`),
    INDEX `ix_email_otps_lookup` (`user_id`, `otp_code`, `purpose`),
    CONSTRAINT `fk_email_otps_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 2. ĐƠN ĐĂNG KÝ HOST & HỒ SƠ PHÒNG NHÁP (HOST APPLICATION ONBOARDING)
-- =============================================================================

-- 2.1 Bảng Host Applications (Hồ sơ đăng ký Host & KYC)
CREATE TABLE IF NOT EXISTS `host_applications` (
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
    INDEX `ix_host_applications_status_submitted` (`status`, `submitted_at`),
    INDEX `ix_host_applications_user_status` (`user_id`, `status`),
    CONSTRAINT `fk_host_applications_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_host_applications_reviewer`
        FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`)
        ON DELETE RESTRICT,
    CONSTRAINT `fk_host_applications_supersedes`
        FOREIGN KEY (`supersedes_application_id`) REFERENCES `host_applications` (`id`)
        ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 2.2 Bảng Phòng nháp đính kèm đơn đăng ký Host
CREATE TABLE IF NOT EXISTS `partner_application_rooms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `application_id` INT NOT NULL,
    `room_name` VARCHAR(120) NOT NULL,
    `room_type` VARCHAR(50) NOT NULL,
    `price_per_night` DECIMAL(10, 2) NOT NULL,
    `max_guests` SMALLINT UNSIGNED NOT NULL,
    `bed_count` SMALLINT UNSIGNED NOT NULL,
    `bathroom_count` SMALLINT UNSIGNED NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    INDEX `ix_partner_rooms_application` (`application_id`, `sort_order`, `id`),
    CONSTRAINT `fk_partner_rooms_application`
        FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 2.3 Bảng Tiện nghi phòng nháp
CREATE TABLE IF NOT EXISTS `partner_application_room_amenities` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `amenity_name` VARCHAR(80) NOT NULL,
    UNIQUE KEY `uq_partner_room_amenity` (`room_id`, `amenity_name`),
    CONSTRAINT `fk_partner_room_amenities_room`
        FOREIGN KEY (`room_id`) REFERENCES `partner_application_rooms` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 2.4 Bảng Hình ảnh/Video phòng nháp
CREATE TABLE IF NOT EXISTS `partner_application_room_images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `stored_name` VARCHAR(40) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL DEFAULT 'IMAGE',
    `content_type` ENUM('image/jpeg', 'image/png', 'video/mp4', 'video/webm') NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT `fk_partner_room_images_room`
        FOREIGN KEY (`room_id`) REFERENCES `partner_application_rooms` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 2.5 Bảng Media tạm trước khi lưu phòng (Client-side Upload Staging)
CREATE TABLE IF NOT EXISTS `partner_application_staged_media` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `application_id` INT NOT NULL,
    `client_room_key` VARCHAR(64) NOT NULL,
    `stored_name` VARCHAR(40) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL,
    `content_type` ENUM('image/jpeg', 'image/png', 'video/mp4', 'video/webm') NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_partner_staged_media_room` (`application_id`, `client_room_key`, `sort_order`, `id`),
    CONSTRAINT `fk_partner_staged_media_application`
        FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 3. BẢNG MOCK PROPERTIES & ROOMS (DÙNG CHO LUỒNG CHUYỂN TIẾP DUYỆT HOST & TEST)
-- =============================================================================

CREATE TABLE IF NOT EXISTS `properties` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner_id` INT NOT NULL,
    `application_id` INT NULL UNIQUE,
    `property_name` VARCHAR(150) NOT NULL,
    `property_type` VARCHAR(50) NOT NULL,
    `description` TEXT NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `city` VARCHAR(100) NOT NULL,
    `district` VARCHAR(100) NOT NULL,
    `ward` VARCHAR(100) NOT NULL,
    `latitude` DECIMAL(10, 8) NULL,
    `longitude` DECIMAL(11, 8) NULL,
    `room_count` SMALLINT UNSIGNED NOT NULL,
    `max_guests` SMALLINT UNSIGNED NOT NULL,
    `status` ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `ix_properties_owner_status` (`owner_id`, `status`),
    CONSTRAINT `fk_properties_owner`
        FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_properties_application`
        FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`)
        ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `rooms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` INT NOT NULL,
    `room_name` VARCHAR(120) NOT NULL,
    `room_type` VARCHAR(50) NOT NULL,
    `price_per_night` DECIMAL(10, 2) NOT NULL,
    `max_guests` SMALLINT UNSIGNED NOT NULL,
    `bed_count` SMALLINT UNSIGNED NOT NULL,
    `bathroom_count` SMALLINT UNSIGNED NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    INDEX `ix_rooms_property_sort` (`property_id`, `sort_order`, `id`),
    CONSTRAINT `fk_rooms_property`
        FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `room_amenities` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `amenity_name` VARCHAR(80) NOT NULL,
    UNIQUE KEY `uq_room_amenity` (`room_id`, `amenity_name`),
    CONSTRAINT `fk_room_amenities_room`
        FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `room_images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `stored_name` VARCHAR(40) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL DEFAULT 'IMAGE',
    `content_type` ENUM('image/jpeg', 'image/png', 'video/mp4', 'video/webm') NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    INDEX `ix_room_images_room_sort` (`room_id`, `sort_order`, `id`),
    CONSTRAINT `fk_room_images_room`
        FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 4. BẢNG BOOKINGS (PHỤC VỤ HOST DASHBOARD & DOANH THU - AN TOÀN DỮ LIỆU)
-- =============================================================================

CREATE TABLE IF NOT EXISTS `bookings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `booking_code` VARCHAR(50) NOT NULL UNIQUE,
    `room_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `customer_name` VARCHAR(100) NULL,
    `customer_email` VARCHAR(150) NULL,
    `customer_phone` VARCHAR(30) NULL,
    `check_in_date` DATE NOT NULL,
    `check_out_date` DATE NOT NULL,
    `guest_count` SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    `total_price` DECIMAL(12, 2) NOT NULL,
    `status` ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
    `special_requests` VARCHAR(500) NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_bookings_room_dates` (`room_id`, `check_in_date`, `check_out_date`),
    INDEX `ix_bookings_user` (`user_id`),
    INDEX `ix_bookings_status_created` (`status`, `created_at`),
    -- KHÔNG DÙNG ON DELETE CASCADE ĐỂ TRÁNH MẤT LỊCH SỬ DOANH THU VÀ HÓA ĐƠN
    CONSTRAINT `fk_bookings_room`
        FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
        ON DELETE RESTRICT,
    CONSTRAINT `fk_bookings_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 5. SEED DATA MẪU (CHUẨN BỊ SẴN ĐỂ ĐĂNG NHẬP VÀ TEST TẤT CẢ LUỒNG)
-- =============================================================================

-- Mật khẩu mặc định: admin123 (PBKDF2-SHA256 hash)
-- Tài khoản 1: admin / admin@homestay.com (Role: ADMIN)
-- Tài khoản 2: khanhcustomer / khanhcustomer@gmail.com (Role: CUSTOMER - Chưa đăng ký Host)
-- Tài khoản 3: hostdemo / hostdemo@gmail.com (Role: HOST + CUSTOMER - Đã được duyệt Host)
INSERT INTO `users` (`id`, `username`, `display_name`, `email`, `password`, `phone`, `role_id`, `status`) VALUES
    (1, 'admin', 'System Admin', 'admin@homestay.com', 'pbkdf2-sha256$210000$17yWOR8XjZ1Xa4KL6Sq7vg$Mxl8VxFNJfeUsOnc6KHSkZhTs50DdPf-YAgSNPLSpx4', '0901234567', 3, 'ACTIVE'),
    (2, 'khanhcustomer', 'Khánh Customer', 'khanhcustomer@gmail.com', 'pbkdf2-sha256$210000$17yWOR8XjZ1Xa4KL6Sq7vg$Mxl8VxFNJfeUsOnc6KHSkZhTs50DdPf-YAgSNPLSpx4', '0987654321', 1, 'ACTIVE'),
    (3, 'hostdemo', 'Nguyễn Văn Host Demo', 'hostdemo@gmail.com', 'pbkdf2-sha256$210000$17yWOR8XjZ1Xa4KL6Sq7vg$Mxl8VxFNJfeUsOnc6KHSkZhTs50DdPf-YAgSNPLSpx4', '0912345678', 2, 'ACTIVE')
ON DUPLICATE KEY UPDATE `email` = VALUES(`email`);

-- Cấp quyền trong bảng mapping userroles:
-- User 1: ADMIN
-- User 2: CUSTOMER
-- User 3: Vừa là CUSTOMER vừa là HOST (Đa quyền chuẩn)
INSERT INTO `userroles` (`user_id`, `role_id`) VALUES
    (1, 3),
    (2, 1),
    (3, 1),
    (3, 2)
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- KẾT THÚC IDENTITY & SECURITY SCHEMA
-- =============================================================================
