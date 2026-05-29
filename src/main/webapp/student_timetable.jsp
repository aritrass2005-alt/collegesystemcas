<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.Timetable" %>
<%@ page import="java.util.List" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<Timetable> studentTimetable = (List<Timetable>) request.getAttribute("studentTimetable");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Class Routine – CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .glass-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-card);
        }
    </style>
</head>
<body>
    <jsp:include page="includes/student_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/student_header.jsp" />
            <div class="container-fluid p-4 p-md-5">
                <div class="row">
                    <div class="col-12">
                        <div class="glass-card p-4">
                            <h4 class="fw-bold mb-4"><i class="bi bi-clock-history me-2 text-primary"></i>Class Routine</h4>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="border-0 rounded-start">Day</th>
                                            <th class="border-0">Subject</th>
                                            <th class="border-0">Time</th>
                                            <th class="border-0 rounded-end">Room</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (studentTimetable != null && !studentTimetable.isEmpty()) {
                                            for (Timetable t : studentTimetable) { 
                                        %>
                                            <tr>
                                                <td class="fw-semibold"><%= t.getDayOfWeek() %></td>
                                                <td><%= t.getSubjectName() %></td>
                                                <td><%= t.getStartTime() %> - <%= t.getEndTime() %></td>
                                                <td><%= t.getRoomNo() %></td>
                                            </tr>
                                        <% }
                                        } else { %>
                                            <tr><td colspan="4" class="text-center text-muted py-4">No routine available.</td></tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
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

