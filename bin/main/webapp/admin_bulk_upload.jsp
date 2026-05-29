<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Bulk Upload - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .upload-area {
            border: 2px dashed var(--primary);
            border-radius: var(--card-radius);
            padding: 40px;
            text-align: center;
            background: rgba(123, 44, 191, 0.03);
            transition: all 0.2s;
            cursor: pointer;
        }
        .upload-area:hover {
            background: rgba(123, 44, 191, 0.08);
        }
    </style>
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">CSV Bulk Upload</h3>

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
                        <h5 class="fw-bold mb-3 text-primary"><i class="bi bi-mortarboard me-2"></i>Upload Students</h5>
                        <p class="text-muted small mb-4">Upload a CSV file containing student records. Use the exact column format as the sample.</p>
                        
                        <div class="mb-3">
                            <a href="bulkUpload?type=student" class="btn btn-sm btn-outline-primary"><i class="bi bi-download"></i> Download Sample CSV</a>
                        </div>
                        
                        <form action="bulkUpload" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="uploadType" value="student">
                            <div class="upload-area mb-3" onclick="document.getElementById('studentFile').click()">
                                <i class="bi bi-cloud-arrow-up fs-1 text-primary mb-2"></i>
                                <h6 class="fw-bold">Click to select CSV file</h6>
                                <p class="text-muted small m-0" id="studentFileName">No file chosen</p>
                                <input type="file" name="csvFile" id="studentFile" class="d-none" accept=".csv" onchange="document.getElementById('studentFileName').innerText = this.files[0] ? this.files[0].name : 'No file chosen'">
                            </div>
                            <button type="submit" class="btn btn-primary-custom w-100">Upload Students</button>
                        </form>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                        <h5 class="fw-bold mb-3 text-success"><i class="bi bi-person-video3 me-2"></i>Upload Teachers</h5>
                        <p class="text-muted small mb-4">Upload a CSV file containing teacher records. Password will default to 'teacher123'.</p>
                        
                        <div class="mb-3">
                            <a href="bulkUpload?type=teacher" class="btn btn-sm btn-outline-success"><i class="bi bi-download"></i> Download Sample CSV</a>
                        </div>
                        
                        <form action="bulkUpload" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="uploadType" value="teacher">
                            <div class="upload-area mb-3" onclick="document.getElementById('teacherFile').click()" style="border-color: #198754; background: rgba(25, 135, 84, 0.03);">
                                <i class="bi bi-cloud-arrow-up fs-1 text-success mb-2"></i>
                                <h6 class="fw-bold">Click to select CSV file</h6>
                                <p class="text-muted small m-0" id="teacherFileName">No file chosen</p>
                                <input type="file" name="csvFile" id="teacherFile" class="d-none" accept=".csv" onchange="document.getElementById('teacherFileName').innerText = this.files[0] ? this.files[0].name : 'No file chosen'">
                            </div>
                            <button type="submit" class="btn btn-success w-100" style="border-radius: 8px;">Upload Teachers</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
