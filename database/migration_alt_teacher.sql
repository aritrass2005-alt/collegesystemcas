-- ============================================================
-- CAS Migration: Alt Teacher
-- Run ONCE in your database
-- ============================================================

-- Step 1. Add alternative teacher column to subject table
ALTER TABLE subject ADD COLUMN alt_teacher_id INT NULL;

-- Step 2. Add foreign key constraint
ALTER TABLE subject ADD CONSTRAINT fk_subject_alt_teacher FOREIGN KEY (alt_teacher_id) REFERENCES teacher(id) ON DELETE SET NULL;

-- Done! The Java code handles everything else automatically.
