package com.college.attendance.dao;

import com.college.attendance.model.Holiday;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HolidayDAO {

    public boolean addHoliday(Holiday holiday) {
        String query = "INSERT INTO holiday_calendar (holiday_date, description) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setDate(1, holiday.getHolidayDate());
            ps.setString(2, holiday.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Holiday> getAllHolidays() {
        List<Holiday> holidays = new ArrayList<>();
        String query = "SELECT * FROM holiday_calendar ORDER BY holiday_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Holiday holiday = new Holiday();
                holiday.setId(rs.getInt("id"));
                holiday.setHolidayDate(rs.getDate("holiday_date"));
                holiday.setDescription(rs.getString("description"));
                holidays.add(holiday);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return holidays;
    }

    public boolean isTodayAHoliday() {
        String query = "SELECT COUNT(*) FROM holiday_calendar WHERE holiday_date = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
