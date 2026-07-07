USE college_attendance;

ALTER TABLE student 
ADD COLUMN is_profile_completed BOOLEAN DEFAULT FALSE,
ADD COLUMN is_parent_verified BOOLEAN DEFAULT FALSE;
