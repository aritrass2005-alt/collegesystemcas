<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPath = request.getRequestURI();
    String activePage = currentPath.substring(currentPath.lastIndexOf("/") + 1);
%>
<nav id="sidebar">
    <!-- Brand -->
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon" style="background: transparent; border: none;">
            <img src="img/main_logo.jpg" alt="Logo" style="height: 36px; width: 36px; object-fit: contain; border-radius: 8px;">
        </div>
        <div class="sidebar-brand-text">
            <div class="brand-name">CAS Faculty</div>
            <div class="brand-sub">Attendance System</div>
        </div>
    </div>

    <!-- Navigation -->
    <div class="sidebar-content">
        <div class="sidebar-section-label">Main Menu</div>
        <ul class="sidebar-nav">
            <li>
                <a href="teacher_dashboard.jsp" class="<%= activePage.equals("teacher_dashboard.jsp") ? "active" : "" %>">
                    <i class="bi bi-house-door"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="facultyAttendance" class="<%= activePage.contains("facultyAttendance") || activePage.contains("teacher_my_attendance.jsp") ? "active" : "" %>">
                    <i class="bi bi-calendar-event"></i>
                    <span>My Attendance</span>
                </a>
            </li>
            <li>
                <a href="takeAttendance" class="<%= activePage.contains("takeAttendance") || activePage.contains("teacher_attendance.jsp") ? "active" : "" %>">
                    <i class="bi bi-calendar-plus"></i>
                    <span>Take Attendance</span>
                </a>
            </li>
            <li>
                <a href="teacherDefaulterList" class="<%= activePage.contains("teacherDefaulterList") || activePage.contains("teacher_defaulter_list.jsp") ? "active" : "" %>">
                    <i class="bi bi-exclamation-triangle"></i>
                    <span>Defaulter List</span>
                </a>
            </li>
            <li>
                <a href="teacherStudentView" class="<%= activePage.contains("teacherStudentView") || activePage.contains("teacher_student_view.jsp") ? "active" : "" %>">
                    <i class="bi bi-mortarboard"></i>
                    <span>Student Directory</span>
                </a>
            </li>
            <li>
                <a href="teacherAttendanceView" class="<%= activePage.contains("teacherAttendanceView") || activePage.contains("teacher_attendance_view.jsp") ? "active" : "" %>">
                    <i class="bi bi-calendar-check"></i>
                    <span>Attendance History</span>
                </a>
            </li>
            <li>
                <a href="teacherTimetable" class="<%= activePage.contains("teacherTimetable") || activePage.contains("teacher_timetable.jsp") ? "active" : "" %>">
                    <i class="bi bi-clock-history"></i>
                    <span>Class Routine</span>
                </a>
            </li>

        </ul>
    </div>

    <!-- Footer -->
    <div class="sidebar-footer">
        <a href="logout" class="danger">
            <i class="bi bi-box-arrow-right"></i>
            <span>Logout</span>
        </a>
    </div>
</nav>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const sidebar   = document.getElementById("sidebar");
    const content   = document.getElementById("content-wrapper");
    const toggleBtn = document.getElementById("sidebarToggle");
    if (toggleBtn) {
        toggleBtn.addEventListener("click", function() {
            sidebar.classList.toggle("collapsed");
            content.classList.toggle("expanded");
        });
    }
});
</script>
