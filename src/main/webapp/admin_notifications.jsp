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
    <title>Mass Notifications - Admin CAS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    
    <jsp:include page="includes/admin_sidebar.jsp" />

    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Broadcast Mass Notifications</h3>
            
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0"><i class="bi bi-check-circle me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0"><i class="bi bi-exclamation-triangle me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <div class="card border-0 shadow-sm" style="border-radius: var(--card-radius);">
                <div class="card-header bg-white border-bottom p-4">
                    <h5 class="fw-bold mb-0 text-primary"><i class="bi bi-megaphone-fill me-2"></i>System-wide Broadcast</h5>
                </div>
                <div class="card-body p-4">
                    <div class="alert alert-info border-0 bg-info bg-opacity-10 text-dark mb-4">
                        <i class="bi bi-info-circle-fill text-info me-2"></i>
                        <strong>Admin Override:</strong> These messages bypass standard filters and can reach every student or all defaulters instantly.
                    </div>

                    <form action="sendNotification" method="post" enctype="multipart/form-data">
                        
                        <div class="row mb-4 g-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold text-dark">Target Scope</label>
                                <select class="form-select bg-light" name="targetType" id="targetType" required>
                                    <option value="ALL">Entire College (All Students)</option>
                                    <option value="DEFAULTERS">Global Defaulters</option>
                                </select>
                            </div>
                            <div class="col-md-3 d-none" id="thresholdDiv">
                                <label class="form-label fw-bold text-dark">Defaulter Threshold (%)</label>
                                <input type="number" step="0.1" class="form-control bg-light" name="defaulterThreshold" id="defaulterThreshold" value="75" placeholder="e.g. 75">
                            </div>
                            <!-- Admins bypass department/year/section filters by passing null/0 -->
                            <input type="hidden" name="department" value="">
                            <input type="hidden" name="year" value="0">
                            <input type="hidden" name="section" value="">
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold text-dark">Announcement Title</label>
                            <input type="text" class="form-control bg-light" name="title" required placeholder="e.g. Urgent: College Closed Tomorrow">
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark">Message Details</label>
                            <textarea class="form-control bg-light" name="message" rows="5" required placeholder="Type the system announcement here..."></textarea>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark"><i class="bi bi-paperclip me-1"></i>Attach Document (Optional)</label>
                            <input type="file" class="form-control bg-light" name="attachment">
                            <div class="form-text">Supported formats: PDF, Images, Word (Max 10MB)</div>
                        </div>

                        <button type="submit" class="btn btn-primary px-5 fw-bold" style="border-radius: 8px;"><i class="bi bi-broadcast-pin me-2"></i>Broadcast Now</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('targetType').addEventListener('change', function() {
            if(this.value === 'DEFAULTERS') {
                document.getElementById('thresholdDiv').classList.remove('d-none');
                document.getElementById('defaulterThreshold').required = true;
            } else {
                document.getElementById('thresholdDiv').classList.add('d-none');
                document.getElementById('defaulterThreshold').required = false;
            }
        });
    </script>
</body>
</html>
