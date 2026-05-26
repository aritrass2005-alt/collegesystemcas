package com.college.attendance.dao;

import com.college.attendance.model.FacultyAttendance;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class FacultyAttendanceDAO {

    public boolean checkIn(int teacherId) {
        String sql = "INSERT INTO faculty_attendance (teacher_id, date, check_in_time, status) VALUES (?, CURDATE(), CURTIME(), 'Present')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean checkOut(int teacherId) {
        String sql = "UPDATE faculty_attendance SET check_out_time = CURTIME() WHERE teacher_id = ? AND date = CURDATE() AND check_out_time IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public FacultyAttendance getTodayAttendance(int teacherId) {
        String sql = "SELECT * FROM faculty_attendance WHERE teacher_id = ? AND date = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToFacultyAttendance(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<FacultyAttendance> getHistoryByTeacher(int teacherId) {
        List<FacultyAttendance> list = new ArrayList<>();
        String sql = "SELECT * FROM faculty_attendance WHERE teacher_id = ? ORDER BY date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToFacultyAttendance(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<FacultyAttendance> getAllFacultyAttendance(Date targetDate, String department) {
        List<FacultyAttendance> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT fa.*, t.name as teacher_name, t.department as teacher_department, t.email as teacher_email " +
            "FROM faculty_attendance fa " +
            "JOIN teacher t ON fa.teacher_id = t.id " +
            "WHERE 1=1 "
        );

        if (targetDate != null) {
            sql.append(" AND fa.date = ? ");
        }
        if (department != null && !department.isEmpty()) {
            sql.append(" AND t.department = ? ");
        }
        sql.append(" ORDER BY fa.date DESC, t.name ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (targetDate != null) {
                stmt.setDate(paramIndex++, targetDate);
            }
            if (department != null && !department.isEmpty()) {
                stmt.setString(paramIndex++, department);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    FacultyAttendance fa = mapRowToFacultyAttendance(rs);
                    fa.setTeacherName(rs.getString("teacher_name"));
                    fa.setTeacherDepartment(rs.getString("teacher_department"));
                    fa.setTeacherEmail(rs.getString("teacher_email"));
                    list.add(fa);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateAttendanceByAdmin(int id, String status, String notes) {
        String sql = "UPDATE faculty_attendance SET status = ?, admin_notes = ?, verified_by_admin = 1 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, notes);
            stmt.setInt(3, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private FacultyAttendance mapRowToFacultyAttendance(ResultSet rs) throws Exception {
        FacultyAttendance fa = new FacultyAttendance();
        fa.setId(rs.getInt("id"));
        fa.setTeacherId(rs.getInt("teacher_id"));
        fa.setDate(rs.getDate("date"));
        fa.setCheckInTime(rs.getTime("check_in_time"));
        fa.setCheckOutTime(rs.getTime("check_out_time"));
        fa.setStatus(rs.getString("status"));
        fa.setVerifiedByAdmin(rs.getBoolean("verified_by_admin"));
        fa.setAdminNotes(rs.getString("admin_notes"));
        return fa;
    }
}
