<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.FacultyAttendance" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<FacultyAttendance> history = (List<FacultyAttendance>) request.getAttribute("history");
    SimpleDateFormat sdtf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    SimpleDateFormat timeOnly = new SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Attendance – CAS Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
    <style>
        .fc-theme-standard td, .fc-theme-standard th { border-radius: 8px; }
        .fc-event { border-radius: 6px; border: none; padding: 2px 4px; font-weight: 600; font-size: 0.85em; }
    </style>
</head>
<body>
    <jsp:include page="includes/teacher_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/teacher_header.jsp" />
        <div class="container-fluid p-4">
            <h3 class="fw-bold mb-4">My Attendance History</h3>
            <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius); background: white;">
                <div id="attendanceCalendar"></div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const events = [];
            <% if (history != null) {
                for (FacultyAttendance fa : history) {
                    String color = "#dc3545"; // Absent
                    if ("Present".equalsIgnoreCase(fa.getStatus())) color = "#198754";
                    else if ("Half Day".equalsIgnoreCase(fa.getStatus())) color = "#ffc107";
                    else if ("On Leave".equalsIgnoreCase(fa.getStatus())) color = "#6c757d";
                    
                    String title = fa.getStatus();
                    String inStr = fa.getCheckInTime() != null ? timeOnly.format(fa.getCheckInTime()) : "--";
                    String outStr = fa.getCheckOutTime() != null ? timeOnly.format(fa.getCheckOutTime()) : "--";
            %>
            events.push({
                title: '<%= title %>',
                start: '<%= fa.getDate() %>',
                backgroundColor: '<%= color %>',
                borderColor: 'transparent',
                textColor: '#fff',
                extendedProps: {
                    status: '<%= title %>',
                    inTime: '<%= inStr %>',
                    outTime: '<%= outStr %>',
                    hours: '<%= fa.getHoursWorked() %>'
                }
            });
            <% } } %>

            var calendar = new FullCalendar.Calendar(document.getElementById('attendanceCalendar'), {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,listMonth'
                },
                events: events,
                height: 650,
                eventDidMount: function(info) {
                    var props = info.event.extendedProps;
                    var tooltipText = props.status + '\nIn: ' + props.inTime + '\nOut: ' + props.outTime + '\nHours: ' + props.hours;
                    info.el.setAttribute('title', tooltipText);
                }
            });
            calendar.render();
        });
    </script>
</body>
</html>
