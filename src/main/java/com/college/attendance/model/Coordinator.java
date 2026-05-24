package com.college.attendance.model;

public class Coordinator {
    private int id;
    private int teacherId;
    private String department;
    private String section;
    private int year;
    
    // Additional fields for display
    private String teacherName;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    
    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
}
