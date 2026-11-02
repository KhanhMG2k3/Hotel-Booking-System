-- Iteration 3: Refund tracking & host management enhancements
ALTER TABLE refunds ADD COLUMN IF NOT EXISTS customer_bank_info VARCHAR(255) NULL;
ALTER TABLE refunds ADD COLUMN IF NOT EXISTS host_note VARCHAR(500) NULL;

