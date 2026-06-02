<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPath = request.getRequestURI();
    String activePage = currentPath.substring(currentPath.lastIndexOf("/") + 1);
    String roleName = (String) session.getAttribute("role");
%>
<nav id="sidebar">
    <!-- Brand -->
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon" style="background: transparent; border: none;">
            <img src="img/main_logo.jpg" alt="Logo" style="height: 36px; width: 36px; object-fit: contain; border-radius: 8px;">
        </div>
        <div class="sidebar-brand-text">
            <div class="brand-name">CAS Admin</div>
            <div class="brand-sub">Administration</div>
        </div>
    </div>

    <!-- Navigation -->
    <div class="sidebar-content">
        <div class="sidebar-section-label">Management</div>
        <ul class="sidebar-nav">
            <li>
                <a href="admin_dashboard.jsp" class="<%= activePage.equals("admin_dashboard.jsp") ? "active" : "" %>">
                    <i class="bi bi-house-door"></i> <span>Dashboard</span>
                </a>
            </li>
            <% if ("SuperAdmin".equals(roleName)) { %>
            <li>
                <a href="manageAdmins" class="<%= activePage.equals("admin_admins.jsp") || activePage.equals("manageAdmins") ? "active" : "" %>">
                    <i class="bi bi-shield-lock"></i> <span>Administrators</span>
                </a>
            </li>
            <% } %>
            <li>
                <a href="manageStudents" class="<%= activePage.contains("student") ? "active" : "" %>">
                    <i class="bi bi-mortarboard"></i> <span>Students</span>
                </a>
            </li>
            <li>
                <a href="manageTeachers" class="<%= activePage.contains("teacher") && request.getParameter("filter") == null ? "active" : "" %>">
                    <i class="bi bi-person-video3"></i> <span>Teachers</span>
                </a>
            </li>
            <li>
                <a href="manageTeachers?filter=pending" class="<%= activePage.contains("teacher") && "pending".equals(request.getParameter("filter")) ? "active" : "" %>" style="position:relative;">
                    <i class="bi bi-person-check"></i> <span>Faculty Approvals</span>
                    <%
                        int _pendingTeachers = 0;
                        try (java.sql.Connection _c = com.college.attendance.util.DBConnection.getConnection();
                             java.sql.PreparedStatement _ps = _c.prepareStatement("SELECT COUNT(*) FROM teacher WHERE is_approved = 0");
                             java.sql.ResultSet _rs = _ps.executeQuery()) {
                             if(_rs.next()) _pendingTeachers = _rs.getInt(1);
                        } catch(Exception e){}
                        if (_pendingTeachers > 0) {
                    %>
                    <span class="badge bg-danger ms-auto" style="font-size:0.7rem;padding:2px 7px;border-radius:20px;"><%= _pendingTeachers %></span>
                    <% } %>
                </a>
            </li>
            <li>
                <a href="adminFacultyAttendance" class="<%= activePage.contains("adminFacultyAttendance") || activePage.contains("admin_faculty_attendance.jsp") ? "active" : "" %>">
                    <i class="bi bi-person-lines-fill"></i> <span>Faculty Attendance</span>
                </a>
            </li>
            <li>
                <a href="manageCoordinator" class="<%= activePage.contains("Coordinator") || activePage.contains("coordinat") ? "active" : "" %>">
                    <i class="bi bi-person-badge"></i> <span>Coordinators</span>
                </a>
            </li>
            <li>
                <a href="manageConfig" class="<%= activePage.equals("admin_config.jsp") || activePage.equals("manageConfig") ? "active" : "" %>">
                    <i class="bi bi-building"></i> <span>Dept &amp; Sections</span>
                </a>
            </li>
            <li>
                <a href="manageSubjects" class="<%= activePage.contains("subject") ? "active" : "" %>">
                    <i class="bi bi-book"></i> <span>Subjects</span>
                </a>
            </li>
            <li>
                <a href="manageTimetable" class="<%= activePage.contains("timetable") ? "active" : "" %>">
                    <i class="bi bi-clock-history"></i> <span>Timetable</span>
                </a>
            </li>
            <li>
                <a href="admin_notifications.jsp" class="<%= activePage.equals("admin_notifications.jsp") ? "active" : "" %>">
                    <i class="bi bi-megaphone"></i> <span>Announcements</span>
                </a>
            </li>
            <li>
                <a href="adminAttendance" class="<%= (activePage.contains("adminAttendance") || activePage.contains("admin_attendance.jsp")) ? "active" : "" %>">
                    <i class="bi bi-calendar-check"></i> <span>Edit Attendance</span>
                </a>
            </li>
            <li>
                <a href="adminAppeals" class="<%= activePage.contains("appeal") || activePage.contains("Appeals") ? "active" : "" %>" style="position:relative;">
                    <i class="bi bi-envelope-exclamation"></i>
                    <span>Appeal Approvals</span>
                    <%
                        // Show live pending count badge
                        com.college.attendance.dao.AttendanceDAO _aDao = new com.college.attendance.dao.AttendanceDAO();
                        int _pendingCount = _aDao.getPendingAppeals().size();
                        if (_pendingCount > 0) {
                    %>
                    <span class="badge bg-danger ms-auto" style="font-size:0.7rem;padding:2px 7px;border-radius:20px;"><%= _pendingCount %></span>
                    <% } %>
                </a>
            </li>
            <li>
                <a href="bulkUpload" class="<%= activePage.contains("upload") ? "active" : "" %>">
                    <i class="bi bi-cloud-arrow-up"></i> <span>Bulk Upload</span>
                </a>
            </li>
            <li>
                <a href="chat.jsp" class="<%= activePage.equals("chat.jsp") ? "active" : "" %>">
                    <i class="bi bi-chat-dots"></i> <span>Department Chat</span>
                </a>
            </li>
            <li>
                <a href="systemControl" class="<%= activePage.contains("systemControl") || activePage.contains("system_control") ? "active" : "" %>">
                    <i class="bi bi-sliders"></i> <span>System Control</span>
                </a>
            </li>
            <% if ("SuperAdmin".equals(roleName)) { %>
            <li>
                <a href="dbTools" class="<%= activePage.contains("db_tools") ? "active" : "" %>">
                    <i class="bi bi-database"></i> <span>Backup &amp; Restore</span>
                </a>
            </li>
            <% } %>
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
