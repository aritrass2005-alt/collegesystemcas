package com.college.attendance.dao;

import com.college.attendance.model.ChatConversation;
import com.college.attendance.model.ChatMessage;
import com.college.attendance.model.ChatParticipant;
import com.college.attendance.model.ChatPoll;
import com.college.attendance.model.ChatPollOption;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChatDAO {

    // Hardcoded global conversation ID for all staff (removed as per new architecture)

    /**
     * Get all allotted departments for a teacher (primary dept + any subject or coordinator dept).
     */
    public List<String> getAllottedDepartments(int teacherId) {
        List<String> depts = new ArrayList<>();
        String sql = "SELECT department FROM teacher WHERE id = ? AND department IS NOT NULL AND department != '' " +
                     "UNION " +
                     "SELECT department FROM subject WHERE (teacher_id = ? OR alt_teacher_id = ?) AND department IS NOT NULL AND department != '' " +
                     "UNION " +
                     "SELECT department FROM coordinator WHERE teacher_id = ? AND department IS NOT NULL AND department != ''";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setInt(2, teacherId);
            ps.setInt(3, teacherId);
            ps.setInt(4, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String d = rs.getString("department");
                if (d != null && !d.trim().isEmpty()) {
                    depts.add(d.trim());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return depts;
    }

    /**
     * Auto-provisions a teacher into every DEPARTMENT chat group that matches
     * any of their allotted departments (primary, subject, coordinator).
     * Safe to call on every login — uses INSERT IGNORE internally.
     */
    public void autoJoinAllDepartmentGroups(int teacherId) {
        String sql = "INSERT IGNORE INTO chat_participants (conversation_id, user_role, user_id) " +
                     "SELECT cc.id, 'Teacher', ? " +
                     "FROM chat_conversations cc " +
                     "WHERE cc.type = 'DEPARTMENT' " +
                     "AND cc.department_name IN (" +
                     "  SELECT department FROM teacher WHERE id = ? AND department IS NOT NULL AND department != '' " +
                     "  UNION " +
                     "  SELECT department FROM subject WHERE (teacher_id = ? OR alt_teacher_id = ?) AND department IS NOT NULL AND department != '' " +
                     "  UNION " +
                     "  SELECT department FROM coordinator WHERE teacher_id = ? AND department IS NOT NULL AND department != '' " +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ps.setInt(2, teacherId);
            ps.setInt(3, teacherId);
            ps.setInt(4, teacherId);
            ps.setInt(5, teacherId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /**
     * Get all departments from the database
     */
    public List<String> getAllDepartments() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT name FROM department ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get conversation ID for a given department group.
     */
    public int getDepartmentConversationId(String department) {
        String sql = "SELECT id FROM chat_conversations WHERE type = 'DEPARTMENT' AND department_name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, department);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Create a new Department Group and auto-add all faculty in that department.
     */
    public int createDepartmentGroup(String groupName, String department, String createdByRole, int createdById) {
        String sqlConv = "INSERT INTO chat_conversations (name, type, department_name, created_by_role, created_by_id) VALUES (?, 'DEPARTMENT', ?, ?, ?)";
        String sqlPart = "INSERT INTO chat_participants (conversation_id, user_role, user_id) VALUES (?, ?, ?)";
        String sqlTeachers = "SELECT DISTINCT t.id FROM teacher t " +
                             "LEFT JOIN subject s ON (s.teacher_id = t.id OR s.alt_teacher_id = t.id) " +
                             "LEFT JOIN coordinator c ON c.teacher_id = t.id " +
                             "WHERE (t.department = ? OR s.department = ? OR c.department = ?) " +
                             "AND t.is_approved = 1 AND t.is_banned = 0";
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sqlConv, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, groupName);
                ps.setString(2, department);
                ps.setString(3, createdByRole);
                ps.setInt(4, createdById);
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    int convId = keys.getInt(1);
                    
                    try (PreparedStatement psPart = conn.prepareStatement(sqlPart)) {
                        // Add Creator (Admin)
                        psPart.setInt(1, convId);
                        psPart.setString(2, createdByRole);
                        psPart.setInt(3, createdById);
                        psPart.addBatch();
                        
                        // Add all faculty from department
                        try (PreparedStatement psT = conn.prepareStatement(sqlTeachers)) {
                            psT.setString(1, department);
                            psT.setString(2, department);
                            psT.setString(3, department);
                            ResultSet rsT = psT.executeQuery();
                            while(rsT.next()) {
                                psPart.setInt(1, convId);
                                psPart.setString(2, "Teacher");
                                psPart.setInt(3, rsT.getInt("id"));
                                psPart.addBatch();
                            }
                        }
                        
                        // Execute batch inserts
                        psPart.executeBatch();
                    }
                    conn.commit();
                    return convId;
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Delete a conversation
     */
    public boolean deleteConversation(int conversationId) {
        String sql = "DELETE FROM chat_conversations WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get all conversations for a user, ordered by latest message time.
     */
    public List<ChatConversation> getConversationsForUser(String role, int userId) {
        List<ChatConversation> list = new ArrayList<>();
        String sql = "SELECT cc.*, " +
                     "(SELECT cm.encrypted_content FROM chat_messages cm WHERE cm.conversation_id = cc.id ORDER BY cm.sent_at DESC LIMIT 1) AS last_msg, " +
                     "(SELECT cm.message_type FROM chat_messages cm WHERE cm.conversation_id = cc.id ORDER BY cm.sent_at DESC LIMIT 1) AS last_msg_type, " +
                     "(SELECT cm.sent_at FROM chat_messages cm WHERE cm.conversation_id = cc.id ORDER BY cm.sent_at DESC LIMIT 1) AS last_msg_time, " +
                     "(SELECT COUNT(*) FROM chat_messages cm2 WHERE cm2.conversation_id = cc.id AND cm2.id > cp.last_read_message_id) AS unread_count " +
                     "FROM chat_conversations cc " +
                     "JOIN chat_participants cp ON cp.conversation_id = cc.id " +
                     "WHERE cp.user_role = ? AND cp.user_id = ? " +
                     "ORDER BY last_msg_time DESC, cc.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatConversation c = new ChatConversation();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setType(rs.getString("type"));
                c.setDepartmentName(rs.getString("department_name"));
                c.setCreatedByRole(rs.getString("created_by_role"));
                c.setCreatedById(rs.getInt("created_by_id"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                
                String lastMsg = rs.getString("last_msg");
                String lastMsgType = rs.getString("last_msg_type");
                if (lastMsgType != null && !lastMsgType.equals("TEXT") && !lastMsgType.equals("SYSTEM")) {
                    c.setLastMessage("[" + lastMsgType + "]");
                } else {
                    c.setLastMessage(lastMsg);
                }
                c.setLastMessageTime(rs.getTimestamp("last_msg_time"));
                c.setUnreadCount(rs.getInt("unread_count"));
                c.setDisplayName(c.getName() != null ? c.getName() : "Group Chat");
                c.setParticipants(getParticipants(c.getId()));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get participants of a conversation.
     */
    public List<ChatParticipant> getParticipants(int conversationId) {
        List<ChatParticipant> list = new ArrayList<>();
        String sql = "SELECT cp.*, " +
                     "COALESCE(" +
                     "  (SELECT t.name FROM teacher t WHERE t.id = cp.user_id AND (cp.user_role = 'Teacher' OR cp.user_role = 'Coordinator')), " +
                     "  (SELECT a.name FROM admin a WHERE a.id = cp.user_id AND (cp.user_role = 'Admin' OR cp.user_role = 'SuperAdmin'))" +
                     ") AS user_name, " +
                     "COALESCE(" +
                     "  (SELECT t.profile_photo FROM teacher t WHERE t.id = cp.user_id AND (cp.user_role = 'Teacher' OR cp.user_role = 'Coordinator')), " +
                     "  (SELECT a.profile_photo FROM admin a WHERE a.id = cp.user_id AND (cp.user_role = 'Admin' OR cp.user_role = 'SuperAdmin'))" +
                     ") AS profile_photo " +
                     "FROM chat_participants cp WHERE cp.conversation_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatParticipant p = new ChatParticipant();
                p.setId(rs.getInt("id"));
                p.setConversationId(rs.getInt("conversation_id"));
                p.setUserRole(rs.getString("user_role"));
                p.setUserId(rs.getInt("user_id"));
                p.setUserName(rs.getString("user_name"));
                p.setProfilePhoto(rs.getString("profile_photo"));
                p.setLastReadMessageId(rs.getLong("last_read_message_id"));
                p.setJoinedAt(rs.getTimestamp("joined_at"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Add a member to a conversation
     */
    public boolean addParticipant(int conversationId, String role, int userId) {
        String sql = "INSERT INTO chat_participants (conversation_id, user_role, user_id) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setString(2, role);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Add a member to a conversation by Email
     */
    public boolean addParticipantByEmail(int conversationId, String role, String email) {
        String query = "";
        if ("Teacher".equals(role)) {
            query = "SELECT id FROM teacher WHERE email = ?";
        } else if ("Coordinator".equals(role)) {
            query = "SELECT t.id FROM teacher t JOIN coordinator c ON t.id = c.teacher_id WHERE t.email = ?";
        } else if ("Admin".equals(role) || "SuperAdmin".equals(role)) {
            query = "SELECT id FROM admin WHERE email = ? AND role = ?";
        } else {
            return false;
        }

        int userId = -1;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            if ("Admin".equals(role) || "SuperAdmin".equals(role)) {
                ps.setString(2, role);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                userId = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (userId != -1) {
            return addParticipant(conversationId, role, userId);
        }
        return false;
    }

    /**
     * Check if user is participant
     */
    public boolean isParticipant(int conversationId, String role, int userId) {
        String sql = "SELECT 1 FROM chat_participants WHERE conversation_id = ? AND user_role = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setString(2, role);
            ps.setInt(3, userId);
            return ps.executeQuery().next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Save a message.
     */
    public long saveMessage(ChatMessage msg) {
        String sql = "INSERT INTO chat_messages (conversation_id, sender_role, sender_id, encrypted_content, message_type, file_url, file_name) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, msg.getConversationId());
            ps.setString(2, msg.getSenderRole());
            ps.setInt(3, msg.getSenderId());
            ps.setString(4, msg.getEncryptedContent());
            ps.setString(5, msg.getMessageType() != null ? msg.getMessageType() : "TEXT");
            ps.setString(6, msg.getFileUrl());
            ps.setString(7, msg.getFileName());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                long id = keys.getLong(1);
                // Also update sender's last read ID so they don't have unread on their own msg
                updateLastRead(msg.getConversationId(), msg.getSenderRole(), msg.getSenderId(), id);
                return id;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Edit an existing message.
     */
    public boolean editMessage(long messageId, String role, int userId, String newContent) {
        String sql = "UPDATE chat_messages SET encrypted_content = ?, is_edited = 1 WHERE id = ? AND sender_role = ? AND sender_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newContent);
            ps.setLong(2, messageId);
            ps.setString(3, role);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete a message for a specific user locally (Delete for Me).
     */
    public boolean deleteMessageForMe(long messageId, String role, int userId) {
        String sql = "INSERT IGNORE INTO chat_message_deletions (message_id, user_role, user_id) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, messageId);
            ps.setString(2, role);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Delete a message for everyone (Delete for Everyone).
     */
    public boolean deleteMessageForEveryone(long messageId, String role, int userId) {
        String sql;
        if ("SuperAdmin".equals(role)) {
            // SuperAdmin can delete anyone's messages
            sql = "UPDATE chat_messages SET encrypted_content = 'This message was deleted', message_type = 'SYSTEM', file_url = NULL, file_name = NULL, is_deleted = 1 WHERE id = ?";
        } else {
            // Others can only delete their own
            sql = "UPDATE chat_messages SET encrypted_content = 'This message was deleted', message_type = 'SYSTEM', file_url = NULL, file_name = NULL, is_deleted = 1 WHERE id = ? AND sender_role = ? AND sender_id = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, messageId);
            if (!"SuperAdmin".equals(role)) {
                ps.setString(2, role);
                ps.setInt(3, userId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update the last read message ID for a user in a conversation
     */
    public boolean updateLastRead(int conversationId, String role, int userId, long messageId) {
        String sql = "UPDATE chat_participants SET last_read_message_id = GREATEST(last_read_message_id, ?) WHERE conversation_id = ? AND user_role = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, messageId);
            ps.setInt(2, conversationId);
            ps.setString(3, role);
            ps.setInt(4, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Compute message status based on participants' lastReadMessageId
     */
    private String getMessageStatus(long messageId, int conversationId, Connection conn) throws SQLException {
        // Find total participants (excluding sender), and how many have read it
        String sql = "SELECT COUNT(*) as total, SUM(CASE WHEN last_read_message_id >= ? THEN 1 ELSE 0 END) as read_count FROM chat_participants WHERE conversation_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, messageId);
            ps.setInt(2, conversationId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int total = rs.getInt("total") - 1; // subtract sender
                int read = rs.getInt("read_count") - 1; 
                if (total <= 0) return "READ";
                if (read >= total) return "READ"; // Everyone read it
                if (read > 0) return "DELIVERED"; // Some read it (or we could say READ if one person read it, let's say DELIVERED)
                // If this was a real system with offline detection we'd distinguish SENT vs DELIVERED.
                // For now, if read == 0, it's DELIVERED to server.
                return "DELIVERED";
            }
        }
        return "SENT";
    }

    /**
     * Get messages for a conversation, filtering out locally deleted messages.
     */
    public List<ChatMessage> getMessages(int conversationId, int limit, int offset, String userRole, int userId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT m.*, " +
                     "COALESCE(" +
                     "  (SELECT t.name FROM teacher t WHERE t.id = m.sender_id AND m.sender_role = 'Teacher'), " +
                     "  (SELECT a.name FROM admin a WHERE a.id = m.sender_id AND (m.sender_role = 'Admin' OR m.sender_role = 'SuperAdmin'))" +
                     ") AS sender_name, " +
                     "COALESCE(" +
                     "  (SELECT t.profile_photo FROM teacher t WHERE t.id = m.sender_id AND m.sender_role = 'Teacher'), " +
                     "  (SELECT a.profile_photo FROM admin a WHERE a.id = m.sender_id AND (m.sender_role = 'Admin' OR m.sender_role = 'SuperAdmin'))" +
                     ") AS sender_photo " +
                     "FROM chat_messages m " +
                     "LEFT JOIN chat_message_deletions d ON d.message_id = m.id AND d.user_role = ? AND d.user_id = ? " +
                     "WHERE m.conversation_id = ? AND d.message_id IS NULL " +
                     "ORDER BY m.sent_at DESC LIMIT ? OFFSET ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userRole);
            ps.setInt(2, userId);
            ps.setInt(3, conversationId);
            ps.setInt(4, limit);
            ps.setInt(5, offset);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatMessage msg = new ChatMessage();
                msg.setId(rs.getLong("id"));
                msg.setConversationId(rs.getInt("conversation_id"));
                msg.setSenderRole(rs.getString("sender_role"));
                msg.setSenderId(rs.getInt("sender_id"));
                msg.setSenderName(rs.getString("sender_name"));
                msg.setSenderPhoto(rs.getString("sender_photo"));
                msg.setEncryptedContent(rs.getString("encrypted_content"));
                msg.setMessageType(rs.getString("message_type"));
                msg.setFileUrl(rs.getString("file_url"));
                msg.setFileName(rs.getString("file_name"));
                msg.setSentAt(rs.getTimestamp("sent_at"));
                msg.setEdited(rs.getBoolean("is_edited"));
                msg.setDeleted(rs.getBoolean("is_deleted"));
                
                // Compute status
                msg.setStatus(getMessageStatus(msg.getId(), msg.getConversationId(), conn));
                
                // Add to start since we ordered by DESC to get latest, but want chronological order in UI
                list.add(0, msg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ======================= POLL METHODS =======================

    /** Create a new poll with options. Returns poll id or -1 on failure. */
    public int createPoll(int conversationId, String question, List<String> options, String creatorRole, int creatorId) {
        String sqlPoll = "INSERT INTO chat_polls (conversation_id, question, created_by_role, created_by_id) VALUES (?, ?, ?, ?)";
        String sqlOpt = "INSERT INTO chat_poll_options (poll_id, option_text) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sqlPoll, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, conversationId);
                ps.setString(2, question);
                ps.setString(3, creatorRole);
                ps.setInt(4, creatorId);
                ps.executeUpdate();
                ResultSet keys = ps.getGeneratedKeys();
                if (keys.next()) {
                    int pollId = keys.getInt(1);
                    try (PreparedStatement psOpt = conn.prepareStatement(sqlOpt)) {
                        for (String opt : options) {
                            if (opt != null && !opt.trim().isEmpty()) {
                                psOpt.setInt(1, pollId);
                                psOpt.setString(2, opt.trim());
                                psOpt.addBatch();
                            }
                        }
                        psOpt.executeBatch();
                    }
                    conn.commit();
                    return pollId;
                }
            } catch (Exception e) { conn.rollback(); throw e; }
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }

    /** Get poll with options and vote counts for a specific user. */
    public ChatPoll getPoll(int pollId, String voterRole, int voterId) {
        String sqlPoll = "SELECT p.*, " +
            "(SELECT pv.option_id FROM chat_poll_votes pv WHERE pv.poll_id = p.id AND pv.voter_role = ? AND pv.voter_id = ?) AS my_vote " +
            "FROM chat_polls p WHERE p.id = ?";
        String sqlOpts = "SELECT o.*, COUNT(pv.id) AS vote_count FROM chat_poll_options o " +
            "LEFT JOIN chat_poll_votes pv ON pv.option_id = o.id GROUP BY o.id ORDER BY o.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPoll)) {
            ps.setString(1, voterRole);
            ps.setInt(2, voterId);
            ps.setInt(3, pollId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                ChatPoll poll = new ChatPoll();
                poll.setId(rs.getInt("id"));
                poll.setConversationId(rs.getInt("conversation_id"));
                poll.setQuestion(rs.getString("question"));
                poll.setCreatedByRole(rs.getString("created_by_role"));
                poll.setCreatedById(rs.getInt("created_by_id"));
                poll.setCreatedAt(rs.getTimestamp("created_at"));
                poll.setClosed(rs.getBoolean("is_closed"));
                int myVote = rs.getInt("my_vote");
                poll.setMyVotedOptionId(rs.wasNull() ? 0 : myVote);

                List<ChatPollOption> opts = new ArrayList<>();
                try (PreparedStatement psOpt = conn.prepareStatement(sqlOpts)) {
                    ResultSet rsOpt = psOpt.executeQuery();
                    // filter only options for this poll
                    String sqlOptsFiltered = "SELECT o.*, COUNT(pv.id) AS vote_count FROM chat_poll_options o " +
                        "LEFT JOIN chat_poll_votes pv ON pv.option_id = o.id WHERE o.poll_id = ? GROUP BY o.id ORDER BY o.id";
                    try (PreparedStatement psF = conn.prepareStatement(sqlOptsFiltered)) {
                        psF.setInt(1, pollId);
                        ResultSet rsF = psF.executeQuery();
                        while (rsF.next()) {
                            ChatPollOption opt = new ChatPollOption();
                            opt.setId(rsF.getInt("id"));
                            opt.setPollId(pollId);
                            opt.setOptionText(rsF.getString("option_text"));
                            opt.setVoteCount(rsF.getInt("vote_count"));
                            opts.add(opt);
                        }
                    }
                }
                poll.setOptions(opts);
                return poll;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /** Get all polls for a conversation. */
    public List<ChatPoll> getAllPolls(int conversationId, String voterRole, int voterId) {
        List<ChatPoll> polls = new ArrayList<>();
        String sqlPolls = "SELECT p.*, " +
            "(SELECT pv.option_id FROM chat_poll_votes pv WHERE pv.poll_id = p.id AND pv.voter_role = ? AND pv.voter_id = ?) AS my_vote " +
            "FROM chat_polls p WHERE p.conversation_id = ? ORDER BY p.created_at ASC";
            
        String sqlOpts = "SELECT o.*, COUNT(pv.id) AS vote_count FROM chat_poll_options o " +
            "LEFT JOIN chat_poll_votes pv ON pv.option_id = o.id WHERE o.poll_id = ? GROUP BY o.id ORDER BY o.id";
            
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlPolls)) {
            ps.setString(1, voterRole);
            ps.setInt(2, voterId);
            ps.setInt(3, conversationId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatPoll poll = new ChatPoll();
                poll.setId(rs.getInt("id"));
                poll.setConversationId(rs.getInt("conversation_id"));
                poll.setQuestion(rs.getString("question"));
                poll.setCreatedByRole(rs.getString("created_by_role"));
                poll.setCreatedById(rs.getInt("created_by_id"));
                poll.setCreatedAt(rs.getTimestamp("created_at"));
                poll.setClosed(rs.getBoolean("is_closed"));
                int myVote = rs.getInt("my_vote");
                poll.setMyVotedOptionId(rs.wasNull() ? 0 : myVote);

                List<ChatPollOption> opts = new ArrayList<>();
                try (PreparedStatement psOpt = conn.prepareStatement(sqlOpts)) {
                    psOpt.setInt(1, poll.getId());
                    ResultSet rsOpt = psOpt.executeQuery();
                    while (rsOpt.next()) {
                        ChatPollOption opt = new ChatPollOption();
                        opt.setId(rsOpt.getInt("id"));
                        opt.setPollId(poll.getId());
                        opt.setOptionText(rsOpt.getString("option_text"));
                        opt.setVoteCount(rsOpt.getInt("vote_count"));
                        opts.add(opt);
                    }
                }
                poll.setOptions(opts);
                polls.add(poll);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return polls;
    }

    /** Cast or change a vote on a poll. Returns false if poll is closed. */
    public boolean votePoll(int pollId, int optionId, String voterRole, int voterId) {
        // Check poll is still open and option belongs to poll
        String checkSql = "SELECT p.is_closed FROM chat_polls p JOIN chat_poll_options o ON o.poll_id = p.id WHERE p.id = ? AND o.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setInt(1, pollId);
            check.setInt(2, optionId);
            ResultSet rs = check.executeQuery();
            if (!rs.next() || rs.getBoolean("is_closed")) return false;
        } catch (Exception e) { e.printStackTrace(); return false; }

        // Upsert vote (replace old vote if any)
        String sql = "INSERT INTO chat_poll_votes (poll_id, option_id, voter_role, voter_id) VALUES (?, ?, ?, ?) " +
            "ON DUPLICATE KEY UPDATE option_id = VALUES(option_id)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pollId);
            ps.setInt(2, optionId);
            ps.setString(3, voterRole);
            ps.setInt(4, voterId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** Close a poll (only creator or SuperAdmin can close). */
    public boolean closePoll(int pollId, String requesterRole, int requesterId) {
        String sql;
        if ("SuperAdmin".equals(requesterRole) || "Admin".equals(requesterRole)) {
            sql = "UPDATE chat_polls SET is_closed = 1 WHERE id = ?";
        } else {
            sql = "UPDATE chat_polls SET is_closed = 1 WHERE id = ? AND created_by_role = ? AND created_by_id = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pollId);
            if (!"SuperAdmin".equals(requesterRole) && !"Admin".equals(requesterRole)) {
                ps.setString(2, requesterRole);
                ps.setInt(3, requesterId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ======================= PIN METHODS =======================

    /** Pin a message. Only Admins/SuperAdmins and Teachers can pin. Returns true on success. */
    public boolean pinMessage(int conversationId, long messageId, String pinnerRole, int pinnerId) {
        String sql = "INSERT IGNORE INTO chat_pinned_messages (conversation_id, message_id, pinned_by_role, pinned_by_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setLong(2, messageId);
            ps.setString(3, pinnerRole);
            ps.setInt(4, pinnerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** Unpin a message. */
    public boolean unpinMessage(int conversationId, long messageId) {
        String sql = "DELETE FROM chat_pinned_messages WHERE conversation_id = ? AND message_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setLong(2, messageId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    /** Get all pinned messages for a conversation (with decryptable content). */
    public List<ChatMessage> getPinnedMessages(int conversationId, String userRole, int userId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT m.*, pm.pinned_at, pm.pinned_by_role, pm.pinned_by_id, " +
            "COALESCE((SELECT t.name FROM teacher t WHERE t.id = m.sender_id AND m.sender_role = 'Teacher'), " +
            "(SELECT a.name FROM admin a WHERE a.id = m.sender_id AND (m.sender_role = 'Admin' OR m.sender_role = 'SuperAdmin'))) AS sender_name " +
            "FROM chat_pinned_messages pm JOIN chat_messages m ON m.id = pm.message_id " +
            "WHERE pm.conversation_id = ? ORDER BY pm.pinned_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ChatMessage msg = new ChatMessage();
                msg.setId(rs.getLong("id"));
                msg.setConversationId(rs.getInt("conversation_id"));
                msg.setSenderRole(rs.getString("sender_role"));
                msg.setSenderId(rs.getInt("sender_id"));
                msg.setSenderName(rs.getString("sender_name"));
                msg.setEncryptedContent(rs.getString("encrypted_content"));
                msg.setMessageType(rs.getString("message_type"));
                msg.setFileUrl(rs.getString("file_url"));
                msg.setFileName(rs.getString("file_name"));
                msg.setSentAt(rs.getTimestamp("sent_at"));
                msg.setEdited(rs.getBoolean("is_edited"));
                msg.setDeleted(rs.getBoolean("is_deleted"));
                list.add(msg);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /** Check if a message is pinned. */
    public boolean isPinned(int conversationId, long messageId) {
        String sql = "SELECT 1 FROM chat_pinned_messages WHERE conversation_id = ? AND message_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, conversationId);
            ps.setLong(2, messageId);
            return ps.executeQuery().next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}
