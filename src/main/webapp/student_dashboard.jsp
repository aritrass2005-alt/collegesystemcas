<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-info">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">CRUD Student</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-light">Welcome, <%= student.getName() %> (Roll: <%= student.getRollNo() %>)</span>
                <a href="logout" class="btn btn-outline-dark btn-sm">Logout</a>
            </div>
        </div>
    </nav>
    <div class="container mt-5">
        <h2>Student Dashboard</h2>
        <hr>
        <div class="row">
            <div class="col-md-6">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h5 class="card-title">View Attendance</h5>
                        <p class="card-text">Check your subject-wise attendance status and percentage.</p>
                        <a href="viewAttendance" class="btn btn-info text-white">View Attendance</a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h5 class="card-title">Apply for Leave</h5>
                        <p class="card-text">Submit a leave application to your coordinator.</p>
                        <a href="#" class="btn btn-secondary">Apply Leave</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
