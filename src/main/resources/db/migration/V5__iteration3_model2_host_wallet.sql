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
    `user_id` BIGINT NOT NULL,
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

-- 3. Initialize wallet for existing host (user_id = 3, host@homestay.com) with 25,000,000 VND
INSERT INTO `wallet_accounts` (`owner_type`, `owner_key`, `owner_user_id`, `account_type`, `currency`, `status`, `balance`)
SELECT 'HOST', 'host_3', 3, 'AVAILABLE', 'VND', 'ACTIVE', 25000000.00
WHERE NOT EXISTS (
    SELECT 1 FROM `wallet_accounts` WHERE `owner_type` = 'HOST' AND `owner_user_id` = 3 AND `account_type` = 'AVAILABLE'
);

-- Ensure balance is at least 25,000,000 for host 3 if wallet already existed with 0
UPDATE `wallet_accounts`
SET `balance` = 25000000.00
WHERE `owner_type` = 'HOST' AND `owner_user_id` = 3 AND `account_type` = 'AVAILABLE' AND `balance` = 0.00;

-- 4. Seed initial transaction log for host 3
INSERT INTO `wallet_transactions` (`wallet_account_id`, `user_id`, `transaction_type`, `amount`, `balance_before`, `balance_after`, `reference_type`, `reference_id`, `description`)
SELECT w.wallet_account_id, 3, 'TOPUP', 25000000.00, 0.00, 25000000.00, 'SYSTEM', NULL, 'Nạp số dư ký quỹ ban đầu vào Ví Host'
FROM `wallet_accounts` w
WHERE w.owner_type = 'HOST' AND w.owner_user_id = 3 AND w.account_type = 'AVAILABLE'
  AND NOT EXISTS (SELECT 1 FROM `wallet_transactions` WHERE user_id = 3);
