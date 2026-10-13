CREATE TABLE `roles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `role_name` VARCHAR(50) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `role_id` INT NOT NULL DEFAULT 2,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(20) NULL,
    `status` ENUM('ACTIVE', 'INACTIVE', 'BANNED') DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `google_id` VARCHAR(255) NULL UNIQUE,
    `auth_provider` VARCHAR(30) NOT NULL DEFAULT 'local',
    `avatar_url` VARCHAR(500) NULL,
    CONSTRAINT `fk_users_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE `host_profiles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `business_name` VARCHAR(150) NOT NULL,
    `business_type` VARCHAR(50) NULL,
    `phone` VARCHAR(20) NULL,
    `verification_status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED') NOT NULL DEFAULT 'PENDING',
    `rejection_reason` VARCHAR(500) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_host_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE `properties` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `host_id` INT NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `property_type` VARCHAR(50) NULL,
    `address` VARCHAR(255) NOT NULL,
    `city` VARCHAR(100) NULL,
    `country` VARCHAR(100) NOT NULL DEFAULT 'Vietnam',
    `status` ENUM(
        'DRAFT',
        'PENDING_REVIEW',
        'PUBLISHED',
        'REJECTED',
        'SUSPENDED'
    ) NOT NULL DEFAULT 'DRAFT',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_properties_host` FOREIGN KEY (`host_id`) REFERENCES `host_profiles` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE `room_types` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` INT NOT NULL,
    `type_name` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT NULL,
    CONSTRAINT `fk_room_types_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE `rooms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type_id` INT NOT NULL,
    `room_number` VARCHAR(20) NOT NULL UNIQUE,
    `room_name` VARCHAR(100) NOT NULL,
    `price_per_night` DECIMAL(12, 2) NOT NULL,
    `capacity` INT NOT NULL DEFAULT 2,
    `image_url` VARCHAR(255) NULL,
    `description` TEXT NULL,
    `status` ENUM('AVAILABLE', 'BOOKED', 'MAINTENANCE') DEFAULT 'AVAILABLE',
    `is_featured` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_rooms_room_types` FOREIGN KEY (`type_id`) REFERENCES `room_types` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
CREATE TABLE `bookings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NULL,
    `customer_name` VARCHAR(100) NOT NULL,
    `customer_email` VARCHAR(100) NOT NULL,
    `customer_phone` VARCHAR(20) NOT NULL,
    `room_id` INT NOT NULL,
    `check_in_date` DATE NOT NULL,
    `check_out_date` DATE NOT NULL,
    `adults` INT NOT NULL DEFAULT 1,
    `children` INT NOT NULL DEFAULT 0,
    `total_price` DECIMAL(12, 2) NOT NULL,
    `notes` TEXT NULL,
    `status` ENUM('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED') DEFAULT 'PENDING',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_bookings_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE
    SET NULL,
        CONSTRAINT `fk_bookings_rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;