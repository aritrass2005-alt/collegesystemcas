-- ============================================================
-- Chat System Migration (Department Version)
-- Run this against the college_attendance database
-- ============================================================

USE college_attendance;

-- Drop old tables if they exist to apply new schema
DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS chat_participants;
DROP TABLE IF EXISTS chat_conversations;
DROP TABLE IF EXISTS chat_files;

-- Conversations (1-on-1, Custom Group, or Department Group)
CREATE TABLE chat_conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) DEFAULT NULL,
    type ENUM('DIRECT', 'GROUP', 'DEPARTMENT') DEFAULT 'GROUP',
    department_name VARCHAR(100) DEFAULT NULL,
    created_by_role VARCHAR(20) NOT NULL,
    created_by_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Participants in each conversation
CREATE TABLE chat_participants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    user_role VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    last_read_message_id BIGINT DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE,
    UNIQUE KEY uc_conv_user (conversation_id, user_role, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Messages (stored encrypted)
CREATE TABLE chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender_role VARCHAR(20) NOT NULL,
    sender_id INT NOT NULL,
    encrypted_content TEXT NOT NULL,
    message_type ENUM('TEXT', 'SYSTEM', 'FILE', 'PHOTO', 'AUDIO') DEFAULT 'TEXT',
    file_url VARCHAR(255) DEFAULT NULL,
    file_name VARCHAR(255) DEFAULT NULL,
    is_edited TINYINT(1) DEFAULT 0,
    is_deleted TINYINT(1) DEFAULT 0,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES chat_conversations(id) ON DELETE CASCADE,
    INDEX idx_conv_time (conversation_id, sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Message deletions per user
CREATE TABLE chat_message_deletions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    message_id BIGINT NOT NULL,
    user_role VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (message_id) REFERENCES chat_messages(id) ON DELETE CASCADE,
    UNIQUE KEY uq_msg_del (message_id, user_role, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
