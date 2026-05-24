CREATE DATABASE IF NOT EXISTS college_attendance;
USE college_attendance;

-- Admins Table (For Super Admin and Admin)
CREATE TABLE IF NOT EXISTS admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Hashed password
    role ENUM('SuperAdmin', 'Admin') DEFAULT 'Admin',
    profile_photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Teacher Table
CREATE TABLE IF NOT EXISTS teacher (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL, -- Hashed password
    department VARCHAR(100),
    year INT,
    section VARCHAR(10),
    is_approved BOOLEAN DEFAULT FALSE,
    profile_photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coordinator Table
CREATE TABLE IF NOT EXISTS coordinator (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id INT NOT NULL,
    department VARCHAR(100),
    section VARCHAR(10),
    year INT,
    FOREIGN KEY (teacher_id) REFERENCES teacher(id) ON DELETE CASCADE
);

-- Student Table
CREATE TABLE IF NOT EXISTS student (
    id INT AUTO_INCREMENT PRIMARY KEY,
    roll_no VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL, -- Auto-generated DOB format (hashed)
    address TEXT,
    department VARCHAR(100),
    year INT,
    section VARCHAR(10),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    profile_photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subject Table
CREATE TABLE IF NOT EXISTS subject (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    year INT,
    teacher_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teacher(id) ON DELETE SET NULL
);

-- Attendance Table
CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    status ENUM('Present', 'Absent', 'Leave') NOT NULL,
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_locked BOOLEAN DEFAULT FALSE, -- Locked after submission
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subject(id) ON DELETE CASCADE,
    UNIQUE KEY uc_student_subject_date (student_id, subject_id, (DATE(date_time)))
);

-- Leave Application Table
CREATE TABLE IF NOT EXISTS leave_application (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    reason TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    declaration BOOLEAN DEFAULT FALSE,
    proof_path VARCHAR(255), -- File path for uploaded PDF/Image
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    applied_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
);

-- Defaulter List Table
CREATE TABLE IF NOT EXISTS defaulter_list (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    attendance_percentage DECIMAL(5,2) NOT NULL,
    generated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subject(id) ON DELETE CASCADE
);

-- INSERT SAMPLE DATA --
-- Super Admin (Password: admin123, hashed using BCrypt)
INSERT INTO admin (name, email, password, role) 
VALUES ('Super Admin', 'super@college.edu', '$2a$12$r/vnu8AObAl42J.sZdDzZO9xKjdm2p81xR24heAL7ZrWAxkdaf7zC', 'SuperAdmin')
ON DUPLICATE KEY UPDATE name=name;

-- Sample Teacher (Password: teacher123, hashed)
INSERT INTO teacher (name, email, phone, password, department, year, section, is_approved)
VALUES ('John Doe', 'john.doe@college.edu', '1234567890', '$2a$12$dE7f5f.X8N2P8JvA9J.2Ue3O.7L7y.X8Y9L8V9W9V.X8Y9L8V9W9V', 'Computer Science', 2, 'A', TRUE);

-- Sample Student (DOB: 15082002 -> Password: 15082002 hashed)
INSERT INTO student (roll_no, name, email, phone, password, department, year, section)
VALUES ('CS202001', 'Alice Smith', 'alice@student.edu', '0987654321', '$2a$12$z2P.X8N2P8JvA9J.2Ue3O.7L7y.X8Y9L8V9W9V.X8Y9L8V9W9V.X8Y', 'Computer Science', 2, 'A');

-- Sample Subject
INSERT INTO subject (subject_code, name, department, year, teacher_id)
VALUES ('CS201', 'Data Structures', 'Computer Science', 2, 1);
