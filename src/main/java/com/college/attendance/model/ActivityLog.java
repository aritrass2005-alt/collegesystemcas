package com.college.attendance.model;

import java.sql.Timestamp;

public class ActivityLog {
    private int id;
    private String userType;
    private String userName;
    private String action;
    private Timestamp createdAt;

    public ActivityLog() {}

    public ActivityLog(String userType, String userName, String action) {
        this.userType = userType;
        this.userName = userName;
        this.action = action;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }
    
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
