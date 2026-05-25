package com.college.attendance.dao;

import com.college.attendance.model.Subject;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class SubjectDAO {

    /** True once we've confirmed alt_teacher_id exists in DB */
    private static Boolean altColExists = null;

    private boolean checkAltCol() {
        if (altColExists != null) return altColExists;
        try (Connection conn = DBConnection.getConnection();
             ResultSet rs = conn.getMetaData().getColumns(null, null, "subject", "alt_teacher_id")) {
            altColExists = rs.next();
        } catch (Exception e) {
            altColExists = false;
        }
        return altColExists;
    }

    // ── Helper ─────────────────────────────────────────────────────────────────
    private Subject mapRow(ResultSet rs) throws Exception {
        Subject s = new Subject();
        s.setId(rs.getInt("id"));
        s.setSubjectCode(rs.getString("subject_code"));
        s.setName(rs.getString("name"));
        s.setDepartment(rs.getString("department"));
        s.setYear(rs.getInt("year"));
        s.setSection(rs.getString("section"));
        s.setTeacherId(rs.getInt("teacher_id"));
        if (checkAltCol()) {
            try { s.setAltTeacherId(rs.getInt("alt_teacher_id")); } catch (Exception ignored) {}
            try { s.setAltTeacherName(rs.getString("alt_teacher_name")); } catch (Exception ignored) {}
        }
        try { s.setTeacherName(rs.getString("teacher_name")); } catch (Exception ignored) {}
        return s;
    }

    private String baseSelect(boolean withAlt) {
        if (withAlt && checkAltCol()) {
            return "SELECT s.*, t.name AS teacher_name, a.name AS alt_teacher_name " +
                   "FROM subject s " +
                   "LEFT JOIN teacher t ON s.teacher_id = t.id " +
                   "LEFT JOIN teacher a ON s.alt_teacher_id = a.id";
        } else {
            return "SELECT s.*, t.name AS teacher_name " +
                   "FROM subject s " +
                   "LEFT JOIN teacher t ON s.teacher_id = t.id";
        }
    }

    // ── Create ─────────────────────────────────────────────────────────────────
    public boolean addSubject(Subject subject) {
        String sql;
        if (checkAltCol()) {
            sql = "INSERT INTO subject (subject_code, name, department, year, section, teacher_id, alt_teacher_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        } else {
            sql = "INSERT INTO subject (subject_code, name, department, year, section, teacher_id) VALUES (?, ?, ?, ?, ?, ?)";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, subject.getSubjectCode());
            stmt.setString(2, subject.getName());
            stmt.setString(3, subject.getDepartment());
            stmt.setInt(4, subject.getYear());
            stmt.setString(5, subject.getSection());
            if (subject.getTeacherId() > 0) stmt.setInt(6, subject.getTeacherId());
            else stmt.setNull(6, java.sql.Types.INTEGER);
            if (checkAltCol()) {
                if (subject.getAltTeacherId() > 0) stmt.setInt(7, subject.getAltTeacherId());
                else stmt.setNull(7, java.sql.Types.INTEGER);
            }
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Update ─────────────────────────────────────────────────────────────────
    public boolean updateSubject(Subject subject) {
        String sql;
        if (checkAltCol()) {
            sql = "UPDATE subject SET subject_code=?, name=?, department=?, year=?, section=?, teacher_id=?, alt_teacher_id=? WHERE id=?";
        } else {
            sql = "UPDATE subject SET subject_code=?, name=?, department=?, year=?, section=?, teacher_id=? WHERE id=?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, subject.getSubjectCode());
            stmt.setString(2, subject.getName());
            stmt.setString(3, subject.getDepartment());
            stmt.setInt(4, subject.getYear());
            stmt.setString(5, subject.getSection());
            if (subject.getTeacherId() > 0) stmt.setInt(6, subject.getTeacherId());
            else stmt.setNull(6, java.sql.Types.INTEGER);
            if (checkAltCol()) {
                if (subject.getAltTeacherId() > 0) stmt.setInt(7, subject.getAltTeacherId());
                else stmt.setNull(7, java.sql.Types.INTEGER);
                stmt.setInt(8, subject.getId());
            } else {
                stmt.setInt(7, subject.getId());
            }
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Delete ─────────────────────────────────────────────────────────────────
    public boolean deleteSubject(int id) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM subject WHERE id = ?")) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Read All ───────────────────────────────────────────────────────────────
    public List<Subject> getAllSubjects() {
        List<Subject> subjects = new ArrayList<>();
        String sql = baseSelect(true) + " ORDER BY s.department, s.year, s.section, s.name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) subjects.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return subjects;
    }

    // ── Read with filters ──────────────────────────────────────────────────────
    public List<Subject> getSubjectsByFilter(String department, String year, String section) {
        List<Subject> subjects = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseSelect(true) + " WHERE 1=1");
        if (department != null && !department.isEmpty()) sql.append(" AND s.department = ?");
        if (year != null && !year.isEmpty()) sql.append(" AND s.year = ?");
        if (section != null && !section.isEmpty()) sql.append(" AND s.section = ?");
        sql.append(" ORDER BY s.name");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (department != null && !department.isEmpty()) stmt.setString(idx++, department);
            if (year != null && !year.isEmpty()) stmt.setInt(idx++, Integer.parseInt(year));
            if (section != null && !section.isEmpty()) stmt.setString(idx++, section);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) subjects.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return subjects;
    }

    // ── Read by teacher ────────────────────────────────────────────────────────
    public List<Subject> getSubjectsByTeacher(int teacherId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = baseSelect(false) + " WHERE s.teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) subjects.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return subjects;
    }

    // ── Read for coordinator ───────────────────────────────────────────────────
    public List<Subject> getSubjectsForCoordinator(String department, int year, String section) {
        List<Subject> subjects = new ArrayList<>();
        String sql = baseSelect(false) +
                " WHERE s.department = ? AND s.year = ? AND (s.section IS NULL OR s.section = '' OR s.section = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, department);
            stmt.setInt(2, year);
            stmt.setString(3, section);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) subjects.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return subjects;
    }

    // ── Read by ID ─────────────────────────────────────────────────────────────
    public Subject getSubjectById(int id) {
        String sql = baseSelect(true) + " WHERE s.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ── Add alt_teacher_id column if missing ───────────────────────────────────
    public void ensureAltTeacherColumn() {
        if (checkAltCol()) return; // already exists
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("ALTER TABLE subject ADD COLUMN alt_teacher_id INT NULL");
            altColExists = true;
        } catch (Exception ignored) {
            altColExists = false;
        }
    }
}
