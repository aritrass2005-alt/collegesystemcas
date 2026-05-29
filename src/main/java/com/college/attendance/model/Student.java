package com.college.attendance.model;

public class Student {
    private int id;
    private String rollNo;
    private String name;
    private String email;
    private String phone;
    private String address;
    private String profilePhoto;
    private String department;
    private int year;
    private String section;
    private boolean isBanned;
    private String dob;
    private String status;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getRollNo() { return rollNo; }
    public void setRollNo(String rollNo) { this.rollNo = rollNo; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getProfilePhoto() { return profilePhoto; }
    public void setProfilePhoto(String profilePhoto) { this.profilePhoto = profilePhoto; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }

    public boolean isBanned() { return isBanned; }
    public void setBanned(boolean banned) { isBanned = banned; }

    public String getDob() { return dob; }
    public void setDob(String dob) { this.dob = dob; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
