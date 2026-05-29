<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Attendance> pendingAppeals = (List<Attendance>) request.getAttribute("pendingAppeals");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Appeal Approvals - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .appeal-card {
            border-left: 4px solid #f59e0b;
            transition: box-shadow 0.2s;
        }
        .appeal-card:hover {
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .status-badge-present { background: #dcfce7; color: #166534; }
        .status-badge-absent  { background: #fee2e2; color: #991b1b; }
        .empty-state-icon { font-size: 3.5rem; color: #d1d5db; }
    </style>
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1">Attendance Appeal Approvals</h3>
                    <p class="text-muted small mb-0">Review requests from teachers and coordinators to edit attendance records.</p>
                </div>
                <span class="badge fs-6 px-3 py-2"
                      style="background:#fff3cd; color:#92400e; border:1px solid #f59e0b;">
                    <i class="bi bi-hourglass-split me-1"></i>
                    <%= pendingAppeals != null ? pendingAppeals.size() : 0 %> Pending
                </span>
            </div>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0">
                    <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <% if (pendingAppeals != null && !pendingAppeals.isEmpty()) { %>

                <div class="d-flex flex-column gap-3">
                <% for (Attendance a : pendingAppeals) {
                    String dateStr = a.getDateTime() != null ? sdf.format(a.getDateTime()) : "Unknown";
                    boolean isPresent = "Present".equals(a.getStatus());
                %>
                <div class="card border-0 shadow-sm appeal-card">
                    <div class="card-body p-4">
                        <div class="row align-items-center g-3">

                            <!-- Student Info -->
                            <div class="col-md-3">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="https://ui-avatars.com/api/?name=<%= a.getStudentName() %>&background=fef3c7&color=92400e&bold=true"
                                         style="width:44px;height:44px;border-radius:50%;flex-shrink:0;">
                                    <div>
                                        <div class="fw-bold"><%= a.getStudentName() %></div>
                                        <div class="text-muted small"><%= a.getStudentRollNo() %></div>
                                    </div>
                                </div>
                            </div>

                            <!-- Subject & Teacher -->
                            <div class="col-md-3">
                                <div class="fw-semibold text-dark">
                                    <i class="bi bi-book me-1 text-primary"></i>
                                    <%= a.getSubjectCode() %> - <%= a.getSubjectName() %>
                                </div>
                                <div class="text-muted small mt-1">
                                    <i class="bi bi-person me-1"></i>By: <%= a.getTeacherName() %>
                                </div>
                                <div class="text-muted small">
                                    <i class="bi bi-calendar3 me-1"></i><%= dateStr %>
                                </div>
                            </div>

                            <!-- Current Status -->
                            <div class="col-md-2 text-center">
                                <div class="text-muted small mb-1">Current Status</div>
                                <span class="badge rounded-pill px-3 py-2 fs-6 <%= isPresent ? "status-badge-present" : "status-badge-absent" %>">
                                    <i class="bi bi-<%= isPresent ? "check-circle" : "x-circle" %> me-1"></i>
                                    <%= a.getStatus() %>
                                </span>
                            </div>

                            <!-- Actions -->
                            <div class="col-md-4">
                                <div class="d-flex flex-wrap gap-2 justify-content-end">

                                    <!-- Approve (let teacher edit) -->
                                    <form action="adminAppeals" method="post" class="m-0">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                        <button type="submit" class="btn btn-success btn-sm px-3 fw-bold"
                                                title="Approve: Teacher can then edit the record">
                                            <i class="bi bi-check-lg me-1"></i>Approve
                                        </button>
                                    </form>

                                    <!-- Admin Direct Edit -->
                                    <button class="btn btn-primary btn-sm px-3 fw-bold"
                                            data-bs-toggle="collapse"
                                            data-bs-target="#editPanel_<%= a.getId() %>"
                                            title="Edit directly as Admin (will lock the record)">
                                        <i class="bi bi-pencil-fill me-1"></i>Admin Edit
                                    </button>

                                    <!-- Reject -->
                                    <form action="adminAppeals" method="post" class="m-0"
                                          onsubmit="return confirm('Reject this appeal?');">
                                        <input type="hidden" name="action" value="reject">
                                        <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                        <button type="submit" class="btn btn-outline-danger btn-sm px-3 fw-bold">
                                            <i class="bi bi-x-lg me-1"></i>Reject
                                        </button>
                                    </form>

                                </div>

                                <!-- Inline Admin Edit Panel -->
                                <div class="collapse mt-3" id="editPanel_<%= a.getId() %>">
                                    <div class="bg-light rounded p-3 border">
                                        <p class="text-danger small fw-bold mb-2">
                                            <i class="bi bi-lock-fill me-1"></i>Admin edit permanently locks this record.
                                        </p>
                                        <form action="adminAppeals" method="post" class="d-flex gap-2 align-items-center">
                                            <input type="hidden" name="action" value="adminEdit">
                                            <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                            <select name="newStatus" class="form-select form-select-sm" style="width:140px;">
                                                <option value="Present" <%= isPresent ? "selected" : "" %>>Present</option>
                                                <option value="Absent"  <%= !isPresent ? "selected" : "" %>>Absent</option>
                                            </select>
                                            <button type="submit" class="btn btn-warning btn-sm fw-bold px-3"
                                                    onclick="return confirm('This will permanently lock the record. Continue?')">
                                                <i class="bi bi-save me-1"></i>Save & Lock
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                </div>

            <% } else { %>
                <div class="card border-0 shadow-sm">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-check-all empty-state-icon d-block mb-3 text-success"></i>
                        <h5 class="fw-bold text-muted">No Pending Appeals</h5>
                        <p class="text-muted small">All attendance appeal requests have been resolved.</p>
                        <a href="adminAttendance" class="btn btn-outline-primary mt-2">
                            <i class="bi bi-calendar-check me-1"></i>Go to Edit Attendance
                        </a>
                    </div>
                </div>
            <% } %>

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

