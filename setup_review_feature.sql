USE college_attendance;

-- Alter notification table to support other receiver types
ALTER TABLE notification DROP FOREIGN KEY notification_ibfk_1;
ALTER TABLE notification ADD COLUMN receiver_type ENUM('Student', 'Teacher', 'Admin') DEFAULT 'Student' AFTER receiver_id;

-- Create attendance_review table
CREATE TABLE IF NOT EXISTS attendance_review (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT,
    review_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('Pending', 'In Review', 'Approved', 'Rejected') DEFAULT 'Pending',
    coordinator_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subject(id) ON DELETE CASCADE,
    FOREIGN KEY (coordinator_id) REFERENCES teacher(id) ON DELETE SET NULL
);

-- Create review_chat table
CREATE TABLE IF NOT EXISTS review_chat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    sender_type ENUM('Student', 'Coordinator') NOT NULL,
    sender_id INT NOT NULL,
    message TEXT NOT NULL,
    proof_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES attendance_review(id) ON DELETE CASCADE
);
