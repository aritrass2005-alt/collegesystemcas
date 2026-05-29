<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%
    String activePage = request.getRequestURI();
    Student sidebarStudent = (Student) session.getAttribute("user");
    String sidebarName = sidebarStudent != null ? sidebarStudent.getName() : "Student";
    String sidebarDept = sidebarStudent != null ? sidebarStudent.getDepartment() : "";
    String sidebarRoll = sidebarStudent != null ? sidebarStudent.getRollNo() : "";
%>

<nav id="sidebar">
    <!-- Brand -->
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon" style="background: transparent; border: none;">
            <img src="img/main_logo.jpg" alt="Logo" style="height: 36px; width: 36px; object-fit: contain; border-radius: 8px;">
        </div>
        <div class="sidebar-brand-text">
            <div class="brand-name">Student Portal</div>
            <div class="brand-sub">Attendance System</div>
        </div>
    </div>

    <!-- Navigation -->
    <div class="sidebar-content">
        <div class="sidebar-section-label">Main Menu</div>
        <ul class="sidebar-nav">
            <li>
                <a href="studentDashboard"
                   class="<%= activePage.contains("studentDashboard") || activePage.contains("student_dashboard") ? "active" : "" %>">
                    <i class="bi bi-grid-1x2-fill"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="studentLeave"
                   class="<%= activePage.contains("studentLeave") || activePage.contains("student_leave") ? "active" : "" %>">
                    <i class="bi bi-envelope-paper-fill"></i>
                    <span>Leave Application</span>
                </a>
            </li>
            <li>
                <a href="studentTimetable"
                   class="<%= activePage.contains("studentTimetable") || activePage.contains("student_timetable") ? "active" : "" %>">
                    <i class="bi bi-clock-history"></i>
                    <span>Class Routine</span>
                </a>
            </li>
        </ul>
    </div>

    <!-- Footer / Logout -->
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
            if (content) {
                content.classList.toggle("expanded");
            }
        });
    }
});
</script>
