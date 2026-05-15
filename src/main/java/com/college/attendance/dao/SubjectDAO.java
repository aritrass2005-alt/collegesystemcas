package com.college.attendance.dao;

import com.college.attendance.model.Subject;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SubjectDAO {

    public boolean addSubject(Subject subject) {
        String sql = "INSERT INTO subject (subject_code, name, department, year, section, teacher_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, subject.getSubjectCode());
            stmt.setString(2, subject.getName());
            stmt.setString(3, subject.getDepartment());
            stmt.setInt(4, subject.getYear());
            stmt.setString(5, subject.getSection());
            stmt.setInt(6, subject.getTeacherId());
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Subject> getAllSubjects() {
        List<Subject> subjects = new ArrayList<>();
        // Join with Teacher table to get the assigned teacher's name
        String sql = "SELECT s.*, t.name AS teacher_name FROM subject s LEFT JOIN teacher t ON s.teacher_id = t.id";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
             
            while (rs.next()) {
                Subject s = new Subject();
                s.setId(rs.getInt("id"));
                s.setSubjectCode(rs.getString("subject_code"));
                s.setName(rs.getString("name"));
                s.setDepartment(rs.getString("department"));
                s.setYear(rs.getInt("year"));
                s.setSection(rs.getString("section"));
                s.setTeacherId(rs.getInt("teacher_id"));
                s.setTeacherName(rs.getString("teacher_name"));
                subjects.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return subjects;
    }

    public List<Subject> getSubjectsByTeacher(int teacherId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subject WHERE teacher_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Subject s = new Subject();
                    s.setId(rs.getInt("id"));
                    s.setSubjectCode(rs.getString("subject_code"));
                    s.setName(rs.getString("name"));
                    s.setDepartment(rs.getString("department"));
                    s.setYear(rs.getInt("year"));
                    s.setTeacherId(rs.getInt("teacher_id"));
                    subjects.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return subjects;
    }
    
    public Subject getSubjectById(int id) {
        String sql = "SELECT * FROM subject WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Subject s = new Subject();
                    s.setId(rs.getInt("id"));
                    s.setSubjectCode(rs.getString("subject_code"));
                    s.setName(rs.getString("name"));
                    s.setDepartment(rs.getString("department"));
                    s.setYear(rs.getInt("year"));
                    s.setTeacherId(rs.getInt("teacher_id"));
                    return s;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
