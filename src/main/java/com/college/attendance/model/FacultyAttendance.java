package com.college.attendance.model;

import java.sql.Date;
import java.sql.Time;

public class FacultyAttendance {
    private int id;
    private int teacherId;
    private Date date;
    private Time checkInTime;
    private Time checkOutTime;
    private String status; // 'Present', 'Absent', 'Half Day', 'On Leave'
    private boolean verifiedByAdmin;
    private String adminNotes;

    // Display fields (joined from teacher table)
    private String teacherName;
    private String teacherDepartment;
    private String teacherEmail;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }

    public Time getCheckInTime() { return checkInTime; }
    public void setCheckInTime(Time checkInTime) { this.checkInTime = checkInTime; }

    public Time getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(Time checkOutTime) { this.checkOutTime = checkOutTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isVerifiedByAdmin() { return verifiedByAdmin; }
    public void setVerifiedByAdmin(boolean verifiedByAdmin) { this.verifiedByAdmin = verifiedByAdmin; }

    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getTeacherDepartment() { return teacherDepartment; }
    public void setTeacherDepartment(String teacherDepartment) { this.teacherDepartment = teacherDepartment; }

    public String getTeacherEmail() { return teacherEmail; }
    public void setTeacherEmail(String teacherEmail) { this.teacherEmail = teacherEmail; }

    // Helper: Calculate total hours worked
    public String getHoursWorked() {
        if (checkInTime == null || checkOutTime == null) return "--";
        long diffMs = checkOutTime.getTime() - checkInTime.getTime();
        if (diffMs <= 0) return "--";
        long hours = diffMs / (1000 * 60 * 60);
        long minutes = (diffMs / (1000 * 60)) % 60;
        return hours + "h " + minutes + "m";
    }
}
