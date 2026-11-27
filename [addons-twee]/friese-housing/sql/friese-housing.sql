CREATE TABLE IF NOT EXISTS `friese_houses` (
 `property_id` VARCHAR(64) NOT NULL, `citizenid` VARCHAR(64) NOT NULL, `label` VARCHAR(120) NOT NULL,
 `purchase_price` INT UNSIGNED NOT NULL DEFAULT 0, `purchased_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`property_id`), KEY `idx_house_owner` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS `friese_house_keys` (
 `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, `property_id` VARCHAR(64) NOT NULL,
 `citizenid` VARCHAR(64) NOT NULL, `granted_by` VARCHAR(64) NOT NULL,
 `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`),
 UNIQUE KEY `uniq_house_key` (`property_id`,`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
