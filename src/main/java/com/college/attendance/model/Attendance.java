package com.college.attendance.model;

import java.sql.Timestamp;

public class Attendance {
    private int id;
    private int studentId;
    private int subjectId;
    private String status; // 'Present' or 'Absent'
    private Timestamp dateTime;
    private boolean isLocked;
    
    // Additional fields for displaying information
    private String studentName;
    private String studentRollNo;
    private String appealStatus;
    private boolean adminEdited;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getDateTime() { return dateTime; }
    public void setDateTime(Timestamp dateTime) { this.dateTime = dateTime; }

    public boolean isLocked() { return isLocked; }
    public void setLocked(boolean locked) { isLocked = locked; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentRollNo() { return studentRollNo; }
    public void setStudentRollNo(String studentRollNo) { this.studentRollNo = studentRollNo; }

    public String getAppealStatus() { return appealStatus; }
    public void setAppealStatus(String appealStatus) { this.appealStatus = appealStatus; }

    public boolean isAdminEdited() { return adminEdited; }
    public void setAdminEdited(boolean adminEdited) { this.adminEdited = adminEdited; }

    // Extra display fields for appeals view
    private String subjectName;
    private String subjectCode;
    private String teacherName;

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
}
