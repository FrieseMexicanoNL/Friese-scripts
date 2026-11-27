-- Bedrijfs- en werknemersadministratie gebruikt de jobgegevens in friese_characters.
-- Deze tabel reserveert een uitbreidbaar bedrijfsregister voor volgende releases.
CREATE TABLE IF NOT EXISTS friese_businesses (id INT UNSIGNED NOT NULL AUTO_INCREMENT, job_name VARCHAR(40) NOT NULL UNIQUE, label VARCHAR(80) NOT NULL, balance BIGINT NOT NULL DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id));
