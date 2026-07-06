# College Attendance Management System Architecture

This document provides a comprehensive overview of the architecture and key implementations for the Java-based College Attendance Management System.

---

## 1. Project Architecture (MVC)

The system uses the **Model-View-Controller (MVC)** design pattern:

- **Model:** Java Beans (POJOs) representing database entities (`Student`, `Teacher`, `Attendance`) and DAO classes (`StudentDAO`, `AttendanceDAO`) handling MySQL database operations.
- **View:** JSP files (`admin_dashboard.jsp`, `take_attendance.jsp`) containing HTML, CSS, and Bootstrap (optional) to present data to the user. JSTL is used for logic within JSP pages.
- **Controller:** Java Servlets (`LoginServlet`, `AttendanceServlet`) that intercept HTTP requests, coordinate with the Model, and forward the request to the appropriate View.

---

## 2. Folder Structure

The project has been structured for deployment on **Apache Tomcat 10**.

```text
collegeatt\cas\
├── database\
│   └── attendance_system.sql         <-- Database Schema
├── download_jars.ps1                 <-- Script to fetch dependencies
├── src\
│   ├── main\
│   │   ├── java\
│   │   │   └── com\college\attendance\
│   │   │       ├── controller\       <-- Servlets
│   │   │       ├── dao\              <-- Data Access Objects
│   │   │       ├── model\            <-- POJO Entities
│   │   │       └── util\             <-- DB Connection, Password Hashing
│   │   └── webapp\
│   │       ├── css\                  <-- Custom Stylesheets
│   │       ├── js\                   <-- JavaScript files
│   │       ├── admin_dashboard.jsp
│   │       ├── teacher_dashboard.jsp
│   │       ├── student_dashboard.jsp
│   │       ├── login.jsp
│   │       └── WEB-INF\
│   │           ├── lib\              <-- Downloaded JARs (MySQL, BCrypt, JSTL)
│   │           └── web.xml           <-- Deployment Descriptor
```

---

## 3. Key Core Implementations

### A. Database Connection & Security Utilities
**`src/main/java/com/college/attendance/util/DBConnection.java`**
```java
package com.college.attendance.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/college_attendance";
    private static final String USER = "root";
    private static final String PASSWORD = "aritra04"; // Requested Password

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // Load the MySQL Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
```

**Auto-Password Generation & Hashing (Student DOB)**
When an Admin adds a student, the password is auto-generated in `DDMMYYYY` format.
```java
import org.mindrot.jbcrypt.BCrypt;

// Example inside StudentDAO.java when adding a student
public boolean addStudent(Student student, String dobStr) {
    // dobStr assumed to be "DDMMYYYY"
    String hashedPassword = BCrypt.hashpw(dobStr, BCrypt.gensalt(12));
    
    String sql = "INSERT INTO student (roll_no, name, email, password, department, year, section) VALUES (?, ?, ?, ?, ?, ?, ?)";
    
    // ... JDBC PreparedStatement execution ...
}
```

### B. Unified Login Servlet
Handles login requests for all 4 roles.
**`src/main/java/com/college/attendance/controller/LoginServlet.java`**
```java
package com.college.attendance.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String identifier = request.getParameter("identifier"); // Can be Email or Roll No
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // 'Admin', 'Teacher', 'Student'
        
        HttpSession session = request.getSession();
        
        try {
            // Note: In a real app, you would have separate DAOs for each role.
            // Example for Student:
            if ("Student".equals(role)) {
                // StudentDAO dao = new StudentDAO();
                // Student student = dao.getStudentByRollNo(identifier);
                // if (student != null && BCrypt.checkpw(password, student.getPassword())) {
                //     session.setAttribute("user", student);
                //     session.setAttribute("role", "Student");
                //     response.sendRedirect("student_dashboard.jsp");
                //     return;
                // }
            }
            
            // Similar logic for Admin and Teacher...
            
            // If authentication fails:
            request.setAttribute("error", "Invalid credentials or role.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### C. Attendance Tracking (Teacher Feature)
Allows teachers to take attendance and lock it.
**`src/main/java/com/college/attendance/controller/AttendanceServlet.java`**
```java
package com.college.attendance.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/submitAttendance")
public class AttendanceServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        String[] studentIds = request.getParameterValues("studentIds"); // List of all students in class
        
        // Loop through submitted students and save their status
        for (String studentIdStr : studentIds) {
            int studentId = Integer.parseInt(studentIdStr);
            // The frontend should name checkboxes like status_1, status_2, etc.
            String status = request.getParameter("status_" + studentId);
            
            if (status == null) status = "Absent"; // Default to absent if checkbox unchecked
            
            // AttendanceDAO dao = new AttendanceDAO();
            // boolean isLocked = dao.isAttendanceLocked(subjectId, currentDate);
            // if (!isLocked) {
            //     dao.saveAttendance(studentId, subjectId, status);
            // }
        }
        
        // After submission, redirect back with success message
        response.sendRedirect("teacher_dashboard.jsp?msg=Attendance Saved");
    }
}
```

### D. Representative Frontend (Login Page)
**`src/main/webapp/login.jsp`**
```html
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>College Attendance System - Login</title>
    <!-- Optional Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white text-center">
                        <h4>Login to DAMS</h4>
                    </div>
                    <div class="card-body">
                        <% if(request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                        <% } %>
                        <form action="login" method="post">
                            <div class="mb-3">
                                <label>Login As</label>
                                <select name="role" class="form-select" required>
                                    <option value="Student">Student</option>
                                    <option value="Teacher">Teacher / Coordinator</option>
                                    <option value="Admin">Admin / Super Admin</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label>Identifier (Email / Roll No)</label>
                                <input type="text" name="identifier" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label>Password</label>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">Login</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
```

---

## 4. Deployment Instructions (Apache Tomcat Community Server)

### Step 1: Database Setup
1. Ensure MySQL is running on your machine with the password `aritra04`.
2. Open MySQL Workbench or your terminal.
3. Source the provided `database/attendance_system.sql` script to create the database, tables, and the default **Super Admin** account (`super@college.edu` / `admin123`).

### Step 2: Ensure JAR Dependencies
1. Check the `src/main/webapp/WEB-INF/lib` folder.
2. The `download_jars.ps1` script should have downloaded the `mysql-connector`, `jbcrypt`, `jstl`, and `gson` JARs.

### Step 3: Deploy to Tomcat 10
1. Create a folder named `college_attendance` inside your Tomcat's `webapps` directory (e.g., `C:\apache-tomcat-10.x.x\webapps\college_attendance`).
2. Copy the contents of the `src/main/webapp` folder from this workspace into the `webapps/college_attendance` folder.
3. Compile all the Java files located in `src/main/java/` using a tool like Eclipse, IntelliJ, or `javac`, ensuring that the Tomcat 10 Servlet API jar (`lib/servlet-api.jar`) is in the classpath.
4. Place the compiled `.class` files into `webapps/college_attendance/WEB-INF/classes/` mirroring the package structure (`com/college/attendance/...`).
   - *Tip: If you open this folder (`cas`) in an IDE like Eclipse or IntelliJ as a Dynamic Web Project, it will handle the compilation and deployment for you automatically!*
5. Start your Tomcat server.

### Step 4: Access the Application
- Open your browser and navigate to: `http://localhost:8080/college_attendance/login.jsp`
- Log in using the default Super Admin credentials:
  - **Email:** `super@college.edu`
  - **Password:** `admin123`
  - **Role:** `Admin`
