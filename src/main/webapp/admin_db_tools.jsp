<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("user") == null || !"SuperAdmin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access. SuperAdmin only.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Database Tools - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Database Backup & Restore</h3>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <div class="row g-4">
                <div class="col-md-6">
                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                        <h5 class="fw-bold mb-3 text-primary"><i class="bi bi-cloud-arrow-down me-2"></i>Backup Database</h5>
                        <p class="text-muted small mb-4">Generate a full backup of the College Attendance System database. This will download a <code>.sql</code> file containing all tables, structures, and data.</p>
                        
                        <a href="dbTools?action=backup" class="btn btn-primary-custom w-100" onclick="return confirm('Generate backup now? This might take a moment depending on database size.');">
                            <i class="bi bi-download me-2"></i> Download Backup File
                        </a>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                        <h5 class="fw-bold mb-3 text-danger"><i class="bi bi-arrow-counterclockwise me-2"></i>Restore Database</h5>
                        <p class="text-muted small mb-4">Upload a previously generated <code>.sql</code> backup file to restore the database. <strong class="text-danger">Warning: This will overwrite current data!</strong></p>
                        
                        <form action="dbTools" method="post" enctype="multipart/form-data" onsubmit="return confirm('WARNING: Are you absolutely sure? This will overwrite all current data in the database with the backup file data.');">
                            <div class="mb-3">
                                <input type="file" name="sqlFile" class="form-control" accept=".sql" required>
                            </div>
                            <button type="submit" class="btn btn-danger w-100" style="border-radius: 8px;">
                                <i class="bi bi-upload me-2"></i> Restore Database
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
