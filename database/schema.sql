-- =======================================================
-- Database Schema for Sogo Homestay Booking System
-- Database Engine: MySQL 8.0+
-- Character Set: UTF8MB4
-- =======================================================
-- =======================================================
-- 1. CREATE DATABASE
-- Tạo database nếu database chưa tồn tại.
-- =======================================================
CREATE DATABASE IF NOT EXISTS `homestaybooking` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Chọn database homestaybooking để sử dụng.
USE `homestaybooking`;
-- =======================================================
-- 2. DROP TABLES
-- Xóa các bảng cũ trước khi tạo lại.
-- Phải xóa bảng có FOREIGN KEY trước bảng được tham chiếu.
-- =======================================================
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `rooms`;
DROP TABLE IF EXISTS `room_types`;
DROP TABLE IF EXISTS `properties`;
DROP TABLE IF EXISTS `host_profiles`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `roles`;
-- =======================================================
-- 3. TABLE ROLES
-- Phân quyền:
-- ADMIN    : Quản trị viên
-- CUSTOMER : Khách hàng
-- HOST     : Chủ nhà
-- =======================================================
CREATE TABLE `roles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `role_name` VARCHAR(50) NOT NULL UNIQUE,
    `description` VARCHAR(255) NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =======================================================
-- 4. TABLE USERS
-- Lưu tài khoản người dùng.
-- Mỗi user thuộc một role.
-- =======================================================
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `role_id` INT NOT NULL DEFAULT 2,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(20) NULL,
    `status` ENUM ('ACTIVE', 'INACTIVE', 'BANNED') DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_users_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =======================================================
-- 5. TABLE ROOM TYPES
-- Loại phòng homestay:
-- Single, Family, Presidential, Deluxe...
------------------------------------------
-- Lưu ý:
-- property_id sẽ được thêm ở phần ALTER TABLE bên dưới.
-- =======================================================
CREATE TABLE `room_types` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type_name` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =======================================================
-- 6. TABLE ROOMS
-- Lưu thông tin từng phòng homestay.
-- Mỗi phòng thuộc một room type.
-- =======================================================
CREATE TABLE `rooms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type_id` INT NOT NULL,
    `room_number` VARCHAR(20) NOT NULL UNIQUE,
    `room_name` VARCHAR(100) NOT NULL,
    `price_per_night` DECIMAL(12, 2) NOT NULL,
    `capacity` INT NOT NULL DEFAULT 2,
    `image_url` VARCHAR(255) NULL,
    `description` TEXT NULL,
    `status` ENUM ('AVAILABLE', 'BOOKED', 'MAINTENANCE') DEFAULT 'AVAILABLE',
    `is_featured` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_rooms_room_types` FOREIGN KEY (`type_id`) REFERENCES `room_types` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =======================================================
-- 7. TABLE BOOKINGS
-- Lưu các đơn đặt phòng.
-- user_id có thể NULL nếu khách đặt phòng không đăng nhập.
-- =======================================================
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
    `status` ENUM (
        'PENDING',
        'CONFIRMED',
        'CANCELLED',
        'COMPLETED'
    ) DEFAULT 'PENDING',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_bookings_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE
    SET NULL,
        CONSTRAINT `fk_bookings_rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =======================================================
