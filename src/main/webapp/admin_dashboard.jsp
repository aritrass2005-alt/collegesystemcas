<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.college.attendance.util.DBConnection" %>
<%@ page import="com.college.attendance.listener.ActiveSessionListener" %>
<%
    Admin admin = (Admin) session.getAttribute("user");
    if (admin == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }

    int studentCount = 0;
    int teacherCount = 0;
    int deptCount = 0;
    int subjectCount = 0;
    int pendingTeacherCount = 0;

    try (Connection conn = DBConnection.getConnection()) {
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM student"); ResultSet rs = ps.executeQuery()) { if(rs.next()) studentCount = rs.getInt(1); }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM teacher"); ResultSet rs = ps.executeQuery()) { if(rs.next()) teacherCount = rs.getInt(1); }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM department"); ResultSet rs = ps.executeQuery()) { if(rs.next()) deptCount = rs.getInt(1); }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM subject"); ResultSet rs = ps.executeQuery()) { if(rs.next()) subjectCount = rs.getInt(1); }
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM teacher WHERE is_approved = 0"); ResultSet rs = ps.executeQuery()) { if(rs.next()) pendingTeacherCount = rs.getInt(1); }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/admin_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold m-0">Admin Dashboard</h3>
                <div class="d-none d-md-flex gap-3 align-items-center">
                    <span class="badge bg-success-subtle text-success px-3 py-2 rounded-pill shadow-sm"><i class="bi bi-database-check me-1"></i> DB Active</span>
                    <span class="badge bg-primary-subtle text-primary px-3 py-2 rounded-pill shadow-sm"><i class="bi bi-people-fill me-1"></i> <span id="activeUsersBadge"><%= com.college.attendance.listener.ActiveSessionListener.getActiveSessions() %></span> Active Users</span>
                    <% if (pendingTeacherCount > 0) { %>
                    <span class="badge bg-danger-subtle text-danger px-3 py-2 rounded-pill shadow-sm"><i class="bi bi-person-exclamation me-1"></i> <%= pendingTeacherCount %> Pending Approvals</span>
                    <% } %>
                </div>
            </div>
            
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <a href="manageStudents" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Students</p>
                                <h3><%= studentCount %></h3>
                            </div>
                            <div class="metric-icon bg-purple-light">
                                <i class="bi bi-mortarboard"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="manageTeachers" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Teachers</p>
                                <h3><%= teacherCount %></h3>
                            </div>
                            <div class="metric-icon bg-blue-light">
                                <i class="bi bi-person-video3"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="admin_config.jsp" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Departments</p>
                                <h3><%= deptCount %></h3>
                            </div>
                            <div class="metric-icon bg-orange-light">
                                <i class="bi bi-building"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="manageSubjects" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Subjects</p>
                                <h3><%= subjectCount %></h3>
                            </div>
                            <div class="metric-icon bg-green-light">
                                <i class="bi bi-book"></i>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
            
            <style>
                .hover-elevate {
                    transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.2s;
                    cursor: pointer;
                    border: 1px solid rgba(0,0,0,0.03) !important;
                }
                .hover-elevate:hover {
                    transform: translateY(-3px);
                    box-shadow: 0 8px 15px rgba(0,0,0,0.08) !important;
                    border-color: rgba(0,0,0,0.08) !important;
                }
                .bg-indigo-light { background: #e0e7ff; color: #4338ca; }
                .bg-teal-light { background: #ccfbf1; color: #0f766e; }
                .bg-rose-light { background: #ffe4e6; color: #be123c; }
            </style>

            <!-- College Management Grid -->
            <div class="mb-4">
                <h5 class="fw-bold mb-3 text-primary"><i class="bi bi-building me-2"></i>College Management</h5>
                <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                    
                    <div class="col">
                        <a href="manageStudents" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-mortarboard"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Students</h6>
                                    <small class="text-muted">Manage directory</small>
                                </div>
                            </div>
                        </a>
                    </div>
                    
                    <div class="col">
                        <a href="manageTeachers" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-success-subtle text-success rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-person-video3"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Teachers</h6>
                                    <small class="text-muted">Approve & manage</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="adminFacultyAttendance" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-indigo-light rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-person-lines-fill"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Faculty Attendance</h6>
                                    <small class="text-muted">Track check-ins</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="manageCoordinator" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-person-badge"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Coordinators</h6>
                                    <small class="text-muted">Assign roles</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="manageSubjects" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-warning-subtle text-warning rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem; color: #b7791f !important;">
                                    <i class="bi bi-book"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Subjects</h6>
                                    <small class="text-muted">Curriculum setup</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="manageTimetable" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-danger-subtle text-danger rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-clock-history"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Timetable</h6>
                                    <small class="text-muted">Class schedules</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="adminAttendance" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-teal-light rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-calendar-check"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Edit Attendance</h6>
                                    <small class="text-muted">Admin overrides</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="adminAppeals" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-rose-light rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-envelope-exclamation"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Appeals</h6>
                                    <small class="text-muted">Review requests</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="parentAlertLogs" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-send-exclamation"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Parent Alerts</h6>
                                    <small class="text-muted">Comms log</small>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>

            <!-- System Management Grid -->
            <div class="mb-4">
                <h5 class="fw-bold mb-3 text-secondary"><i class="bi bi-gear me-2"></i>System Management</h5>
                <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                    
                    <div class="col">
                        <a href="manageConfig" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-info bg-opacity-10 text-info rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-sliders"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Configuration</h6>
                                    <small class="text-muted">Depts & Years</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="admin_notifications.jsp" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-warning-subtle text-warning rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem; color: #b7791f !important;">
                                    <i class="bi bi-megaphone"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Announcements</h6>
                                    <small class="text-muted">Broadcast alerts</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="bulkUpload" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-success-subtle text-success rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-cloud-arrow-up"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Bulk Upload</h6>
                                    <small class="text-muted">CSV imports</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="adminLogs" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-danger-subtle text-danger rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-activity"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Activity Log</h6>
                                    <small class="text-muted">System audit</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <% if ("SuperAdmin".equals(session.getAttribute("role"))) { %>
                    <div class="col">
                        <a href="manageAdmins" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-shield-lock"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Administrators</h6>
                                    <small class="text-muted">Manage access</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="serverManagement" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-server"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Server Load</h6>
                                    <small class="text-muted">Traffic & users</small>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col">
                        <a href="dbTools" class="text-decoration-none text-dark">
                            <div class="card border-0 shadow-sm p-3 d-flex flex-row align-items-center gap-3 h-100 hover-elevate">
                                <div class="bg-indigo-light rounded-circle d-flex align-items-center justify-content-center flex-shrink-0" style="width: 50px; height: 50px; font-size: 1.5rem;">
                                    <i class="bi bi-database"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1">Backup/Restore</h6>
                                    <small class="text-muted">Data tools</small>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>

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
<script>
    setInterval(function() {
        fetch('active_users_count.jsp')
            .then(response => response.text())
            .then(text => {
                const count = text.trim();
                if(count) {
                    const badge = document.getElementById('activeUsersBadge');
                    if(badge) badge.innerText = count;
                }
            })
            .catch(e => console.error('Error fetching active users', e));
    }, 5000); // Poll every 5 seconds
</script>
</body>
</html>




