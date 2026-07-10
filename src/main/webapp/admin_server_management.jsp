<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.SessionInfo" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user") == null || !"SuperAdmin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Boolean maintenanceMode = (Boolean) request.getAttribute("maintenanceMode");
    Integer maxTrafficLimit = (Integer) request.getAttribute("maxTrafficLimit");
    Collection<SessionInfo> activeSessions = (Collection<SessionInfo>) request.getAttribute("activeSessions");
    
    if (maintenanceMode == null) maintenanceMode = false;
    if (maxTrafficLimit == null) maxTrafficLimit = 1000;
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Server Management - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Server & Load Management</h3>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row g-4 mb-4">
                <!-- Maintenance Mode Card -->
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm h-100" style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); color: #f8fafc; border-radius: 12px; overflow: hidden;">
                        <div class="card-body p-4 d-flex flex-column justify-content-between">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="bg-danger bg-opacity-25 text-danger rounded-circle d-flex align-items-center justify-content-center" style="width: 54px; height: 54px; font-size: 1.5rem; box-shadow: 0 0 15px rgba(220, 38, 38, 0.2);">
                                    <i class="bi bi-shield-slash"></i>
                                </div>
                                <div>
                                    <h5 class="fw-bold mb-1 d-flex align-items-center gap-2">
                                        Global Maintenance Mode
                                        <% if (maintenanceMode) { %>
                                            <span class="badge bg-danger text-white px-2 py-1 fs-6 fw-semibold rounded-pill animate-pulse">Active</span>
                                        <% } else { %>
                                            <span class="badge bg-success text-white px-2 py-1 fs-6 fw-semibold rounded-pill">Inactive</span>
                                        <% } %>
                                    </h5>
                                    <p class="mb-0 text-secondary" style="font-size: 0.875rem;">
                                        When active, only Super Admins can log in.
                                    </p>
                                </div>
                            </div>
                            <div>
                                <form action="serverManagement" method="post" id="maintenanceForm">
                                    <input type="hidden" name="action" value="toggleMaintenance">
                                    <input type="hidden" name="enable" value="<%= !maintenanceMode %>">
                                    <button type="submit" class="btn <%= maintenanceMode ? "btn-outline-success" : "btn-danger" %> px-4 py-2 w-100 fw-bold d-flex align-items-center justify-content-center gap-2" style="border-radius: 8px; transition: all 0.3s ease;">
                                        <% if (maintenanceMode) { %>
                                            <i class="bi bi-play-fill"></i> Disable Maintenance Mode
                                        <% } else { %>
                                            <i class="bi bi-pause-fill"></i> Enable Maintenance Mode
                                        <% } %>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Traffic Limit Card -->
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm custom-table h-100">
                        <div class="card-body p-4">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center" style="width: 54px; height: 54px; font-size: 1.5rem;">
                                    <i class="bi bi-speedometer2"></i>
                                </div>
                                <div>
                                    <h5 class="fw-bold mb-1">Max Traffic Limit</h5>
                                    <p class="mb-0 text-muted" style="font-size: 0.875rem;">
                                        Limit the maximum number of concurrent active users.
                                    </p>
                                </div>
                            </div>
                            <form action="serverManagement" method="post">
                                <input type="hidden" name="action" value="updateTrafficLimit">
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-people"></i></span>
                                    <input type="number" name="maxTrafficLimit" class="form-control border-start-0" value="<%= maxTrafficLimit %>" min="1" required>
                                    <button type="submit" class="btn btn-primary px-4 fw-bold">Update Limit</button>
                                </div>
                                <small class="text-muted mt-2 d-block">Current Active Users: <%= activeSessions != null ? activeSessions.size() : 0 %></small>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Active Users Table -->
            <div class="card custom-table p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                <h5 class="fw-bold mb-3 text-dark"><i class="bi bi-person-lines-fill me-2"></i>Active Sessions</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Session ID</th>
                                <th>Username</th>
                                <th>Role</th>
                                <th>Login Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (activeSessions != null && !activeSessions.isEmpty()) { 
                                for (SessionInfo info : activeSessions) { %>
                                <tr>
                                    <td><span class="badge bg-secondary"><%= info.getSessionId().substring(0, Math.min(8, info.getSessionId().length())) %>...</span></td>
                                    <td class="fw-bold"><%= info.getUsername() %></td>
                                    <td>
                                        <% if ("Student".equals(info.getRole())) { %>
                                            <span class="badge bg-primary-subtle text-primary"><%= info.getRole() %></span>
                                        <% } else if ("Teacher".equals(info.getRole())) { %>
                                            <span class="badge bg-success-subtle text-success"><%= info.getRole() %></span>
                                        <% } else { %>
                                            <span class="badge bg-danger-subtle text-danger"><%= info.getRole() %></span>
                                        <% } %>
                                    </td>
                                    <td><%= sdf.format(info.getLoginTime()) %></td>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-4">No active sessions found.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
