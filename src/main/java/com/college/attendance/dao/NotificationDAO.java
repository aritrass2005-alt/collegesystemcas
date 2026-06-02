package com.college.attendance.dao;

import com.college.attendance.model.Notification;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean sendNotification(String senderName, String senderRole, int receiverId, String receiverType, String title, String message, String attachmentPath) {
        String query = "INSERT INTO notification (sender_name, sender_role, receiver_id, receiver_type, title, message, attachment_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setString(1, senderName);
            ps.setString(2, senderRole);
            ps.setInt(3, receiverId);
            ps.setString(4, receiverType);
            ps.setString(5, title);
            ps.setString(6, message);
            ps.setString(7, attachmentPath);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Notification> getNotificationsForUser(int receiverId, String receiverType) {
        List<Notification> list = new ArrayList<>();
        String query = "SELECT * FROM notification WHERE receiver_id = ? AND receiver_type = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, receiverId);
            ps.setString(2, receiverType);
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

    public boolean markAsRead(int notificationId, int receiverId, String receiverType) {
        String query = "UPDATE notification SET is_read = TRUE WHERE id = ? AND receiver_id = ? AND receiver_type = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, notificationId);
            ps.setInt(2, receiverId);
            ps.setString(3, receiverType);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getUnreadCount(int receiverId, String receiverType) {
        String query = "SELECT COUNT(*) FROM notification WHERE receiver_id = ? AND receiver_type = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, receiverId);
            ps.setString(2, receiverType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean deleteAllNotificationsForUser(int receiverId, String receiverType) {
        String query = "DELETE FROM notification WHERE receiver_id = ? AND receiver_type = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setInt(1, receiverId);
            ps.setString(2, receiverType);
            return ps.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
