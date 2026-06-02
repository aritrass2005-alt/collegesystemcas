USE college_attendance;

-- Chat System Tables
CREATE TABLE IF NOT EXISTS chat_group (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department VARCHAR(100) NOT NULL,
    admin_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admin(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chat_participant (
    group_id INT NOT NULL,
    user_type ENUM('Admin', 'Teacher', 'Coordinator') NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_type, user_id),
    FOREIGN KEY (group_id) REFERENCES chat_group(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_public_keys (
    user_type ENUM('Admin', 'Teacher', 'Coordinator') NOT NULL,
    user_id INT NOT NULL,
    public_key TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_type, user_id)
);

CREATE TABLE IF NOT EXISTS chat_message (
    id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    sender_type ENUM('Admin', 'Teacher', 'Coordinator') NOT NULL,
    sender_id INT NOT NULL,
    encrypted_content TEXT NOT NULL,
    iv TEXT NOT NULL, -- Initialization vector for AES-GCM
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES chat_group(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS group_keys (
    group_id INT NOT NULL,
    user_type ENUM('Admin', 'Teacher', 'Coordinator') NOT NULL,
    user_id INT NOT NULL,
    encrypted_symmetric_key TEXT NOT NULL,
    PRIMARY KEY (group_id, user_type, user_id),
    FOREIGN KEY (group_id) REFERENCES chat_group(id) ON DELETE CASCADE
);
