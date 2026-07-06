-- ============================================================
-- CAS Migration: Parent Notification System
-- Run ONCE in your database
-- ============================================================

-- Step 1. Add parent columns to student table
ALTER TABLE student 
ADD COLUMN parent_name VARCHAR(100) DEFAULT NULL,
ADD COLUMN parent_email VARCHAR(100) DEFAULT NULL,
ADD COLUMN parent_phone VARCHAR(20) DEFAULT NULL;

-- Step 2. Create parent_alert_log table
CREATE TABLE IF NOT EXISTS parent_alert_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    parent_name VARCHAR(100) NOT NULL,
    parent_email VARCHAR(100),
    parent_phone VARCHAR(20),
    alert_type VARCHAR(10) NOT NULL, -- 'EMAIL', 'SMS', 'BOTH'
    subject VARCHAR(255),
    message TEXT NOT NULL,
    status VARCHAR(15) DEFAULT 'SENT',
    sender_name VARCHAR(100) NOT NULL,
    sender_role VARCHAR(50) NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
);
