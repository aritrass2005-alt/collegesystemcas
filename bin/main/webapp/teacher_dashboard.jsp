<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teacher Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">CRUD Teacher</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-light">Welcome, <%= teacher.getName() %></span>
                <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
            </div>
        </div>
    </nav>
    <div class="container mt-5">
        <h2>Teacher Dashboard</h2>
        <hr>
        <div class="row">
            <div class="col-md-6">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h5 class="card-title">Take Attendance</h5>
                        <p class="card-text">Select your assigned subject to mark student attendance.</p>
                        <a href="takeAttendance" class="btn btn-primary">Take Attendance</a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <h5 class="card-title">Defaulter List</h5>
                        <p class="card-text">Generate a list of students with attendance below 75%.</p>
                        <a href="#" class="btn btn-danger">View Defaulters</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
