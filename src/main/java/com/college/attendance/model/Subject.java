package com.college.attendance.model;

public class Subject {
    private int id;
    private String subjectCode;
    private String name;
    private String department;
    private int year;
    private String section;
    private int teacherId;
    
    // Extra field for joining with Teacher table to display teacher's name
    private String teacherName;

    // Getters and Setters
    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public int getTeacherId() { return teacherId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }

    public String getTeacherName() { return teacherName; }
    public void setTeacherName(String teacherName) { this.teacherName = teacherName; }
}
