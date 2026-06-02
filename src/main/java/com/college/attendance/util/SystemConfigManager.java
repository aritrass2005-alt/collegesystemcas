package com.college.attendance.util;

import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Runtime system config singleton — holds maintenance mode flag and max session limit.
 * Values are stored in memory (reset on server restart).
 * SuperAdmin can toggle maintenance. Admin/SuperAdmin can set session cap.
 */
public class SystemConfigManager {
    private static final SystemConfigManager INSTANCE = new SystemConfigManager();

    private final AtomicBoolean maintenanceMode = new AtomicBoolean(false);
    private final AtomicInteger maxActiveSessions = new AtomicInteger(0); // 0 = unlimited

    private SystemConfigManager() {}

    public static SystemConfigManager getInstance() {
        return INSTANCE;
    }

    // ── Maintenance Mode ─────────────────────────────────────────────────────
    public boolean isMaintenanceMode() {
        return maintenanceMode.get();
    }

    public void setMaintenanceMode(boolean enabled) {
        maintenanceMode.set(enabled);
    }

    // ── Session Capacity ─────────────────────────────────────────────────────
    public int getMaxActiveSessions() {
        return maxActiveSessions.get();
    }

    public void setMaxActiveSessions(int max) {
        maxActiveSessions.set(max);
    }
}
