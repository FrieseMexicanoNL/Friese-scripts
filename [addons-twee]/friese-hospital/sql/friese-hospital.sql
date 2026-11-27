CREATE TABLE IF NOT EXISTS friese_medical_records (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 medic_citizenid VARCHAR(64) NOT NULL,
 patient_citizenid VARCHAR(64) NOT NULL,
 treatment VARCHAR(1200) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id), KEY idx_medical_patient (patient_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
ALTER TABLE friese_medical_records MODIFY treatment VARCHAR(1200) NOT NULL;
