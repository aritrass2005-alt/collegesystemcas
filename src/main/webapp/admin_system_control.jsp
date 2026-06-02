<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    if (currentAdmin == null || (!"Admin".equals(role) && !"SuperAdmin".equals(role))) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean isSuperAdmin = "SuperAdmin".equals(role);
    Boolean maintenanceMode = (Boolean) request.getAttribute("maintenanceMode");
    Integer maxActiveSessions = (Integer) request.getAttribute("maxActiveSessions");
    Integer activeSessions = (Integer) request.getAttribute("activeSessions");
    Integer activeStudents = (Integer) request.getAttribute("activeStudents");
    Integer activeTeachers = (Integer) request.getAttribute("activeTeachers");
    Integer activeAdmins = (Integer) request.getAttribute("activeAdmins");
    if (maintenanceMode == null) maintenanceMode = false;
    if (maxActiveSessions == null) maxActiveSessions = 0;
    if (activeSessions == null) activeSessions = 0;
    if (activeStudents == null) activeStudents = 0;
    if (activeTeachers == null) activeTeachers = 0;
    if (activeAdmins == null) activeAdmins = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>System Control – CAS Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
<link href="css/theme.css?v=3" rel="stylesheet">
<style>
    .control-card {
        background: var(--bg-card);
        border: 1px solid var(--border);
        border-radius: var(--radius-lg);
        padding: 24px;
        box-shadow: var(--shadow-card);
        margin-bottom: 20px;
    }
    .control-card h5 { font-weight: 700; margin-bottom: 16px; }
    .status-indicator {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 6px 16px; border-radius: 50px; font-size: 0.85rem; font-weight: 600;
    }
    .status-on { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
    .status-off { background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; }
    .live-stat {
        background: linear-gradient(135deg, rgba(30,58,95,0.06), rgba(79,156,249,0.04));
        border: 1px solid rgba(30,58,95,0.1);
        border-radius: var(--radius-lg);
        padding: 18px;
        text-align: center;
    }
    .live-stat .number { font-size: 2rem; font-weight: 800; color: var(--primary); }
    .live-stat .label { font-size: 0.78rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
    .pulse-dot-live {
        width: 8px; height: 8px; border-radius: 50%;
        animation: pulse 1.5s ease-in-out infinite;
    }
    @keyframes pulse {
        0%, 100% { opacity:1; transform:scale(1); }
        50% { opacity:0.5; transform:scale(1.4); }
    }
</style>
</head>
<body>
<jsp:include page="includes/admin_sidebar.jsp"/>
<div id="content-wrapper">
<jsp:include page="includes/admin_header.jsp"/>
<div class="container-fluid p-0">

<div class="page-title-row">
  <div>
    <h1 class="page-title"><i class="bi bi-gear-wide-connected me-2 text-primary"></i>System Control</h1>
    <p class="page-subtitle">Maintenance mode, session limits & live traffic monitoring</p>
  </div>
</div>

<% if(request.getParameter("msg") != null) { %>
  <div class="alert-cas alert-cas-success mb-3"><i class="bi bi-check-circle-fill"></i> <%= request.getParameter("msg") %></div>
<% } %>
<% if(request.getParameter("error") != null) { %>
  <div class="alert-cas alert-cas-error mb-3"><i class="bi bi-exclamation-circle-fill"></i> <%= request.getParameter("error") %></div>
<% } %>

<!-- Live Traffic Stats -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="live-stat">
            <div class="number" id="liveTotalSessions"><%= activeSessions %></div>
            <div class="label"><div class="pulse-dot-live bg-success d-inline-block me-1"></div> Total Active</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="live-stat">
            <div class="number" id="liveStudentSessions"><%= activeStudents %></div>
            <div class="label"><i class="bi bi-mortarboard me-1"></i> Students</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="live-stat">
            <div class="number" id="liveTeacherSessions"><%= activeTeachers %></div>
            <div class="label"><i class="bi bi-person-video3 me-1"></i> Teachers</div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="live-stat">
            <div class="number" id="liveAdminSessions"><%= activeAdmins %></div>
            <div class="label"><i class="bi bi-shield-lock me-1"></i> Admins</div>
        </div>
    </div>
</div>

<div class="row g-4">
    <!-- Maintenance Mode -->
    <div class="col-lg-6">
        <div class="control-card">
            <h5><i class="bi bi-wrench-adjustable-circle me-2 text-warning"></i>Maintenance Mode</h5>
            <p class="text-muted small mb-3">
                When enabled, <strong>all students and teachers</strong> will see a maintenance page.
                Only Admin/SuperAdmin can access the portal.
            </p>
            <div class="d-flex align-items-center justify-content-between">
                <div class="status-indicator <%= maintenanceMode ? "status-on" : "status-off" %>">
                    <div class="pulse-dot-live <%= maintenanceMode ? "bg-danger" : "bg-success" %>"></div>
                    <%= maintenanceMode ? "MAINTENANCE ON" : "SYSTEM ONLINE" %>
                </div>
                <% if (isSuperAdmin) { %>
                    <form action="systemControl" method="post">
                        <input type="hidden" name="action" value="toggle_maintenance">
                        <button type="submit" class="btn <%= maintenanceMode ? "btn-success" : "btn-danger" %> btn-sm fw-bold"
                            onclick="return confirm('<%= maintenanceMode ? "Bring the system back online?" : "Put the system into maintenance mode? All non-admin users will be blocked." %>');">
                            <i class="bi bi-<%= maintenanceMode ? "play-circle" : "pause-circle" %> me-1"></i>
                            <%= maintenanceMode ? "Disable Maintenance" : "Enable Maintenance" %>
                        </button>
                    </form>
                <% } else { %>
                    <span class="badge bg-secondary">SuperAdmin Only</span>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Session Capacity Control -->
    <div class="col-lg-6">
        <div class="control-card">
            <h5><i class="bi bi-speedometer me-2 text-info"></i>Session Capacity Control</h5>
            <p class="text-muted small mb-3">
                Limit the total number of active sessions. <strong>Teachers and Admins are never blocked</strong> — only student logins are restricted when the cap is reached. Set to <code>0</code> for unlimited.
            </p>
            <div class="d-flex align-items-center justify-content-between mb-3">
                <div>
                    <span class="fw-bold">Current Limit:</span>
                    <span class="badge bg-<%= maxActiveSessions == 0 ? "success" : "warning text-dark" %> fs-6 ms-2">
                        <%= maxActiveSessions == 0 ? "∞ Unlimited" : maxActiveSessions + " max" %>
                    </span>
                </div>
                <div>
                    <span class="fw-bold">Active Now:</span>
                    <span class="badge bg-primary fs-6 ms-2" id="liveActiveNow"><%= activeSessions %></span>
                </div>
            </div>
            <form action="systemControl" method="post" class="d-flex gap-2">
                <input type="hidden" name="action" value="set_session_cap">
                <input type="number" name="maxSessions" class="form-control" value="<%= maxActiveSessions %>" min="0" placeholder="0 = unlimited" style="max-width: 140px;">
                <button type="submit" class="btn btn-primary btn-sm fw-bold px-4">
                    <i class="bi bi-check-circle me-1"></i>Apply
                </button>
            </form>
            <% if (maxActiveSessions > 0 && activeSessions >= maxActiveSessions) { %>
                <div class="alert alert-warning mt-3 mb-0 py-2 small">
                    <i class="bi bi-exclamation-triangle me-1"></i> <strong>Capacity reached!</strong> New student logins are currently being blocked.
                </div>
            <% } %>
        </div>
    </div>
</div>

</div><!-- /container -->
</div><!-- /content-wrapper -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Live-refresh stats every 5 seconds
setInterval(function() {
    fetch('systemControl?action=status')
        .then(function(r) { return r.json(); })
        .then(function(d) {
            document.getElementById('liveTotalSessions').textContent = d.activeSessions;
            document.getElementById('liveStudentSessions').textContent = d.activeStudents;
            document.getElementById('liveTeacherSessions').textContent = d.activeTeachers;
            document.getElementById('liveAdminSessions').textContent = d.activeAdmins;
            document.getElementById('liveActiveNow').textContent = d.activeSessions;
        })
        .catch(function() {});
}, 5000);

// Auto-dismiss alerts
setTimeout(function(){
    document.querySelectorAll('.alert-cas').forEach(function(e){
        e.style.transition='opacity .4s'; e.style.opacity='0';
        setTimeout(function(){e.remove();},400);
    });
}, 5000);
</script>
</body>
</html>
