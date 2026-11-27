CREATE TABLE IF NOT EXISTS `friese_invoices` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `issuer_citizenid` VARCHAR(64) NOT NULL,
  `target_citizenid` VARCHAR(64) NOT NULL,
  `amount` INT UNSIGNED NOT NULL,
  `description` VARCHAR(180) NOT NULL,
  `category` VARCHAR(40) NOT NULL DEFAULT 'general',
  `status` ENUM('unpaid','paid','cancelled') NOT NULL DEFAULT 'unpaid',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `due_at` DATETIME NULL,
  `paid_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  KEY `idx_target_status` (`target_citizenid`,`status`),
  KEY `idx_issuer` (`issuer_citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
