-- =======================================================
-- Database Schema for Sogo Homestay Booking System
-- Database Engine: MySQL 8.0+
-- Character Set: UTF8MB4
-- =======================================================

CREATE DATABASE IF NOT EXISTS `homestaybooking` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `homestaybooking`;

-- 1. Table Roles (Phân quyền: ADMIN, CUSTOMER, STAFF)
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `rooms`;
DROP TABLE IF EXISTS `room_types`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;

CREATE TABLE `roles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `role_name` VARCHAR(50) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table Users (Tài khoản người dùng)
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `role_id` INT NOT NULL DEFAULT 2,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(20) NULL,
    `status` ENUM('ACTIVE', 'INACTIVE', 'BANNED') DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_users_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Table Room Types (Loại phòng homestay: Single, Family, Deluxe, Bungalow)
CREATE TABLE `room_types` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type_name` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Table Rooms (Phòng homestay)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Table Bookings (Đơn đặt phòng)
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
    CONSTRAINT `fk_bookings_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_bookings_rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================================================
-- SEED DATA (Dữ liệu mẫu ban đầu)
-- =======================================================

-- Roles
INSERT INTO `roles` (`id`, `role_name`, `description`) VALUES
(1, 'ROLE_ADMIN', 'Quản trị viên hệ thống'),
(2, 'ROLE_CUSTOMER', 'Khách hàng đặt phòng');

-- Users
INSERT INTO `users` (`id`, `role_id`, `username`, `password`, `full_name`, `email`, `phone`, `status`) VALUES
(1, 1, 'admin', 'admin123', 'System Administrator', 'admin@homestay.com', '0901234567', 'ACTIVE'),
(2, 2, 'khanhmg', '123456', 'Khanh MG', 'khanhmg2k3@gmail.com', '0987654321', 'ACTIVE');

-- Room Types
INSERT INTO `room_types` (`id`, `type_name`, `description`) VALUES
(1, 'Single Room', 'Phòng đơn tiêu chuẩn ấm cúng dành cho 1-2 người'),
(2, 'Family Room', 'Phòng gia đình rộng rãi đầy đủ tiện nghi'),
(3, 'Presidential Room', 'Phòng cao cấp với tầm nhìn tuyệt đẹp'),
(4, 'Deluxe Room', 'Phòng hạng sang view đồi/vườn');

-- Rooms (Mapping với hình ảnh trong template Sogo)
INSERT INTO `rooms` (`type_id`, `room_number`, `room_name`, `price_per_night`, `capacity`, `image_url`, `description`, `status`, `is_featured`) VALUES
(1, 'HOMESTAY-101', 'Single Cozy Room', 90.00, 1, 'images/img_1.jpg', 'Phòng đơn thoáng mát với đầy đủ tiện ích cơ bản, phù hợp cho cá nhân du lịch.', 'AVAILABLE', TRUE),
(2, 'HOMESTAY-201', 'Family Sweet Suite', 120.00, 4, 'images/img_2.jpg', 'Không gian gia đình thoải mái, có ban công ngắm cảnh và bếp nhỏ.', 'AVAILABLE', TRUE),
(3, 'HOMESTAY-301', 'Presidential Suite Room', 250.00, 2, 'images/img_3.jpg', 'Phòng phong cách tổng thống với nội thất sang trọng, dịch vụ cao cấp.', 'AVAILABLE', TRUE),
(4, 'HOMESTAY-401', 'Deluxe Garden Room', 150.00, 2, 'images/slider-1.jpg', 'Phòng Deluxe hướng vườn yên tĩnh, thoáng đãng.', 'AVAILABLE', FALSE),
(1, 'HOMESTAY-102', 'Classic Standard Room', 80.00, 2, 'images/slider-2.jpg', 'Phòng tiêu chuẩn gọn gàng, tiện lợi cho các chuyến công tác ngắn ngày.', 'AVAILABLE', FALSE),
(2, 'HOMESTAY-202', 'Grand Family Room', 180.00, 5, 'images/slider-3.jpg', 'Phòng đại gia đình với 2 giường lớn và phòng khách riêng.', 'AVAILABLE', FALSE);
