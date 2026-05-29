<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.LeaveApplication" %>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<LeaveApplication> leaves = (List<LeaveApplication>) request.getAttribute("leaves");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Leave Applications - Coordinator</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- Main Content -->
    <div id="main-content" style="margin-left:260px; min-height:100vh; background:#f0f2f8;">
        
        <!-- Header Include -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Leave Applications</h3>
            </div>
            
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <!-- Table of Leaves -->
            <div class="card border-0 shadow-sm custom-table">
                <div class="card-header bg-white border-0 pt-4 pb-0">
                    <h5 class="fw-bold mb-0">Pending & Reviewed Leave Requests</h5>
                </div>
                <div class="card-body mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="leaveTable">
                            <thead>
                                <tr>
                                    <th>Roll No</th>
                                    <th>Student Name</th>
                                    <th>Reason</th>
                                    <th>Dates</th>
                                    <th>Proof</th>
                                    <th>Applied On</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (leaves != null && !leaves.isEmpty()) {
                                    for (LeaveApplication l : leaves) { 
                                %>
                                    <tr>
                                        <td class="fw-bold"><%= l.getStudentRollNo() %></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="https://ui-avatars.com/api/?name=<%= l.getStudentName() %>&background=random" 
                                                     style="width: 32px; height: 32px; border-radius: 50%;">
                                                <span class="fw-semibold"><%= l.getStudentName() %></span>
                                            </div>
                                        </td>
                                        <td><span class="text-truncate d-inline-block" style="max-width: 150px;" title="<%= l.getReason() %>"><%= l.getReason() %></span></td>
                                        <td><span class="small fw-bold"><%= l.getStartDate() %><br>to<br><%= l.getEndDate() %></span></td>
                                        <td>
                                            <% String proofFile = l.getProofPath();
                                               if (proofFile != null && !proofFile.isEmpty()) { %>
                                                <a href="<%= proofFile %>" target="_blank" class="btn btn-sm btn-outline-primary rounded-pill px-3">
                                                    <i class="bi bi-file-earmark-text me-1"></i>View
                                                </a>
                                            <% } else { %>
                                                <span class="text-muted small"><i class="bi bi-dash"></i> No file</span>
                                            <% } %>
                                        </td>
                                        <td><%= l.getAppliedOn() %></td>
                                        <td>
                                            <% if("Pending".equals(l.getStatus())) { %>
                                                <span class="badge bg-warning text-dark border">Pending</span>
                                            <% } else if ("Approved".equals(l.getStatus())) { %>
                                                <span class="badge bg-success">Approved</span>
                                            <% } else { %>
                                                <span class="badge bg-danger">Rejected</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if("Pending".equals(l.getStatus())) { %>
                                            <div class="d-flex gap-2">
                                                <form action="coordinatorLeaves" method="post" class="m-0 p-0">
                                                    <input type="hidden" name="leaveId" value="<%= l.getId() %>">
                                                    <input type="hidden" name="action" value="Approve">
                                                    <button type="submit" class="btn btn-sm btn-success" title="Approve"><i class="bi bi-check-lg"></i></button>
                                                </form>
                                                <form action="coordinatorLeaves" method="post" class="m-0 p-0">
                                                    <input type="hidden" name="leaveId" value="<%= l.getId() %>">
                                                    <input type="hidden" name="action" value="Reject">
                                                    <button type="submit" class="btn btn-sm btn-danger" title="Reject"><i class="bi bi-x-lg"></i></button>
                                                </form>
                                            </div>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% }
                                } else { %>
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">No leave applications found.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
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

