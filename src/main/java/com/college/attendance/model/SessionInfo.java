package com.college.attendance.model;

import java.util.Date;

public class SessionInfo {
    private String sessionId;
    private String username;
    private String role;
    private Date loginTime;

    public SessionInfo(String sessionId, String username, String role, Date loginTime) {
        this.sessionId = sessionId;
        this.username = username;
        this.role = role;
        this.loginTime = loginTime;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Date getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(Date loginTime) {
        this.loginTime = loginTime;
    }
}
