-- =====================================================================
-- F R I E S E - C O R E  |  COMPLETE DATABASE INSTALLER v1.7.0
-- One-file import for HeidiSQL / MariaDB / MySQL.
--
-- IMPORTANT:
-- 1) Select your intended database in HeidiSQL before importing.
-- 2) Back up your database first.
-- 3) This is an idempotent fresh-install schema pack (CREATE TABLE IF NOT EXISTS).
--    It does not delete existing data.
-- 4) Existing older tables are NOT automatically structurally upgraded by
--    CREATE TABLE IF NOT EXISTS. Existing installations may still need a
--    version-specific migration if their table columns differ.
-- 5) Legacy data-copy migrations are intentionally excluded because they
--    require old source tables and must not run blindly on every install.
--
-- Public job resources currently do not define additional SQL tables.
-- =====================================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- DATABASE-v1.4.0.sql
-- ============================================================
-- Friese-Core v1.4.0 additional tables. Backup database before importing.
CREATE TABLE IF NOT EXISTS friese_police_records (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, citizenid VARCHAR(64) NOT NULL, officer_citizenid VARCHAR(64) NOT NULL, record_type VARCHAR(32) NOT NULL, title VARCHAR(120) NOT NULL, details TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX idx_record_citizen(citizenid));
CREATE TABLE IF NOT EXISTS friese_dispatch_units (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, callsign VARCHAR(16) NOT NULL UNIQUE, citizenid VARCHAR(64) NOT NULL, department VARCHAR(32) NOT NULL, status VARCHAR(24) NOT NULL DEFAULT 'available', x DOUBLE NULL, y DOUBLE NULL, z DOUBLE NULL, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS friese_vehicle_service (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, plate VARCHAR(16) NOT NULL, citizenid VARCHAR(64) NOT NULL, service_type VARCHAR(40) NOT NULL, odometer INT NOT NULL DEFAULT 0, notes TEXT, mechanic_citizenid VARCHAR(64) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX idx_service_plate(plate));
CREATE TABLE IF NOT EXISTS friese_finance_contracts (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, citizenid VARCHAR(64) NOT NULL, plate VARCHAR(16) NOT NULL, principal INT NOT NULL, remaining INT NOT NULL, installment INT NOT NULL, next_due DATE NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'active', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS friese_keys (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, kind VARCHAR(16) NOT NULL, access_key VARCHAR(32) NOT NULL, citizenid VARCHAR(64) NOT NULL, granted_by VARCHAR(64) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), UNIQUE KEY unique_access(kind,access_key,citizenid));
CREATE TABLE IF NOT EXISTS friese_crafting_history (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, citizenid VARCHAR(64) NOT NULL, recipe VARCHAR(64) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS friese_shop_transactions (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, citizenid VARCHAR(64) NOT NULL, shop VARCHAR(64) NOT NULL, item VARCHAR(64) NOT NULL, amount INT NOT NULL, total INT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS friese_gang_members (citizenid VARCHAR(64) NOT NULL PRIMARY KEY, gang VARCHAR(64) NOT NULL, grade INT NOT NULL DEFAULT 0, joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, INDEX idx_gang(gang));

-- ============================================================
-- resources/[addons]/friese-business/sql/friese-business.sql
-- ============================================================
-- Bedrijfs- en werknemersadministratie gebruikt de jobgegevens in friese_characters.
-- Deze tabel reserveert een uitbreidbaar bedrijfsregister voor volgende releases.
CREATE TABLE IF NOT EXISTS friese_businesses (id INT UNSIGNED NOT NULL AUTO_INCREMENT, job_name VARCHAR(40) NOT NULL UNIQUE, label VARCHAR(80) NOT NULL, balance BIGINT NOT NULL DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id));

-- ============================================================
-- resources/[addons]/friese-clothing/sql/friese-clothing.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_outfits (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, citizenid VARCHAR(64) NOT NULL, name VARCHAR(40) NOT NULL, components LONGTEXT NOT NULL, props LONGTEXT NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), UNIQUE KEY citizen_outfit (citizenid,name));

-- ============================================================
-- resources/[addons]/friese-crafting/sql/friese-crafting.sql
-- ============================================================
-- Friese-Core v1.4.0
-- No additional tables required by this module.

-- ============================================================
-- resources/[addons]/friese-dealership/sql/friese-dealership.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_owned_vehicles (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, citizenid VARCHAR(64) NOT NULL, plate VARCHAR(8) NOT NULL, model VARCHAR(60) NOT NULL, vehicle LONGTEXT NOT NULL, stored TINYINT(1) NOT NULL DEFAULT 1, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), UNIQUE KEY(plate), INDEX(citizenid));

-- ============================================================
-- resources/[addons]/friese-dispatch/sql/friese-dispatch.sql
-- ============================================================
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

