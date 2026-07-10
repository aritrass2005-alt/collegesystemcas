<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.AttendanceSummary" %>
<%@ page import="com.college.attendance.model.Attendance" %>
<%@ page import="com.college.attendance.model.DefaulterRecord" %>

<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    
    List<AttendanceSummary> subjectSummary = (List<AttendanceSummary>) request.getAttribute("subjectSummary");
    List<AttendanceSummary> monthSummary = (List<AttendanceSummary>) request.getAttribute("monthSummary");
    List<Attendance> history = (List<Attendance>) request.getAttribute("history");
    List<DefaulterRecord> defaulters = (List<DefaulterRecord>) request.getAttribute("defaulters");

    Double overallPercentage = (Double) request.getAttribute("overallPercentage");
    if (overallPercentage == null) overallPercentage = 0.0;
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdtf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss"); // Full ISO datetime for calendar
    SimpleDateFormat timeOnly = new SimpleDateFormat("hh:mm a"); // e.g. 10:30 AM
%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard – CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <!-- FullCalendar CSS -->
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
    
    <style>
        body { overflow-x: hidden; }

        /* Dashboard specific styles */
        .glass-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-card);
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }
        .glass-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 32px rgba(15,34,64,0.10);
        }

        .hero-banner {
            background: linear-gradient(160deg, #1e3a5f 0%, #0f2240 60%, #071629 100%);
            border-radius: 20px;
            color: white;
            padding: 2.5rem;
            position: relative;
            overflow: hidden;
            box-shadow: 0 12px 32px rgba(15,34,64,0.25);
            animation: fadeInDown 0.8s ease;
        }

        .hero-banner::before {
            content: '';
            position: absolute;
            width: 320px; height: 320px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            top: -80px; right: -80px;
        }

        .hero-banner::after {
            content: '';
            position: absolute;
            width: 200px; height: 200px;
            background: rgba(255,255,255,0.03);
            border-radius: 50%;
            bottom: -60px; left: -40px;
        }

        .stat-ring {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: conic-gradient(#4f9cf9 <%= overallPercentage %>%, rgba(255,255,255,0.15) 0);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            animation: popIn 1s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        
        .stat-ring::before {
            content: '';
            width: 130px;
            height: 130px;
            background: linear-gradient(160deg, #1e3a5f, #0f2240);
            border-radius: 50%;
            position: absolute;
        }

        .stat-ring .inner-text {
            position: relative;
            font-size: 2rem;
            font-weight: 700;
            z-index: 2;
        }
        
        /* ── FullCalendar Themed Overrides ──────────────────────────── */
        #attendanceCalendar {
            font-family: 'Inter', 'Segoe UI', sans-serif;
        }

        /* Toolbar */
        .fc .fc-toolbar {
            padding: 12px 16px;
            background: linear-gradient(135deg, #1e3a5f 0%, #0f2240 100%);
            border-radius: 14px 14px 0 0;
            margin-bottom: 0 !important;
            flex-wrap: wrap;
            gap: 8px;
        }
        .fc .fc-toolbar-title {
            color: #fff;
            font-size: 1.2rem;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        /* Toolbar buttons */
        .fc .fc-button {
            background: rgba(255,255,255,0.12) !important;
            border: 1px solid rgba(255,255,255,0.2) !important;
            border-radius: 8px !important;
            color: #fff !important;
            font-size: 0.82rem !important;
            font-weight: 600 !important;
            padding: 5px 14px !important;
            transition: all 0.2s ease !important;
            box-shadow: none !important;
            text-transform: capitalize;
        }
        .fc .fc-button:hover {
            background: rgba(255,255,255,0.25) !important;
            border-color: rgba(255,255,255,0.4) !important;
        }
        .fc .fc-button-primary:not(:disabled).fc-button-active,
        .fc .fc-button-primary:not(:disabled):active {
            background: #4f9cf9 !important;
            border-color: #4f9cf9 !important;
        }

        /* Grid */
        .fc .fc-scrollgrid {
            border: none !important;
            border-radius: 0 0 14px 14px;
            overflow: hidden;
        }
        .fc .fc-scrollgrid-section-header th {
            background: #f0f4fb;
            border: none !important;
            padding: 10px 0 !important;
        }
        .fc .fc-col-header-cell-cushion {
            font-weight: 700;
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #1e3a5f;
            text-decoration: none;
        }

        /* Day cells */
        .fc .fc-daygrid-day {
            background: #fff;
            border-color: #e8edf5 !important;
            transition: background 0.18s ease;
        }
        .fc .fc-daygrid-day:hover {
            background: #f5f8ff;
        }
        .fc .fc-day-today {
            background: linear-gradient(135deg, #eef4ff 0%, #deeaff 100%) !important;
        }
        .fc .fc-daygrid-day-number {
            font-weight: 600;
            font-size: 0.85rem;
            color: #374151;
            text-decoration: none;
            padding: 6px 10px !important;
        }
        .fc .fc-day-today .fc-daygrid-day-number {
            background: #1e3a5f;
            color: #fff;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 4px;
            padding: 0 !important;
        }
        /* Other-month days */
        .fc .fc-day-other .fc-daygrid-day-number { color: #aab4c8; }
        .fc .fc-day-other { background: #fafbfd; }

        /* Events */
        .fc-event {
            border-radius: 4px !important;
            border: none !important;
            padding: 1px 2px !important;
            margin: 1px 3px !important;
            cursor: pointer;
            background: transparent !important;
            box-shadow: none !important;
        }
        .fc-event:hover {
            opacity: 0.85 !important;
        }
        .fc-event .fc-event-title { font-weight: 700; }

        /* "more" link */
        .fc .fc-daygrid-more-link {
            font-size: 0.72rem;
            font-weight: 700;
            color: #1e3a5f;
            background: #deeaff;
            border-radius: 4px;
            padding: 1px 6px;
            margin: 1px 4px;
        }

        /* Week / Day grid time labels */
        .fc .fc-timegrid-slot-label-cushion {
            font-size: 0.72rem;
            color: #6b7280;
            font-weight: 600;
        }
        .fc .fc-timegrid-now-indicator-line {
            border-color: #ef4444;
        }
        .fc .fc-timegrid-now-indicator-arrow {
            border-color: #ef4444;
        }

        /* Modal body background */
        #calendarModal .modal-body {
            background: #f4f7fd;
            padding: 20px 24px 24px !important;
        }

        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes popIn {
            from { opacity: 0; transform: scale(0.5); }
            to { opacity: 1; transform: scale(1); }
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-up { animation: fadeInUp 0.6s ease forwards; opacity: 0; }
        .delay-1 { animation-delay: 0.2s; }
        .delay-2 { animation-delay: 0.4s; }
        .delay-3 { animation-delay: 0.6s; }

        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: #c5cfd9; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #9eaab6; }
        
        .nav-pills .nav-link {
            border-radius: 50px;
            padding: 7px 20px;
            font-weight: 600;
            color: var(--text-muted);
            font-size: 0.875rem;
        }
        .nav-pills .nav-link.active {
            background: var(--primary);
            box-shadow: 0 4px 12px rgba(30,58,95,0.25);
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <jsp:include page="includes/student_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        <!-- Header Include -->
        <jsp:include page="includes/student_header.jsp" />

        <div class="container-fluid p-4 p-md-5">
            
            <!-- Hero Banner -->
            <div class="hero-banner mb-5 d-flex flex-column flex-md-row align-items-center justify-content-between">
                <div>
                    <h1 class="fw-bold mb-2">Hello, <%= student.getName() %>! 👋</h1>
                    <p class="fs-5 opacity-75 mb-0">Here is your attendance performance at a glance.</p>
                    <div class="mt-3 d-inline-block px-3 py-2 rounded" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); font-size: 0.95rem;">
                        <span class="fw-bold"><i class="bi bi-person-badge me-1"></i> Roll: <%= student.getRollNo() %></span>
                        <span class="mx-2 opacity-50">|</span>
                        <span class="fw-medium"><i class="bi bi-building me-1"></i> <%= student.getDepartment() %></span>
                        <span class="mx-2 opacity-50">|</span>
                        <span class="fw-medium"><i class="bi bi-mortarboard me-1"></i> Year <%= student.getYear() %></span>
                        <span class="mx-2 opacity-50">|</span>
                        <span class="fw-medium"><i class="bi bi-people me-1"></i> Sec <%= student.getSection() %></span>
                    </div>
                </div>
                <div class="mt-4 mt-md-0 d-flex flex-column align-items-center">
                    <a href="#" data-bs-toggle="modal" data-bs-target="#calendarModal" style="text-decoration:none; color:inherit; display:block;" onclick="setTimeout(() => window.calendar.render(), 300)" title="Click to open Attendance Calendar">
                        <div class="stat-ring shadow-lg" style="transition: transform 0.3s; cursor: pointer;" onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1)'">
                            <span class="inner-text"><%= overallPercentage %>%</span>
                        </div>
                    </a>
                    <span class="mt-3 fw-semibold text-uppercase letter-spacing-1 small">Overall Attendance</span>
                </div>
            </div>


            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 rounded-3 mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 rounded-3 mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <!-- Left Column: Attendance Stats -->
                <div class="col-xl-8">
                    <div class="glass-card p-4 h-100 animate-up delay-1">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h4 class="fw-bold m-0"><i class="bi bi-bar-chart-fill text-primary me-2"></i> Attendance Analytics</h4>
                            
                            <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" id="pills-subject-tab" data-bs-toggle="pill" data-bs-target="#pills-subject" type="button" role="tab">Subject-wise</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="pills-month-tab" data-bs-toggle="pill" data-bs-target="#pills-month" type="button" role="tab">Month-wise</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="pills-absent-tab" data-bs-toggle="pill" data-bs-target="#pills-absent" type="button" role="tab">Absent Records & Appeals</button>
                                </li>
                            </ul>
                        </div>
                        
                        <div class="tab-content" id="pills-tabContent">
                            <!-- Subject-wise Tab -->
                            <div class="tab-pane fade show active" id="pills-subject" role="tabpanel">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th class="border-0 rounded-start">Subject</th>
                                                <th class="border-0">Total Classes</th>
                                                <th class="border-0">Attended</th>
                                                <th class="border-0 text-center rounded-end">Percentage</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (subjectSummary != null && !subjectSummary.isEmpty()) {
                                                for (AttendanceSummary s : subjectSummary) { 
                                                    String colorClass = s.getPercentage() >= 75.0 ? "success" : (s.getPercentage() >= 50.0 ? "warning" : "danger");
                                            %>
                                                <tr>
                                                    <td class="fw-semibold"><%= s.getSubjectCode() %> - <%= s.getSubjectName() %></td>
                                                    <td><%= s.getTotalClasses() %></td>
                                                    <td><%= s.getAttendedClasses() %></td>
                                                    <td class="text-center">
                                                        <span class="badge bg-<%= colorClass %> rounded-pill px-3 py-2 fs-6">
                                                            <%= s.getPercentage() %>%
                                                        </span>
                                                    </td>
                                                </tr>
                                            <% }
                                            } else { %>
                                                <tr><td colspan="4" class="text-center text-muted py-4">No data available.</td></tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- Month-wise Tab -->
                            <div class="tab-pane fade" id="pills-month" role="tabpanel">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th class="border-0 rounded-start">Month</th>
                                                <th class="border-0">Total Classes</th>
                                                <th class="border-0">Attended</th>
                                                <th class="border-0 text-center rounded-end">Percentage</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (monthSummary != null && !monthSummary.isEmpty()) {
                                                for (AttendanceSummary s : monthSummary) { 
                                                    String colorClass = s.getPercentage() >= 75.0 ? "success" : (s.getPercentage() >= 50.0 ? "warning" : "danger");
                                            %>
                                                <tr>
                                                    <td class="fw-semibold"><i class="bi bi-calendar-event me-2 text-muted"></i><%= s.getSubjectName() %></td>
                                                    <td><%= s.getTotalClasses() %></td>
                                                    <td><%= s.getAttendedClasses() %></td>
                                                    <td class="text-center">
                                                        <span class="badge bg-<%= colorClass %> rounded-pill px-3 py-2 fs-6">
                                                            <%= s.getPercentage() %>%
                                                        </span>
                                                    </td>
                                                </tr>
                                            <% }
                                            } else { %>
                                                <tr><td colspan="4" class="text-center text-muted py-4">No data available.</td></tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- Absent Records & Appeals Tab -->
                            <div class="tab-pane fade" id="pills-absent" role="tabpanel">
                                <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light" style="position: sticky; top: 0; z-index: 1;">
                                            <tr>
                                                <th class="border-0 rounded-start">Subject</th>
                                                <th class="border-0">Date & Time</th>
                                                <th class="border-0">Appeal Status</th>
                                                <th class="border-0">Remarks / Reason</th>
                                                <th class="border-0 text-center rounded-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% 
                                            boolean hasAbsences = false;
                                            if (history != null) {
                                                for (Attendance a : history) {
                                                    if ("Absent".equals(a.getStatus())) {
                                                        hasAbsences = true;
                                                        String subCode = a.getSubjectCode() != null ? a.getSubjectCode() : "";
                                                        String subName = a.getSubjectName() != null ? a.getSubjectName() : "Unknown Subject";
                                                        String timeStr = timeOnly.format(a.getDateTime());
                                                        String dateStr = sdf.format(a.getDateTime());
                                                        String appealStatus = a.getStudentAppealStatus();
                                                        String appealReason = a.getStudentAppealReason();
                                                        String appealRemarks = a.getStudentAppealRemarks();
                                            %>
                                                <tr>
                                                    <td class="fw-semibold"><%= subCode %> - <%= subName %></td>
                                                    <td>
                                                        <div class="fw-medium"><%= dateStr %></div>
                                                        <small class="text-muted"><%= timeStr %></small>
                                                    </td>
                                                    <td>
                                                        <% if (appealStatus == null) { %>
                                                            <span class="badge bg-secondary rounded-pill px-3 py-2">Not Appealed</span>
                                                        <% } else if ("Pending".equals(appealStatus)) { %>
                                                            <span class="badge bg-warning text-dark rounded-pill px-3 py-2"><i class="bi bi-hourglass-split me-1"></i>Pending Review</span>
                                                        <% } else if ("Approved".equals(appealStatus)) { %>
                                                            <span class="badge bg-success rounded-pill px-3 py-2"><i class="bi bi-check-circle-fill me-1"></i>Approved</span>
                                                        <% } else if ("Rejected".equals(appealStatus)) { %>
                                                            <span class="badge bg-danger rounded-pill px-3 py-2"><i class="bi bi-x-circle-fill me-1"></i>Rejected</span>
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <% if (appealStatus != null) { %>
                                                            <div class="small text-dark"><strong>Reason:</strong> <%= appealReason %></div>
                                                            <% if (appealRemarks != null && !appealRemarks.isEmpty()) { %>
                                                                <div class="small text-muted mt-1 bg-light p-2 rounded" style="border-left: 3px solid var(--secondary);"><strong>Reviewer:</strong> <%= appealRemarks %></div>
                                                            <% } %>
                                                        <% } else { %>
                                                            <span class="text-muted small">No appeal filed yet.</span>
                                                        <% } %>
                                                    </td>
                                                    <td class="text-center">
                                                        <% if (appealStatus == null) { %>
                                                            <button class="btn btn-sm btn-primary-custom px-3 rounded-pill fw-bold" 
                                                                    data-bs-toggle="modal" 
                                                                    data-bs-target="#appealModal" 
                                                                    data-attendance-id="<%= a.getId() %>" 
                                                                    data-subject-info="<%= subCode %> - <%= subName %>" 
                                                                    data-date-info="<%= dateStr %> <%= timeStr %>">
                                                                <i class="bi bi-exclamation-circle me-1"></i> File Appeal
                                                            </button>
                                                        <% } else { %>
                                                            <button class="btn btn-sm btn-outline-secondary px-3 rounded-pill" disabled>Filed</button>
                                                        <% } %>
                                                    </td>
                                                </tr>
                                            <% 
                                                    }
                                                }
                                            }
                                            if (!hasAbsences) {
                                            %>
                                                <tr>
                                                    <td colspan="5" class="text-center text-muted py-5">
                                                        <i class="bi bi-emoji-smile fs-1 text-success d-block mb-3"></i>
                                                        <h6 class="fw-bold">No Absent Records!</h6>
                                                        <p class="mb-0 small">Keep up the flawless attendance!</p>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Section Defaulters -->
                <div class="col-xl-4">
                    <div class="glass-card p-4 h-100 animate-up delay-2">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold m-0"><i class="bi bi-exclamation-triangle-fill text-danger me-2"></i> Section Defaulters</h5>
                        </div>
                        
                        <div class="list-group list-group-flush" style="max-height: 350px; overflow-y: auto;">
                            <% if (defaulters != null && !defaulters.isEmpty()) {
                                for (DefaulterRecord dr : defaulters) { 
                                    boolean isMe = dr.getStudentId() == student.getId();
                            %>
                                <div class="list-group-item px-0 py-3 d-flex align-items-center justify-content-between border-0 border-bottom <%= isMe ? "bg-danger bg-opacity-10 rounded px-2" : "" %>">
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="https://ui-avatars.com/api/?name=<%= dr.getStudentName() %>&background=ffebeb&color=dc3545&bold=true" class="rounded-circle" width="40" height="40">
                                        <div>
                                            <h6 class="mb-0 fw-bold <%= isMe ? "text-danger" : "" %>"><%= dr.getStudentName() %> <%= isMe ? "(You)" : "" %></h6>
                                            <small class="text-muted"><%= dr.getStudentRollNo() %></small>
                                        </div>
                                    </div>
                                    <span class="fw-bold text-danger"><%= dr.getPercentage() %>%</span>
                                </div>
                            <% }
                            } else { %>
                                <div class="text-center text-muted py-5">
                                    <i class="bi bi-shield-check fs-1 text-success d-block mb-3"></i>
                                    No defaulters in your section!
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Full Width: Attendance Calendar Card -->
                <div class="col-12 mt-4">
                    <div class="animate-up delay-3 glass-card p-5 text-center d-flex flex-column align-items-center justify-content-center" style="min-height: 200px;">
                        <div class="mb-4">
                            <i class="bi bi-calendar3" style="font-size: 3rem; color: #667eea;"></i>
                        </div>
                        <h4 class="fw-bold mb-2">View Your Attendance History</h4>
                        <p class="text-muted mb-4">Check your day-to-day presence, absences, and leaves in a detailed calendar view.</p>
                        <button type="button" class="btn btn-primary px-5 py-3 rounded-pill fw-bold" style="background: linear-gradient(135deg, #667eea, #764ba2); border: none; box-shadow: 0 8px 20px rgba(102,126,234,0.3);" data-bs-toggle="modal" data-bs-target="#calendarModal" onclick="setTimeout(() => window.calendar.render(), 300)">
                            <i class="bi bi-calendar2-range me-2"></i> Open Attendance Calendar
                        </button>
                    </div>
                </div>


            </div>
        </div>
    </div>
</div>

<!-- Calendar Modal -->
<div class="modal fade" id="calendarModal" tabindex="-1" aria-labelledby="calendarModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content" style="border-radius: 24px; overflow: hidden; border: none;">
            <div class="modal-header p-4" style="background: linear-gradient(135deg, #1e1e2d 0%, #2d2d44 100%);">
                <div class="w-100 d-flex flex-column flex-md-row justify-content-between align-items-md-center">
                    <div>
                        <h4 class="fw-bold text-white mb-1"><i class="bi bi-calendar3 me-2" style="color:#0dcaf0;"></i> Attendance Calendar</h4>
                    </div>
                    <div class="d-flex gap-3 flex-wrap mt-3 mt-md-0">
                        <span class="d-flex align-items-center gap-2 px-3 py-2 rounded-pill" style="background:rgba(25,135,84,0.2);border:1px solid rgba(25,135,84,0.4);">
                            <span style="width:10px;height:10px;border-radius:50%;background:#198754;display:inline-block;"></span>
                            <small class="fw-semibold" style="color:#4ade80;">Present</small>
                        </span>
                        <span class="d-flex align-items-center gap-2 px-3 py-2 rounded-pill" style="background:rgba(220,53,69,0.2);border:1px solid rgba(220,53,69,0.4);">
                            <span style="width:10px;height:10px;border-radius:50%;background:#dc3545;display:inline-block;"></span>
                            <small class="fw-semibold" style="color:#f87171;">Absent</small>
                        </span>
                        <span class="d-flex align-items-center gap-2 px-3 py-2 rounded-pill" style="background:rgba(108,117,125,0.2);border:1px solid rgba(108,117,125,0.4);">
                            <span style="width:10px;height:10px;border-radius:50%;background:#6c757d;display:inline-block;"></span>
                            <small class="fw-semibold" style="color:#cbd5e1;">On Leave</small>
                        </span>
                        <button type="button" class="btn-close btn-close-white ms-3" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                </div>
            </div>
            <div class="modal-body" style="padding:0 !important; background:#f4f7fd;">
                <!-- Event detail toast -->
                <div id="calEventToast" style="display:none;position:absolute;top:80px;right:24px;z-index:1100;min-width:240px;max-width:320px;background:#fff;border-radius:14px;box-shadow:0 8px 32px rgba(30,58,95,0.18);padding:18px 20px;border-top:4px solid #1e3a5f;animation:fadeInDown 0.25s ease;">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <span id="calToastStatus" class="badge fs-6 px-3 py-2 rounded-pill"></span>
                        <button onclick="document.getElementById('calEventToast').style.display='none'" style="background:none;border:none;cursor:pointer;font-size:1.1rem;color:#6b7280;line-height:1;">&times;</button>
                    </div>
                    <div class="fw-bold text-dark mb-1" id="calToastSubject" style="font-size:0.95rem;"></div>
                    <div class="small text-muted" id="calToastDate"></div>
                    <div class="small text-muted" id="calToastTime"></div>
                </div>
                <div style="border-radius:0 0 24px 24px;overflow:hidden;">
                    <div id="attendanceCalendar"></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Appeal Modal -->
<div class="modal fade" id="appealModal" tabindex="-1" aria-labelledby="appealModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: var(--shadow-card);">
            <div class="modal-header bg-primary text-white border-0 py-3" style="border-top-left-radius: 16px; border-top-right-radius: 16px;">
                <h5 class="modal-title fw-bold" id="appealModalLabel"><i class="bi bi-exclamation-circle-fill me-2"></i> File Recheck Appeal</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="studentDashboard" method="post">
                <div class="modal-body p-4">
                    <input type="hidden" name="action" value="submitAppeal">
                    <input type="hidden" name="attendanceId" id="modalAttendanceId">
                    
                    <div class="mb-3 bg-light p-3 rounded shadow-sm" style="border-left: 4px solid var(--primary);">
                        <div class="small text-muted fw-bold mb-1" style="font-size: 0.75rem; letter-spacing: 0.5px;">SUBJECT</div>
                        <div class="fw-bold text-dark mb-3" id="modalSubjectInfo">CS201 - Data Structures</div>
                        
                        <div class="small text-muted fw-bold mb-1" style="font-size: 0.75rem; letter-spacing: 0.5px;">DATE & TIME</div>
                        <div class="fw-bold text-dark" id="modalDateInfo">2026-05-31 10:30 AM</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="appealReason" class="form-label fw-bold text-dark">Reason for Appeal</label>
                        <textarea class="form-control bg-light" name="reason" id="appealReason" rows="4" required placeholder="Please explain why your attendance should be rechecked (e.g., I was in class, technical issue, etc.)..."></textarea>
                    </div>
                </div>
                <div class="modal-footer border-0 p-3">
                    <button type="button" class="btn btn-light px-4 rounded-pill fw-bold" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 rounded-pill fw-bold" style="background: linear-gradient(135deg, #1e3a5f, #0f2240); border: none;">Submit Appeal</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const appealModal = document.getElementById('appealModal');
        if (appealModal) {
            appealModal.addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget;
                const attendanceId = button.getAttribute('data-attendance-id');
                const subjectInfo = button.getAttribute('data-subject-info');
                const dateInfo = button.getAttribute('data-date-info');
                
                appealModal.querySelector('#modalAttendanceId').value = attendanceId;
                appealModal.querySelector('#modalSubjectInfo').textContent = subjectInfo;
                appealModal.querySelector('#modalDateInfo').textContent = dateInfo;
            });
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
<script>

    document.addEventListener('DOMContentLoaded', function() {
        const events = [];
        <% if (history != null) {
            for (Attendance a : history) {
                String color = "#dc3545";
                if ("Present".equals(a.getStatus())) color = "#198754";
                else if ("Leave".equals(a.getStatus())) color = "#6c757d";
                String subCode = a.getSubjectCode() != null ? a.getSubjectCode() : "";
                String subName = a.getSubjectName() != null ? a.getSubjectName() : "Unknown";
                String calTitle = subCode.isEmpty() ? subName : (subCode + " - " + subName);
                // Escape single quotes to avoid JS syntax errors
                calTitle = calTitle.replace("'", "\\'");
                subName = subName.replace("'", "\\'");
                String isoDateTime = sdtf.format(a.getDateTime());
                String timeStr = timeOnly.format(a.getDateTime());
                String dateOnly = sdf.format(a.getDateTime()); // yyyy-MM-dd in server timezone
        %>
        events.push({
            title: '<%= calTitle %>: <%= a.getStatus() %>',
            start: '<%= isoDateTime %>',
            dateOnly: '<%= dateOnly %>',
            backgroundColor: '<%= color %>',
            borderColor: 'transparent',
            textColor: '#fff',
            extendedProps: {
                subject: '<%= subName %>',
                status: '<%= a.getStatus() %>',
                time: '<%= timeStr %>'
            }
        });
        <% } } %>

        // Build a map: 'YYYY-MM-DD' -> [ {color, subject, status, time, code} ]
        var dateEventsMap = {};
        events.forEach(function(ev) {
            var dateKey = ev.dateOnly; // Server-formatted date avoids JS timezone parsing
            if (!dateEventsMap[dateKey]) dateEventsMap[dateKey] = [];
            // Extract just the subject code (part before " - ")
            var parts = ev.title.split(':')[0].split(' - ');
            var code = parts[0].trim();
            dateEventsMap[dateKey].push({
                color:   ev.backgroundColor,
                subject: ev.extendedProps.subject,
                status:  ev.extendedProps.status,
                time:    ev.extendedProps.time,
                code:    code,
                dateStr: ev.start
            });
        });

        function showCalToast(ev, dateStr) {
            var toast    = document.getElementById('calEventToast');
            var statusEl = document.getElementById('calToastStatus');
            statusEl.textContent = ev.status;
            statusEl.className   = 'badge px-3 py-2 rounded-pill';
            if (ev.status === 'Present')      { statusEl.style.background='#198754'; statusEl.style.color='#fff'; }
            else if (ev.status === 'Absent')  { statusEl.style.background='#dc3545'; statusEl.style.color='#fff'; }
            else                              { statusEl.style.background='#6c757d'; statusEl.style.color='#fff'; }
            document.getElementById('calToastSubject').textContent = ev.subject;
            document.getElementById('calToastDate').textContent    = '\uD83D\uDCC5 ' + dateStr;
            document.getElementById('calToastTime').textContent    = '\uD83D\uDD50 ' + ev.time;
            toast.style.display = 'block';
            clearTimeout(window._calToastTimer);
            window._calToastTimer = setTimeout(function() { toast.style.display='none'; }, 4000);
        }

        window.calendar = new FullCalendar.Calendar(document.getElementById('attendanceCalendar'), {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left:   'prev,next today',
                center: 'title',
                right:  'dayGridMonth,timeGridWeek,timeGridDay'
            },
            buttonText: { today: 'Today', month: 'Month', week: 'Week', day: 'Day' },
            events: [],           // No FullCalendar-managed events — we render dots ourselves
            height: 430,
            dayCellDidMount: function(info) {
                // Use toISOString() — matches FullCalendar's internal UTC date representation
                var key = info.date.toISOString().substring(0, 10);
                var dayEvs = dateEventsMap[key];
                if (!dayEvs || dayEvs.length === 0) return;

                // Create a dots row under the date number
                var container = document.createElement('div');
                container.style.cssText = 'display:flex;flex-direction:column;gap:2px;padding:2px 4px 3px;';

                dayEvs.forEach(function(ev) {
                    var row = document.createElement('div');
                    row.style.cssText = 'display:flex;align-items:center;gap:4px;cursor:pointer;padding:1px 2px;border-radius:4px;transition:background 0.15s;';
                    row.onmouseover = function() { row.style.background='rgba(0,0,0,0.06)'; };
                    row.onmouseout  = function() { row.style.background='transparent'; };

                    var dot = document.createElement('span');
                    dot.style.cssText = 'width:8px;height:8px;border-radius:50%;background:' + ev.color
                        + ';display:inline-block;flex-shrink:0;box-shadow:0 1px 4px rgba(0,0,0,0.2);';

                    var label = document.createElement('span');
                    label.textContent  = ev.code;
                    label.style.cssText = 'font-size:0.68rem;font-weight:700;color:#1e293b;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:80px;';

                    row.appendChild(dot);
                    row.appendChild(label);

                    // Click → show toast
                    (function(evData) {
                        row.onclick = function() {
                            var dateLabel = info.date.toLocaleDateString('en-IN', {
                                weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
                            });
                            showCalToast(evData, dateLabel);
                        };
                    })(ev);

                    container.appendChild(row);
                });

                // Append below the date number inside the cell frame
                var frame = info.el.querySelector('.fc-daygrid-day-frame');
                if (frame) frame.appendChild(container);
            }
        });
        window.calendar.render();
    });
</script>

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

