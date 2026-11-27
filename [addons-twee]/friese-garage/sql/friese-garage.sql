CREATE TABLE IF NOT EXISTS `friese_vehicles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(32) NOT NULL,
  `plate` VARCHAR(12) NOT NULL,
  `vehicle` VARCHAR(60) NOT NULL,
  `props` LONGTEXT NOT NULL,
  `garage` VARCHAR(40) NOT NULL DEFAULT 'legion',
  `state` TINYINT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`), UNIQUE KEY `uq_friese_plate` (`plate`), KEY `idx_friese_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
