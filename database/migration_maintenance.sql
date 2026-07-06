-- ============================================================
-- CAS Migration: System Maintenance Mode Settings
-- Run ONCE in your database
-- ============================================================

-- Step 1. Create system_settings table
CREATE TABLE IF NOT EXISTS system_settings (
    setting_key VARCHAR(50) PRIMARY KEY,
    setting_value VARCHAR(255) NOT NULL
);

-- Step 2. Initialize maintenance_mode to false
INSERT INTO system_settings (setting_key, setting_value) 
VALUES ('maintenance_mode', 'false') 
ON DUPLICATE KEY UPDATE setting_key=setting_key;
