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
    Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
    if (isCoordinator == null || !isCoordinator) {
        response.sendRedirect("login.jsp?msg=Coordinator access required");
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
    <title>Section Appeals - Coordinator Panel</title>
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
        .guardian-contact-card {
            background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%);
            border: 1px solid #bbf7d0;
            border-radius: 12px;
            padding: 12px 16px;
        }
        .guardian-contact-card .contact-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            font-weight: 700;
            color: #16a34a;
        }
        .btn-call {
            background: linear-gradient(135deg, #16a34a, #15803d);
            border: none;
            color: white;
            border-radius: 50px;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(22,163,74,0.3);
            transition: all 0.3s ease;
        }
        .btn-call:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(22,163,74,0.4);
            color: white;
        }
        .btn-message {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            border: none;
            color: white;
            border-radius: 50px;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(37,99,235,0.3);
            transition: all 0.3s ease;
        }
        .btn-message:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(37,99,235,0.4);
            color: white;
        }
        .btn-email-guardian {
            background: linear-gradient(135deg, #7c3aed, #6d28d9);
            border: none;
            color: white;
            border-radius: 50px;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(124,58,237,0.3);
            transition: all 0.3s ease;
        }
        .btn-email-guardian:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(124,58,237,0.4);
            color: white;
        }
        .coordinator-badge {
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            color: #78350f;
            font-size: 0.7rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 50px;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>

    <!-- Sidebar Include -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">

        <!-- Header Include -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="container-fluid px-4 py-4">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1"><i class="bi bi-shield-exclamation text-primary me-2"></i> Section Student Appeals</h3>
                    <p class="text-muted small mb-0">Review and manage recheck appeals from students in your assigned sections. <span class="coordinator-badge ms-2"><i class="bi bi-star-fill me-1"></i>COORDINATOR ONLY</span></p>
                </div>
            </div>
            
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

            <!-- Coordinator Privilege Notice -->
            <div class="alert border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #f0fdf4, #ecfdf5); border-left: 4px solid #16a34a !important;">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px; background: #16a34a; flex-shrink: 0;">
                        <i class="bi bi-telephone-fill text-white"></i>
                    </div>
                    <div>
                        <h6 class="mb-0 fw-bold text-dark">Guardian Contact Access</h6>
                        <p class="mb-0 small text-muted">As a coordinator, you can directly <strong>call</strong> or <strong>message</strong> the guardian/parent of students in your assigned section regarding their attendance appeals.</p>
                    </div>
                </div>
            </div>

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
                            <p class="text-muted mb-0">No students in your section have pending attendance recheck appeals.</p>
                        </div>
                    <% } else { %>
                    <div class="d-flex flex-column gap-3">
                            <% for (Attendance a : pendingAppeals) { %>
                                <div class="card border-0 shadow-sm appeal-card">
                                    <div class="card-body p-0">
                                        <div class="row g-0">
                                            <%-- LEFT: Student info + subject + reason + guardian --%>
                                            <div class="col-lg-7 p-4 border-end">
                                                <div class="d-flex justify-content-between align-items-start mb-3">
                                                    <div class="d-flex align-items-center gap-3">
                                                        <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(a.getStudentName(), "UTF-8") %>&background=dbeafe&color=1d4ed8&bold=true" class="rounded-circle" width="48" height="48">
                                                        <div>
                                                            <h6 class="mb-0 fw-bold text-dark"><%= a.getStudentName() %></h6>
                                                            <small class="text-muted"><%= a.getStudentRollNo() %></small>
                                                            <% if (a.getStudentSection() != null) { %>
                                                                <span class="badge bg-light text-dark border ms-1" style="font-size: 0.65rem;">Sec <%= a.getStudentSection() %></span>
                                                            <% } %>
                                                        </div>
                                                    </div>
                                                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill small fw-bold">Pending Review</span>
                                                </div>

                                                <div class="p-3 rounded-3 mb-3" style="background:#f1f5fb; border-left: 4px solid #1e3a5f; font-size: 0.88rem;">
                                                    <div class="row g-2">
                                                        <div class="col-6">
                                                            <div class="text-muted small fw-bold mb-1">SUBJECT</div>
                                                            <div class="fw-bold text-dark"><%= a.getSubjectCode() %> – <%= a.getSubjectName() %></div>
                                                        </div>
                                                        <div class="col-6">
                                                            <div class="text-muted small fw-bold mb-1">ABSENT DATE</div>
                                                            <div class="fw-bold text-dark"><%= sdtf.format(a.getDateTime()) %></div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="mb-3">
                                                    <div class="text-muted small fw-bold mb-1"><i class="bi bi-chat-quote-fill me-1 text-primary"></i>Student's Explanation</div>
                                                    <p class="mb-0 p-3 rounded-3 small border" style="background:#fafbff; white-space:pre-line; line-height:1.6; font-style:italic; color:#374151;">"<%= a.getStudentAppealReason() %>"</p>
                                                </div>

                                                <div class="guardian-contact-card">
                                                    <div class="contact-label mb-2"><i class="bi bi-person-lines-fill me-1"></i>Guardian / Parent Contact</div>
                                                    <% if (a.getParentName() != null && !a.getParentName().isEmpty()) { %>
                                                        <div class="fw-semibold text-dark mb-2" style="font-size: 0.88rem;"><i class="bi bi-person-fill text-success me-1"></i><%= a.getParentName() %></div>
                                                    <% } %>
                                                    <div class="d-flex flex-wrap gap-2">
                                                        <% if (a.getParentPhone() != null && !a.getParentPhone().isEmpty()) { %>
                                                            <a href="tel:<%= a.getParentPhone() %>" class="btn btn-sm btn-call px-3"><i class="bi bi-telephone-fill me-1"></i>Call</a>
                                                            <a href="sms:<%= a.getParentPhone() %>" class="btn btn-sm btn-message px-3"><i class="bi bi-chat-dots-fill me-1"></i>SMS</a>
                                                        <% } %>
                                                        <% if (a.getParentEmail() != null && !a.getParentEmail().isEmpty()) { %>
                                                            <a href="mailto:<%= a.getParentEmail() %>" class="btn btn-sm btn-email-guardian px-3"><i class="bi bi-envelope-fill me-1"></i>Email</a>
                                                        <% } %>
                                                        <% if ((a.getParentPhone() == null || a.getParentPhone().isEmpty()) && (a.getParentEmail() == null || a.getParentEmail().isEmpty())) { %>
                                                            <span class="text-muted small"><i class="bi bi-exclamation-circle me-1"></i>No guardian contact info available</span>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- RIGHT: Action panel --%>
                                            <div class="col-lg-5 p-4 d-flex flex-column" style="background:#f8faff;">
                                                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-pencil-square me-2 text-primary"></i>Coordinator Decision</h6>
                                                <form action="coordinatorAppeals" method="post" class="d-flex flex-column flex-grow-1">
                                                    <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                                    <div class="mb-3 flex-grow-1">
                                                        <label class="form-label text-muted fw-bold small">Remarks / Feedback</label>
                                                        <textarea class="form-control textarea-custom" name="remarks" rows="5" placeholder="Explain your decision after contacting the guardian (e.g., Guardian confirmed student was ill)..."></textarea>
                                                    </div>
                                                    <div class="d-flex gap-2 mt-auto">
                                                        <button type="submit" name="action" value="reject" class="btn btn-outline-danger flex-fill rounded-pill fw-bold" onclick="return confirm('Reject this appeal?')">
                                                            <i class="bi bi-x-circle me-1"></i>Reject
                                                        </button>
                                                        <button type="submit" name="action" value="approve" class="btn btn-success flex-fill rounded-pill fw-bold text-white" style="background:#16a34a;border-color:#16a34a;" onclick="return confirm('Approve? Student will be marked PRESENT.')">
                                                            <i class="bi bi-check-circle me-1"></i>Approve
                                                        </button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
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
                                            <th>Remarks</th>
                                            <th>Guardian Contact</th>
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
                                                    <% if (a.getStudentSection() != null) { %>
                                                        <span class="badge bg-light text-dark border ms-1" style="font-size: 0.6rem;">Sec <%= a.getStudentSection() %></span>
                                                    <% } %>
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
                                                <td>
                                                    <% if (a.getParentPhone() != null && !a.getParentPhone().isEmpty()) { %>
                                                        <a href="tel:<%= a.getParentPhone() %>" class="btn btn-sm btn-outline-success" title="Call Guardian"><i class="bi bi-telephone-fill"></i></a>
                                                        <a href="sms:<%= a.getParentPhone() %>" class="btn btn-sm btn-outline-primary" title="Message Guardian"><i class="bi bi-chat-dots-fill"></i></a>
                                                    <% } else { %>
                                                        <span class="text-muted small">N/A</span>
                                                    <% } %>
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
                        <h5 class="fw-bold mb-4">Coordinator Alerts & Notifications</h5>
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
                                                <a href="coordinatorAppeals?readNotifId=<%= n.getId() %>" class="btn btn-sm btn-outline-warning rounded-pill flex-shrink-0 px-3 fw-bold">
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
