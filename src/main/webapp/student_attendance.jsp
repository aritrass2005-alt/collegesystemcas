<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.AttendanceSummary" %>
<%@ page import="java.util.List" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<AttendanceSummary> summaryList = (List<AttendanceSummary>) request.getAttribute("attendanceSummary");
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Attendance - Student</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .progress {
            height: 20px;
            border-radius: 10px;
        }
        .progress-bar-defaulter {
            background-color: #dc3545; /* Red */
        }
        .progress-bar-good {
            background-color: #198754; /* Green */
        }
        .progress-bar-warning-zone {
            background-color: #ffc107; /* Yellow */
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-info">
        <div class="container-fluid">
            <a class="navbar-brand" href="student_dashboard.jsp">Student Dashboard</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-light">Welcome, <%= student.getName() %></span>
                <a href="logout" class="btn btn-outline-dark btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h3>My Attendance Summary</h3>
        <p class="text-muted">A minimum of 75% attendance is required to appear for exams.</p>
        <hr>

        <div class="card shadow-sm">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Subject Code</th>
                                <th>Subject Name</th>
                                <th class="text-center">Total Classes</th>
                                <th class="text-center">Attended</th>
                                <th class="text-center">Missed</th>
                                <th class="text-center">Percentage</th>
                                <th style="width: 25%">Progress</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (summaryList != null && !summaryList.isEmpty()) { 
                                for (AttendanceSummary s : summaryList) { 
                                    double p = s.getPercentage();
                                    String barClass = "progress-bar-good";
                                    if (p < 75.0) {
                                        barClass = "progress-bar-defaulter";
                                    } else if (p < 80.0) {
                                        barClass = "progress-bar-warning-zone";
                                    }
                            %>
                            <tr>
                                <td class="fw-bold"><%= s.getSubjectCode() %></td>
                                <td><%= s.getSubjectName() %></td>
                                <td class="text-center"><%= s.getTotalClasses() %></td>
                                <td class="text-center text-success fw-bold"><%= s.getAttendedClasses() %></td>
                                <td class="text-center text-danger fw-bold"><%= s.getMissedClasses() %></td>
                                <td class="text-center fw-bold <%= p < 75 ? "text-danger" : "" %>">
                                    <%= String.format("%.2f", p) %>%
                                </td>
                                <td>
                                    <div class="progress shadow-sm">
                                        <div class="progress-bar <%= barClass %>" role="progressbar" style="width: <%= p %>%;" aria-valuenow="<%= p %>" aria-valuemin="0" aria-valuemax="100">
                                            <%= String.format("%.0f", p) %>%
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            <tr>
                                <td colspan="7" class="text-center py-4">
                                    <h5 class="text-muted">No attendance records found yet.</h5>
                                    <p class="mb-0">Your teachers haven't submitted any attendance data for you.</p>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        setTimeout(function() {
            var alerts = document.querySelectorAll(".alert, .alert-custom");
            alerts.forEach(function(alert) {
                alert.style.transition = "opacity 0.5s ease";
                alert.style.opacity = "0";
                setTimeout(function() { alert.remove(); }, 500);
            });
        }, 3000);
    });
</script>
</body>
</html>

