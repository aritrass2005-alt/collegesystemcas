package com.college.attendance.dao;

import com.college.attendance.model.ParentAlertLog;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ParentAlertLogDAO {

    public boolean logAlert(ParentAlertLog log) {
        String sql = "INSERT INTO parent_alert_log (student_id, parent_name, parent_email, parent_phone, alert_type, subject, message, status, sender_name, sender_role) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, log.getStudentId());
            stmt.setString(2, log.getParentName());
            stmt.setString(3, log.getParentEmail());
            stmt.setString(4, log.getParentPhone());
            stmt.setString(5, log.getAlertType());
            stmt.setString(6, log.getSubject());
            stmt.setString(7, log.getMessage());
            stmt.setString(8, log.getStatus());
            stmt.setString(9, log.getSenderName());
            stmt.setString(10, log.getSenderRole());
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ParentAlertLog> getAllLogs() {
        List<ParentAlertLog> list = new ArrayList<>();
        String sql = "SELECT l.*, s.name as student_name, s.roll_no as student_roll_no " +
                     "FROM parent_alert_log l " +
                     "JOIN student s ON l.student_id = s.id " +
                     "ORDER BY l.sent_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
             
            while (rs.next()) {
                ParentAlertLog log = new ParentAlertLog();
                log.setId(rs.getInt("id"));
                log.setStudentId(rs.getInt("student_id"));
                log.setParentName(rs.getString("parent_name"));
                log.setParentEmail(rs.getString("parent_email"));
                log.setParentPhone(rs.getString("parent_phone"));
                log.setAlertType(rs.getString("alert_type"));
                log.setSubject(rs.getString("subject"));
                log.setMessage(rs.getString("message"));
                log.setStatus(rs.getString("status"));
                log.setSenderName(rs.getString("sender_name"));
                log.setSenderRole(rs.getString("sender_role"));
                log.setSentAt(rs.getTimestamp("sent_at"));
                log.setStudentName(rs.getString("student_name"));
                log.setStudentRollNo(rs.getString("student_roll_no"));
                list.add(log);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ParentAlertLog> getLogsByTeacher(String senderName) {
        List<ParentAlertLog> list = new ArrayList<>();
        String sql = "SELECT l.*, s.name as student_name, s.roll_no as student_roll_no " +
                     "FROM parent_alert_log l " +
                     "JOIN student s ON l.student_id = s.id " +
                     "WHERE l.sender_name = ? " +
                     "ORDER BY l.sent_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, senderName);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ParentAlertLog log = new ParentAlertLog();
                    log.setId(rs.getInt("id"));
                    log.setStudentId(rs.getInt("student_id"));
                    log.setParentName(rs.getString("parent_name"));
                    log.setParentEmail(rs.getString("parent_email"));
                    log.setParentPhone(rs.getString("parent_phone"));
                    log.setAlertType(rs.getString("alert_type"));
                    log.setSubject(rs.getString("subject"));
                    log.setMessage(rs.getString("message"));
                    log.setStatus(rs.getString("status"));
                    log.setSenderName(rs.getString("sender_name"));
                    log.setSenderRole(rs.getString("sender_role"));
                    log.setSentAt(rs.getTimestamp("sent_at"));
                    log.setStudentName(rs.getString("student_name"));
                    log.setStudentRollNo(rs.getString("student_roll_no"));
                    list.add(log);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
