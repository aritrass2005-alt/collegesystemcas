package com.college.attendance.dao;

import com.college.attendance.model.ConfigData;
import com.college.attendance.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ConfigDAO {

    public List<ConfigData> getAll(String tableName) {
        List<ConfigData> list = new ArrayList<>();
        // Note: Dynamic table name requires careful handling to avoid SQL injection
        // Since we control the tableName from the servlet, it's safe here if strictly validated.
        if (!tableName.equals("department") && !tableName.equals("section") && !tableName.equals("academic_year")) {
            return list;
        }

        String colName = tableName.equals("academic_year") ? "year_name" : "name";
        String sql = "SELECT id, " + colName + " AS name FROM " + tableName + " ORDER BY id";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(new ConfigData(rs.getInt("id"), rs.getString("name"), tableName));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addConfig(String tableName, String value) {
        if (!tableName.equals("department") && !tableName.equals("section") && !tableName.equals("academic_year")) {
            return false;
        }

        String colName = tableName.equals("academic_year") ? "year_name" : "name";
        String sql = "INSERT INTO " + tableName + " (" + colName + ") VALUES (?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, value);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteConfig(String tableName, int id) {
        if (!tableName.equals("department") && !tableName.equals("section") && !tableName.equals("academic_year")) {
            return false;
        }

        String sql = "DELETE FROM " + tableName + " WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
