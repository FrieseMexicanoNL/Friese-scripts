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
