-- =============================================================================
-- V3__finance_migration_v3.sql
-- Flyway Migration: Iteration 3 Finance, Double-Entry Ledger, Payouts & Refunds
-- Target: MySQL 8.0+ / 9.x
-- =============================================================================

-- 1. WALLET ACCOUNTS (Ví tài khoản cho Host và Sàn/Platform)
CREATE TABLE IF NOT EXISTS `wallet_accounts` (
    `wallet_account_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `owner_type` VARCHAR(20) NOT NULL,
    `owner_key` VARCHAR(100) NOT NULL,
    `owner_user_id` BIGINT NULL,
    `account_type` VARCHAR(40) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_wallet_account` (`owner_type`, `owner_key`, `account_type`, `currency`),
    FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`user_id`),
    CHECK (`owner_type` IN ('HOST', 'PLATFORM')),
    CHECK (`status` IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    CHECK (`currency` = UPPER(`currency`)),
    CHECK ((`owner_type` = 'HOST' AND `owner_user_id` IS NOT NULL) OR (`owner_type` = 'PLATFORM' AND `owner_user_id` IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. LEDGER ENTRIES (Sổ cái kế toán - Bút toán)
CREATE TABLE IF NOT EXISTS `ledger_entries` (
    `ledger_entry_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `entry_type` VARCHAR(40) NOT NULL,
    `reference_type` VARCHAR(40) NOT NULL,
    `reference_id` BIGINT NOT NULL,
    `idempotency_key` VARCHAR(191) NOT NULL UNIQUE,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `status` VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    `reversal_of_entry_id` BIGINT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`reversal_of_entry_id`) REFERENCES `ledger_entries` (`ledger_entry_id`),
    CHECK (`status` IN ('DRAFT', 'POSTED', 'REVERSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. LEDGER LINES (Dòng ghi nợ / có của sổ cái - Kế toán kép)
CREATE TABLE IF NOT EXISTS `ledger_lines` (
    `ledger_line_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `ledger_entry_id` BIGINT NOT NULL,
    `wallet_account_id` BIGINT NOT NULL,
    `direction` VARCHAR(6) NOT NULL,
    `amount` DECIMAL(18, 2) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    FOREIGN KEY (`ledger_entry_id`) REFERENCES `ledger_entries` (`ledger_entry_id`),
    FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`wallet_account_id`),
    INDEX `ix_ledger_wallet` (`wallet_account_id`),
    CHECK (`direction` IN ('DEBIT', 'CREDIT')),
    CHECK (`amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. PAYMENT CONFIGS (Cấu hình chính sách phí & hoa hồng nền tảng)
CREATE TABLE IF NOT EXISTS `payment_configs` (
    `payment_config_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `config_type` VARCHAR(40) NOT NULL,
    `calculation_type` VARCHAR(20) NOT NULL,
    `config_value` DECIMAL(18, 6) NOT NULL,
    `currency` CHAR(3) NULL,
    `country_code` CHAR(2) NULL,
    `listing_type` VARCHAR(50) NULL,
    `property_id` BIGINT NULL,
    `effective_from` DATETIME NOT NULL,
    `effective_to` DATETIME NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    `created_by` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
    INDEX `ix_config_lookup` (`config_type`, `status`, `effective_from`),
    CHECK (`calculation_type` IN ('PERCENT', 'FIXED')),
    CHECK (`status` IN ('DRAFT', 'ACTIVE', 'INACTIVE')),
    CHECK (`config_value` >= 0 AND (`calculation_type` <> 'PERCENT' OR `config_value` <= 100)),
    CHECK (`calculation_type` <> 'FIXED' OR `currency` IS NOT NULL),
    CHECK (`effective_to` IS NULL OR `effective_to` > `effective_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. PAYMENT FEE SNAPSHOTS (Bản chụp cấu trúc phí áp dụng tại thời điểm giao dịch)
CREATE TABLE IF NOT EXISTS `payment_fee_snapshots` (
    `payment_fee_snapshot_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` BIGINT NOT NULL,
    `payment_config_id` BIGINT NULL,
    `fee_type` VARCHAR(40) NOT NULL,
    `calculation_type` VARCHAR(20) NOT NULL,
    `applied_value` DECIMAL(18, 6) NOT NULL,
    `base_amount` DECIMAL(18, 2) NOT NULL,
    `fee_amount` DECIMAL(18, 2) NOT NULL,
    `charged_to` VARCHAR(20) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`),
    FOREIGN KEY (`payment_config_id`) REFERENCES `payment_configs` (`payment_config_id`),
    UNIQUE KEY `uq_fee_snapshot` (`payment_id`, `fee_type`, `charged_to`),
    CHECK (`base_amount` >= 0 AND `fee_amount` >= 0),
    CHECK (`charged_to` IN ('HOST', 'CUSTOMER', 'PLATFORM'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. PAYMENT ATTEMPTS (Quản lý các lần thử thanh toán & Idempotency)
CREATE TABLE IF NOT EXISTS `payment_attempts` (
    `payment_attempt_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` BIGINT NOT NULL,
    `gateway` VARCHAR(40) NOT NULL,
    `idempotency_key` VARCHAR(191) NOT NULL,
    `gateway_request_id` VARCHAR(191) NULL,
    `gateway_transaction_id` VARCHAR(191) NULL,
    `expected_amount` DECIMAL(18, 2) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `status` VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_payment_attempt_idempotency` (`gateway`, `idempotency_key`),
    UNIQUE KEY `uq_payment_attempt_request` (`gateway`, `gateway_request_id`),
    UNIQUE KEY `uq_payment_attempt_txn` (`gateway`, `gateway_transaction_id`),
    INDEX `ix_payment_attempt_payment` (`payment_id`, `status`),
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`),
    CHECK (`expected_amount` > 0),
    CHECK (`status` IN ('CREATED', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'EXPIRED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. PAYMENT EVENTS (Nhật ký sự kiện Webhook/IPN Gateway)
CREATE TABLE IF NOT EXISTS `payment_events` (
    `payment_event_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` BIGINT NULL,
    `gateway` VARCHAR(40) NOT NULL,
    `gateway_event_id` VARCHAR(191) NOT NULL,
    `event_type` VARCHAR(80) NOT NULL,
    `verification_status` VARCHAR(20) NOT NULL DEFAULT 'RECEIVED',
    `processing_status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    `payload_sha256` CHAR(64) NOT NULL,
    `received_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `processed_at` DATETIME NULL,
    UNIQUE KEY `uq_gateway_event` (`gateway`, `gateway_event_id`),
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`),
    CHECK (`verification_status` IN ('RECEIVED', 'VERIFIED', 'REJECTED')),
    CHECK (`processing_status` IN ('PENDING', 'PROCESSED', 'FAILED', 'IGNORED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. PAYMENT ALLOCATIONS (Phân bổ tài chính cho Host & Sàn)
CREATE TABLE IF NOT EXISTS `payment_allocations` (
    `allocation_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` BIGINT NOT NULL UNIQUE,
    `booking_id` BIGINT NOT NULL,
    `property_id` BIGINT NOT NULL,
    `beneficiary_user_id` BIGINT NULL,
    `gross_amount` DECIMAL(18, 2) NOT NULL,
    `host_net_amount` DECIMAL(18, 2) NOT NULL,
    `platform_fee_amount` DECIMAL(18, 2) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `status` VARCHAR(30) NOT NULL DEFAULT 'PENDING_REVIEW',
    `review_reason` VARCHAR(500) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`),
    FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    FOREIGN KEY (`property_id`) REFERENCES `properties` (`property_id`),
    FOREIGN KEY (`beneficiary_user_id`) REFERENCES `users` (`user_id`),
    CHECK (`gross_amount` >= 0 AND `host_net_amount` >= 0 AND `platform_fee_amount` >= 0),
    CHECK (`status` IN ('PENDING_REVIEW', 'ALLOCATED', 'REVERSED')),
    CHECK (`status` <> 'ALLOCATED' OR `beneficiary_user_id` IS NOT NULL),
    CHECK (`host_net_amount` + `platform_fee_amount` <= `gross_amount`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. PAYOUTS (Lệnh chi trả tiền cho Host)
CREATE TABLE IF NOT EXISTS `payouts` (
    `payout_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `host_user_id` BIGINT NOT NULL,
    `wallet_account_id` BIGINT NOT NULL,
    `amount` DECIMAL(18, 2) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `status` VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    `idempotency_key` VARCHAR(191) NOT NULL UNIQUE,
    `destination_token` VARCHAR(255) NOT NULL,
    `gateway` VARCHAR(40) NULL,
    `gateway_payout_id` VARCHAR(191) NULL,
    `requested_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `approved_by` BIGINT NULL,
    `processed_at` DATETIME NULL,
    UNIQUE KEY `uq_gateway_payout` (`gateway`, `gateway_payout_id`),
    FOREIGN KEY (`host_user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`wallet_account_id`) REFERENCES `wallet_accounts` (`wallet_account_id`),
    FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`),
    CHECK (`amount` > 0),
    CHECK (`status` IN ('REQUESTED', 'APPROVED', 'PROCESSING', 'PAID', 'FAILED', 'REJECTED', 'CANCELLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. REFUNDS (Hoàn tiền giao dịch)
CREATE TABLE IF NOT EXISTS `refunds` (
    `refund_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` BIGINT NOT NULL,
    `booking_id` BIGINT NULL,
    `amount` DECIMAL(18, 2) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `reason` VARCHAR(500) NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    `idempotency_key` VARCHAR(191) NOT NULL UNIQUE,
    `gateway` VARCHAR(40) NULL,
    `gateway_refund_id` VARCHAR(191) NULL,
    `requested_by` BIGINT NOT NULL,
    `approved_by` BIGINT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `completed_at` DATETIME NULL,
    UNIQUE KEY `uq_gateway_refund` (`gateway`, `gateway_refund_id`),
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`),
    FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`),
    INDEX `ix_refund_payment_status` (`payment_id`, `status`),
    CHECK (`amount` > 0),
    CHECK (`status` IN ('REQUESTED', 'APPROVED', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'REJECTED', 'CANCELLED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. TAX RECORDS (Ghi nhận nghĩa vụ thuế)
CREATE TABLE IF NOT EXISTS `tax_records` (
    `tax_record_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `payment_id` BIGINT NOT NULL,
    `booking_id` BIGINT NULL,
    `payment_config_id` BIGINT NULL,
    `tax_type` VARCHAR(50) NOT NULL,
    `jurisdiction` VARCHAR(150) NOT NULL,
    `taxable_amount` DECIMAL(18, 2) NOT NULL,
    `tax_rate` DECIMAL(18, 6) NOT NULL,
    `tax_amount` DECIMAL(18, 2) NOT NULL,
    `currency` CHAR(3) NOT NULL DEFAULT 'VND',
    `remittance_party` VARCHAR(20) NOT NULL,
    `remittance_status` VARCHAR(20) NOT NULL DEFAULT 'UNREMITTED',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `remitted_at` DATETIME NULL,
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`),
    FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`),
    FOREIGN KEY (`payment_config_id`) REFERENCES `payment_configs` (`payment_config_id`),
    CHECK (`taxable_amount` >= 0 AND `tax_rate` >= 0 AND `tax_amount` >= 0),
    CHECK (`remittance_party` IN ('HOST', 'PLATFORM', 'GATEWAY')),
    CHECK (`remittance_status` IN ('UNREMITTED', 'PROCESSING', 'REMITTED', 'EXEMPT', 'ADJUSTED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. FINANCE AUDIT LOGS (Nhật ký kiểm toán tài chính - Chỉ thêm, không sửa/xóa)
CREATE TABLE IF NOT EXISTS `finance_audit_logs` (
    `finance_audit_log_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `actor_user_id` BIGINT NULL,
    `action` VARCHAR(100) NOT NULL,
    `entity_type` VARCHAR(50) NOT NULL,
    `entity_id` BIGINT NOT NULL,
    `request_id` VARCHAR(191) NULL,
    `details_json` JSON NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`user_id`),
    INDEX `ix_audit_entity` (`entity_type`, `entity_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- TRIGGERS: Bảo vệ tính bất biến của Sổ cái và Audit Logs
-- =============================================================================

DROP TRIGGER IF EXISTS `trg_ledger_entry_insert_draft`;
DROP TRIGGER IF EXISTS `trg_ledger_line_only_draft_insert`;
DROP TRIGGER IF EXISTS `trg_ledger_line_guard_update`;
DROP TRIGGER IF EXISTS `trg_ledger_line_guard_delete`;
DROP TRIGGER IF EXISTS `trg_ledger_entry_guard_delete`;
DROP TRIGGER IF EXISTS `trg_ledger_entry_guard_update`;
DROP TRIGGER IF EXISTS `trg_finance_audit_no_update`;
DROP TRIGGER IF EXISTS `trg_finance_audit_no_delete`;

DELIMITER $$

CREATE TRIGGER `trg_ledger_entry_insert_draft` BEFORE INSERT ON `ledger_entries`
FOR EACH ROW BEGIN
    IF NEW.status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger entry must start DRAFT';
    END IF;
END$$

CREATE TRIGGER `trg_ledger_line_only_draft_insert` BEFORE INSERT ON `ledger_lines`
FOR EACH ROW BEGIN
    IF NOT EXISTS (SELECT 1 FROM `ledger_entries` WHERE `ledger_entry_id` = NEW.ledger_entry_id AND `status` = 'DRAFT') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger lines require DRAFT entry';
    END IF;
END$$

CREATE TRIGGER `trg_ledger_line_guard_update` BEFORE UPDATE ON `ledger_lines`
FOR EACH ROW BEGIN
    IF NOT EXISTS (SELECT 1 FROM `ledger_entries` WHERE `ledger_entry_id` = OLD.ledger_entry_id AND `status` = 'DRAFT')
       OR NOT EXISTS (SELECT 1 FROM `ledger_entries` WHERE `ledger_entry_id` = NEW.ledger_entry_id AND `status` = 'DRAFT') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot change posted ledger lines';
    END IF;
END$$

CREATE TRIGGER `trg_ledger_line_guard_delete` BEFORE DELETE ON `ledger_lines`
FOR EACH ROW BEGIN
    IF NOT EXISTS (SELECT 1 FROM `ledger_entries` WHERE `ledger_entry_id` = OLD.ledger_entry_id AND `status` = 'DRAFT') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete posted ledger lines';
    END IF;
END$$

CREATE TRIGGER `trg_ledger_entry_guard_delete` BEFORE DELETE ON `ledger_entries`
FOR EACH ROW BEGIN
    IF OLD.status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete posted ledger entry';
    END IF;
END$$

CREATE TRIGGER `trg_ledger_entry_guard_update` BEFORE UPDATE ON `ledger_entries`
FOR EACH ROW BEGIN
    DECLARE debit_total DECIMAL(28, 2) DEFAULT 0;
    DECLARE credit_total DECIMAL(28, 2) DEFAULT 0;
    DECLARE line_count INT DEFAULT 0;
    DECLARE bad_currency INT DEFAULT 0;

    IF OLD.status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Posted ledger entry is immutable';
    END IF;

    IF NOT (NEW.entry_type <=> OLD.entry_type)
       OR NOT (NEW.reference_type <=> OLD.reference_type)
       OR NOT (NEW.reference_id <=> OLD.reference_id)
       OR NOT (NEW.idempotency_key <=> OLD.idempotency_key)
       OR NOT (NEW.currency <=> OLD.currency)
       OR NOT (NEW.reversal_of_entry_id <=> OLD.reversal_of_entry_id)
       OR NOT (NEW.created_at <=> OLD.created_at) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger entry identity cannot change';
    END IF;

    IF NEW.status <> 'POSTED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only DRAFT to POSTED is allowed';
    END IF;

    SELECT COALESCE(SUM(CASE WHEN ll.direction = 'DEBIT' THEN ll.amount ELSE 0 END), 0),
           COALESCE(SUM(CASE WHEN ll.direction = 'CREDIT' THEN ll.amount ELSE 0 END), 0),
           COUNT(*),
           COALESCE(SUM(CASE WHEN ll.currency <> NEW.currency OR wa.currency <> NEW.currency THEN 1 ELSE 0 END), 0)
    INTO debit_total, credit_total, line_count, bad_currency
    FROM `ledger_lines` ll
    JOIN `wallet_accounts` wa ON wa.wallet_account_id = ll.wallet_account_id
    WHERE ll.ledger_entry_id = OLD.ledger_entry_id;

    IF line_count < 2 OR debit_total <= 0 OR debit_total <> credit_total OR bad_currency > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ledger requires balanced same-currency lines';
    END IF;
END$$

CREATE TRIGGER `trg_finance_audit_no_update` BEFORE UPDATE ON `finance_audit_logs`
FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Finance audit log is append-only';
END$$

CREATE TRIGGER `trg_finance_audit_no_delete` BEFORE DELETE ON `finance_audit_logs`
FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Finance audit log is append-only';
END$$

DELIMITER ;

