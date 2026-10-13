CREATE DATABASE IF NOT EXISTS `homestaybooking`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `homestaybooking`;

-- Seed roles before creating accounts that reference them.
CREATE TABLE IF NOT EXISTS `roles` (
    `id` TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `roles` (`id`, `name`) VALUES
    (1, 'CUSTOMER'),
    (2, 'HOST'),
    (3, 'ADMIN');

-- Store account identity, authentication, status, and current role.
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

-- Store Host application details, review state, and private document references.
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
    -- These fields store private document references, not uploaded file contents.
    `document_status` ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    INDEX `ix_host_applications_status_submitted` (`status`, `submitted_at`),
    INDEX `ix_host_applications_user_status` (`user_id`, `status`),
    CONSTRAINT `fk_host_applications_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
    CONSTRAINT `fk_host_applications_reviewer`
        FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
    CONSTRAINT `fk_host_applications_supersedes`
        FOREIGN KEY (`supersedes_application_id`) REFERENCES `host_applications` (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `host_applications`
    MODIFY COLUMN `status`
        ENUM('DRAFT', 'PENDING', 'APPROVED', 'REJECTED') NOT NULL DEFAULT 'DRAFT',
    MODIFY COLUMN `submitted_at` TIMESTAMP NULL;

-- Add application fields safely when upgrading an existing database.
DELIMITER $$

DROP PROCEDURE IF EXISTS `add_host_application_column`$$
CREATE PROCEDURE `add_host_application_column`(
    IN column_name VARCHAR(64),
    IN column_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns AS existing_column
        WHERE existing_column.table_schema = DATABASE()
          AND existing_column.table_name = 'host_applications'
          AND existing_column.column_name = column_name
    ) THEN
        SET @alter_sql = CONCAT(
            'ALTER TABLE `host_applications` ADD COLUMN `',
            column_name,
            '` ',
            column_definition
        );
        PREPARE alter_statement FROM @alter_sql;
        EXECUTE alter_statement;
        DEALLOCATE PREPARE alter_statement;
    END IF;
END$$

DELIMITER ;

CALL `add_host_application_column`('applicant_name', 'VARCHAR(150) NULL');
CALL `add_host_application_column`('applicant_email', 'VARCHAR(254) NULL');
CALL `add_host_application_column`('applicant_phone', 'VARCHAR(30) NULL');
CALL `add_host_application_column`(
    'identification_type',
    'ENUM(''NATIONAL_ID'', ''PASSPORT'', ''OTHER'') NULL'
);
CALL `add_host_application_column`('identification_number', 'VARCHAR(100) NULL');
CALL `add_host_application_column`('property_name', 'VARCHAR(150) NULL');
CALL `add_host_application_column`('property_type', 'VARCHAR(50) NULL');
CALL `add_host_application_column`('property_description', 'TEXT NULL');
CALL `add_host_application_column`('property_address', 'VARCHAR(255) NULL');
CALL `add_host_application_column`('property_city', 'VARCHAR(100) NULL');
CALL `add_host_application_column`('property_district', 'VARCHAR(100) NULL');
CALL `add_host_application_column`('property_ward', 'VARCHAR(100) NULL');
CALL `add_host_application_column`('latitude', 'DECIMAL(10, 8) NULL');
CALL `add_host_application_column`('longitude', 'DECIMAL(11, 8) NULL');
CALL `add_host_application_column`('room_count', 'SMALLINT UNSIGNED NULL');
CALL `add_host_application_column`('max_guests', 'SMALLINT UNSIGNED NULL');
CALL `add_host_application_column`('identity_document_url', 'VARCHAR(1000) NULL');
CALL `add_host_application_column`('ownership_document_url', 'VARCHAR(1000) NULL');
CALL `add_host_application_column`('business_document_url', 'VARCHAR(1000) NULL');
CALL `add_host_application_column`('supersedes_application_id', 'INT NULL');
CALL `add_host_application_column`(
    'document_status',
    'ENUM(''PENDING'', ''VERIFIED'', ''REJECTED'') NOT NULL DEFAULT ''PENDING'''
);

DROP PROCEDURE IF EXISTS `add_host_application_column`;

-- Add the self-reference separately so existing application rows remain untouched.
SET @supersedes_fk_exists = (
    SELECT COUNT(*)
    FROM information_schema.referential_constraints
    WHERE constraint_schema = DATABASE()
      AND constraint_name = 'fk_host_applications_supersedes'
);
SET @supersedes_fk_sql = IF(
    @supersedes_fk_exists = 0,
    'ALTER TABLE `host_applications` ADD CONSTRAINT `fk_host_applications_supersedes` FOREIGN KEY (`supersedes_application_id`) REFERENCES `host_applications` (`id`)',
    'SELECT 1'
);
PREPARE supersedes_fk_statement FROM @supersedes_fk_sql;
EXECUTE supersedes_fk_statement;
DEALLOCATE PREPARE supersedes_fk_statement;

