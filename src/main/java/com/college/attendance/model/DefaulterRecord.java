package com.college.attendance.model;

public class DefaulterRecord {
    private int studentId;
    private String studentRollNo;
    private String studentName;
    private String studentSection;
    private String studentDepartment;
    private String subjectCode;
    private String subjectName;
    private int totalClasses;
    private int attendedClasses;
    private double percentage;

    // Getters and Setters
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentRollNo() { return studentRollNo; }
    public void setStudentRollNo(String studentRollNo) { this.studentRollNo = studentRollNo; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentSection() { return studentSection; }
    public void setStudentSection(String studentSection) { this.studentSection = studentSection; }

    public String getStudentDepartment() { return studentDepartment; }
    public void setStudentDepartment(String studentDepartment) { this.studentDepartment = studentDepartment; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public int getTotalClasses() { return totalClasses; }
    public void setTotalClasses(int totalClasses) { this.totalClasses = totalClasses; }

    public int getAttendedClasses() { return attendedClasses; }
    public void setAttendedClasses(int attendedClasses) { this.attendedClasses = attendedClasses; }

    public double getPercentage() { return percentage; }
    public void setPercentage(double percentage) { this.percentage = percentage; }
}
