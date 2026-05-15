package com.college.attendance.dao;

import com.college.attendance.model.Attendance;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.college.attendance.model.AttendanceSummary;

public class AttendanceDAO {

    public boolean submitAttendance(List<Attendance> records) {
        if (records == null || records.isEmpty()) return false;
        
        String sql = "INSERT INTO attendance (student_id, subject_id, status, is_locked) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            conn.setAutoCommit(false);
            
            for (Attendance record : records) {
                stmt.setInt(1, record.getStudentId());
                stmt.setInt(2, record.getSubjectId());
                stmt.setString(3, record.getStatus());
                stmt.setBoolean(4, false); // Locked later if requested, defaults to false on submit
                stmt.addBatch();
            }
            
            stmt.executeBatch();
            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<AttendanceSummary> getStudentAttendanceSummary(int studentId) {
        List<AttendanceSummary> summaryList = new ArrayList<>();
        String sql = "SELECT s.subject_code, s.name AS subject_name, " +
                     "COUNT(a.id) AS total_classes, " +
                     "SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended_classes, " +
                     "SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS missed_classes " +
                     "FROM attendance a " +
                     "JOIN subject s ON a.subject_id = s.id " +
                     "WHERE a.student_id = ? " +
                     "GROUP BY s.id, s.subject_code, s.name";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AttendanceSummary summary = new AttendanceSummary();
                    summary.setSubjectCode(rs.getString("subject_code"));
                    summary.setSubjectName(rs.getString("subject_name"));
                    summary.setTotalClasses(rs.getInt("total_classes"));
                    summary.setAttendedClasses(rs.getInt("attended_classes"));
                    summary.setMissedClasses(rs.getInt("missed_classes"));
                    
                    int total = summary.getTotalClasses();
                    if (total > 0) {
                        double percentage = ((double) summary.getAttendedClasses() / total) * 100.0;
                        summary.setPercentage(Math.round(percentage * 100.0) / 100.0); // round to 2 decimals
                    } else {
                        summary.setPercentage(0.0);
                    }
                    
                    summaryList.add(summary);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return summaryList;
    }

    public List<Attendance> getAttendanceBySubjectAndDate(int subjectId, String dateString) {
        List<Attendance> list = new ArrayList<>();
        // dateString expected in YYYY-MM-DD
        String sql = "SELECT a.id, a.student_id, a.subject_id, a.status, a.date_time, a.is_locked, s.name as student_name, s.roll_no " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "WHERE a.subject_id = ? AND DATE(a.date_time) = ?";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, subjectId);
            stmt.setString(2, dateString);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attendance a = new Attendance();
                    a.setId(rs.getInt("id"));
                    a.setStudentId(rs.getInt("student_id"));
                    a.setSubjectId(rs.getInt("subject_id"));
                    a.setStatus(rs.getString("status"));
                    a.setDateTime(rs.getTimestamp("date_time"));
                    a.setLocked(rs.getBoolean("is_locked"));
                    a.setStudentName(rs.getString("student_name"));
                    a.setStudentRollNo(rs.getString("roll_no"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateAttendanceStatus(int id, String status) {
        String sql = "UPDATE attendance SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
