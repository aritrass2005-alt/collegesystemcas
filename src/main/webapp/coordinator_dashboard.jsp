<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.*" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    Boolean isCoord = (Boolean) session.getAttribute("isCoordinator");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role")) || !Boolean.TRUE.equals(isCoord)) {
        response.sendRedirect("login.jsp?error=Unauthorized Access"); return;
    }
    List<Coordinator> assignments = (List<Coordinator>) request.getAttribute("assignments");
    Coordinator active = (Coordinator) request.getAttribute("activeAssignment");
    List<LeaveApplication> leaves = (List<LeaveApplication>) request.getAttribute("leaves");
    List<DefaulterRecord> defaulters = (List<DefaulterRecord>) request.getAttribute("defaulters");
    int studentCount = request.getAttribute("studentCount") != null ? (int) request.getAttribute("studentCount") : 0;
    int pendingLeaves = request.getAttribute("pendingLeaves") != null ? (int) request.getAttribute("pendingLeaves") : 0;
    int defaulterCount = defaulters != null ? defaulters.size() : 0;
    String photoUrl = teacher.getProfilePhoto();
    String avatarUrl = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(teacher.getName(),"UTF-8") + "&background=764ba2&color=fff&bold=true&size=80";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Coordinator Dashboard &ndash; CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        body { background: var(--bg-page); }

        /* ── Class Switcher ── */
        #main-content { margin-left: var(--sidebar-width); min-height: 100vh; background: var(--bg-page); }
        .class-switcher-bar {
            background: linear-gradient(160deg, #1e3a5f 0%, #0f2240 100%);
            padding: 0.9rem 2rem; display:flex; align-items:center; gap:12px; flex-wrap:wrap;
        }
        .class-chip {
            padding: 7px 16px; border-radius: 50px; font-size: 0.83rem; font-weight: 600;
            cursor: pointer; border: 1.5px solid rgba(255,255,255,0.2); text-decoration: none; transition: all 0.2s;
            color: rgba(255,255,255,0.65); background: rgba(255,255,255,0.07);
        }
        .class-chip.active-chip, .class-chip:hover {
            background: rgba(79,156,249,0.2);
            color: #fff; border-color: rgba(79,156,249,0.5); box-shadow: 0 4px 12px rgba(79,156,249,0.2);
        }

        /* ── Stat Cards ── */
        .stat-card {
            border-radius: var(--radius-xl); padding: 1.4rem; border: 1px solid var(--border);
            background: var(--bg-card); box-shadow: var(--shadow-card);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(15,34,64,0.10); }
        .stat-icon { width: 50px; height: 50px; border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; font-size: 1.35rem; }

        /* ── Cards ── */
        .glass-card { background: var(--bg-card); border-radius: var(--radius-xl); border: 1px solid var(--border); box-shadow: var(--shadow-card); overflow: hidden; }
        .proof-btn { font-size: 0.78rem; padding: 4px 12px; border-radius: 50px; }
    </style>
</head>
<body>
<div class="d-flex">

    <!-- ══ COORDINATOR SIDEBAR ══ -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- ══ MAIN CONTENT ══ -->
    <div id="main-content" class="flex-grow-1">
        
        <!-- Coordinator Header -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="p-4">
            <!-- Active Context Banner -->
            <% if (active != null) {
                String sec = (active.getSection() == null || active.getSection().isEmpty()) ? "All Sections" : "Section " + active.getSection();
            %>
            <div class="d-flex align-items-center justify-content-between mb-4">
                <div>
                    <h4 class="fw-bold mb-1">
                        <span style="color:var(--primary);"><%= active.getDepartment() %></span>
                        &mdash; Year <%= active.getYear() %>, <%= sec %>
                    </h4>
                    <p class="text-muted mb-0 small">Coordinator overview for your assigned class</p>
                </div>
                <div class="d-flex align-items-center gap-3">
                    <div class="dropdown">
                        <button class="btn btn-outline-primary text-dark border dropdown-toggle shadow-sm bg-white fw-bold" type="button" id="classSwitchBtn" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="bi bi-diagram-3 me-2 text-primary"></i>Switch Class
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end shadow border-0" aria-labelledby="classSwitchBtn">
                            <% if (assignments != null && !assignments.isEmpty()) { 
                                for (Coordinator c : assignments) {
                                    boolean isActive = active != null && c.getId() == active.getId();
                                    String sc = (c.getSection() == null || c.getSection().isEmpty()) ? "All" : c.getSection();
                            %>
                            <li>
                                <a class="dropdown-item <%= isActive ? "active fw-bold" : "" %> py-2" href="coordinatorDashboard?assignmentId=<%= c.getId() %>">
                                    <i class="bi bi-building me-2 <%= isActive ? "text-white" : "text-muted" %>"></i><%= c.getDepartment() %> &bull; Yr<%= c.getYear() %> &bull; <%= sc %>
                                </a>
                            </li>
                            <% }} else { %>
                            <li><span class="dropdown-item text-muted">No classes assigned</span></li>
                            <% } %>
                        </ul>
                    </div>
                    <span class="badge rounded-pill px-3 py-2" style="background:var(--primary-dark);font-size:0.85rem;">Active Class</span>
                </div>
            </div>
            <% } %>

            <!-- Stat Cards -->
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <a href="coordinatorStudents" style="text-decoration:none; color:inherit; display:block;">
                        <div class="stat-card">
                            <div class="d-flex align-items-center gap-3">
                                <div class="stat-icon" style="background:rgba(102,126,234,0.1);"><i class="bi bi-mortarboard-fill" style="color:#667eea;"></i></div>
                                <div>
                                    <div class="fs-2 fw-bold"><%= studentCount %></div>
                                    <div class="text-muted small">Total Students</div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-4">
                    <a href="coordinatorLeaves" style="text-decoration:none; color:inherit; display:block;">
                        <div class="stat-card">
                            <div class="d-flex align-items-center gap-3">
                                <div class="stat-icon" style="background:rgba(251,191,36,0.1);"><i class="bi bi-envelope-paper-fill" style="color:#f59e0b;"></i></div>
                                <div>
                                    <div class="fs-2 fw-bold"><%= pendingLeaves %></div>
                                    <div class="text-muted small">Pending Leaves</div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-4">
                    <a href="coordinatorDefaulterList" style="text-decoration:none; color:inherit; display:block;">
                        <div class="stat-card">
                            <div class="d-flex align-items-center gap-3">
                                <div class="stat-icon" style="background:rgba(239,68,68,0.1);"><i class="bi bi-exclamation-octagon-fill" style="color:#ef4444;"></i></div>
                                <div>
                                    <div class="fs-2 fw-bold"><%= defaulterCount %></div>
                                    <div class="text-muted small">Defaulters (&lt;75%)</div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </div>

            <!-- Leave Applications -->
            <div class="glass-card mb-4">
                <div class="p-4 border-bottom d-flex align-items-center justify-content-between">
                    <h5 class="fw-bold mb-0"><i class="bi bi-envelope-paper me-2 text-warning"></i>Pending Leave Applications</h5>
                    <a href="coordinatorLeaves" class="btn btn-sm btn-outline-secondary rounded-pill">View All</a>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Student</th>
                                <th>Dates</th>
                                <th>Reason</th>
                                <th>Proof</th>
                                <th>Status</th>
                                <th class="text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% boolean hasLeaves = false;
                           if (leaves != null) { for (LeaveApplication l : leaves) { if ("Pending".equals(l.getStatus())) { hasLeaves = true; %>
                            <tr>
                                <td class="ps-4">
                                    <div class="d-flex align-items-center gap-2">
                                        <img src="https://ui-avatars.com/api/?name=<%= l.getStudentName() %>&background=random" class="rounded-circle" width="32" height="32">
                                        <div>
                                            <p class="mb-0 fw-semibold small"><%= l.getStudentName() %></p>
                                            <small class="text-muted"><%= l.getStudentRollNo() %></small>
                                        </div>
                                    </div>
                                </td>
                                <td><small class="fw-bold"><%= l.getStartDate() %><br>to<br><%= l.getEndDate() %></small></td>
                                <td><span class="text-truncate d-inline-block" style="max-width:140px;" title="<%= l.getReason() %>"><%= l.getReason() %></span></td>
                                <td>
                                    <% String proof = l.getProofPath();
                                       if (proof != null && !proof.isEmpty()) { %>
                                        <a href="<%= proof %>" target="_blank" class="btn btn-sm btn-outline-primary proof-btn">
                                            <i class="bi bi-file-earmark-text me-1"></i>View
                                        </a>
                                    <% } else { %>
                                        <span class="text-muted small"><i class="bi bi-dash"></i> None</span>
                                    <% } %>
                                </td>
                                <td><span class="badge bg-warning text-dark">Pending</span></td>
                                <td class="text-center">
                                    <div class="d-flex gap-2 justify-content-center">
                                        <form action="coordinatorLeaves" method="post" class="m-0">
                                            <input type="hidden" name="leaveId" value="<%= l.getId() %>">
                                            <input type="hidden" name="action" value="Approve">
                                            <button type="submit" class="btn btn-sm btn-success rounded-pill px-3"><i class="bi bi-check-lg"></i> Approve</button>
                                        </form>
                                        <form action="coordinatorLeaves" method="post" class="m-0">
                                            <input type="hidden" name="leaveId" value="<%= l.getId() %>">
                                            <input type="hidden" name="action" value="Reject">
                                            <button type="submit" class="btn btn-sm btn-danger rounded-pill px-3"><i class="bi bi-x-lg"></i> Reject</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% }}} %>
                        <% if (!hasLeaves) { %>
                            <tr><td colspan="6" class="text-center text-muted py-4"><i class="bi bi-check-circle fs-4 text-success d-block mb-2"></i>No pending leave applications.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Defaulters Quick List -->
            <% if (defaulters != null && !defaulters.isEmpty()) { %>
            <div class="glass-card">
                <div class="p-4 border-bottom">
                    <h5 class="fw-bold mb-0"><i class="bi bi-exclamation-octagon me-2 text-danger"></i>Attendance Defaulters</h5>
                </div>
                <div class="p-4">
                    <div class="row g-3">
                    <% for (DefaulterRecord dr : defaulters) { %>
                        <div class="col-md-4">
                            <div class="d-flex align-items-center gap-3 p-3 rounded-3" style="background:#fff5f5;border:1px solid #fecaca;">
                                <img src="https://ui-avatars.com/api/?name=<%= dr.getStudentName() %>&background=ffebeb&color=dc3545&bold=true" class="rounded-circle" width="38" height="38">
                                <div class="flex-grow-1">
                                    <p class="mb-0 fw-semibold small"><%= dr.getStudentName() %></p>
                                    <small class="text-muted"><%= dr.getStudentRollNo() %></small>
                                </div>
                                <span class="fw-bold text-danger"><%= dr.getPercentage() %>%</span>
                            </div>
                        </div>
                    <% } %>
                    </div>
                </div>
            </div>
            <% } %>

        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
