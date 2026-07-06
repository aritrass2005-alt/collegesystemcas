package com.college.attendance.dao;

import com.college.attendance.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SystemSettingsDAO {
    // Thread-safe volatile cache for high performance global filters
    private static volatile Boolean maintenanceModeCache = null;

    /**
     * Checks if maintenance mode is active. Uses cached value first.
     */
    public boolean isMaintenanceMode() {
        if (maintenanceModeCache != null) {
            return maintenanceModeCache;
        }
        
        String sql = "SELECT setting_value FROM system_settings WHERE setting_key = 'maintenance_mode'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean active = "true".equalsIgnoreCase(rs.getString("setting_value"));
                    maintenanceModeCache = active; // Seed cache
                    return active;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Fallback default
        return false;
    }

    /**
     * Updates the maintenance mode state in the database and invalidates/updates the cache.
     */
    public boolean setMaintenanceMode(boolean active) {
        String sql = "UPDATE system_settings SET setting_value = ? WHERE setting_key = 'maintenance_mode'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, String.valueOf(active));
            boolean success = stmt.executeUpdate() > 0;
            if (success) {
                maintenanceModeCache = active; // Synchronize cache
            }
            return success;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Explicitly invalidates the cached settings.
     */
    public static void invalidateCache() {
        maintenanceModeCache = null;
    }
}
