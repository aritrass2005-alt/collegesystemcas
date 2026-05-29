<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%@ page import="com.college.attendance.model.ActivityLog" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("user");
    if (currentAdmin == null || session.getAttribute("role") == null || !((String)session.getAttribute("role")).contains("Admin")) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<ActivityLog> logs = (List<ActivityLog>) request.getAttribute("logs");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy hh:mm a");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Activity Log - CAS Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold m-0"><i class="bi bi-activity text-primary me-2"></i> System Activity Log</h3>
            </div>

            <div class="card custom-table border-0 shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Timestamp</th>
                                <th>User Type</th>
                                <th>User Name</th>
                                <th>Action Performed</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (logs != null && !logs.isEmpty()) { 
                                for(ActivityLog log : logs) { 
                                    String badgeClass = "bg-secondary";
                                    if ("Admin".equals(log.getUserType()) || "SuperAdmin".equals(log.getUserType())) badgeClass = "bg-danger";
                                    else if ("Teacher".equals(log.getUserType()) || "Coordinator".equals(log.getUserType())) badgeClass = "bg-primary";
                                    else if ("Student".equals(log.getUserType())) badgeClass = "bg-success";
                            %>
                                <tr>
                                    <td class="text-muted small"><%= sdf.format(log.getCreatedAt()) %></td>
                                    <td><span class="badge <%= badgeClass %>"><%= log.getUserType() %></span></td>
                                    <td class="fw-bold"><%= log.getUserName() %></td>
                                    <td><%= log.getAction() %></td>
                                </tr>
                            <%  } 
                               } else { %>
                                <tr>
                                    <td colspan="4" class="text-center py-5 text-muted">No activities recorded yet.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
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
</body>
</html>

