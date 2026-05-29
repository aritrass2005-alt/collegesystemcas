package com.college.attendance.dao;

import com.college.attendance.model.Admin;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import com.college.attendance.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    public Admin authenticateAdmin(String email, String password) {
        String sql = "SELECT * FROM admin WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password");
                boolean authenticated = false;
                try {
                    if (storedHash != null && storedHash.startsWith("$2a$")) {
                        authenticated = BCrypt.checkpw(password, storedHash);
                    } else if (storedHash != null) {
                        authenticated = storedHash.equals(password);
                    }
                } catch (IllegalArgumentException e) {
                    authenticated = storedHash.equals(password);
                }
                if (authenticated) {
                    Admin admin = new Admin();
                    admin.setId(rs.getInt("id"));
                    admin.setName(rs.getString("name"));
                    admin.setEmail(rs.getString("email"));
                    admin.setRole(rs.getString("role"));
                    return admin;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Teacher authenticateTeacher(String email, String password) {
        String sql = "SELECT * FROM teacher WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password");
                boolean authenticated = false;
                try {
                    if (storedHash != null && storedHash.startsWith("$2a$")) {
                        authenticated = BCrypt.checkpw(password, storedHash);
                    } else if (storedHash != null) {
                        authenticated = storedHash.equals(password);
                    }
                } catch (IllegalArgumentException e) {
                    authenticated = storedHash.equals(password);
                }
                if (authenticated) {
                    Teacher teacher = new Teacher();
                    teacher.setId(rs.getInt("id"));
                    teacher.setName(rs.getString("name"));
                    teacher.setEmail(rs.getString("email"));
                    teacher.setDepartment(rs.getString("department"));
                    teacher.setProfilePhoto(rs.getString("profile_photo"));
                    teacher.setApproved(rs.getBoolean("is_approved"));
                    teacher.setBanned(rs.getBoolean("is_banned"));
                    return teacher;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Student authenticateStudent(String rollNo, String password) {
        String sql = "SELECT * FROM student WHERE roll_no = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, rollNo);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                String storedHash = rs.getString("password");
                boolean authenticated = false;
                try {
                    if (storedHash != null && storedHash.startsWith("$2a$")) {
                        authenticated = BCrypt.checkpw(password, storedHash);
                    } else if (storedHash != null) {
                        authenticated = storedHash.equals(password);
                    }
                } catch (IllegalArgumentException e) {
                    authenticated = storedHash.equals(password);
                }
                if (authenticated) {
                    Student student = new Student();
                    student.setId(rs.getInt("id"));
                    student.setRollNo(rs.getString("roll_no"));
                    student.setName(rs.getString("name"));
                    student.setEmail(rs.getString("email"));
                    student.setDepartment(rs.getString("department"));
                    student.setYear(rs.getInt("year"));
                    student.setSection(rs.getString("section"));
                    student.setProfilePhoto(rs.getString("profile_photo"));
                    student.setBanned(rs.getBoolean("is_banned"));
                    return student;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateAdminProfile(int id, String name, String email) {
        String sql = "UPDATE admin SET name = ?, email = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, email);
            stmt.setInt(3, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateAdminPassword(int id, String hashedPassword) {
        String sql = "UPDATE admin SET password = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<Admin> getAllAdmins() {
        java.util.List<Admin> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM admin";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Admin admin = new Admin();
                admin.setId(rs.getInt("id"));
                admin.setName(rs.getString("name"));
                admin.setEmail(rs.getString("email"));
                admin.setRole(rs.getString("role"));
                list.add(admin);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addAdmin(Admin admin, String hashedPassword) {
        String sql = "INSERT INTO admin (name, email, password, role) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, admin.getName());
            stmt.setString(2, admin.getEmail());
            stmt.setString(3, hashedPassword);
            stmt.setString(4, admin.getRole());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteAdmin(int id) {
        String sql = "DELETE FROM admin WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleBanStatus(int userId, String role, boolean banStatus) {
        String table = role.equalsIgnoreCase("Student") ? "student" : "teacher";
        String sql = "UPDATE " + table + " SET is_banned = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, banStatus);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
