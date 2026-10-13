-- =======================================================
-- SOGO HOMESTAY BOOKING SYSTEM
-- 02_seed.sql
--------------
-- File này tạo dữ liệu mẫu cho database.
-- Chạy một lần sau migration Flyway V1.
-- =======================================================
USE `homestaybooking`;
-- =======================================================
-- 1. INSERT ROLES
-- Tạo các quyền mặc định.
-- =======================================================
INSERT INTO `roles` (`role_name`, `description`)
VALUES ('ROLE_ADMIN', 'Quản trị viên hệ thống'),
    ('ROLE_CUSTOMER', 'Khách hàng đặt phòng'),
    ('ROLE_HOST', 'Chủ nhà quản lý property');
-- =======================================================
-- 2. LẤY ROLE ID
-- Không hard-code role_id.
-- =======================================================
SELECT `id` INTO @admin_role_id
FROM `roles`
WHERE `role_name` = 'ROLE_ADMIN';
SELECT `id` INTO @customer_role_id
FROM `roles`
WHERE `role_name` = 'ROLE_CUSTOMER';
SELECT `id` INTO @host_role_id
FROM `roles`
WHERE `role_name` = 'ROLE_HOST';
-- =======================================================
-- 3. CREATE ADMIN USER
-- Password đã được hash bằng BCrypt.
-- =======================================================
INSERT INTO `users` (
        `role_id`,
        `username`,
        `password`,
        `full_name`,
        `email`,
        `phone`,
        `status`,
        `auth_provider`
    )
VALUES (
        @admin_role_id,
        'admin',
        '$2a$10$LKdfYfQz8C11OVAJauZl7.fcuQhY3JQYIYvfNMWGUb9p.wd0lr5QC',
        'System Administrator',
        'admin@homestay.com',
        '0901234567',
        'ACTIVE',
        'local'
    );
-- =======================================================
-- 4. CREATE CUSTOMER USER
-- Password đã được hash bằng BCrypt.
-- =======================================================
INSERT INTO `users` (
        `role_id`,
        `username`,
        `password`,
        `full_name`,
        `email`,
        `phone`,
        `status`,
        `auth_provider`
    )
VALUES (
        @customer_role_id,
        'khanhmg',
        '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a',
        'Khanh MG',
        'khanhmg2k3@gmail.com',
        '0987654321',
        'ACTIVE',
        'local'
    );
-- =======================================================
-- 5. CREATE HOST USER
-- Tạo một tài khoản Host mẫu.
-- =======================================================
INSERT INTO `users` (
        `role_id`,
        `username`,
        `password`,
        `full_name`,
        `email`,
        `phone`,
        `status`,
        `auth_provider`
    )
VALUES (
        @host_role_id,
        'hostdemo',
        '$2a$10$zmAOP9rNOQuWHBwSJXe3LuHj5CSvHEoL8MQYb16CvcqxneS4WZT8a',
        'Demo Host',
        'host@homestay.com',
        '0912345678',
        'ACTIVE',
        'local'
    );
-- =======================================================
-- 6. LẤY HOST USER ID
-- Không giả định user_id = 3.
-- =======================================================
SELECT `id` INTO @host_user_id
FROM `users`
WHERE `username` = 'hostdemo';
-- =======================================================
-- 7. CREATE HOST PROFILE
-------------------------
-- Host mẫu được APPROVED để có thể quản lý Property
-- ngay khi chạy seed.
----------------------
-- Trong hệ thống thật:
-- Host mới đăng ký nên bắt đầu ở trạng thái PENDING.
-- =======================================================
INSERT INTO `host_profiles` (
        `user_id`,
        `business_name`,
        `business_type`,
        `phone`,
        `verification_status`
    )
VALUES (
        @host_user_id,
        'Sogo Homestay',
        'HOMESTAY',
        '0912345678',
        'APPROVED'
    );
-- =======================================================
-- 8. LẤY HOST PROFILE ID
-- Không hard-code host_profile_id.
-- =======================================================
SELECT `id` INTO @host_profile_id
FROM `host_profiles`
WHERE `user_id` = @host_user_id;
-- =======================================================
-- 9. CREATE PROPERTY
-- Property thuộc Host Profile vừa tạo.
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
VALUES (
        @host_profile_id,
        'Sogo Homestay',
        'Homestay mẫu của hệ thống Sogo.',
        'HOMESTAY',
        'Địa chỉ mẫu',
        'Hà Nội',
        'Vietnam',
        'PUBLISHED'
    );
-- =======================================================
-- 10. LẤY PROPERTY ID
-- Không giả định property_id = 1.
-- =======================================================
SET @property_id = LAST_INSERT_ID();
-- =======================================================
-- 11. CREATE ROOM TYPES
-- Tất cả Room Type đều thuộc Property vừa tạo.
-- =======================================================
INSERT INTO `room_types` (`property_id`, `type_name`, `description`)
VALUES (
        @property_id,
        'Single Room',
        'Phòng đơn tiêu chuẩn ấm cúng dành cho 1-2 người'
    ),
    (
        @property_id,
        'Family Room',
        'Phòng gia đình rộng rãi đầy đủ tiện nghi'
    ),
    (
        @property_id,
        'Presidential Room',
        'Phòng cao cấp với tầm nhìn tuyệt đẹp'
    ),
    (
        @property_id,
        'Deluxe Room',
        'Phòng hạng sang view đồi/vườn'
    );
-- =======================================================
-- 12. LẤY ROOM TYPE ID
-- Không hard-code type_id.
-- =======================================================
SELECT `id` INTO @single_room_type_id
FROM `room_types`
WHERE `property_id` = @property_id
    AND `type_name` = 'Single Room';
SELECT `id` INTO @family_room_type_id
FROM `room_types`
WHERE `property_id` = @property_id
    AND `type_name` = 'Family Room';
SELECT `id` INTO @presidential_room_type_id
FROM `room_types`
WHERE `property_id` = @property_id
    AND `type_name` = 'Presidential Room';
SELECT `id` INTO @deluxe_room_type_id
FROM `room_types`
WHERE `property_id` = @property_id
    AND `type_name` = 'Deluxe Room';
-- =======================================================
-- 13. CREATE ROOMS
-- Tạo các phòng mẫu.
-- type_id được lấy từ Room Type thực tế.
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
        @single_room_type_id,
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
        @family_room_type_id,
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
        @presidential_room_type_id,
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
        @deluxe_room_type_id,
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
        @single_room_type_id,
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
        @family_room_type_id,
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
-- END OF 02_seed.sql
-- =======================================================