-- =============================================================================
-- V5__iteration3_model2_host_wallet.sql
-- Iteration 3: Model 2 - Host Wallet & Transaction Ledger for Refunds
-- =============================================================================

-- 1. Add balance column to wallet_accounts
ALTER TABLE `wallet_accounts` ADD COLUMN `balance` DECIMAL(18,2) NOT NULL DEFAULT 0.00;

-- 2. Create wallet_transactions table
CREATE TABLE IF NOT EXISTS `wallet_transactions` (
    `transaction_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `wallet_account_id` BIGINT NOT NULL,
    `user_id` INT NOT NULL,
    `transaction_type` VARCHAR(30) NOT NULL, -- 'CREDIT_BOOKING', 'DEBIT_REFUND', 'TOPUP', 'WITHDRAWAL'
    `amount` DECIMAL(18,2) NOT NULL,
    `balance_before` DECIMAL(18,2) NOT NULL,
    `balance_after` DECIMAL(18,2) NOT NULL,
    `reference_type` VARCHAR(40) NULL, -- 'BOOKING', 'REFUND', 'SYSTEM'
    `reference_id` BIGINT NULL,
    `description` VARCHAR(500) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`wallet_account_id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Initialize wallet for existing host (user_id = 3, host@homestay.com) with 0.00 VND (Model 2)
INSERT INTO `wallet_accounts` (`owner_type`, `owner_key`, `owner_user_id`, `account_type`, `currency`, `status`, `balance`)
SELECT 'HOST', 'host_3', 3, 'AVAILABLE', 'VND', 'ACTIVE', 0.00
WHERE NOT EXISTS (
    SELECT 1 FROM `wallet_accounts` WHERE `owner_type` = 'HOST' AND `owner_user_id` = 3 AND `account_type` = 'AVAILABLE'
);