-- 8. TABLE HOST_PROFILES
-- Một user có tối đa một host profile.
-- Một host profile thuộc về một user.
--------------------------------------
-- Host mới đăng ký có trạng thái PENDING.
-- =======================================================
CREATE TABLE `host_profiles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL UNIQUE,
    `business_name` VARCHAR(150) NOT NULL,
    `business_type` VARCHAR(50) NULL,
    `phone` VARCHAR(20) NULL,
    `verification_status` ENUM (
        'PENDING',
        'APPROVED',
        'REJECTED',
        'SUSPENDED'
    ) NOT NULL DEFAULT 'PENDING',
    `rejection_reason` VARCHAR(500) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_host_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- =======================================================
-- 9. TABLE PROPERTIES
-- Lưu thông tin Homestay / Property.
-------------------------------------
-- host_id tham chiếu host_profiles.id,
-- không tham chiếu trực tiếp users.id.
-- =======================================================
CREATE TABLE `properties` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `host_id` INT NOT NULL,
    `name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `property_type` VARCHAR(50) NULL,
    `address` VARCHAR(255) NOT NULL,
    `city` VARCHAR(100) NULL,
    `country` VARCHAR(100) NOT NULL DEFAULT 'Vietnam',
    `status` ENUM (
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
-- =======================================================
-- 10. ALTER ROOM_TYPES
-- Thêm property_id vào room_types.
-----------------------------------
-- Vì room_types được tạo trước khi có Property,
-- nên property_id ban đầu cho phép NULL.
-- Sau khi dữ liệu cũ được gán Property,
-- sẽ đổi thành NOT NULL ở phần bên dưới.
-- =======================================================
ALTER TABLE `room_types`
ADD COLUMN `property_id` INT NULL
AFTER `id`;
-- =======================================================
-- 11. ADD FOREIGN KEY FOR ROOM_TYPES
-- Liên kết room_types với properties.
-- =======================================================
ALTER TABLE `room_types`
ADD CONSTRAINT `fk_room_types_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE RESTRICT;
-- =======================================================
-- 12. SEED DATA - ROLES
-- Tạo role ADMIN và CUSTOMER ban đầu.
-- =======================================================
INSERT INTO `roles` (`id`, `role_name`, `description`)
VALUES (1, 'ROLE_ADMIN', 'Quản trị viên hệ thống'),
    (2, 'ROLE_CUSTOMER', 'Khách hàng đặt phòng');
-- =======================================================
-- 13. SEED DATA - USERS
-- Tạo tài khoản Admin và Customer mẫu.
-- =======================================================
INSERT INTO `users` (
        `id`,
        `role_id`,
        `username`,
        `password`,
        `full_name`,
        `email`,
        `phone`,
        `status`
    )
VALUES (
        1,
        1,
        'admin',
        'admin123',
        'System Administrator',
        'admin@homestay.com',
        '0901234567',
        'ACTIVE'
    ),
    (
        2,
        2,
        'khanhmg',
        '123456',
        'Khanh MG',
        'khanhmg2k3@gmail.com',
        '0987654321',
        'ACTIVE'
    );
-- =======================================================
-- 14. BCRYPT PASSWORD
-- Thay password dạng text bằng password BCrypt.
-- =======================================================
UPDATE `users`
SET `password` = '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC'
WHERE `username` = 'admin';
UPDATE `users`
SET `password` = '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a'
WHERE `username` = 'khanhmg';
-- =======================================================
-- 15. ADD GOOGLE LOGIN COLUMNS
-- google_id      : ID tài khoản Google
-- auth_provider  : local / google
-- avatar_url     : ảnh đại diện
-- =======================================================
ALTER TABLE `users`
ADD COLUMN `google_id` VARCHAR(255) NULL UNIQUE,
    ADD COLUMN `auth_provider` VARCHAR(30) NOT NULL DEFAULT 'local',
    ADD COLUMN `avatar_url` VARCHAR(500) NULL;
-- =======================================================
-- 16. ALLOW PASSWORD NULL
-- Cho phép password NULL đối với tài khoản đăng nhập
-- bằng Google OAuth.
-- =======================================================
ALTER TABLE `users`
MODIFY COLUMN `password` VARCHAR(255) NULL;
-- =======================================================
-- 17. ADD ROLE HOST
-- Tạo ROLE_HOST nếu chưa tồn tại.
-- ID = 3 theo cấu trúc DB cũ.
-- =======================================================
INSERT INTO `roles` (`id`, `role_name`, `description`)
SELECT 3,
    'ROLE_HOST',
    'Chủ nhà quản lý property'
WHERE NOT EXISTS (
        SELECT 1
        FROM `roles`
        WHERE `role_name` = 'ROLE_HOST'
    );
-- =======================================================
-- 18. CREATE LEGACY HOST PROFILE
-- Tạo Host Profile cho dữ liệu Homestay cũ.
--------------------------------------------
-- Ở đây sử dụng User có ROLE_ADMIN làm owner tạm thời.
-- Sau này có thể đổi sang Host User riêng.
-- =======================================================
INSERT INTO `host_profiles` (
        `user_id`,
        `business_name`,
        `business_type`,
        `verification_status`
    )
SELECT `id`,
    'Legacy Homestay',
    'HOTEL',
    'APPROVED'
FROM `users`
WHERE `role_id` = 1
LIMIT 1;
-- =======================================================
-- 19. CREATE LEGACY PROPERTY
-- Tạo Property cũ trước khi hệ thống Host được triển khai.
-- =======================================================
INSERT INTO `properties` (
        `host_id`,
        `name`,
        `description`,
        `property_type`,
        `address`,
        `city`,
        `country`,
        `status`
    )
SELECT `id`,
    'Legacy Homestay',
    'Property hiện có trước khi triển khai Host',
    'HOMESTAY',
    'Địa chỉ chưa cập nhật',
    'Địa điểm chưa cập nhật',
    'Vietnam',
    'PUBLISHED'
FROM `host_profiles`
WHERE `business_name` = 'Legacy Homestay'
LIMIT 1;
-- =======================================================
-- 20. GET PROPERTY ID
-- Kiểm tra ID thực tế của Property Legacy Homestay.
-- =======================================================
SELECT `id`,
    `name`
FROM `properties`
WHERE `name` = 'Legacy Homestay';
-- =======================================================
-- 21. GÁN PROPERTY CHO ROOM TYPES CŨ
-- Giả sử Property ID thực tế là 1.
-----------------------------------
-- Nếu ID khác 1:
-- Thay số 1 bằng ID thực tế của Property.
-- =======================================================
UPDATE `room_types`
SET `property_id` = 1
WHERE `property_id` IS NULL;
-- =======================================================
-- 22. SEED DATA - ROOM TYPES
-- Tạo 4 loại phòng.
--------------------
-- property_id = 1 là Property Legacy Homestay.
-- =======================================================
INSERT INTO `room_types` (
        `id`,
        `property_id`,
        `type_name`,
        `description`
    )
VALUES (
        1,
        1,
        'Single Room',
        'Phòng đơn tiêu chuẩn ấm cúng dành cho 1-2 người'
    ),
    (
        2,
        1,
        'Family Room',
        'Phòng gia đình rộng rãi đầy đủ tiện nghi'
    ),
    (
        3,
        1,
        'Presidential Room',
        'Phòng cao cấp với tầm nhìn tuyệt đẹp'
    ),
    (
        4,
        1,
        'Deluxe Room',
        'Phòng hạng sang view đồi/vườn'
    );
-- =======================================================
-- 23. SEED DATA - ROOMS
-- Mapping với hình ảnh trong template Sogo.
-- =======================================================
INSERT INTO `rooms` (
        `type_id`,
        `room_number`,
        `room_name`,
        `price_per_night`,
        `capacity`,
        `image_url`,
        `description`,
        `status`,
        `is_featured`
    )
VALUES (
        1,
        'HOMESTAY-101',
        'Single Cozy Room',
        90.00,
        1,
        'images/img_1.jpg',
        'Phòng đơn thoáng mát với đầy đủ tiện ích cơ bản, phù hợp cho cá nhân du lịch.',
        'AVAILABLE',
        TRUE
    ),
    (
        2,
        'HOMESTAY-201',
        'Family Sweet Suite',
        120.00,
        4,
        'images/img_2.jpg',
        'Không gian gia đình thoải mái, có ban công ngắm cảnh và bếp nhỏ.',
        'AVAILABLE',
        TRUE
    ),
    (
        3,
        'HOMESTAY-301',
        'Presidential Suite Room',
        250.00,
        2,
        'images/img_3.jpg',
        'Phòng phong cách tổng thống với nội thất sang trọng, dịch vụ cao cấp.',
        'AVAILABLE',
        TRUE
    ),
    (
        4,
        'HOMESTAY-401',
        'Deluxe Garden Room',
        150.00,
        2,
        'images/slider-1.jpg',
        'Phòng Deluxe hướng vườn yên tĩnh, thoáng đãng.',
        'AVAILABLE',
        FALSE
    ),
    (
        1,
        'HOMESTAY-102',
        'Classic Standard Room',
        80.00,
        2,
        'images/slider-2.jpg',
        'Phòng tiêu chuẩn gọn gàng, tiện lợi cho các chuyến công tác ngắn ngày.',
        'AVAILABLE',
        FALSE
    ),
    (
        2,
        'HOMESTAY-202',
        'Grand Family Room',
        180.00,
        5,
        'images/slider-3.jpg',
        'Phòng đại gia đình với 2 giường lớn và phòng khách riêng.',
        'AVAILABLE',
        FALSE
    );
-- =======================================================
-- 24. KIỂM TRA ROLE_HOST
-- Kiểm tra ROLE_HOST và ID của role.
-- =======================================================
SELECT `id`,
    `role_name`
FROM `roles`
WHERE `role_name` = 'ROLE_HOST';
-- =======================================================
-- 25. KIỂM TRA USERS
-- Hiển thị toàn bộ user.
-- =======================================================
SELECT `id`,
    `role_id`,
    `username`,
    `password`,
    `full_name`,
    `email`,
    `phone`,
    `status`
FROM `users`;
-- =======================================================
-- 26. KIỂM TRA ADMIN
-- Kiểm tra riêng tài khoản admin.
-- =======================================================
SELECT *
FROM `users`
WHERE `username` = 'admin';
-- =======================================================
-- 27. KIỂM TRA USER + ROLE
-- Kiểm tra User đang thuộc Role nào.
-- =======================================================
SELECT u.`username`,
    u.`role_id`,
    r.`role_name`,
    u.`status`
FROM `users` u
    JOIN `roles` r ON u.`role_id` = r.`id`
WHERE u.`username` = 'admin';
-- =======================================================
-- 28. KIỂM TRA DANH SÁCH ROLE
-- =======================================================
SELECT `id`,
    `role_name`
FROM `roles`
ORDER BY `id`;
-- =======================================================
-- 29. KIỂM TRA HOST PROFILE
-- Kiểm tra bản ghi Host Profile vừa tạo.
-- =======================================================
SELECT *
FROM `host_profiles`
ORDER BY `id` DESC
LIMIT 1;
-- =======================================================
-- 30. KIỂM TRA HOST PROFILE
-- Kiểm tra trạng thái duyệt của Host.
-- =======================================================
SELECT `id`,
    `user_id`,
    `business_name`,
    `verification_status`
FROM `host_profiles`;
-- =======================================================
-- 31. KIỂM TRA HOST ĐÃ APPROVED
-- =======================================================
SELECT `id`,
    `user_id`,
    `business_name`,
    `verification_status`
FROM `host_profiles`
WHERE `verification_status` = 'APPROVED';
-- =======================================================
-- 32. KIỂM TRA USER ID = 3
-- Kiểm tra user có ID 3 có phải Host hay không.
-- =======================================================
SELECT `id`,
    `role_id`,
    `email`,
    `full_name`
FROM `users`
WHERE `id` = 3;
-- =======================================================
-- 33. KIỂM TRA PROPERTY
-- =======================================================
SELECT `id`,
    `name`,
    `host_id`,
    `status`
FROM `properties`;
-- =======================================================
-- 34. KIỂM TRA ROOM TYPES
-- Kiểm tra room type thuộc Property nào.
-- =======================================================
SELECT rt.`id`,
    rt.`type_name`,
    rt.`property_id`,
    p.`name` AS `property_name`
FROM `room_types` rt
    LEFT JOIN `properties` p ON rt.`property_id` = p.`id`
ORDER BY rt.`id`;
-- =======================================================
-- 35. KIỂM TRA SỐ LƯỢNG DỮ LIỆU
--------------------------------
-- Kỳ vọng:
-- host_profile_count >= 1
-- property_count >= 1
-- room_type_count = 4
-- room_count = 6
-- =======================================================
SELECT COUNT(*) AS `host_profile_count`
FROM `host_profiles`;
SELECT COUNT(*) AS `property_count`
FROM `properties`;
SELECT COUNT(*) AS `room_type_count`
FROM `room_types`;
SELECT COUNT(*) AS `room_count`
FROM `rooms`;
-- =======================================================
-- 36. KIỂM TRA PROPERTY_ID NULL
-- Kết quả phải là 0 trước khi đổi property_id thành NOT NULL.
-- =======================================================
SELECT COUNT(*) AS `null_property_count`
FROM `room_types`
WHERE `property_id` IS NULL;
-- =======================================================
-- 37. ĐỔI PROPERTY_ID THÀNH NOT NULL
-- Chỉ thực hiện sau khi kiểm tra null_property_count = 0.
-- =======================================================
ALTER TABLE `room_types`
MODIFY COLUMN `property_id` INT NOT NULL;
-- =======================================================
-- 38. KIỂM TRA CẤU TRÚC ROOM_TYPES
-- Xác nhận property_id và FOREIGN KEY.
-- =======================================================
SHOW CREATE TABLE `room_types`;
-- =======================================================
-- 39. KIỂM TRA CẤU TRÚC USERS
-- =======================================================
SHOW CREATE TABLE `users`;
-- =======================================================
-- 40. KIỂM TRA CẤU TRÚC ROLES
-- =======================================================
SHOW CREATE TABLE `roles`;
-- =======================================================
-- 41. KIỂM TRA CẤU TRÚC PROPERTIES
-----------------------------------
-- Xác nhận có:
-- host_id
-- name
-- description
-- property_type
-- address
-- city
-- country
-- status
-- created_at
-- updated_at
-- =======================================================
DESCRIBE `properties`;
-- =======================================================
-- 42. KIỂM TRA PROPERTY_ID
-- Xác nhận property_id đã tồn tại và NOT NULL.
-- =======================================================
SHOW COLUMNS
FROM `room_types` LIKE 'property_id';
-- =======================================================
-- 43. KIỂM TRA TOÀN BỘ ROOM TYPE
-- =======================================================
SELECT `id`,
    `type_name`,
    `property_id`
FROM `room_types`
ORDER BY `id`;
-- =======================================================
-- 44. KIỂM TRA TOÀN BỘ ROOM
-- =======================================================
SELECT `id`,
    `type_id`,
    `room_number`,
    `room_name`,
    `price_per_night`,
    `capacity`,
    `status`
FROM `rooms`
ORDER BY `id`;
-- =======================================================
-- 45. KIỂM TRA USER ID
-- Hiển thị toàn bộ User ID để xác định user thực tế.
-- =======================================================
SELECT `id`,
    `username`,
    `email`,
    `role_id`,
    `full_name`
FROM `users`
ORDER BY `id`;
-- =======================================================
-- END OF DATABASE SCRIPT
-- =======================================================