CREATE TABLE IF NOT EXISTS friese_impound_records (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 plate VARCHAR(12) NOT NULL,
 owner_citizenid VARCHAR(32) NOT NULL,
 officer_citizenid VARCHAR(32) NOT NULL,
 reason VARCHAR(160) NOT NULL,
 fee INT UNSIGNED NOT NULL DEFAULT 0,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 released_at TIMESTAMP NULL DEFAULT NULL,
 PRIMARY KEY (id), KEY idx_impound_plate (plate), KEY idx_impound_owner (owner_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
