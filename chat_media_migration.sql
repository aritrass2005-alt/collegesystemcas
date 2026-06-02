-- MySQL 8.0 compatible migration: add media columns to chat_message
USE college_attendance;

DROP PROCEDURE IF EXISTS add_chat_media_columns;

DELIMITER //
CREATE PROCEDURE add_chat_media_columns()
BEGIN
    -- Add message_type column if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'chat_message'
          AND COLUMN_NAME = 'message_type'
    ) THEN
        ALTER TABLE chat_message ADD COLUMN message_type VARCHAR(20) DEFAULT 'text';
    END IF;

    -- Add file_url column if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'chat_message'
          AND COLUMN_NAME = 'file_url'
    ) THEN
        ALTER TABLE chat_message ADD COLUMN file_url VARCHAR(500) DEFAULT NULL;
    END IF;

    -- Add file_name column if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'chat_message'
          AND COLUMN_NAME = 'file_name'
    ) THEN
        ALTER TABLE chat_message ADD COLUMN file_name VARCHAR(255) DEFAULT NULL;
    END IF;

    -- Backfill existing rows
    UPDATE chat_message SET message_type = 'text' WHERE message_type IS NULL;
END //
DELIMITER ;

CALL add_chat_media_columns();
DROP PROCEDURE IF EXISTS add_chat_media_columns;

SELECT 'Migration complete!' AS status;
