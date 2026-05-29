<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.college.attendance.util.DBConnection" %>
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
            <h3 class="fw-bold mb-4">Admin Dashboard</h3>
            
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
            
            <div class="row g-4">
                <div class="col-md-8">
                    <div class="card custom-table p-4 border-0">
                        <h5 class="fw-bold mb-3">Quick Actions</h5>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <a href="manageStudents" class="text-decoration-none">
                                    <div class="p-3 border rounded d-flex align-items-center gap-3 bg-light text-dark hover-shadow">
                                        <i class="bi bi-person-plus fs-4 text-primary"></i>
                                        <div>
                                            <h6 class="mb-0 fw-bold">Manage Students</h6>
                                            <small class="text-muted">Add, update or remove students</small>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="manageTeachers" class="text-decoration-none">
                                    <div class="p-3 border rounded d-flex align-items-center gap-3 bg-light text-dark hover-shadow">
                                        <i class="bi bi-person-check fs-4 text-success"></i>
                                        <div>
                                            <h6 class="mb-0 fw-bold">Manage Teachers</h6>
                                            <small class="text-muted">Approve and manage faculty</small>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="manageSubjects" class="text-decoration-none">
                                    <div class="p-3 border rounded d-flex align-items-center gap-3 bg-light text-dark hover-shadow">
                                        <i class="bi bi-journal-bookmark fs-4 text-warning"></i>
                                        <div>
                                            <h6 class="mb-0 fw-bold">Manage Subjects</h6>
                                            <small class="text-muted">Assign subjects and track curriculum</small>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="admin_config.jsp" class="text-decoration-none">
                                    <div class="p-3 border rounded d-flex align-items-center gap-3 bg-light text-dark hover-shadow">
                                        <i class="bi bi-gear fs-4 text-info"></i>
                                        <div>
                                            <h6 class="mb-0 fw-bold">Configuration</h6>
                                            <small class="text-muted">Configure Depts, Sections & Years</small>
                                        </div>
                                    </div>
                                </a>
                            </div>
                            <div class="col-md-6">
                                <a href="adminLogs" class="text-decoration-none">
                                    <div class="p-3 border rounded d-flex align-items-center gap-3 bg-light text-dark hover-shadow">
                                        <i class="bi bi-activity fs-4 text-danger"></i>
                                        <div>
                                            <h6 class="mb-0 fw-bold">Activity Log</h6>
                                            <small class="text-muted">View system activity and audit logs</small>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                        <h5 class="fw-bold mb-3">System Status</h5>
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                Database Connection
                                <span class="badge bg-success rounded-pill">Active</span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                Last Backup
                                <span class="text-muted small">Never</span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                Pending Approvals (Teachers)
                                <span class="badge bg-danger rounded-pill"><%= pendingTeacherCount %></span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
