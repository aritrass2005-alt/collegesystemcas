package com.college.attendance.model;

public class AttendanceSummary {
    private String subjectCode;
    private String subjectName;
    private int totalClasses;
    private int attendedClasses;
    private int missedClasses;
    private double percentage;

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public int getTotalClasses() { return totalClasses; }
    public void setTotalClasses(int totalClasses) { this.totalClasses = totalClasses; }

    public int getAttendedClasses() { return attendedClasses; }
    public void setAttendedClasses(int attendedClasses) { this.attendedClasses = attendedClasses; }

    public int getMissedClasses() { return missedClasses; }
    public void setMissedClasses(int missedClasses) { this.missedClasses = missedClasses; }

    public double getPercentage() { return percentage; }
    public void setPercentage(double percentage) { this.percentage = percentage; }
}
