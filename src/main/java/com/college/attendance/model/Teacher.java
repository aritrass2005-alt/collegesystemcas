package com.college.attendance.model;

public class Teacher {
    private int id;
    private String name;
    private String email;
    private String phone;
    private String department;
    private String profilePhoto;
    private boolean isApproved;
    private boolean isBanned;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getProfilePhoto() { return profilePhoto; }
    public void setProfilePhoto(String profilePhoto) { this.profilePhoto = profilePhoto; }

    public boolean isApproved() { return isApproved; }
    public void setApproved(boolean approved) { isApproved = approved; }

    public boolean isBanned() { return isBanned; }
    public void setBanned(boolean banned) { isBanned = banned; }
}
