<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    if (subjects == null) {
        response.sendRedirect("adminAttendance");
        return;
    }
    List<Attendance> records = (List<Attendance>) request.getAttribute("records");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Attendance - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Edit Attendance</h3>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <!-- Selector -->
            <div class="card p-4 border-0 shadow-sm mb-4 d-print-none" style="border-radius: var(--card-radius);">
                <form action="adminAttendance" method="get" class="row g-3 align-items-end">
                    <div class="col-md-2">
                        <label class="form-label text-muted small">Department</label>
                        <select id="deptFilter" class="form-select form-select-sm">
                            <option value="">All</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small">Year</label>
                        <select id="yearFilter" class="form-select form-select-sm">
                            <option value="">All</option>
                            <option value="1">1</option>
                            <option value="2">2</option>
                            <option value="3">3</option>
                            <option value="4">4</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small">Section</label>
                        <select id="secFilter" class="form-select form-select-sm">
                            <option value="">All</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label text-muted small">Select Subject</label>
                        <select name="subject_id" id="subjectSelect" class="form-select form-select-sm" required>
                            <option value="">-- Choose Subject --</option>
                            <% if(subjects!=null){ for(Subject s:subjects){ 
                                String sid = String.valueOf(s.getId());
                            %>
                                <option value="<%= s.getId() %>" data-dept="<%= s.getDepartment() %>" data-year="<%= s.getYear() %>" data-sec="<%= s.getSection() != null ? s.getSection() : "" %>" <%= sid.equals(request.getAttribute("selectedSubject")) ? "selected" : "" %>><%= s.getName() %> (<%= s.getSubjectCode() %>)</option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small">Select Date</label>
                        <input type="date" name="date" class="form-control form-control-sm" required value="<%= request.getAttribute("selectedDate") != null ? request.getAttribute("selectedDate") : "" %>">
                    </div>
                    <div class="col-md-1">
                        <button type="submit" class="btn btn-sm btn-primary-custom w-100">Fetch</button>
                    </div>
                </form>
            </div>

            <!-- Attendance Records -->
            <% if (request.getAttribute("selectedSubject") != null && request.getAttribute("selectedDate") != null) { %>
                <div class="card custom-table border-0 shadow-sm">
                    <div class="card-header bg-white border-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold mb-0">Records for <%= request.getAttribute("selectedDate") %></h5>
                        <button class="btn btn-outline-secondary btn-sm d-print-none" onclick="window.print()"><i class="bi bi-printer"></i> Print / Download Log</button>
                    </div>
                    <div class="card-body mt-3">
                        <% if(records != null && !records.isEmpty()) { %>
                            <form action="adminAttendance" method="post">
                                <input type="hidden" name="subject_id" value="<%= request.getAttribute("selectedSubject") %>">
                                <input type="hidden" name="date" value="<%= request.getAttribute("selectedDate") %>">
                                
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th>Roll No</th>
                                                <th>Student Name</th>
                                                <th>Current Status</th>
                                                <th>Change To</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for(Attendance a : records) { 
                                                boolean pending = "Pending".equals(a.getAppealStatus());
                                            %>
                                            <tr>
                                                <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                                <td class="fw-bold"><%= a.getStudentRollNo() %></td>
                                                <td>
                                                    <%= a.getStudentName() %>
                                                    <% if(pending) { %>
                                                        <span class="badge bg-warning text-dark ms-2"><i class="bi bi-exclamation-triangle"></i> Appeal Pending</span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <% if("Present".equals(a.getStatus())) { %>
                                                        <span class="badge bg-success">Present</span>
                                                    <% } else { %>
                                                        <span class="badge bg-danger">Absent</span>
                                                    <% } %>
                                                    <% if(a.isAdminEdited()) { %>
                                                        <span class="badge bg-secondary ms-2" title="Edited by Admin"><i class="bi bi-lock-fill"></i> Admin Locked</span>
                                                    <% } else if(a.isLocked()) { %>
                                                        <span class="badge bg-secondary ms-2" title="Teacher Locked"><i class="bi bi-lock-fill"></i> Locked</span>
                                                    <% } %>
                                                </td>
                                                <td class="d-flex align-items-center gap-2">
                                                    <% if(!a.isAdminEdited()) { %>
                                                        <select name="status_<%= a.getId() %>" class="form-select form-select-sm" style="width: 130px;">
                                                            <option value="Present" <%= "Present".equals(a.getStatus()) ? "selected" : "" %>>Present</option>
                                                            <option value="Absent" <%= "Absent".equals(a.getStatus()) ? "selected" : "" %>>Absent</option>
                                                        </select>
                                                        <% if(pending) { %>
                                                            <button type="submit" name="approveAppeal" value="<%= a.getId() %>" class="btn btn-sm btn-success fw-bold" formnovalidate>
                                                                <i class="bi bi-check-circle"></i> Approve Appeal
                                                            </button>
                                                        <% } %>
                                                    <% } else { %>
                                                        <span class="text-muted small fst-italic">Cannot override admin edits</span>
                                                    <% } %>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                <div class="mt-4 text-end d-print-none">
                                    <p class="text-muted small mb-2"><i class="bi bi-info-circle"></i> Note: Editing a record as Admin will permanently lock it.</p>
                                    <button type="submit" name="action" value="updateAll" class="btn btn-warning fw-bold px-4">Update Records (Admin Edit)</button>
                                </div>
                            </form>
                        <% } else { %>
                            <div class="text-center py-4 text-muted">No attendance records found for this subject and date.</div>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const deptFilter = document.getElementById('deptFilter');
            const yearFilter = document.getElementById('yearFilter');
            const secFilter = document.getElementById('secFilter');
            const subjectSelect = document.getElementById('subjectSelect');
            const originalOptions = Array.from(subjectSelect.options).filter(opt => opt.value !== "");

            // Populate distinct departments and sections
            const depts = new Set();
            const secs = new Set();
            originalOptions.forEach(opt => {
                const d = opt.getAttribute('data-dept');
                const s = opt.getAttribute('data-sec');
                if(d) depts.add(d);
                if(s) secs.add(s);
            });

            depts.forEach(d => {
                const option = document.createElement('option');
                option.value = d; option.textContent = d;
                deptFilter.appendChild(option);
            });
            secs.forEach(s => {
                const option = document.createElement('option');
                option.value = s; option.textContent = s;
                secFilter.appendChild(option);
            });

            function filterSubjects() {
                const selectedDept = deptFilter.value;
                const selectedYear = yearFilter.value;
                const selectedSec = secFilter.value;

                // Clear current options except the placeholder
                while(subjectSelect.options.length > 1) {
                    subjectSelect.remove(1);
                }

                originalOptions.forEach(opt => {
                    const matchDept = selectedDept === "" || opt.getAttribute('data-dept') === selectedDept;
                    const matchYear = selectedYear === "" || opt.getAttribute('data-year') === selectedYear;
                    const matchSec = selectedSec === "" || opt.getAttribute('data-sec') === selectedSec;
                    
                    if(matchDept && matchYear && matchSec) {
                        subjectSelect.appendChild(opt.cloneNode(true));
                    }
                });
            }

            deptFilter.addEventListener('change', filterSubjects);
            yearFilter.addEventListener('change', filterSubjects);
            secFilter.addEventListener('change', filterSubjects);
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

