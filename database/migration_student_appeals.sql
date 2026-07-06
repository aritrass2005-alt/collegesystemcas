-- ============================================================
-- CAS Migration: Student Attendance Recheck Appeals
-- Run ONCE in your database
-- ============================================================

-- Step 1. Add student appeal columns to attendance table
ALTER TABLE attendance 
ADD COLUMN student_appeal_status VARCHAR(20) DEFAULT NULL,
ADD COLUMN student_appeal_reason TEXT DEFAULT NULL,
ADD COLUMN student_appeal_remarks TEXT DEFAULT NULL;

-- Step 2. Add receiver_role column to notification table
ALTER TABLE notification 
ADD COLUMN receiver_role VARCHAR(20) DEFAULT 'Student';
