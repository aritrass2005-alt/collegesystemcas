package com.college.attendance.dao;

import com.college.attendance.model.Coordinator;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CoordinatorDAO {

    public boolean addCoordinatorRole(int teacherId, String department, int year, String section) {
        String sql = "INSERT INTO coordinator (teacher_id, department, year, section) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, teacherId);
            stmt.setString(2, department);
            stmt.setInt(3, year);
            stmt.setString(4, section);
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeCoordinatorRole(int id) {
        String sql = "DELETE FROM coordinator WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateCoordinatorRole(int id, int teacherId, String department, int year, String section) {
        String sql = "UPDATE coordinator SET teacher_id = ?, department = ?, year = ?, section = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, teacherId);
            stmt.setString(2, department);
            stmt.setInt(3, year);
            stmt.setString(4, section);
            stmt.setInt(5, id);
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Coordinator> getCoordinatorAssignments(int teacherId) {
        List<Coordinator> list = new ArrayList<>();
        String sql = "SELECT * FROM coordinator WHERE teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Coordinator c = new Coordinator();
                    c.setId(rs.getInt("id"));
                    c.setTeacherId(rs.getInt("teacher_id"));
                    c.setDepartment(rs.getString("department"));
                    c.setYear(rs.getInt("year"));
                    c.setSection(rs.getString("section"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Coordinator> getAllCoordinators() {
        List<Coordinator> list = new ArrayList<>();
        String sql = "SELECT c.*, t.name as teacher_name FROM coordinator c " +
                     "JOIN teacher t ON c.teacher_id = t.id ORDER BY c.department, c.year, c.section";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Coordinator c = new Coordinator();
                c.setId(rs.getInt("id"));
                c.setTeacherId(rs.getInt("teacher_id"));
                c.setDepartment(rs.getString("department"));
                c.setYear(rs.getInt("year"));
                c.setSection(rs.getString("section"));
                c.setTeacherName(rs.getString("teacher_name"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isCoordinator(int teacherId) {
        String sql = "SELECT COUNT(*) FROM coordinator WHERE teacher_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get the coordinator's teacher_id for a specific section (department, year, section).
     * Returns -1 if no coordinator is assigned to the section.
     */
    public int getCoordinatorTeacherIdForSection(String department, int year, String section) {
        String sql = "SELECT teacher_id FROM coordinator WHERE department = ? AND year = ? " +
                     "AND (section = ? OR section IS NULL OR section = '') LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, department);
            stmt.setInt(2, year);
            stmt.setString(3, section);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("teacher_id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
}

