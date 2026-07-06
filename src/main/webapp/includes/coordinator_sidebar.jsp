<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher coordTeacher = (Teacher) session.getAttribute("user");
    String activePage = request.getRequestURI();
    String photoUrl = coordTeacher != null && coordTeacher.getProfilePhoto() != null && !coordTeacher.getProfilePhoto().isEmpty()
        ? coordTeacher.getProfilePhoto()
        : "https://ui-avatars.com/api/?name=" + (coordTeacher != null ? java.net.URLEncoder.encode(coordTeacher.getName(), "UTF-8") : "Coord") + "&background=1e3a5f&color=fff&bold=true&size=80";

    Integer pLeaves = (Integer) request.getAttribute("pendingLeaves");
    int sidebarPendingLeaves = pLeaves != null ? pLeaves : 0;

    Integer dCount = (Integer) request.getAttribute("defaulterCount");
    int sidebarDefaulterCount = dCount != null ? dCount : 0;
%>

<nav id="coord-sidebar">
    <!-- Brand -->
    <div class="sidebar-brand coord-brand">
        <div class="sidebar-brand-icon" style="background: transparent; border: none;">
            <img src="img/main_logo.jpg" alt="Logo" style="height: 36px; width: 36px; object-fit: contain; border-radius: 8px;">
        </div>
        <div class="sidebar-brand-text">
            <div class="brand-name">Coordinator</div>
            <div class="brand-sub">Control Panel</div>
        </div>
    </div>

    <!-- Navigation -->
    <div class="sidebar-content">
        <div class="sidebar-section-label">Navigation</div>
        <div class="sidebar-nav-item">
            <a href="coordinatorDashboard" class="<%= activePage.contains("coordinatorDashboard") || activePage.contains("coordinator_dashboard.jsp") ? "active" : "" %>">
                <i class="bi bi-speedometer2"></i> <span>Dashboard</span>
            </a>
        </div>
        <div class="sidebar-nav-item">
            <a href="coordinatorStudents" class="<%= activePage.contains("coordinatorStudents") || activePage.contains("coordinator_students.jsp") ? "active" : "" %>">
                <i class="bi bi-people-fill"></i> <span>Section Students</span>
            </a>
        </div>
        <div class="sidebar-nav-item">
            <a href="coordinatorLeaves" class="<%= activePage.contains("coordinatorLeaves") || activePage.contains("coordinator_leaves.jsp") ? "active" : "" %>">
                <i class="bi bi-envelope-paper-fill"></i>
                <span>Leave Applications</span>
                <% if (sidebarPendingLeaves > 0) { %>
                <span class="badge-cas badge-warning ms-auto"><%= sidebarPendingLeaves %></span>
                <% } %>
            </a>
        </div>
        <div class="sidebar-nav-item">
            <a href="coordinatorDefaulterList" class="<%= activePage.contains("coordinatorDefaulterList") || activePage.contains("coordinator_defaulters.jsp") ? "active" : "" %>">
                <i class="bi bi-exclamation-octagon-fill"></i>
                <span>Section Defaulters</span>
                <% if (sidebarDefaulterCount > 0) { %>
                <span class="badge-cas badge-danger ms-auto"><%= sidebarDefaulterCount %></span>
                <% } %>
            </a>
        </div>
        <div class="sidebar-nav-item">
            <a href="parentAlertLogs" class="<%= activePage.contains("parentAlertLogs") || activePage.contains("parent_alert_logs.jsp") ? "active" : "" %>">
                <i class="bi bi-send-exclamation-fill"></i> <span>Parent Alerts</span>
            </a>
        </div>
        <div class="sidebar-nav-item">
            <a href="coordinatorAttendanceView" class="<%= activePage.contains("coordinatorAttendanceView") || activePage.contains("coordinator_attendance_view.jsp") ? "active" : "" %>">
                <i class="bi bi-calendar-check-fill"></i>
                <span>Attendance History</span>
            </a>
        </div>
        <div class="sidebar-nav-item">
            <a href="coordinator_notifications.jsp" class="<%= activePage.contains("coordinator_notifications.jsp") ? "active" : "" %>">
                <i class="bi bi-send-fill"></i>
                <span>Send Notices</span>
            </a>
        </div>
    </div>

    <!-- Footer -->
    <div class="sidebar-footer">
        <a href="teacher_dashboard.jsp">
            <i class="bi bi-person-video3"></i>
            <span>Switch to Teacher View</span>
        </a>
        <a href="chat" class="<%= activePage.contains("chat") || activePage.contains("staff_chat") ? "active" : "" %>" style="background: rgba(79,156,249,0.08); border-color: rgba(79,156,249,0.2);">
            <i class="bi bi-chat-dots-fill" style="color: #4f9cf9;"></i>
            <span>Staff Chat</span>
        </a>
        <a href="logout" class="danger">
            <i class="bi bi-box-arrow-right"></i>
            <span>Logout</span>
        </a>
    </div>
</nav>
