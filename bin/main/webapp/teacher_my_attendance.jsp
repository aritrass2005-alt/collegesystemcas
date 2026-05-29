<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.FacultyAttendance" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<FacultyAttendance> history = (List<FacultyAttendance>) request.getAttribute("history");
    List<FacultyAttendance> pendingList = new java.util.ArrayList<>();
    SimpleDateFormat sdtf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    SimpleDateFormat timeOnly = new SimpleDateFormat("hh:mm a");

    int presentDays = 0, absentDays = 0, leaveDays = 0, pendingLeaves = 0;
    if (history != null) {
        for (FacultyAttendance fa : history) {
            if (!fa.isVerifiedByAdmin()) {
                pendingLeaves++;
                pendingList.add(fa);
            }
            else if ("Present".equalsIgnoreCase(fa.getStatus()) || "Half Day".equalsIgnoreCase(fa.getStatus())) presentDays++;
            else if ("Absent".equalsIgnoreCase(fa.getStatus())) absentDays++;
            else leaveDays++;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Attendance – CAS Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
    <style>
        .fc-theme-standard td, .fc-theme-standard th { border-radius: 8px; }
        .fc-event { border-radius: 6px; border: none; padding: 2px 4px; font-weight: 600; font-size: 0.85em; }
    </style>
</head>
<body>
    <jsp:include page="includes/teacher_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/teacher_header.jsp" />
        <div class="container-fluid p-4">
            
            <% if (request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row mb-4">
                <div class="col-12">
                    <h3 class="fw-bold mb-0">My Attendance History</h3>
                </div>
            </div>

            <div class="row g-4">
                <!-- Left Column: Calendar -->
                <div class="col-lg-8">
                    <div class="card p-3 border-0 shadow-sm" style="border-radius: var(--card-radius); background: white;">
                        <div id="attendanceCalendar"></div>
                    </div>
                </div>
                
                <!-- Right Column: Summary & Actions -->
                <div class="col-lg-4">
                    <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius); background: white;">
                        <h5 class="fw-bold mb-3">Leave Actions</h5>
                        <button class="btn btn-primary w-100 py-2 d-flex justify-content-center align-items-center" data-bs-toggle="modal" data-bs-target="#applyLeaveModal">
                            <i class="bi bi-calendar2-plus fs-5 me-2"></i> Apply for Leave
                        </button>
                    </div>

                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius); background: white;">
                        <h5 class="fw-bold mb-4">Attendance Summary</h5>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <i class="bi bi-check-circle-fill text-success me-2"></i>
                                <span class="fw-medium">Present Days</span>
                            </div>
                            <span class="badge bg-success rounded-pill px-3"><%= presentDays %></span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <i class="bi bi-airplane-fill text-info me-2"></i>
                                <span class="fw-medium">Approved Leaves</span>
                            </div>
                            <span class="badge bg-info rounded-pill px-3"><%= leaveDays %></span>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <i class="bi bi-x-circle-fill text-danger me-2"></i>
                                <span class="fw-medium">Absent Days</span>
                            </div>
                            <span class="badge bg-danger rounded-pill px-3"><%= absentDays %></span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <i class="bi bi-hourglass-split text-secondary me-2"></i>
                                <span class="fw-bold text-muted">Pending Requests</span>
                            </div>
                            <span class="badge bg-secondary rounded-pill px-3"><%= pendingLeaves %></span>
                        </div>
                    </div>
                    
                    <% if (!pendingList.isEmpty()) { %>
                    <div class="card p-3 border-0 shadow-sm mt-4" style="border-radius: var(--card-radius); background: white;">
                        <h6 class="fw-bold mb-3 text-secondary">Cancel Pending Leaves</h6>
                        <ul class="list-group list-group-flush">
                            <% for (FacultyAttendance pfa : pendingList) { %>
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0 py-2 border-0">
                                <div>
                                    <div class="small fw-bold"><%= pfa.getDate() %></div>
                                    <div class="text-muted" style="font-size: 0.8rem;"><%= pfa.getStatus() %></div>
                                </div>
                                <a href="facultyAttendance?action=cancel_leave&id=<%= pfa.getId() %>" class="btn btn-sm btn-outline-danger py-0 px-2" style="font-size: 0.75rem;" onclick="return confirm('Cancel this leave application?');">Cancel</a>
                            </li>
                            <% } %>
                        </ul>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Apply Leave Modal -->
            <div class="modal fade" id="applyLeaveModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="facultyAttendance" method="post">
                            <input type="hidden" name="action" value="apply_leave">
                            <div class="modal-header">
                                <h5 class="modal-title">Apply for Leave</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Start Date</label>
                                        <input type="date" name="startDate" class="form-control" required id="startDateInput">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">End Date</label>
                                        <input type="date" name="endDate" class="form-control" required id="endDateInput">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Leave Type</label>
                                    <select name="status" class="form-select" required>
                                        <option value="CL">Casual Leave (CL)</option>
                                        <option value="CCL">Child Care Leave (CCL)</option>
                                        <option value="EL">Earned Leave (EL)</option>
                                        <option value="Normal Leave">Normal Leave</option>
                                        <option value="On Leave">Other / On Leave</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Reason / Notes</label>
                                    <textarea name="notes" class="form-control" rows="3" required placeholder="Provide reason for leave"></textarea>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="submit" class="btn btn-primary">Submit Application</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const events = [];
            <% if (history != null) {
                for (FacultyAttendance fa : history) {
                    String color = "#dc3545"; // Absent
                    if ("Present".equalsIgnoreCase(fa.getStatus())) color = "#198754";
                    else if ("Half Day".equalsIgnoreCase(fa.getStatus())) color = "#ffc107";
                    else if (fa.getStatus().contains("Leave") || "CL".equals(fa.getStatus()) || "CCL".equals(fa.getStatus()) || "EL".equals(fa.getStatus())) color = "#0dcaf0";
                    
                    String title = fa.getStatus();
                    if (!fa.isVerifiedByAdmin()) {
                        title += " (Pending)";
                        color = "#6c757d"; // Gray out pending requests
                    }
                    String inStr = fa.getCheckInTime() != null ? timeOnly.format(fa.getCheckInTime()) : "--";
                    String outStr = fa.getCheckOutTime() != null ? timeOnly.format(fa.getCheckOutTime()) : "--";
            %>
            events.push({
                title: '<%= title %>',
                start: '<%= fa.getDate() %>',
                backgroundColor: '<%= color %>',
                borderColor: 'transparent',
                textColor: '#fff',
                extendedProps: {
                    status: '<%= title %>',
                    inTime: '<%= inStr %>',
                    outTime: '<%= outStr %>',
                    hours: '<%= fa.getHoursWorked() %>'
                }
            });
            <% } } %>

            var calendar = new FullCalendar.Calendar(document.getElementById('attendanceCalendar'), {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,listMonth'
                },
                events: events,
                height: 500,
                eventDidMount: function(info) {
                    var props = info.event.extendedProps;
                    var tooltipText = props.status + '\nIn: ' + props.inTime + '\nOut: ' + props.outTime + '\nHours: ' + props.hours;
                    info.el.setAttribute('title', tooltipText);
                }
            });
            calendar.render();

            // Restrict leave date to tomorrow or later
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            const yyyy = tomorrow.getFullYear();
            const mm = String(tomorrow.getMonth() + 1).padStart(2, '0');
            const dd = String(tomorrow.getDate()).padStart(2, '0');
            const minDate = yyyy + '-' + mm + '-' + dd;
            
            document.getElementById('startDateInput').setAttribute('min', minDate);
            document.getElementById('endDateInput').setAttribute('min', minDate);
            
            // Ensure end date is not before start date
            document.getElementById('startDateInput').addEventListener('change', function() {
                document.getElementById('endDateInput').setAttribute('min', this.value);
            });
        });
    </script>
</body>
</html>
