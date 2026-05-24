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

        /* Sidebar wrapper layout */
        .wrapper { display: flex; width: 100%; align-items: stretch; }

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
        
        .fc-theme-standard td, .fc-theme-standard th { border-radius: 8px; }
        .fc-event {
            border-radius: 6px;
            border: none;
            padding: 2px 4px;
            font-weight: 600;
            font-size: 0.85em;
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

<div class="wrapper">
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
                    <div class="mt-3 d-inline-block px-3 py-2 rounded" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2);">
                        <i class="bi bi-clock me-2"></i> <span id="realTimeClock" class="fw-bold fs-5"></span>
                        <span class="mx-2">|</span>
                        <i class="bi bi-calendar3 me-2"></i> <span id="realTimeDate" class="fw-medium"></span>
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
            <div class="modal-body p-4">
                <div id="attendanceCalendar"></div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
<script>
    function updateClock() {
        const now = new Date();
        let hours = now.getHours();
        let minutes = now.getMinutes();
        let seconds = now.getSeconds();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        seconds = seconds < 10 ? '0' + seconds : seconds;
        
        const timeStr = hours + ':' + minutes + ':' + seconds + ' ' + ampm;
        
        const options = { weekday: 'short', year: 'numeric', month: 'long', day: 'numeric' };
        const dateStr = now.toLocaleDateString('en-US', options);
        
        document.getElementById('realTimeClock').innerText = timeStr;
        document.getElementById('realTimeDate').innerText = dateStr;
    }
    setInterval(updateClock, 1000);
    updateClock(); // initial call
    
    document.addEventListener('DOMContentLoaded', function() {
        const events = [];
        <% if (history != null) {
            for (Attendance a : history) {
                String color = "#dc3545";
                if ("Present".equals(a.getStatus())) color = "#198754";
                else if ("Leave".equals(a.getStatus())) color = "#6c757d";
                String subjectName = a.getStudentName(); // stored in studentName field
                String isoDateTime = sdtf.format(a.getDateTime());
                String timeStr = timeOnly.format(a.getDateTime());
        %>
        events.push({
            title: '<%= subjectName %>: <%= a.getStatus() %>',
            start: '<%= isoDateTime %>',
            backgroundColor: '<%= color %>',
            borderColor: 'transparent',
            textColor: '#fff',
            extendedProps: {
                subject: '<%= subjectName %>',
                status: '<%= a.getStatus() %>',
                time: '<%= timeStr %>'
            }
        });
        <% } } %>

        window.calendar = new FullCalendar.Calendar(document.getElementById('attendanceCalendar'), {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay'
            },
            buttonText: { today: 'Today', month: 'Month', week: 'Week', day: 'Day' },
            events: events,
            eventDisplay: 'block',
            eventBorderRadius: '6px',
            height: 600,
            dayMaxEvents: 3,
            eventTimeFormat: {
                hour: '2-digit',
                minute: '2-digit',
                hour12: true
            },
            eventDidMount: function(info) {
                info.el.style.fontWeight = '600';
                info.el.style.fontSize = '0.8em';
                info.el.style.padding = '2px 6px';

                // Bootstrap tooltip with time info
                var props = info.event.extendedProps;
                info.el.setAttribute('title', props.subject + ' • ' + props.status + ' at ' + props.time);
                info.el.setAttribute('data-bs-toggle', 'tooltip');
                info.el.setAttribute('data-bs-placement', 'top');
            },
            eventClick: function(info) {
                var props = info.event.extendedProps;
                var dateStr = info.event.start.toLocaleDateString('en-IN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
                alert(props.subject + '\n' + props.status + '\nTime: ' + props.time + '\nDate: ' + dateStr);
            }
        });
        window.calendar.render();

        // Init Bootstrap tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (el) { return new bootstrap.Tooltip(el); });
    });
</script>

</body>
</html>
