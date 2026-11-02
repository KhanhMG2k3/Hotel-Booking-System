-- =============================================================================
-- Migration V2: Contact Messages & Multi-turn Support Thread Schema
-- Feature: Contact & Customer Support System
-- Safe execution: Preserves existing data, idempotent column additions.
-- =============================================================================

-- Step 1: Ensure the contactmessages table exists with legacy baseline
CREATE TABLE IF NOT EXISTS `contactmessages` (
    `message_id` INT NOT NULL AUTO_INCREMENT,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `phone` VARCHAR(30) DEFAULT NULL,
    `subject` VARCHAR(200) NOT NULL,
    `message` TEXT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'NEW',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 2: Dynamically add extended support columns if they are not yet present
DROP PROCEDURE IF EXISTS `upgrade_contactmessages_for_support`;

DELIMITER $$
CREATE PROCEDURE `upgrade_contactmessages_for_support`()
BEGIN
    -- 1. Add user_id column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND COLUMN_NAME = 'user_id'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD COLUMN `user_id` INT NULL AFTER `message_id`;
    END IF;

    -- 2. Add ticket_code column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND COLUMN_NAME = 'ticket_code'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD COLUMN `ticket_code` VARCHAR(30) NULL AFTER `user_id`;
    END IF;

    -- 3. Add category column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND COLUMN_NAME = 'category'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD COLUMN `category` VARCHAR(50) NOT NULL DEFAULT 'GENERAL_FEEDBACK' AFTER `ticket_code`;
    END IF;

    -- 4. Add booking_id column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND COLUMN_NAME = 'booking_id'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD COLUMN `booking_id` INT NULL AFTER `category`;
    END IF;

    -- 5. Add updated_at column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND COLUMN_NAME = 'updated_at'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD COLUMN `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `created_at`;
    END IF;

    -- 6. Add unique constraint on ticket_code if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.TABLE_CONSTRAINTS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND CONSTRAINT_NAME = 'uk_contact_ticket_code'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD CONSTRAINT `uk_contact_ticket_code` UNIQUE (`ticket_code`);
    END IF;

    -- 7. Add index on user_id if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND INDEX_NAME = 'idx_contact_user'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD INDEX `idx_contact_user` (`user_id`);
    END IF;

    -- 8. Add index on status if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND INDEX_NAME = 'idx_contact_status'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD INDEX `idx_contact_status` (`status`);
    END IF;

    -- 9. Add foreign key to users(user_id) if missing and users table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.TABLE_CONSTRAINTS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND CONSTRAINT_NAME = 'fk_contact_user'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'users'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD CONSTRAINT `fk_contact_user` 
            FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) 
            ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;

    -- 10. Add foreign key to bookings(id) if missing and bookings table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.TABLE_CONSTRAINTS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'contactmessages' 
          AND CONSTRAINT_NAME = 'fk_contact_booking'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'bookings'
    ) THEN
        ALTER TABLE `contactmessages` 
            ADD CONSTRAINT `fk_contact_booking` 
            FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) 
            ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
END$$
DELIMITER ;

CALL `upgrade_contactmessages_for_support`();
DROP PROCEDURE IF EXISTS `upgrade_contactmessages_for_support`;

-- Step 3: Create support_replies table for threaded message history
CREATE TABLE IF NOT EXISTS `support_replies` (
    `reply_id` INT NOT NULL AUTO_INCREMENT,
    `ticket_id` INT NOT NULL,
    `sender_id` INT NOT NULL,
    `message` TEXT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`reply_id`),
    KEY `idx_replies_ticket` (`ticket_id`),
    KEY `idx_replies_sender` (`sender_id`),
    CONSTRAINT `fk_replies_ticket` 
        FOREIGN KEY (`ticket_id`) REFERENCES `contactmessages` (`message_id`) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_replies_sender` 
        FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
