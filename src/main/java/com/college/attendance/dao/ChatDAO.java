package com.college.attendance.dao;

import com.college.attendance.model.ChatGroup;
import com.college.attendance.model.ChatMessage;
import com.college.attendance.model.ChatParticipant;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class ChatDAO {

    public ChatGroup getGroupForDepartment(String department) {
        String sql = "SELECT * FROM chat_group WHERE department = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, department);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    ChatGroup g = new ChatGroup();
                    g.setId(rs.getInt("id"));
                    g.setDepartment(rs.getString("department"));
                    g.setAdminId(rs.getInt("admin_id"));
                    g.setCreatedAt(rs.getTimestamp("created_at"));
                    return g;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public ChatGroup createGroup(String department, int adminId) {
        String sql = "INSERT INTO chat_group (department, admin_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, department);
            stmt.setInt(2, adminId);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    ChatGroup g = new ChatGroup();
                    g.setId(rs.getInt(1));
                    g.setDepartment(department);
                    g.setAdminId(adminId);
                    return g;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addParticipant(int groupId, String userType, int userId) {
        String sql = "INSERT INTO chat_participant (group_id, user_type, user_id) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE joined_at=CURRENT_TIMESTAMP";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, groupId);
            stmt.setString(2, userType);
            stmt.setInt(3, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ChatParticipant> getParticipants(int groupId) {
        List<ChatParticipant> list = new ArrayList<>();
        String sql = "SELECT p.*, (k.encrypted_symmetric_key IS NOT NULL) as has_key " +
                     "FROM chat_participant p " +
                     "LEFT JOIN group_keys k ON p.group_id = k.group_id AND p.user_type = k.user_type AND p.user_id = k.user_id " +
                     "WHERE p.group_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, groupId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ChatParticipant p = new ChatParticipant();
                    p.setGroupId(rs.getInt("group_id"));
                    p.setUserType(rs.getString("user_type"));
                    p.setUserId(rs.getInt("user_id"));
                    p.setJoinedAt(rs.getTimestamp("joined_at"));
                    p.setHasKey(rs.getBoolean("has_key"));
                    
                    // Fetch details dynamically based on user type
                    if ("Admin".equals(p.getUserType())) {
                        p.setName(getUserName("admin", p.getUserId()));
                        p.setDetails("Administrator");
                    } else if ("Teacher".equals(p.getUserType()) || "Coordinator".equals(p.getUserType())) {
                        p.setName(getUserName("teacher", p.getUserId()));
                        p.setDetails(getTeacherDetails(p.getUserId()));
                    }
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String getUserName(String table, int id) {
        return getUserNamePublic(table, id);
    }

    public String getUserNamePublic(String table, int id) {
        String sql = "SELECT name FROM " + table + " WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getString("name");
            }
        } catch (Exception e) {}
        return "Unknown";
    }

    private String getTeacherDetails(int teacherId) {
        StringBuilder details = new StringBuilder();
        String sql = "SELECT name, year, department FROM subject WHERE teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while(rs.next()) {
                    if (details.length() > 0) details.append(", ");
                    details.append(rs.getString("name"))
                           .append(" (Yr ").append(rs.getInt("year")).append(")");
                }
            }
        } catch (Exception e) {}
        return details.length() > 0 ? "Teaches: " + details.toString() : "Faculty Member";
    }

    public boolean storePublicKey(String userType, int userId, String publicKey) {
        String sql = "INSERT INTO user_public_keys (user_type, user_id, public_key) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE public_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, userType);
            stmt.setInt(2, userId);
            stmt.setString(3, publicKey);
            stmt.setString(4, publicKey);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getPublicKey(String userType, int userId) {
        String sql = "SELECT public_key FROM user_public_keys WHERE user_id = ?";
        if ("Admin".equals(userType) || "SuperAdmin".equals(userType)) {
            sql += " AND user_type = 'Admin'";
        } else {
            sql += " AND user_type IN ('Teacher', 'Coordinator')";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getString("public_key");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean storeGroupKey(int groupId, String userType, int userId, String encryptedKey) {
        String sql = "INSERT INTO group_keys (group_id, user_type, user_id, encrypted_symmetric_key) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE encrypted_symmetric_key = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, groupId);
            stmt.setString(2, userType);
            stmt.setInt(3, userId);
            stmt.setString(4, encryptedKey);
            stmt.setString(5, encryptedKey);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getGroupKey(int groupId, String userType, int userId) {
        String sql = "SELECT encrypted_symmetric_key FROM group_keys WHERE group_id = ? AND user_id = ?";
        if ("Admin".equals(userType) || "SuperAdmin".equals(userType)) {
            sql += " AND user_type = 'Admin'";
        } else {
            sql += " AND user_type IN ('Teacher', 'Coordinator')";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, groupId);
            stmt.setInt(2, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getString("encrypted_symmetric_key");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public ChatMessage saveMessage(int groupId, String senderType, int senderId, String encryptedContent, String iv) {
        String sql = "INSERT INTO chat_message (group_id, sender_type, sender_id, encrypted_content, iv, message_type) VALUES (?, ?, ?, ?, ?, 'text')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, groupId);
            stmt.setString(2, senderType);
            stmt.setInt(3, senderId);
            stmt.setString(4, encryptedContent);
            stmt.setString(5, iv);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    ChatMessage msg = new ChatMessage();
                    msg.setId(rs.getInt(1));
                    msg.setGroupId(groupId);
                    msg.setSenderType(senderType);
                    msg.setSenderId(senderId);
                    msg.setEncryptedContent(encryptedContent);
                    msg.setIv(iv);
                    msg.setMessageType("text");
                    return msg;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public ChatMessage saveFileMessage(int groupId, String senderType, int senderId, String msgType, String fileUrl, String fileName) {
        String sql = "INSERT INTO chat_message (group_id, sender_type, sender_id, encrypted_content, iv, message_type, file_url, file_name) VALUES (?, ?, ?, '', '', ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, groupId);
            stmt.setString(2, senderType);
            stmt.setInt(3, senderId);
            stmt.setString(4, msgType);
            stmt.setString(5, fileUrl);
            stmt.setString(6, fileName);
            stmt.executeUpdate();
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    ChatMessage msg = new ChatMessage();
                    msg.setId(rs.getInt(1));
                    msg.setGroupId(groupId);
                    msg.setSenderType(senderType);
                    msg.setSenderId(senderId);
                    msg.setMessageType(msgType);
                    msg.setFileUrl(fileUrl);
                    msg.setFileName(fileName);
                    return msg;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ChatMessage> getMessages(int groupId, int limit) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM chat_message WHERE group_id = ? ORDER BY timestamp DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, groupId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                // Detect which columns actually exist (in case migration hasn't run)
                java.sql.ResultSetMetaData meta = rs.getMetaData();
                boolean hasMessageType = false, hasFileUrl = false, hasFileName = false;
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    String col = meta.getColumnName(i).toLowerCase();
                    if (col.equals("message_type")) hasMessageType = true;
                    if (col.equals("file_url")) hasFileUrl = true;
                    if (col.equals("file_name")) hasFileName = true;
                }
                while (rs.next()) {
                    ChatMessage msg = new ChatMessage();
                    msg.setId(rs.getInt("id"));
                    msg.setGroupId(rs.getInt("group_id"));
                    msg.setSenderType(rs.getString("sender_type"));
                    msg.setSenderId(rs.getInt("sender_id"));
                    msg.setEncryptedContent(rs.getString("encrypted_content"));
                    msg.setIv(rs.getString("iv"));
                    msg.setTimestamp(rs.getTimestamp("timestamp"));
                    msg.setMessageType(hasMessageType ? rs.getString("message_type") : "text");
                    msg.setFileUrl(hasFileUrl ? rs.getString("file_url") : null);
                    msg.setFileName(hasFileName ? rs.getString("file_name") : null);
                    list.add(0, msg); // Prepend to order chronologically
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Populate sender names
        for (ChatMessage msg : list) {
            String table = "Admin".equals(msg.getSenderType()) ? "admin" : "teacher";
            msg.setSenderName(getUserName(table, msg.getSenderId()));
            if ("Admin".equals(msg.getSenderType())) {
                msg.setSenderDetails("Administrator");
            } else {
                msg.setSenderDetails(getTeacherDetails(msg.getSenderId()));
            }
        }
        return list;
    }

    public List<ChatGroup> getUserGroups(String userType, int userId) {
        List<ChatGroup> groups = new ArrayList<>();
        String sql = "SELECT g.* FROM chat_group g JOIN chat_participant p ON g.id = p.group_id WHERE p.user_id = ?";
        if ("Admin".equals(userType) || "SuperAdmin".equals(userType)) {
            sql += " AND p.user_type = 'Admin'";
        } else {
            sql += " AND p.user_type IN ('Teacher', 'Coordinator')";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while(rs.next()) {
                    ChatGroup g = new ChatGroup();
                    g.setId(rs.getInt("id"));
                    g.setDepartment(rs.getString("department"));
                    g.setAdminId(rs.getInt("admin_id"));
                    g.setCreatedAt(rs.getTimestamp("created_at"));
                    groups.add(g);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return groups;
    }

    public boolean deleteMessage(int messageId, String userType, int userId, boolean isAdmin) {
        String sql = isAdmin ? "DELETE FROM chat_message WHERE id = ?" 
                             : "DELETE FROM chat_message WHERE id = ? AND sender_type = ? AND sender_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, messageId);
            if (!isAdmin) {
                stmt.setString(2, userType);
                stmt.setInt(3, userId);
            }
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteGroup(int groupId) {
        String sql = "DELETE FROM chat_group WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, groupId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Clears ALL group keys for this user across all groups.
     * Called when the user regenerates their RSA key pair so admins can re-share.
     */
    public boolean clearAllUserGroupKeys(String userType, int userId) {
        String sql;
        if ("Admin".equals(userType) || "SuperAdmin".equals(userType)) {
            sql = "DELETE FROM group_keys WHERE user_id = ? AND user_type = 'Admin'";
        } else {
            sql = "DELETE FROM group_keys WHERE user_id = ? AND user_type IN ('Teacher', 'Coordinator')";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
