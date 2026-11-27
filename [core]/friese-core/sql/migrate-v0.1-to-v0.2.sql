-- Run ONLY after friese-core.sql has created friese_characters.
-- This copies existing v0.1.0 player rows into slot 1. It does not delete the old table.
INSERT IGNORE INTO `friese_characters`
  (`citizenid`, `identifier`, `slot`, `name`, `money`, `charinfo`, `job`, `metadata`, `created_at`, `last_seen`)
SELECT
  `citizenid`, `identifier`, 1, `name`, `money`, `charinfo`, `job`, `metadata`, `created_at`, `last_seen`
FROM `friese_players`;
