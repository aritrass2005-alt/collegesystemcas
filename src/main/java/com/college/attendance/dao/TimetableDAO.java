package com.college.attendance.dao;

import com.college.attendance.model.Timetable;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TimetableDAO {

    // ── Helper ─────────────────────────────────────────────────────────────────
    private Timetable mapRow(ResultSet rs) throws Exception {
        Timetable t = new Timetable();
        t.setId(rs.getInt("id"));
        t.setSubjectId(rs.getInt("subject_id"));
        t.setDayOfWeek(rs.getString("day_of_week"));
        t.setStartTime(rs.getTime("start_time"));
        t.setEndTime(rs.getTime("end_time"));
        t.setRoomNo(rs.getString("room_no"));
        try { t.setSubjectName(rs.getString("subject_name")); } catch (Exception ignored) {}
        try { t.setSubjectCode(rs.getString("subject_code")); } catch (Exception ignored) {}
        try { t.setDepartment(rs.getString("department")); } catch (Exception ignored) {}
        try { t.setYear(rs.getInt("year")); } catch (Exception ignored) {}
        try { t.setSection(rs.getString("section")); } catch (Exception ignored) {}
        try { t.setTeacherName(rs.getString("teacher_name")); } catch (Exception ignored) {}
        try { t.setTeacherId(rs.getInt("teacher_id")); } catch (Exception ignored) {}
        return t;
    }

    private static final String JOIN_SQL =
        "SELECT t.*, s.name as subject_name, s.subject_code, s.department, s.year, s.section, " +
        "       s.teacher_id, tc.name as teacher_name " +
        "FROM timetable t " +
        "JOIN subject s ON t.subject_id = s.id " +
        "LEFT JOIN teacher tc ON s.teacher_id = tc.id";

    // ── Create ─────────────────────────────────────────────────────────────────
    public boolean addTimetable(Timetable timetable) {
        String query = "INSERT INTO timetable (subject_id, day_of_week, start_time, end_time, room_no) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, timetable.getSubjectId());
            ps.setString(2, timetable.getDayOfWeek());
            ps.setTime(3, timetable.getStartTime());
            ps.setTime(4, timetable.getEndTime());
            ps.setString(5, timetable.getRoomNo());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Update ─────────────────────────────────────────────────────────────────
    public boolean updateTimetable(Timetable timetable) {
        String query = "UPDATE timetable SET subject_id = ?, day_of_week = ?, start_time = ?, end_time = ?, room_no = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, timetable.getSubjectId());
            ps.setString(2, timetable.getDayOfWeek());
            ps.setTime(3, timetable.getStartTime());
            ps.setTime(4, timetable.getEndTime());
            ps.setString(5, timetable.getRoomNo());
            ps.setInt(6, timetable.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Delete ─────────────────────────────────────────────────────────────────
    public boolean deleteTimetable(int id) {
        String query = "DELETE FROM timetable WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Delete by dept/year/section ────────────────────────────────────────────
    public boolean deleteTimetablesByGroup(String department, int year, String section) {
        String query = "DELETE FROM timetable WHERE subject_id IN " +
                       "(SELECT id FROM subject WHERE department = ? AND year = ? AND (section IS NULL OR section = '' OR section = ?))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, department);
            ps.setInt(2, year);
            ps.setString(3, section);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Read All ───────────────────────────────────────────────────────────────
    public List<Timetable> getAllTimetables() {
        List<Timetable> list = new ArrayList<>();
        String query = JOIN_SQL + " ORDER BY s.department, s.year, s.section, t.day_of_week, t.start_time";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Read filtered by dept/year/section ────────────────────────────────────
    public List<Timetable> getTimetablesByGroup(String department, int year, String section) {
        List<Timetable> list = new ArrayList<>();
        StringBuilder query = new StringBuilder(JOIN_SQL + " WHERE 1=1");
        if (department != null && !department.isEmpty()) query.append(" AND s.department = ?");
        if (year > 0) query.append(" AND s.year = ?");
        if (section != null && !section.isEmpty()) query.append(" AND (s.section IS NULL OR s.section = '' OR s.section = ?)");
        query.append(" ORDER BY t.day_of_week, t.start_time");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query.toString())) {
            int idx = 1;
            if (department != null && !department.isEmpty()) ps.setString(idx++, department);
            if (year > 0) ps.setInt(idx++, year);
            if (section != null && !section.isEmpty()) ps.setString(idx++, section);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Read for teacher ───────────────────────────────────────────────────────
    public List<Timetable> getTimetableForTeacher(int teacherId) {
        List<Timetable> list = new ArrayList<>();
        String query = JOIN_SQL + " WHERE s.teacher_id = ? ORDER BY t.day_of_week, t.start_time";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── Read for student ───────────────────────────────────────────────────────
    public List<Timetable> getTimetableForStudent(String department, int year, String section) {
        List<Timetable> list = new ArrayList<>();
        String query = JOIN_SQL +
                " WHERE s.department = ? AND s.year = ? AND (s.section IS NULL OR s.section = '' OR s.section = ?) " +
                "ORDER BY t.day_of_week, t.start_time";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, department);
            ps.setInt(2, year);
            ps.setString(3, section);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
