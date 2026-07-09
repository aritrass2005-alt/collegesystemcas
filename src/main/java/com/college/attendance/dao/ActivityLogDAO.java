package com.college.attendance.dao;

import com.college.attendance.model.ActivityLog;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ActivityLogDAO {
    
    private static boolean tableChecked = false;

    private static void ensureTableExists() {
        if (tableChecked) return;
        String sql = "CREATE TABLE IF NOT EXISTS activity_log (" +
                     "id INT AUTO_INCREMENT PRIMARY KEY, " +
                     "user_type VARCHAR(50) NOT NULL, " +
                     "user_name VARCHAR(100) NOT NULL, " +
                     "action TEXT NOT NULL, " +
                     "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
            tableChecked = true;
        } catch (Exception e) {
            System.err.println("[ActivityLogDAO] Failed to create activity_log table: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void log(String userType, String userName, String action) {
        ensureTableExists();
        String sql = "INSERT INTO activity_log (user_type, user_name, action) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, userType);
            stmt.setString(2, userName);
            stmt.setString(3, action);
            stmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<ActivityLog> getRecentLogs(int limit) {
        ensureTableExists();
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM activity_log ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ActivityLog log = new ActivityLog();
                    log.setId(rs.getInt("id"));
                    log.setUserType(rs.getString("user_type"));
                    log.setUserName(rs.getString("user_name"));
                    log.setAction(rs.getString("action"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    logs.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return logs;
    }
}
