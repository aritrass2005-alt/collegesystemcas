package com.college.attendance.dao;

import com.college.attendance.model.Teacher;
import com.college.attendance.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TeacherDAO {

    public boolean addTeacher(Teacher teacher) {
        String sql = "INSERT INTO teacher (name, email, phone, password, department, is_approved) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, teacher.getName());
            stmt.setString(2, teacher.getEmail());
            stmt.setString(3, teacher.getPhone());
            
            // Auto-generate password, let's use "teacher123" as default for manually added teachers
            String hashedPassword = BCrypt.hashpw("teacher123", BCrypt.gensalt(12));
            stmt.setString(4, hashedPassword);
            stmt.setString(5, teacher.getDepartment());
            
            // Teachers added by admin are pre-approved
            stmt.setBoolean(6, true);
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateTeacher(Teacher teacher) {
        String sql = "UPDATE teacher SET name=?, email=?, phone=?, department=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, teacher.getName());
            stmt.setString(2, teacher.getEmail());
            stmt.setString(3, teacher.getPhone());
            stmt.setString(4, teacher.getDepartment());
            stmt.setInt(5, teacher.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteTeacher(int id) {
        String sql = "DELETE FROM teacher WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean registerTeacher(Teacher teacher, String rawPassword) {
        String sql = "INSERT INTO teacher (name, email, phone, password, department, year, section, is_approved) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, teacher.getName());
            stmt.setString(2, teacher.getEmail());
            stmt.setString(3, teacher.getPhone() != null ? teacher.getPhone() : "");
            
            String hashedPassword = BCrypt.hashpw(rawPassword, BCrypt.gensalt(12));
            stmt.setString(4, hashedPassword);
            
            stmt.setString(5, teacher.getDepartment());
            
            stmt.setInt(6, 1); 
            stmt.setString(7, "A");
            
            // Teachers registering themselves are NOT auto-approved
            stmt.setBoolean(8, false);
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Teacher> getAllTeachers() {
        return getTeachersByFilter(null, 0, null, null);
    }

    public List<Teacher> getTeachersByFilter(String department, int year, String section, String subjectId) {
        List<Teacher> teachers = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT DISTINCT t.* FROM teacher t WHERE 1=1");
        
        if (department != null && !department.isEmpty()) sql.append(" AND t.department = ?");
        if (year > 0) sql.append(" AND t.year = ?");
        if (section != null && !section.isEmpty()) sql.append(" AND t.section = ?");
        if (subjectId != null && !subjectId.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM subject sub WHERE sub.teacher_id = t.id AND sub.id = ?)");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
             
            int paramIndex = 1;
            if (department != null && !department.isEmpty()) stmt.setString(paramIndex++, department);
            if (year > 0) stmt.setInt(paramIndex++, year);
            if (section != null && !section.isEmpty()) stmt.setString(paramIndex++, section);
            if (subjectId != null && !subjectId.isEmpty()) stmt.setInt(paramIndex++, Integer.parseInt(subjectId));
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Teacher t = new Teacher();
                    t.setId(rs.getInt("id"));
                    t.setName(rs.getString("name"));
                    t.setEmail(rs.getString("email"));
                    t.setPhone(rs.getString("phone")); // Added phone
                    t.setDepartment(rs.getString("department"));
                    t.setApproved(rs.getBoolean("is_approved"));
                    teachers.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return teachers;
    }

    public boolean approveTeacher(int teacherId) {
        String sql = "UPDATE teacher SET is_approved = TRUE WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean assignCoordinator(int teacherId, String dept, String section, int year) {
        String sql = "INSERT INTO coordinator (teacher_id, department, section, year) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            stmt.setString(2, dept);
            stmt.setString(3, section);
            stmt.setInt(4, year);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean isCoordinator(int teacherId) {
        String sql = "SELECT * FROM coordinator WHERE teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
