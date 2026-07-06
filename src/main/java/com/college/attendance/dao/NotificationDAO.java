package com.college.attendance.dao;

import com.college.attendance.model.Notification;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean sendNotificationToRole(String senderName, String senderRole, int receiverId, String receiverRole, String title, String message, String attachmentPath) {
        String query = "INSERT INTO notification (sender_name, sender_role, receiver_id, receiver_role, title, message, attachment_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setString(1, senderName);
            ps.setString(2, senderRole);
            ps.setInt(3, receiverId);
            ps.setString(4, receiverRole);
            ps.setString(5, title);
            ps.setString(6, message);
            ps.setString(7, attachmentPath);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean sendNotification(String senderName, String senderRole, int receiverId, String title, String message, String attachmentPath) {
        return sendNotificationToRole(senderName, senderRole, receiverId, "Student", title, message, attachmentPath);
    }

    public List<Notification> getNotificationsForStudent(int studentId) {
        List<Notification> list = new ArrayList<>();
        String query = "SELECT * FROM notification WHERE receiver_id = ? AND (receiver_role = 'Student' OR receiver_role IS NULL) ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getInt("id"));
                n.setSenderName(rs.getString("sender_name"));
                n.setSenderRole(rs.getString("sender_role"));
                n.setReceiverId(rs.getInt("receiver_id"));
                n.setTitle(rs.getString("title"));
                n.setMessage(rs.getString("message"));
                n.setAttachmentPath(rs.getString("attachment_path"));
                n.setRead(rs.getBoolean("is_read"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Notification> getNotificationsForTeacher(int teacherId) {
        List<Notification> list = new ArrayList<>();
        String query = "SELECT * FROM notification WHERE receiver_id = ? AND receiver_role = 'Teacher' ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getInt("id"));
                n.setSenderName(rs.getString("sender_name"));
                n.setSenderRole(rs.getString("sender_role"));
                n.setReceiverId(rs.getInt("receiver_id"));
                n.setTitle(rs.getString("title"));
                n.setMessage(rs.getString("message"));
                n.setAttachmentPath(rs.getString("attachment_path"));
                n.setRead(rs.getBoolean("is_read"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean markAsRead(int notificationId, int studentId) {
        String query = "UPDATE notification SET is_read = TRUE WHERE id = ? AND receiver_id = ? AND (receiver_role = 'Student' OR receiver_role IS NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, notificationId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAsReadForTeacher(int notificationId, int teacherId) {
        String query = "UPDATE notification SET is_read = TRUE WHERE id = ? AND receiver_id = ? AND receiver_role = 'Teacher'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, notificationId);
            ps.setInt(2, teacherId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getUnreadCount(int studentId) {
        String query = "SELECT COUNT(*) FROM notification WHERE receiver_id = ? AND is_read = FALSE AND (receiver_role = 'Student' OR receiver_role IS NULL)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getUnreadCountForTeacher(int teacherId) {
        String query = "SELECT COUNT(*) FROM notification WHERE receiver_id = ? AND is_read = FALSE AND receiver_role = 'Teacher'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
