USE college_attendance;

-- 1. Insert groups
INSERT IGNORE INTO chat_conversations (id, name, type, department_name, created_by_role, created_by_id, created_at)
SELECT id, CONCAT(department, ' Department'), 'DEPARTMENT', department, 'Admin', admin_id, created_at
FROM chat_group;

-- 2. Insert participants
INSERT IGNORE INTO chat_participants (conversation_id, user_role, user_id, joined_at)
SELECT group_id, user_type, user_id, joined_at
FROM chat_participant;

-- 3. Insert messages
INSERT IGNORE INTO chat_messages (id, conversation_id, sender_role, sender_id, encrypted_content, message_type, file_url, file_name, sent_at)
SELECT id, group_id, sender_type, sender_id, 
       IF(iv = '' OR iv IS NULL, IFNULL(encrypted_content, ''), REPLACE(TO_BASE64(CONCAT(FROM_BASE64(iv), FROM_BASE64(encrypted_content))), '\n', '')), 
       CASE message_type
           WHEN 'voice' THEN 'AUDIO'
           WHEN 'image' THEN 'PHOTO'
           WHEN 'text' THEN 'TEXT'
           ELSE 'TEXT'
       END,
       file_url, file_name, timestamp
FROM chat_message;
