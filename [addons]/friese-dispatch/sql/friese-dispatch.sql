CREATE TABLE IF NOT EXISTS `friese_dispatch_calls` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `caller_citizenid` VARCHAR(64) NOT NULL,
  `caller_name` VARCHAR(100) NOT NULL,
  `message` VARCHAR(240) NOT NULL,
  `category` VARCHAR(24) NOT NULL DEFAULT 'police',
  `x` DOUBLE NOT NULL, `y` DOUBLE NOT NULL, `z` DOUBLE NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` VARCHAR(20) NOT NULL DEFAULT 'open',
  `accepted_by` VARCHAR(64) NULL,
  `closed_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
