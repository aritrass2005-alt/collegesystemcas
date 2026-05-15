<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPath = request.getRequestURI();
    String activePage = currentPath.substring(currentPath.lastIndexOf("/") + 1);
    
    String roleName = (String) session.getAttribute("role");
%>
<nav id="sidebar">
    <div class="sidebar-brand">
        <i class="bi bi-box-fill text-primary"></i> CAS Admin
    </div>
    <ul class="sidebar-nav">
        <li>
            <a href="admin_dashboard.jsp" class="<%= activePage.equals("admin_dashboard.jsp") ? "active" : "" %>">
                <i class="bi bi-house-door"></i> Dashboard
            </a>
        </li>
        <% if ("SuperAdmin".equals(roleName)) { %>
        <li>
            <a href="admin_admins.jsp" class="<%= activePage.equals("admin_admins.jsp") ? "active" : "" %>">
                <i class="bi bi-shield-lock"></i> Administrators
            </a>
        </li>
        <% } %>
        <li>
            <a href="manageStudents" class="<%= activePage.contains("student") ? "active" : "" %>">
                <i class="bi bi-mortarboard"></i> Students
            </a>
        </li>
        <li>
            <a href="manageTeachers" class="<%= activePage.contains("teacher") ? "active" : "" %>">
                <i class="bi bi-person-video3"></i> Teachers
            </a>
        </li>
        <li>
            <a href="manageConfig" class="<%= activePage.equals("admin_config.jsp") || activePage.equals("manageConfig") ? "active" : "" %>">
                <i class="bi bi-building"></i> Dept & Sections
            </a>
        </li>
        <li>
            <a href="manageSubjects" class="<%= activePage.contains("subject") ? "active" : "" %>">
                <i class="bi bi-book"></i> Subjects
            </a>
        </li>
        <li>
            <a href="adminAttendance" class="<%= activePage.contains("attendance") ? "active" : "" %>">
                <i class="bi bi-calendar-check"></i> Edit Attendance
            </a>
        </li>
        <li>
            <a href="bulkUpload" class="<%= activePage.contains("upload") ? "active" : "" %>">
                <i class="bi bi-cloud-arrow-up"></i> Bulk Upload
            </a>
        </li>
        <% if ("SuperAdmin".equals(roleName)) { %>
        <li>
            <a href="dbTools" class="<%= activePage.contains("db_tools") ? "active" : "" %>">
                <i class="bi bi-database"></i> Backup & Restore
            </a>
        </li>
        <% } %>
    </ul>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const sidebar = document.getElementById("sidebar");
        const content = document.getElementById("content-wrapper");
        const toggleBtn = document.getElementById("sidebarToggle");

        if(toggleBtn) {
            toggleBtn.addEventListener("click", function() {
                sidebar.classList.toggle("collapsed");
                content.classList.toggle("expanded");
            });
        }
    });
</script>
