<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Attendance" %>
<%@ page import="com.college.attendance.model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Attendance> pendingAppeals = (List<Attendance>) request.getAttribute("pendingAppeals");
    List<Attendance> appealHistory = (List<Attendance>) request.getAttribute("appealHistory");
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat sdtf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
    
    int pendingCount = pendingAppeals != null ? pendingAppeals.size() : 0;
    
    int approvedCount = 0;
    int rejectedCount = 0;
    if (appealHistory != null) {
        for (Attendance a : appealHistory) {
            if ("Approved".equalsIgnoreCase(a.getStudentAppealStatus())) approvedCount++;
            else if ("Rejected".equalsIgnoreCase(a.getStudentAppealStatus())) rejectedCount++;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Recheck Appeals - CAS Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .appeal-card {
            background: white;
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-card);
            transition: transform 0.25s, box-shadow 0.25s;
        }
        .appeal-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 32px rgba(15,34,64,0.08);
        }
        .nav-pills .nav-link {
            border-radius: 50px;
            padding: 7px 20px;
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.875rem;
        }
        .nav-pills .nav-link.active {
            background: var(--primary);
            box-shadow: 0 4px 12px rgba(30,58,95,0.2);
        }
        .textarea-custom {
            border-radius: 10px;
            border: 1px solid var(--border);
            background-color: #f8fafc;
            resize: none;
        }
        .textarea-custom:focus {
            background-color: white;
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(30,58,95,0.15);
        }
    </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="includes/teacher_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        <!-- Header Include -->
        <jsp:include page="includes/teacher_header.jsp" />

        <div class="container-fluid p-4 p-md-5">
            <h3 class="fw-bold mb-4"><i class="bi bi-shield-exclamation text-primary me-2"></i> Student Recheck Appeals</h3>
            
            <% if (request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <!-- Metrics Row -->
            <div class="row g-4 mb-5">
                <div class="col-md-4">
                    <div class="metric-card bg-white border">
                        <div class="metric-info">
                            <p class="text-uppercase text-muted small fw-bold">Pending Reviews</p>
                            <h3><%= pendingCount %></h3>
                        </div>
                        <div class="metric-icon bg-warning bg-opacity-10 text-warning">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card bg-white border">
                        <div class="metric-info">
                            <p class="text-uppercase text-muted small fw-bold">Approved History</p>
                            <h3><%= approvedCount %></h3>
                        </div>
                        <div class="metric-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-patch-check"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="metric-card bg-white border">
                        <div class="metric-info">
                            <p class="text-uppercase text-muted small fw-bold">Rejected History</p>
                            <h3><%= rejectedCount %></h3>
                        </div>
                        <div class="metric-icon bg-danger bg-opacity-10 text-danger">
                            <i class="bi bi-patch-exclamation"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs Navigation -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <ul class="nav nav-pills" id="appealTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="pending-tab" data-bs-toggle="pill" data-bs-target="#pending-content" type="button" role="tab">
                            <i class="bi bi-bell-fill me-1"></i> Pending Appeals (<%= pendingCount %>)
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="history-tab" data-bs-toggle="pill" data-bs-target="#history-content" type="button" role="tab">
                            <i class="bi bi-clock-history me-1"></i> Resolution History
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="notif-tab" data-bs-toggle="pill" data-bs-target="#notif-content" type="button" role="tab">
                            <i class="bi bi-inbox-fill me-1"></i> Notification Center
                        </button>
                    </li>
                </ul>
            </div>

            <!-- Tabs Content -->
            <div class="tab-content" id="appealTabsContent">
                
                <!-- Pending Appeals Pane -->
                <div class="tab-pane fade show active" id="pending-content" role="tabpanel">
                    <% if (pendingAppeals == null || pendingAppeals.isEmpty()) { %>
                        <div class="card p-5 text-center border-0 bg-light rounded-4">
                            <i class="bi bi-check2-circle fs-1 text-success mb-3"></i>
                            <h5 class="fw-bold">All caught up!</h5>
                            <p class="text-muted mb-0">No students have pending attendance recheck appeals currently.</p>
                        </div>
                    <% } else { %>
                        <div class="row g-4">
                            <% for (Attendance a : pendingAppeals) { %>
                                <div class="col-lg-6">
                                    <div class="card border-0 shadow-sm p-4 appeal-card">
                                        <div class="d-flex justify-content-between align-items-start mb-3 border-bottom pb-3">
                                            <div class="d-flex align-items-center gap-3">
                                                <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(a.getStudentName(), "UTF-8") %>&background=e2e8f0&color=475569&bold=true" class="rounded-circle" width="45" height="45">
                                                <div>
                                                    <h6 class="mb-0 fw-bold text-dark"><%= a.getStudentName() %></h6>
                                                    <small class="text-muted"><%= a.getStudentRollNo() %></small>
                                                </div>
                                            </div>
                                            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill small fw-bold">Pending Review</span>
                                        </div>
                                        
                                        <div class="mb-3 bg-light p-3 rounded" style="font-size: 0.9rem; border-left: 4px solid var(--primary);">
                                            <div class="d-flex justify-content-between mb-2">
                                                <span class="text-muted fw-bold">Subject:</span>
                                                <span class="fw-bold text-dark"><%= a.getSubjectCode() %> - <%= a.getSubjectName() %></span>
                                            </div>
                                            <div class="d-flex justify-content-between">
                                                <span class="text-muted fw-bold">Absent Date:</span>
                                                <span class="fw-bold text-dark"><%= sdtf.format(a.getDateTime()) %></span>
                                            </div>
                                        </div>

                                        <div class="mb-4">
                                            <label class="form-label text-muted fw-bold small"><i class="bi bi-chat-quote-fill me-1"></i> Student's Explanation</label>
                                            <p class="mb-0 text-dark bg-light p-3 rounded small border border-light-subtle" style="white-space: pre-line; line-height: 1.5; font-style: italic;">"<%= a.getStudentAppealReason() %>"</p>
                                        </div>

                                        <!-- Teacher Actions Form -->
                                        <form action="teacherAppeals" method="post" class="mt-auto">
                                            <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                            
                                            <div class="mb-3">
                                                <label for="remarks-<%= a.getId() %>" class="form-label text-muted fw-bold small">Teacher's Remarks / Feedback</label>
                                                <textarea class="form-control textarea-custom p-3 small" id="remarks-<%= a.getId() %>" name="remarks" rows="2" placeholder="Explain your decision (e.g., Verified, present in laboratory logs / checked in online list)..."></textarea>
                                            </div>
                                            
                                            <div class="d-flex gap-2 justify-content-end">
                                                <button type="submit" name="action" value="reject" class="btn btn-outline-danger px-4 rounded-pill fw-bold" onclick="return confirm('Are you sure you want to reject this appeal?');">
                                                    <i class="bi bi-x-circle me-1"></i> Reject
                                                </button>
                                                <button type="submit" name="action" value="approve" class="btn btn-success px-4 rounded-pill fw-bold text-white" style="background-color: #16a34a; border-color: #16a34a;" onclick="return confirm('Approve this appeal? The student will be marked PRESENT.');">
                                                    <i class="bi bi-check-circle me-1"></i> Verify & Approve
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>

                <!-- Resolution History Pane -->
                <div class="tab-pane fade" id="history-content" role="tabpanel">
                    <div class="card border-0 shadow-sm p-4 bg-white rounded-3">
                        <h5 class="fw-bold mb-3">Appeal Resolutions Log</h5>
                        <% if (appealHistory == null || appealHistory.isEmpty()) { %>
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-journal-x fs-1 opacity-50 mb-3 d-block"></i>
                                <p class="mb-0">No historical appeals resolved yet.</p>
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Student Info</th>
                                            <th>Subject</th>
                                            <th>Date & Time</th>
                                            <th>Student Reason</th>
                                            <th>Verdict</th>
                                            <th>My Remarks</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Attendance a : appealHistory) { 
                                            boolean isApproved = "Approved".equalsIgnoreCase(a.getStudentAppealStatus());
                                        %>
                                            <tr>
                                                <td>
                                                    <div class="fw-bold"><%= a.getStudentName() %></div>
                                                    <small class="text-muted"><%= a.getStudentRollNo() %></small>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold"><%= a.getSubjectCode() %></div>
                                                    <small class="text-muted"><%= a.getSubjectName() %></small>
                                                </td>
                                                <td><%= sdtf.format(a.getDateTime()) %></td>
                                                <td>
                                                    <span class="d-inline-block text-truncate small" style="max-width: 200px;" title="<%= a.getStudentAppealReason() %>">
                                                        <%= a.getStudentAppealReason() %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (isApproved) { %>
                                                        <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-20 px-3 py-2 rounded-pill"><i class="bi bi-check-circle me-1"></i>Approved</span>
                                                    <% } else { %>
                                                        <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-20 px-3 py-2 rounded-pill"><i class="bi bi-x-circle me-1"></i>Rejected</span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <span class="small text-muted" title="<%= a.getStudentAppealRemarks() %>">
                                                        <%= a.getStudentAppealRemarks() != null && !a.getStudentAppealRemarks().isEmpty() ? a.getStudentAppealRemarks() : "No remarks left." %>
                                                    </span>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Notifications Pane -->
                <div class="tab-pane fade" id="notif-content" role="tabpanel">
                    <div class="card border-0 shadow-sm p-4 bg-white rounded-3">
                        <h5 class="fw-bold mb-4">Faculty Alerts & Notifications</h5>
                        <% if (notifications == null || notifications.isEmpty()) { %>
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-bell-slash fs-1 opacity-50 mb-3 d-block"></i>
                                <p class="mb-0">No new notifications in your inbox.</p>
                            </div>
                        <% } else { %>
                            <div class="list-group list-group-flush border rounded-3 overflow-hidden">
                                <% for (Notification n : notifications) { 
                                    boolean isUnread = !n.isRead();
                                %>
                                    <div class="list-group-item p-4 <%= isUnread ? "bg-light border-start border-4 border-warning" : "border-start border-4 border-transparent" %>">
                                        <div class="d-flex w-100 justify-content-between align-items-start">
                                            <div class="d-flex gap-3">
                                                <div class="rounded-circle d-flex align-items-center justify-content-center bg-warning text-dark" style="width: 45px; height: 45px; flex-shrink: 0;">
                                                    <i class="bi bi-exclamation-circle-fill fs-5"></i>
                                                </div>
                                                <div>
                                                    <h6 class="mb-1 fw-bold text-dark"><%= n.getTitle() %></h6>
                                                    <p class="mb-2 small text-muted" style="white-space: pre-line;"><%= n.getMessage() %></p>
                                                    <small class="text-muted d-flex align-items-center gap-2">
                                                        <i class="bi bi-clock"></i> <%= sdtf.format(n.getCreatedAt()) %>
                                                        &bull;
                                                        <span class="badge bg-light text-dark border">From: <%= n.getSenderName() %> (<%= n.getSenderRole() %>)</span>
                                                    </small>
                                                </div>
                                            </div>
                                            <% if (isUnread) { %>
                                                <a href="teacherAppeals?readNotifId=<%= n.getId() %>" class="btn btn-sm btn-outline-warning rounded-pill flex-shrink-0 px-3 fw-bold">
                                                    <i class="bi bi-check2"></i> Mark Read
                                                </a>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
