CREATE TABLE IF NOT EXISTS friese_meos_reports (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 target_citizenid VARCHAR(64) NOT NULL,
 officer_citizenid VARCHAR(64) NOT NULL,
 title VARCHAR(100) NOT NULL,
 body TEXT NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id), KEY idx_meos_target (target_citizenid), KEY idx_meos_officer (officer_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
