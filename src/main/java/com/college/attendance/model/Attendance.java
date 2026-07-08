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
    
    // Student recheck appeal fields
    private String studentAppealStatus;
    private String studentAppealReason;
    private String studentAppealRemarks;

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

    public String getStudentAppealStatus() { return studentAppealStatus; }
    public void setStudentAppealStatus(String studentAppealStatus) { this.studentAppealStatus = studentAppealStatus; }

    public String getStudentAppealReason() { return studentAppealReason; }
    public void setStudentAppealReason(String studentAppealReason) { this.studentAppealReason = studentAppealReason; }

    public String getStudentAppealRemarks() { return studentAppealRemarks; }
    public void setStudentAppealRemarks(String studentAppealRemarks) { this.studentAppealRemarks = studentAppealRemarks; }

    // Extra display fields for appeals view
    private String subjectName;
    private String subjectCode;
    private String teacherName;

    // Guardian contact fields (used in coordinator appeals view)
    private String parentName;
    private String parentPhone;
    private String parentEmail;
    private String studentSection;
    private String studentDepartment;
    private int studentYear;

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }

    public String getParentName() { return parentName; }
    public void setParentName(String parentName) { this.parentName = parentName; }

    public String getParentPhone() { return parentPhone; }
    public void setParentPhone(String parentPhone) { this.parentPhone = parentPhone; }

    public String getParentEmail() { return parentEmail; }
    public void setParentEmail(String parentEmail) { this.parentEmail = parentEmail; }

    public String getStudentSection() { return studentSection; }
    public void setStudentSection(String studentSection) { this.studentSection = studentSection; }

    public String getStudentDepartment() { return studentDepartment; }
    public void setStudentDepartment(String studentDepartment) { this.studentDepartment = studentDepartment; }

    public int getStudentYear() { return studentYear; }
    public void setStudentYear(int studentYear) { this.studentYear = studentYear; }
}