-- ============================================================
-- resources/[addons]/friese-documents/sql/friese-documents.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS `friese_documents` (
 `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 `citizenid` VARCHAR(64) NOT NULL,
 `document_type` VARCHAR(32) NOT NULL,
 `status` VARCHAR(32) NOT NULL DEFAULT 'Geldig',
 `issued_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`id`), UNIQUE KEY `uniq_character_document` (`citizenid`,`document_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- resources/[addons]/friese-garage/sql/friese-garage.sql
-- ============================================================
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

-- ============================================================
-- resources/[addons]/friese-hospital/sql/friese-hospital.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_medical_records (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 medic_citizenid VARCHAR(64) NOT NULL,
 patient_citizenid VARCHAR(64) NOT NULL,
 treatment VARCHAR(1200) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id), KEY idx_medical_patient (patient_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- resources/[addons]/friese-housing/sql/friese-housing.sql
-- ============================================================
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

-- ============================================================
-- resources/[addons]/friese-impound/sql/friese-impound.sql
-- ============================================================
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

-- ============================================================
-- resources/[addons]/friese-meos/sql/friese-meos.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_meos_reports (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 target_citizenid VARCHAR(64) NOT NULL,
 officer_citizenid VARCHAR(64) NOT NULL,
 title VARCHAR(100) NOT NULL,
 body TEXT NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id), KEY idx_meos_target (target_citizenid), KEY idx_meos_officer (officer_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- resources/[addons]/friese-phone/sql/friese-phone.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_phone_numbers (
  citizenid VARCHAR(64) NOT NULL PRIMARY KEY,
  phone_number VARCHAR(16) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS friese_phone_contacts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  owner_citizenid VARCHAR(64) NOT NULL,
  name VARCHAR(64) NOT NULL,
  phone_number VARCHAR(16) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_owner_number (owner_citizenid, phone_number),
  KEY idx_contacts_owner (owner_citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS friese_phone_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  sender_number VARCHAR(16) NOT NULL,
  receiver_number VARCHAR(16) NOT NULL,
  message VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_messages_pair (sender_number, receiver_number, id),
  KEY idx_messages_receiver (receiver_number, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS friese_phone_calls (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  caller_number VARCHAR(16) NOT NULL,
  receiver_number VARCHAR(16) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'missed',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_calls_number (caller_number, id), KEY idx_calls_receiver (receiver_number, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- resources/[addons]/friese-shops/sql/friese-shops.sql
-- ============================================================
-- Friese-Core v1.4.0
-- No additional tables required by this module.

-- ============================================================
-- resources/[addons]/friese-storage/sql/friese-storage.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS `friese_vehicle_storage` (
  `storage_key` varchar(32) NOT NULL,
  `items` longtext NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`storage_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- resources/[core]/friese-banking/sql/friese-banking.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_bank_transactions (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, sender_citizenid VARCHAR(64) NOT NULL, receiver_citizenid VARCHAR(64) NOT NULL, amount INT UNSIGNED NOT NULL, transaction_type VARCHAR(32) NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (id), INDEX idx_sender (sender_citizenid), INDEX idx_receiver (receiver_citizenid));

-- ============================================================
-- resources/[core]/friese-core/sql/friese-core.sql
-- ============================================================
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

-- ============================================================
-- resources/[core]/friese-integrations/sql/friese-integrations.sql
-- ============================================================
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

-- ============================================================
-- resources/[core]/friese-inventory/sql/friese-inventory.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS `friese_inventories` (
  `citizenid` VARCHAR(32) NOT NULL,
  `items` LONGTEXT NOT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- resources/[onderwereldjobs]/friese-gangs/sql/friese-gangs.sql
-- ============================================================
-- Friese-Core v1.4.0
-- No additional tables required by this module.

-- ============================================================
-- resources/[overheidjobs]/friese-mechanic/sql/friese-mechanic.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_vehicle_services (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, citizenid VARCHAR(64) NOT NULL, plate VARCHAR(16) NOT NULL, service_type VARCHAR(32) NOT NULL, cost INT UNSIGNED NOT NULL DEFAULT 0, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), INDEX(plate));

-- ============================================================
-- resources/[overheidjobs]/friese-police/sql/friese-police.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_police_fines (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, officer_citizenid VARCHAR(64) NOT NULL, target_citizenid VARCHAR(64) NOT NULL, amount INT UNSIGNED NOT NULL, reason VARCHAR(160) NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), INDEX(target_citizenid));
CREATE TABLE IF NOT EXISTS friese_police_actions (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, officer_citizenid VARCHAR(64) NOT NULL, target_citizenid VARCHAR(64) NOT NULL, action VARCHAR(40) NOT NULL, details TEXT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), INDEX(target_citizenid));

-- ============================================================
-- resources/[standalone]/friese-appearance/sql/friese-appearance.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS `friese_appearances` (
  `citizenid` varchar(32) NOT NULL,
  `appearance` longtext NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- resources/[standalone]/friese-logs/sql/friese-logs.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS friese_logs (id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, category VARCHAR(40) NOT NULL, actor VARCHAR(80) NOT NULL, message VARCHAR(500) NOT NULL, metadata JSON NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(id), INDEX idx_category(category), INDEX idx_created(created_at));

SET FOREIGN_KEY_CHECKS = 1;
-- Friese-Core v1.7.0 database schema import complete.
