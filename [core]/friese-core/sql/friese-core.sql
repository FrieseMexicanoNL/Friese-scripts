CREATE TABLE IF NOT EXISTS `friese_characters` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(20) NOT NULL,
  `identifier` VARCHAR(80) NOT NULL,
  `slot` TINYINT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `money` LONGTEXT NOT NULL,
  `charinfo` LONGTEXT NOT NULL,
  `job` LONGTEXT NOT NULL,
  `metadata` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_seen` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_friese_citizenid` (`citizenid`),
  UNIQUE KEY `uq_friese_identifier_slot` (`identifier`, `slot`),
  KEY `idx_friese_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
