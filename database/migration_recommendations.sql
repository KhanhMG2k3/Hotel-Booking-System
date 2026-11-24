-- Migration: Create recommendations table for AI Catalog & Discovery
CREATE TABLE IF NOT EXISTS `recommendations` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Seed default popular recommendations for guest / fallback
INSERT INTO `recommendations` (`user_id`, `room_id`, `recommendation_type`, `score`, `reason`, `is_displayed`)
VALUES 
(NULL, 1, 'POPULAR', 0.9800, 'Homestay Cozy Studio Đà Nẵng được đánh giá xuất sắc 4.8 sao và được đặt nhiều nhất', 1),
(NULL, 3, 'POPULAR', 0.9600, 'Penthouse Rooftop Panorama với view triệu đô đạt điểm đánh giá tuyệt đối 5.0 sao', 1),
(NULL, 6, 'POPULAR', 0.9500, 'Phố Cổ Grand Family Loft trung tâm Hà Nội được khách gia đình yêu thích hàng đầu', 1),
(NULL, 9, 'POPULAR', 0.9400, 'Villa Cloud Hunter Attic săn mây Đà Lạt cực hot với đánh giá 4.8 sao', 1)
ON DUPLICATE KEY UPDATE `score` = VALUES(`score`);

