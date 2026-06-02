package com.college.attendance.dao;

import com.college.attendance.model.FacultyAttendance;
import com.college.attendance.model.Teacher;
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
        FacultyAttendance today = getTodayAttendance(teacherId);
        if (today != null) {
            String sql = "UPDATE faculty_attendance SET check_in_time = CURTIME(), status = 'Present' WHERE id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, today.getId());
                return stmt.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        } else {
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

    public List<FacultyAttendance> getPendingLeaves() {
        List<FacultyAttendance> list = new ArrayList<>();
        String sql = "SELECT fa.*, t.name as teacher_name, t.department as teacher_department, t.email as teacher_email " +
                     "FROM faculty_attendance fa " +
                     "JOIN teacher t ON fa.teacher_id = t.id " +
                     "WHERE fa.verified_by_admin = 0 " +
                     "ORDER BY fa.date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                FacultyAttendance fa = mapRowToFacultyAttendance(rs);
                fa.setTeacherName(rs.getString("teacher_name"));
                fa.setTeacherDepartment(rs.getString("teacher_department"));
                fa.setTeacherEmail(rs.getString("teacher_email"));
                list.add(fa);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean verifyAllPendingLeaves() {
        String sql = "UPDATE faculty_attendance SET verified_by_admin = 1 WHERE verified_by_admin = 0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            return stmt.executeUpdate() >= 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addAttendanceByAdmin(int teacherId, Date date, String status, String notes) {
        String sql = "INSERT INTO faculty_attendance (teacher_id, date, status, admin_notes, verified_by_admin) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            stmt.setDate(2, date);
            stmt.setString(3, status);
            stmt.setString(4, notes);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    public boolean deleteFacultyLeave(int id) {
        String sql = "DELETE FROM faculty_attendance WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public FacultyAttendance getAttendanceById(int id) {
        String sql = "SELECT * FROM faculty_attendance WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
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

    public boolean applyLeaveByFaculty(int teacherId, Date date, String status, String notes) {
        String sql = "INSERT INTO faculty_attendance (teacher_id, date, status, admin_notes, verified_by_admin) VALUES (?, ?, ?, ?, 0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            stmt.setDate(2, date);
            stmt.setString(3, status);
            stmt.setString(4, notes);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Teacher> getAbsentFaculty(Date targetDate, String department) {
        List<Teacher> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT t.* FROM teacher t " +
            "WHERE t.id NOT IN (" +
            "   SELECT teacher_id FROM faculty_attendance WHERE date = ?" +
            ") AND t.is_approved = 1 AND t.is_banned = 0 "
        );

        if (department != null && !department.isEmpty()) {
            sql.append(" AND t.department = ? ");
        }
        sql.append(" ORDER BY t.name ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            stmt.setDate(paramIndex++, targetDate);
            
            if (department != null && !department.isEmpty()) {
                stmt.setString(paramIndex++, department);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Teacher t = new Teacher();
                    t.setId(rs.getInt("id"));
                    t.setName(rs.getString("name"));
                    t.setEmail(rs.getString("email"));
                    t.setPhone(rs.getString("phone"));
                    t.setDepartment(rs.getString("department"));
                    t.setProfilePhoto(rs.getString("profile_photo"));
                    t.setApproved(rs.getBoolean("is_approved"));
                    t.setBanned(rs.getBoolean("is_banned"));
                    list.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