-- Store rooms, amenities, and media attached to Host application drafts.
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

CREATE TABLE IF NOT EXISTS `partner_application_room_images` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_id` INT NOT NULL,
    `stored_name` VARCHAR(40) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL DEFAULT 'IMAGE',
    `content_type` ENUM(
        'image/jpeg', 'image/png', 'video/mp4', 'video/webm'
    ) NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT `fk_partner_room_images_room`
        FOREIGN KEY (`room_id`) REFERENCES `partner_application_rooms` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `partner_application_staged_media` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `application_id` INT NOT NULL,
    `client_room_key` VARCHAR(64) NOT NULL,
    `stored_name` VARCHAR(40) NOT NULL,
    `media_type` ENUM('IMAGE', 'VIDEO') NOT NULL,
    `content_type` ENUM(
        'image/jpeg', 'image/png', 'video/mp4', 'video/webm'
    ) NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `ix_partner_staged_media_room` (`application_id`, `client_room_key`, `sort_order`, `id`),
    CONSTRAINT `fk_partner_staged_media_application`
        FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

SET @partner_room_media_type_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'partner_application_room_images'
      AND column_name = 'media_type'
);
SET @partner_room_media_type_sql = IF(
    @partner_room_media_type_exists = 0,
    'ALTER TABLE `partner_application_room_images` ADD COLUMN `media_type` ENUM(''IMAGE'', ''VIDEO'') NOT NULL DEFAULT ''IMAGE'' AFTER `stored_name`',
    'SELECT 1'
);
PREPARE partner_room_media_type_statement FROM @partner_room_media_type_sql;
EXECUTE partner_room_media_type_statement;
DEALLOCATE PREPARE partner_room_media_type_statement;

ALTER TABLE `partner_application_room_images`
    MODIFY COLUMN `content_type` ENUM(
        'image/jpeg', 'image/png', 'video/mp4', 'video/webm'
    ) NOT NULL;

SET @room_image_unique_exists = (
    SELECT COUNT(*)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'partner_application_room_images'
      AND index_name = 'stored_name'
      AND non_unique = 0
);
SET @room_image_unique_sql = IF(
    @room_image_unique_exists > 0,
    'ALTER TABLE `partner_application_room_images` DROP INDEX `stored_name`',
    'SELECT 1'
);
PREPARE room_image_unique_statement FROM @room_image_unique_sql;
EXECUTE room_image_unique_statement;
DEALLOCATE PREPARE room_image_unique_statement;

-- Create approved properties and their room inventory.
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
        FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`),
    CONSTRAINT `fk_properties_application`
        FOREIGN KEY (`application_id`) REFERENCES `host_applications` (`id`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `properties`
    MODIFY COLUMN `application_id` INT NULL;

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
    `content_type` ENUM(
        'image/jpeg', 'image/png', 'video/mp4', 'video/webm'
    ) NOT NULL,
    `sort_order` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    INDEX `ix_room_images_room_sort` (`room_id`, `sort_order`, `id`),
    CONSTRAINT `fk_room_images_room`
        FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- Upgrade room media metadata while preserving existing image records.
SET @room_media_type_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'room_images'
      AND column_name = 'media_type'
);
SET @room_media_type_sql = IF(
    @room_media_type_exists = 0,
    'ALTER TABLE `room_images` ADD COLUMN `media_type` ENUM(''IMAGE'', ''VIDEO'') NOT NULL DEFAULT ''IMAGE'' AFTER `stored_name`',
    'SELECT 1'
);
PREPARE room_media_type_statement FROM @room_media_type_sql;
EXECUTE room_media_type_statement;
DEALLOCATE PREPARE room_media_type_statement;

ALTER TABLE `room_images`
    MODIFY COLUMN `content_type` ENUM(
        'image/jpeg', 'image/png', 'video/mp4', 'video/webm'
    ) NOT NULL;

-- Store temporary password reset requests with cryptographic token and expiration.
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

-- Support adding two_factor_enabled column if upgrading an existing database.
SET @two_factor_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'users'
      AND column_name = 'two_factor_enabled'
);
SET @two_factor_sql = IF(
    @two_factor_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `two_factor_enabled` BOOLEAN NOT NULL DEFAULT FALSE AFTER `status`',
    'SELECT 1'
);
PREPARE two_factor_statement FROM @two_factor_sql;
EXECUTE two_factor_statement;
DEALLOCATE PREPARE two_factor_statement;

-- Store temporary 6-digit email OTPs for two-factor authentication (2FA).
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

-- Store customer bookings, dates, guest counts, pricing, and reservation states.
CREATE TABLE IF NOT EXISTS `bookings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `booking_code` VARCHAR(20) NOT NULL UNIQUE,
    `room_id` INT NOT NULL,
    `user_id` INT NOT NULL,
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
    CONSTRAINT `fk_bookings_room`
        FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`)
        ON DELETE CASCADE,
    CONSTRAINT `fk_bookings_user`
        FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

