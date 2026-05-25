<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.LeaveApplication" %>
<%@ page import="java.util.List" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }
    List<LeaveApplication> leaves = (List<LeaveApplication>) request.getAttribute("leaves");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Leave Application &ndash; CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        body { overflow-x: hidden; }
        .glass-card {
            background: #fff;
            border-radius: var(--radius-xl);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-card);
        }
        .glass-card:hover { box-shadow: 0 8px 24px rgba(15,34,64,0.10); }

        .status-timeline {
            position: relative;
            padding-left: 40px;
            margin: 20px 0;
        }
        .status-timeline::before {
            content: '';
            position: absolute;
            left: 15px; top: 0; bottom: 0;
            width: 2px;
            background: var(--border);
        }
        .timeline-item { position: relative; margin-bottom: 25px; }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -32px; top: 4px;
            width: 16px; height: 16px;
            border-radius: 50%;
            background: #fff;
            border: 3px solid;
            z-index: 2;
        }
        .timeline-item.approved::before { border-color: #16a34a; background: #16a34a; }
        .timeline-item.pending::before  { border-color: #d97706; background: #d97706; }
        .timeline-item.rejected::before { border-color: #dc2626; background: #dc2626; }
        
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(30,58,95,0.07);
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <jsp:include page="includes/student_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        <jsp:include page="includes/student_header.jsp" />

        <div class="container-fluid p-4 p-md-5">
            <h3 class="fw-bold mb-4"><i class="bi bi-envelope-paper-fill text-info me-2"></i> Leave Application</h3>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <div class="row g-4">
                <!-- Apply Form -->
                <div class="col-xl-5">
                    <div class="glass-card p-4">
                        <h5 class="fw-bold mb-4">Submit New Leave</h5>
                        <form action="studentLeave" method="post" enctype="multipart/form-data">
                            <div class="row g-3 mb-3">
                                <div class="col-6">
                                    <label class="form-label fw-bold text-muted small">Start Date</label>
                                    <input type="date" name="start_date" class="form-control bg-light" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label fw-bold text-muted small">End Date</label>
                                    <input type="date" name="end_date" class="form-control bg-light" required>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Reason for Leave</label>
                                <textarea name="reason" class="form-control bg-light" rows="4" required placeholder="Provide a detailed reason..."></textarea>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted small">Proof of Leaving (Optional)</label>
                                <input class="form-control bg-light" type="file" name="proof">
                            </div>

                            <div class="form-check mb-4 mt-3 p-3 bg-light rounded border">
                                <input class="form-check-input ms-1 mt-2" type="checkbox" name="declaration" value="true" id="declaration" required>
                                <label class="form-check-label ms-2 small fw-semibold" for="declaration">
                                    I declare that the information provided is true. I understand providing false information may result in disciplinary action.
                                </label>
                            </div>
                            
                            <button type="submit" class="btn-cas-primary w-100 py-2">
                                Submit Application <i class="bi bi-send ms-2"></i>
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Live Tracking -->
                <div class="col-xl-7">
                    <div class="glass-card p-4 h-100">
                        <h5 class="fw-bold mb-4">Leave Status Tracker</h5>
                        
                        <div class="status-timeline">
                            <% if (leaves != null && !leaves.isEmpty()) {
                                for(LeaveApplication l : leaves) { 
                                    String statusClass = l.getStatus().toLowerCase();
                            %>
                            <div class="timeline-item <%= statusClass %>">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <h6 class="fw-bold m-0"><%= l.getStartDate() %> to <%= l.getEndDate() %></h6>
                                    <span class="badge bg-<%= "pending".equals(statusClass) ? "warning text-dark" : ("approved".equals(statusClass) ? "success" : "danger") %> px-3 rounded-pill">
                                        <%= l.getStatus() %>
                                    </span>
                                </div>
                                <p class="text-muted small mb-2">Applied on: <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(l.getAppliedOn()) %></p>
                                <div class="p-3 bg-light rounded border">
                                    <p class="mb-0 small"><%= l.getReason() %></p>
                                </div>
                            </div>
                            <%  }
                            } else { %>
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-inbox fs-1 mb-3 d-block text-secondary opacity-50"></i>
                                You have no leave applications yet.
                            </div>
                            <% } %>
                        </div>
                        
                    </div>
                </div>
            </div>
        </div>
    </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('sidebarCollapse')?.addEventListener('click', function() {
        document.getElementById('sidebar').classList.toggle('active');
    });
</script>
</body>
</html>
