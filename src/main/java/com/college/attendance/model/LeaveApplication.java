package com.college.attendance.model;

import java.sql.Timestamp;

public class LeaveApplication {
    private int id;
    private int studentId;
    private String reason;
    private String proofPath;
    private String status; // Pending, Approved, Rejected
    private Timestamp appliedOn;
    
    // New fields
    private String startDate; // format yyyy-mm-dd
    private String endDate;   // format yyyy-mm-dd
    private boolean declaration;
    
    // Extra display fields
    private String studentName;
    private String studentRollNo;
    private String studentDepartment;
    private String studentSection;
    private int studentYear;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getProofPath() { return proofPath; }
    public void setProofPath(String proofPath) { this.proofPath = proofPath; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getAppliedOn() { return appliedOn; }
    public void setAppliedOn(Timestamp appliedOn) { this.appliedOn = appliedOn; }

    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }

    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }

    public boolean isDeclaration() { return declaration; }
    public void setDeclaration(boolean declaration) { this.declaration = declaration; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentRollNo() { return studentRollNo; }
    public void setStudentRollNo(String studentRollNo) { this.studentRollNo = studentRollNo; }

    public String getStudentDepartment() { return studentDepartment; }
    public void setStudentDepartment(String studentDepartment) { this.studentDepartment = studentDepartment; }

    public String getStudentSection() { return studentSection; }
    public void setStudentSection(String studentSection) { this.studentSection = studentSection; }

    public int getStudentYear() { return studentYear; }
    public void setStudentYear(int studentYear) { this.studentYear = studentYear; }
}
