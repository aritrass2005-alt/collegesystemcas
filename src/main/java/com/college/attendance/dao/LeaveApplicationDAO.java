package com.college.attendance.dao;

import com.college.attendance.model.LeaveApplication;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class LeaveApplicationDAO {

    public boolean submitLeave(LeaveApplication leave) {
        String sql = "INSERT INTO leave_application (student_id, reason, start_date, end_date, declaration, proof_path, status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, leave.getStudentId());
            stmt.setString(2, leave.getReason());
            stmt.setString(3, leave.getStartDate());
            stmt.setString(4, leave.getEndDate());
            stmt.setBoolean(5, leave.isDeclaration());
            stmt.setString(6, leave.getProofPath());
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateLeaveStatus(int id, String status) {
        String sql = "UPDATE leave_application SET status = ? WHERE id = ?";
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
    public boolean deleteLeave(int id) {
        String sql = "DELETE FROM leave_application WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    public List<LeaveApplication> getLeavesByStudent(int studentId) {
        List<LeaveApplication> list = new ArrayList<>();
        String sql = "SELECT * FROM leave_application WHERE student_id = ? ORDER BY applied_on DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    LeaveApplication l = new LeaveApplication();
                    l.setId(rs.getInt("id"));
                    l.setStudentId(rs.getInt("student_id"));
                    l.setReason(rs.getString("reason"));
                    l.setStartDate(rs.getString("start_date"));
                    l.setEndDate(rs.getString("end_date"));
                    l.setDeclaration(rs.getBoolean("declaration"));
                    l.setProofPath(rs.getString("proof_path"));
                    l.setStatus(rs.getString("status"));
                    l.setAppliedOn(rs.getTimestamp("applied_on"));
                    list.add(l);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LeaveApplication> getLeavesForCoordinator(int coordinatorTeacherId) {
        List<LeaveApplication> list = new ArrayList<>();
        String sql = "SELECT l.*, s.name as student_name, s.roll_no, s.department, s.section, s.year " +
                     "FROM leave_application l " +
                     "JOIN student s ON l.student_id = s.id " +
                     "JOIN coordinator c ON s.department = c.department AND s.year = c.year " +
                     "AND (c.section IS NULL OR c.section = '' OR s.section = c.section) " +
                     "WHERE c.teacher_id = ? ORDER BY l.applied_on DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, coordinatorTeacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    LeaveApplication l = new LeaveApplication();
                    l.setId(rs.getInt("id"));
                    l.setStudentId(rs.getInt("student_id"));
                    l.setReason(rs.getString("reason"));
                    l.setStartDate(rs.getString("start_date"));
                    l.setEndDate(rs.getString("end_date"));
                    l.setDeclaration(rs.getBoolean("declaration"));
                    l.setProofPath(rs.getString("proof_path"));
                    l.setStatus(rs.getString("status"));
                    l.setAppliedOn(rs.getTimestamp("applied_on"));
                    
                    l.setStudentName(rs.getString("student_name"));
                    l.setStudentRollNo(rs.getString("roll_no"));
                    l.setStudentDepartment(rs.getString("department"));
                    l.setStudentSection(rs.getString("section"));
                    l.setStudentYear(rs.getInt("year"));
                    
                    list.add(l);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public LeaveApplication getLeaveById(int id) {
        String sql = "SELECT * FROM leave_application WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    LeaveApplication l = new LeaveApplication();
                    l.setId(rs.getInt("id"));
                    l.setStudentId(rs.getInt("student_id"));
                    l.setReason(rs.getString("reason"));
                    l.setStartDate(rs.getString("start_date"));
                    l.setEndDate(rs.getString("end_date"));
                    l.setDeclaration(rs.getBoolean("declaration"));
                    l.setProofPath(rs.getString("proof_path"));
                    l.setStatus(rs.getString("status"));
                    l.setAppliedOn(rs.getTimestamp("applied_on"));
                    return l;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
