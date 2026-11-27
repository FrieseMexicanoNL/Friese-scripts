CREATE TABLE IF NOT EXISTS `friese_documents` (
 `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 `citizenid` VARCHAR(64) NOT NULL,
 `document_type` VARCHAR(32) NOT NULL,
 `status` VARCHAR(32) NOT NULL DEFAULT 'Geldig',
 `issued_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`id`), UNIQUE KEY `uniq_character_document` (`citizenid`,`document_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
