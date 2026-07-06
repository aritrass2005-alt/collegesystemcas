package com.college.attendance.dao;

import com.college.attendance.model.Attendance;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.college.attendance.model.AttendanceSummary;
import com.college.attendance.model.DefaulterRecord;

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

    public boolean isAttendanceSubmittedForStudents(int subjectId, List<Integer> studentIds, String dateString) {
        if (studentIds == null || studentIds.isEmpty()) return false;
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < studentIds.size(); i++) {
            placeholders.append("?");
            if (i < studentIds.size() - 1) placeholders.append(",");
        }
        String sql = "SELECT COUNT(*) FROM attendance WHERE subject_id = ? AND DATE(date_time) = ? AND student_id IN (" + placeholders.toString() + ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, subjectId);
            stmt.setString(2, dateString);
            int idx = 3;
            for (int id : studentIds) {
                stmt.setInt(idx++, id);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<AttendanceSummary> getStudentAttendanceSummary(int studentId) {
        List<AttendanceSummary> summaryList = new ArrayList<>();
        String sql = "SELECT s.subject_code, s.name AS subject_name, " +
                     "SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END) AS total_classes, " +
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
        String sql = "SELECT a.id, a.student_id, a.subject_id, a.status, a.date_time, a.is_locked, a.appeal_status, a.admin_edited, s.name as student_name, s.roll_no " +
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
                    a.setAppealStatus(rs.getString("appeal_status"));
                    a.setAdminEdited(rs.getBoolean("admin_edited"));
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

    public List<Attendance> getPendingAppeals() {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.id, a.student_id, a.subject_id, a.status, a.date_time, a.is_locked, a.appeal_status, a.admin_edited, " +
                     "s.name as student_name, s.roll_no, sub.name as subject_name, sub.subject_code, " +
                     "t.name as teacher_name " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "JOIN subject sub ON a.subject_id = sub.id " +
                     "JOIN teacher t ON sub.teacher_id = t.id " +
                     "WHERE a.appeal_status = 'Pending' " +
                     "ORDER BY a.date_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attendance a = new Attendance();
                    a.setId(rs.getInt("id"));
                    a.setStudentId(rs.getInt("student_id"));
                    a.setSubjectId(rs.getInt("subject_id"));
                    a.setStatus(rs.getString("status"));
                    a.setDateTime(rs.getTimestamp("date_time"));
                    a.setLocked(rs.getBoolean("is_locked"));
                    a.setAppealStatus(rs.getString("appeal_status"));
                    a.setAdminEdited(rs.getBoolean("admin_edited"));
                    a.setStudentName(rs.getString("student_name"));
                    a.setStudentRollNo(rs.getString("roll_no"));
                    // Store subject info in unused fields temporarily
                    a.setSubjectName(rs.getString("subject_name"));
                    a.setSubjectCode(rs.getString("subject_code"));
                    a.setTeacherName(rs.getString("teacher_name"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean approveAppeal(int id) {
        String sql = "UPDATE attendance SET appeal_status = 'Approved' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean rejectAppeal(int id) {
        String sql = "UPDATE attendance SET appeal_status = 'Rejected' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean requestAppeal(int id) {
        String sql = "UPDATE attendance SET appeal_status = 'Pending' WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAttendanceAndResolveAppeal(int id, String status) {
        String sql = "UPDATE attendance SET status = ?, appeal_status = NULL WHERE id = ?";
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

    public boolean updateAttendanceByAdmin(int id, String status) {
        String sql = "UPDATE attendance SET status = ?, appeal_status = NULL, admin_edited = TRUE, is_locked = TRUE WHERE id = ?";
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

    public Attendance getAttendanceById(int id) {
        String sql = "SELECT a.id, a.student_id, a.subject_id, a.status, a.date_time, a.is_locked, a.appeal_status, a.admin_edited, " +
                     "a.student_appeal_status, a.student_appeal_reason, a.student_appeal_remarks, s.name as student_name, s.roll_no " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "WHERE a.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Attendance a = new Attendance();
                    a.setId(rs.getInt("id"));
                    a.setStudentId(rs.getInt("student_id"));
                    a.setSubjectId(rs.getInt("subject_id"));
                    a.setStatus(rs.getString("status"));
                    a.setDateTime(rs.getTimestamp("date_time"));
                    a.setLocked(rs.getBoolean("is_locked"));
                    a.setAppealStatus(rs.getString("appeal_status"));
                    a.setAdminEdited(rs.getBoolean("admin_edited"));
                    a.setStudentName(rs.getString("student_name"));
                    a.setStudentRollNo(rs.getString("roll_no"));
                    a.setStudentAppealStatus(rs.getString("student_appeal_status"));
                    a.setStudentAppealReason(rs.getString("student_appeal_reason"));
                    a.setStudentAppealRemarks(rs.getString("student_appeal_remarks"));
                    return a;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean markLeaveDays(int studentId, String startDate, String endDate) {
        String sql = "UPDATE attendance SET status = 'Leave' WHERE student_id = ? AND status = 'Absent' AND DATE(date_time) >= ? AND DATE(date_time) <= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            stmt.setString(2, startDate);
            stmt.setString(3, endDate);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getStudentCountForTeacher(int teacherId) {
        String sql = "SELECT COUNT(DISTINCT s.id) " +
                     "FROM student s " +
                     "JOIN subject sub ON s.department = sub.department AND s.year = sub.year " +
                     "WHERE sub.teacher_id = ? AND (sub.section IS NULL OR sub.section = '' OR s.section = sub.section) AND s.status = 'Active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getDefaulterCountForTeacher(int teacherId, double threshold) {
        String sql = "SELECT COUNT(DISTINCT student_id) FROM (" +
                     "    SELECT student_id, " +
                     "           SUM(CASE WHEN status IN ('Present', 'Absent') THEN 1 ELSE 0 END) as total, " +
                     "           SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as attended " +
                     "    FROM attendance " +
                     "    WHERE subject_id IN (SELECT id FROM subject WHERE teacher_id = ?) " +
                     "    GROUP BY student_id, subject_id " +
                     "    HAVING (SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Present', 'Absent') THEN 1 ELSE 0 END), 0)) * 100 < ?" +
                     ") as defaulters";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            stmt.setDouble(2, threshold);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getAverageAttendanceForTeacher(int teacherId) {
        String sql = "SELECT " +
                     "  (SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN status IN ('Present', 'Absent') THEN 1 ELSE 0 END), 0)) * 100 " +
                     "FROM attendance " +
                     "WHERE subject_id IN (SELECT id FROM subject WHERE teacher_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble(1);
                    return Math.round(avg * 100.0) / 100.0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public List<DefaulterRecord> getDefaultersForTeacher(int teacherId, double threshold, String startDate, String endDate) {
        List<DefaulterRecord> list = new ArrayList<>();
        boolean hasDateFilter = startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty();
        String dateFilter = hasDateFilter ? " AND DATE(a.date_time) >= ? AND DATE(a.date_time) <= ? " : "";

        String sql = "SELECT s.id AS student_id, s.roll_no, s.name AS student_name, s.section AS student_section, s.department AS student_dept, " +
                     "       sub.subject_code, sub.name AS subject_name, " +
                     "       SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END) AS total_classes, " +
                     "       SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended_classes " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "JOIN subject sub ON a.subject_id = sub.id " +
                     "WHERE sub.teacher_id = ? " + dateFilter +
                     "GROUP BY s.id, s.roll_no, s.name, s.section, s.department, sub.id, sub.subject_code, sub.name " +
                     "HAVING (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END), 0)) * 100 < ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            stmt.setInt(paramIndex++, teacherId);
            if (hasDateFilter) {
                stmt.setString(paramIndex++, startDate);
                stmt.setString(paramIndex++, endDate);
            }
            stmt.setDouble(paramIndex++, threshold);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DefaulterRecord record = new DefaulterRecord();
                    record.setStudentId(rs.getInt("student_id"));
                    record.setStudentRollNo(rs.getString("roll_no"));
                    record.setStudentName(rs.getString("student_name"));
                    record.setStudentSection(rs.getString("student_section"));
                    record.setStudentDepartment(rs.getString("student_dept"));
                    record.setSubjectCode(rs.getString("subject_code"));
                    record.setSubjectName(rs.getString("subject_name"));
                    record.setTotalClasses(rs.getInt("total_classes"));
                    record.setAttendedClasses(rs.getInt("attended_classes"));
                    
                    double pct = ((double) record.getAttendedClasses() / record.getTotalClasses()) * 100.0;
                    record.setPercentage(Math.round(pct * 100.0) / 100.0);
                    
                    list.add(record);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<DefaulterRecord> getDefaultersForCoordinator(int coordinatorTeacherId, double threshold, String startDate, String endDate) {
        List<DefaulterRecord> list = new ArrayList<>();
        boolean hasDateFilter = startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty();
        String dateFilter = hasDateFilter ? " AND DATE(a.date_time) >= ? AND DATE(a.date_time) <= ? " : "";

        // Overall attendance for all subjects for students under the coordinator's assigned sections
        String sql = "SELECT s.id AS student_id, s.roll_no, s.name AS student_name, s.section AS student_section, s.department AS student_dept, " +
                     "       SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END) AS total_classes, " +
                     "       SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended_classes " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "JOIN coordinator c ON s.department = c.department AND s.year = c.year " +
                     "AND (c.section IS NULL OR c.section = '' OR s.section = c.section) " +
                     "WHERE c.teacher_id = ? " + dateFilter +
                     "GROUP BY s.id, s.roll_no, s.name, s.section, s.department " +
                     "HAVING (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END), 0)) * 100 < ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            stmt.setInt(paramIndex++, coordinatorTeacherId);
            if (hasDateFilter) {
                stmt.setString(paramIndex++, startDate);
                stmt.setString(paramIndex++, endDate);
            }
            stmt.setDouble(paramIndex++, threshold);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DefaulterRecord record = new DefaulterRecord();
                    record.setStudentId(rs.getInt("student_id"));
                    record.setStudentRollNo(rs.getString("roll_no"));
                    record.setStudentName(rs.getString("student_name"));
                    record.setStudentSection(rs.getString("student_section"));
                    record.setStudentDepartment(rs.getString("student_dept"));
                    record.setSubjectCode("OVERALL");
                    record.setSubjectName("All Subjects");
                    record.setTotalClasses(rs.getInt("total_classes"));
                    record.setAttendedClasses(rs.getInt("attended_classes"));
                    
                    double pct = ((double) record.getAttendedClasses() / record.getTotalClasses()) * 100.0;
                    record.setPercentage(Math.round(pct * 100.0) / 100.0);
                    
                    list.add(record);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<AttendanceSummary> getMonthWiseAttendance(int studentId) {
        List<AttendanceSummary> summaryList = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(a.date_time, '%Y-%m') AS month_year, " +
                     "SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END) AS total_classes, " +
                     "SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended_classes " +
                     "FROM attendance a " +
                     "WHERE a.student_id = ? " +
                     "GROUP BY DATE_FORMAT(a.date_time, '%Y-%m') ORDER BY month_year DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AttendanceSummary summary = new AttendanceSummary();
                    summary.setSubjectName(rs.getString("month_year"));
                    summary.setTotalClasses(rs.getInt("total_classes"));
                    summary.setAttendedClasses(rs.getInt("attended_classes"));
                    if (summary.getTotalClasses() > 0) {
                        double pct = ((double) summary.getAttendedClasses() / summary.getTotalClasses()) * 100.0;
                        summary.setPercentage(Math.round(pct * 100.0) / 100.0);
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

    public List<Attendance> getStudentAttendanceHistory(int studentId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, s.name as subject_name, s.subject_code FROM attendance a " +
                     "JOIN subject s ON a.subject_id = s.id " +
                     "WHERE a.student_id = ? ORDER BY a.date_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Attendance a = new Attendance();
                    a.setId(rs.getInt("id"));
                    a.setSubjectId(rs.getInt("subject_id"));
                    a.setStatus(rs.getString("status"));
                    a.setDateTime(rs.getTimestamp("date_time"));
                    a.setSubjectName(rs.getString("subject_name"));
                    a.setSubjectCode(rs.getString("subject_code"));
                    a.setStudentName(rs.getString("subject_name")); // Maintain legacy hack support
                    a.setStudentAppealStatus(rs.getString("student_appeal_status"));
                    a.setStudentAppealReason(rs.getString("student_appeal_reason"));
                    a.setStudentAppealRemarks(rs.getString("student_appeal_remarks"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<DefaulterRecord> getDefaultersForSection(String department, int year, String section, double threshold) {
        List<DefaulterRecord> list = new ArrayList<>();
        String sql = "SELECT s.id AS student_id, s.roll_no, s.name AS student_name, " +
                     "       SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END) AS total_classes, " +
                     "       SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS attended_classes " +
                     "FROM student s " +
                     "JOIN attendance a ON a.student_id = s.id " +
                     "WHERE s.department = ? AND s.year = ? AND (s.section = ? OR ? IS NULL OR ? = '') " +
                     "GROUP BY s.id, s.roll_no, s.name " +
                     "HAVING (SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / NULLIF(SUM(CASE WHEN a.status IN ('Present', 'Absent') THEN 1 ELSE 0 END), 0)) * 100 < ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, department);
            stmt.setInt(2, year);
            stmt.setString(3, section);
            stmt.setString(4, section);
            stmt.setString(5, section);
            stmt.setDouble(6, threshold);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DefaulterRecord record = new DefaulterRecord();
                    record.setStudentId(rs.getInt("student_id"));
                    record.setStudentRollNo(rs.getString("roll_no"));
                    record.setStudentName(rs.getString("student_name"));
                    record.setTotalClasses(rs.getInt("total_classes"));
                    record.setAttendedClasses(rs.getInt("attended_classes"));
                    double pct = record.getTotalClasses() > 0 ? ((double) record.getAttendedClasses() / record.getTotalClasses()) * 100.0 : 0.0;
                    record.setPercentage(Math.round(pct * 100.0) / 100.0);
                    list.add(record);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public double getStudentAttendancePercentage(int studentId) {
        String sql = "SELECT SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS attended, " +
                     "SUM(CASE WHEN status IN ('Present', 'Absent') THEN 1 ELSE 0 END) AS total " +
                     "FROM attendance WHERE student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int attended = rs.getInt("attended");
                    int total = rs.getInt("total");
                    if (total > 0) {
                        return ((double) attended / total) * 100.0;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 100.0; // Default if no classes
    }

    public boolean submitStudentAppeal(int attendanceId, String reason) {
        String sql = "UPDATE attendance SET student_appeal_status = 'Pending', student_appeal_reason = ?, student_appeal_remarks = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, reason);
            stmt.setInt(2, attendanceId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean verifyStudentAppeal(int attendanceId, String status, String remarks) {
        String sql = "UPDATE attendance SET student_appeal_status = ?, student_appeal_remarks = ? " +
                     ("Approved".equalsIgnoreCase(status) ? ", status = 'Present' " : "") + 
                     "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, remarks);
            stmt.setInt(3, attendanceId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Attendance> getPendingStudentAppealsForTeacher(int teacherId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, s.name as student_name, s.roll_no, sub.name as subject_name, sub.subject_code " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "JOIN subject sub ON a.subject_id = sub.id " +
                     "WHERE sub.teacher_id = ? AND a.student_appeal_status = 'Pending' " +
                     "ORDER BY a.date_time DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
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
                    a.setSubjectName(rs.getString("subject_name"));
                    a.setSubjectCode(rs.getString("subject_code"));
                    a.setStudentAppealStatus(rs.getString("student_appeal_status"));
                    a.setStudentAppealReason(rs.getString("student_appeal_reason"));
                    a.setStudentAppealRemarks(rs.getString("student_appeal_remarks"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Attendance> getStudentAppealHistoryForTeacher(int teacherId) {
        List<Attendance> list = new ArrayList<>();
        String sql = "SELECT a.*, s.name as student_name, s.roll_no, sub.name as subject_name, sub.subject_code " +
                     "FROM attendance a " +
                     "JOIN student s ON a.student_id = s.id " +
                     "JOIN subject sub ON a.subject_id = sub.id " +
                     "WHERE sub.teacher_id = ? AND a.student_appeal_status IN ('Approved', 'Rejected') " +
                     "ORDER BY a.resolved_at DESC, a.date_time DESC"; // resolves resolvesresolve resolving Resolving resolved resolved_at Resolve resolves Resolved resolved
        // Wait, resolved_at is not in the attendance table! Our migration added only:
        // student_appeal_status, student_appeal_reason, student_appeal_remarks.
        // Let's order by date_time DESC instead. Yes! That is extremely safe and doesn't require resolved_at.
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.replace("ORDER BY a.resolved_at DESC, a.date_time DESC", "ORDER BY a.date_time DESC"))) {
            stmt.setInt(1, teacherId);
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
                    a.setSubjectName(rs.getString("subject_name"));
                    a.setSubjectCode(rs.getString("subject_code"));
                    a.setStudentAppealStatus(rs.getString("student_appeal_status"));
                    a.setStudentAppealReason(rs.getString("student_appeal_reason"));
                    a.setStudentAppealRemarks(rs.getString("student_appeal_remarks"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
