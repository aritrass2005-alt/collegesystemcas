<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.FacultyAttendance" %>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || (!"Admin".equals(role) && !"SuperAdmin".equals(role))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<FacultyAttendance> records = (List<FacultyAttendance>) request.getAttribute("records");
    List<Teacher> absentRecords = (List<Teacher>) request.getAttribute("absentRecords");
    List<FacultyAttendance> pendingLeaves = (List<FacultyAttendance>) request.getAttribute("pendingLeaves");
    Date targetDate = (Date) request.getAttribute("targetDate");
    String dept = (String) request.getAttribute("department");
    SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Faculty Attendance – Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />
        <div class="container-fluid p-4">
            
            <% if (request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <h3 class="fw-bold mb-4">Faculty Attendance Monitoring</h3>
            
            <div class="card p-3 border-0 shadow-sm mb-3" style="border-radius: var(--card-radius); background: white;">
                <form action="adminFacultyAttendance" method="get" class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Date</label>
                        <input type="date" name="date" class="form-control" value="<%= targetDate != null ? targetDate.toString() : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Department (Optional)</label>
                        <input type="text" name="department" class="form-control" placeholder="e.g. CSE" value="<%= dept != null ? dept : "" %>">
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary-custom px-4"><i class="bi bi-search me-2"></i> Filter</button>
                        <a href="adminFacultyAttendance" class="btn btn-light ms-2">Clear</a>
                    </div>
                </form>
            </div>

            <!-- Nav Tabs -->
            <ul class="nav nav-tabs mb-3" id="attendanceTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active fw-bold" id="records-tab" data-bs-toggle="tab" data-bs-target="#records" type="button" role="tab">Attendance Records</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link fw-bold text-danger" id="absent-tab" data-bs-toggle="tab" data-bs-target="#absent" type="button" role="tab">Absent List</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link fw-bold text-warning" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pending" type="button" role="tab">
                        Pending Leaves
                        <% if (pendingLeaves != null && !pendingLeaves.isEmpty()) { %>
                            <span class="badge bg-warning text-dark ms-1"><%= pendingLeaves.size() %></span>
                        <% } %>
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="attendanceTabsContent">
                <!-- Records Tab -->
                <div class="tab-pane fade show active" id="records" role="tabpanel">
                    <div class="card custom-table p-3 border-0 shadow-sm">
                        <div class="table-responsive">
                            <table class="table table-hover table-sm align-middle mb-0" style="font-size: 0.9rem;">
                        <thead class="table-light">
                            <tr>
                                <th>Faculty Name</th>
                                <th>Department</th>
                                <th>Date</th>
                                <th>Check-In</th>
                                <th>Check-Out</th>
                                <th>Hours</th>
                                <th>Status</th>
                                <th>Admin Verification</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (records != null && !records.isEmpty()) {
                                for (FacultyAttendance fa : records) { 
                            %>
                                <tr>
                                    <td class="fw-bold">
                                        <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(fa.getTeacherName()) %>&background=e2e8f0&color=1e293b" class="rounded-circle me-2" width="30" height="30">
                                        <%= fa.getTeacherName() %>
                                    </td>
                                    <td><%= fa.getTeacherDepartment() %></td>
                                    <td><%= fa.getDate() %></td>
                                    <td><%= fa.getCheckInTime() != null ? timeFmt.format(fa.getCheckInTime()) : "--" %></td>
                                    <td><%= fa.getCheckOutTime() != null ? timeFmt.format(fa.getCheckOutTime()) : "--" %></td>
                                    <td><%= fa.getHoursWorked() %></td>
                                    <td>
                                        <%
                                            String status = fa.getStatus() != null ? fa.getStatus() : "";
                                            String badgeClass = "secondary";
                                            if("Present".equalsIgnoreCase(status)) badgeClass="success";
                                            else if("Absent".equalsIgnoreCase(status)) badgeClass="danger";
                                            else if("Half Day".equalsIgnoreCase(status)) badgeClass="warning text-dark";
                                            else if(status.contains("Leave") || status.equals("CL") || status.equals("CCL") || status.equals("EL")) badgeClass="info text-dark";
                                        %>
                                        <span class="badge bg-<%= badgeClass %>"><%= status %></span>
                                    </td>
                                    <td>
                                        <% if(fa.isVerifiedByAdmin()) { %>
                                            <span class="text-success fw-bold"><i class="bi bi-check-circle-fill"></i> Verified</span>
                                        <% } else { %>
                                            <span class="text-muted"><i class="bi bi-clock"></i> Pending</span>
                                        <% } %>
                                        <% if(fa.getAdminNotes() != null && !fa.getAdminNotes().isEmpty()) { %>
                                            <br><small class="text-muted fst-italic">"<%= fa.getAdminNotes() %>"</small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary py-0" style="font-size: 0.8rem;" data-bs-toggle="modal" data-bs-target="#editModal<%= fa.getId() %>">
                                            <i class="bi bi-pencil-square"></i> Edit
                                        </button>

                                        <!-- Edit Modal -->
                                        <div class="modal fade" id="editModal<%= fa.getId() %>" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <form action="adminFacultyAttendance" method="post">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Verify Attendance: <%= fa.getTeacherName() %></h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="id" value="<%= fa.getId() %>">
                                                            <input type="hidden" name="currentDate" value="<%= targetDate %>">
                                                            <input type="hidden" name="currentDept" value="<%= dept != null ? dept : "" %>">
                                                            
                                                            <div class="mb-3">
                                                                <label class="form-label">Status</label>
                                                                <select name="status" class="form-select form-select-sm">
                                                                    <option value="Present" <%= "Present".equals(fa.getStatus())?"selected":"" %>>Present</option>
                                                                    <option value="Half Day" <%= "Half Day".equals(fa.getStatus())?"selected":"" %>>Half Day</option>
                                                                    <option value="Absent" <%= "Absent".equals(fa.getStatus())?"selected":"" %>>Absent</option>
                                                                    <option value="On Leave" <%= "On Leave".equals(fa.getStatus())?"selected":"" %>>On Leave</option>
                                                                    <option value="CL" <%= "CL".equals(fa.getStatus())?"selected":"" %>>CL</option>
                                                                    <option value="CCL" <%= "CCL".equals(fa.getStatus())?"selected":"" %>>CCL</option>
                                                                    <option value="EL" <%= "EL".equals(fa.getStatus())?"selected":"" %>>EL</option>
                                                                    <option value="Normal Leave" <%= "Normal Leave".equals(fa.getStatus())?"selected":"" %>>Normal Leave</option>
                                                                </select>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label">Admin Notes</label>
                                                                <textarea name="notes" class="form-control" rows="2"><%= fa.getAdminNotes() != null ? fa.getAdminNotes() : "" %></textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="submit" class="btn btn-primary">Save & Verify</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            <% } } else { %>
                                <tr><td colspan="9" class="text-center text-muted py-4">No records found for this date.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                        </div>
                    </div>
                </div>

                <!-- Absent List Tab -->
                <div class="tab-pane fade" id="absent" role="tabpanel">
                    <div class="card custom-table p-3 border-0 shadow-sm">
                        <div class="table-responsive">
                            <table class="table table-hover table-sm align-middle mb-0" style="font-size: 0.9rem;">
                                <thead class="table-light">
                                    <tr>
                                        <th>Faculty Name</th>
                                        <th>Department</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (absentRecords != null && !absentRecords.isEmpty()) {
                                        for (Teacher t : absentRecords) { 
                                    %>
                                        <tr>
                                            <td class="fw-bold text-danger">
                                                <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(t.getName()) %>&background=fee2e2&color=991b1b" class="rounded-circle me-2" width="24" height="24">
                                                <%= t.getName() %>
                                            </td>
                                            <td><%= t.getDepartment() %></td>
                                            <td><%= t.getEmail() %></td>
                                            <td><%= t.getPhone() != null ? t.getPhone() : "--" %></td>
                                            <td><span class="badge bg-danger">Absent (No Entry)</span></td>
                                            <td>
                                                <button class="btn btn-sm btn-outline-primary py-0" style="font-size: 0.8rem;" data-bs-toggle="modal" data-bs-target="#addModal<%= t.getId() %>">
                                                    <i class="bi bi-pencil-square"></i> Mark
                                                </button>

                                                <!-- Add Attendance Modal -->
                                                <div class="modal fade" id="addModal<%= t.getId() %>" tabindex="-1">
                                                    <div class="modal-dialog">
                                                        <div class="modal-content">
                                                            <form action="adminFacultyAttendance" method="post">
                                                                <input type="hidden" name="action" value="add">
                                                                <input type="hidden" name="teacherId" value="<%= t.getId() %>">
                                                                <input type="hidden" name="targetDate" value="<%= targetDate %>">
                                                                <input type="hidden" name="currentDate" value="<%= targetDate %>">
                                                                <input type="hidden" name="currentDept" value="<%= dept != null ? dept : "" %>">
                                                                
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Mark Attendance: <%= t.getName() %></h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Status</label>
                                                                        <select name="status" class="form-select form-select-sm">
                                                                            <option value="Present">Present</option>
                                                                            <option value="Half Day">Half Day</option>
                                                                            <option value="Absent" selected>Absent</option>
                                                                            <option value="On Leave">On Leave</option>
                                                                            <option value="CL">CL</option>
                                                                            <option value="CCL">CCL</option>
                                                                            <option value="EL">EL</option>
                                                                            <option value="Normal Leave">Normal Leave</option>
                                                                        </select>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Leave Reason / Admin Notes</label>
                                                                        <textarea name="notes" class="form-control" rows="2" placeholder="Reason for leave or absence"></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="submit" class="btn btn-primary">Save Record</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } } else { %>
                                        <tr><td colspan="5" class="text-center text-muted py-4">No absent faculty found for this date.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Pending Leaves Tab -->
                <div class="tab-pane fade" id="pending" role="tabpanel">
                    <div class="card custom-table p-3 border-0 shadow-sm">
                        <% if (pendingLeaves != null && !pendingLeaves.isEmpty()) { %>
                        <div class="d-flex justify-content-end mb-3">
                            <form action="adminFacultyAttendance" method="post" onsubmit="return confirm('Are you sure you want to verify and approve ALL pending leaves?');">
                                <input type="hidden" name="action" value="verifyAllPending">
                                <input type="hidden" name="currentDate" value="<%= targetDate %>">
                                <input type="hidden" name="currentDept" value="<%= dept != null ? dept : "" %>">
                                <button type="submit" class="btn btn-success shadow-sm" style="border-radius: var(--card-radius);">
                                    <i class="bi bi-check-all me-1"></i> Verify All Pending Leaves
                                </button>
                            </form>
                        </div>
                        <% } %>
                        <div class="table-responsive">
                            <table class="table table-hover table-sm align-middle mb-0" style="font-size: 0.9rem;">
                                <thead class="table-light">
                                    <tr>
                                        <th>Faculty Name</th>
                                        <th>Department</th>
                                        <th>Leave Date</th>
                                        <th>Requested Leave Type</th>
                                        <th>Reason / Notes</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (pendingLeaves != null && !pendingLeaves.isEmpty()) {
                                        for (FacultyAttendance pl : pendingLeaves) { 
                                    %>
                                        <tr>
                                            <td class="fw-bold">
                                                <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(pl.getTeacherName()) %>&background=e2e8f0&color=1e293b" class="rounded-circle me-2" width="24" height="24">
                                                <%= pl.getTeacherName() %>
                                            </td>
                                            <td><%= pl.getTeacherDepartment() %></td>
                                            <td class="fw-bold text-primary"><%= pl.getDate() %></td>
                                            <td><span class="badge bg-info text-dark"><%= pl.getStatus() %></span></td>
                                            <td><%= pl.getAdminNotes() != null ? pl.getAdminNotes() : "--" %></td>
                                            <td>
                                                <button class="btn btn-sm btn-outline-success py-0" style="font-size: 0.8rem;" data-bs-toggle="modal" data-bs-target="#verifyLeaveModal<%= pl.getId() %>">
                                                    <i class="bi bi-check-circle"></i> Verify
                                                </button>

                                                <!-- Verify Leave Modal -->
                                                <div class="modal fade" id="verifyLeaveModal<%= pl.getId() %>" tabindex="-1">
                                                    <div class="modal-dialog">
                                                        <div class="modal-content">
                                                            <form action="adminFacultyAttendance" method="post">
                                                                <input type="hidden" name="id" value="<%= pl.getId() %>">
                                                                <input type="hidden" name="currentDate" value="<%= targetDate %>">
                                                                <input type="hidden" name="currentDept" value="<%= dept != null ? dept : "" %>">
                                                                
                                                                <div class="modal-header">
                                                                    <h5 class="modal-title">Verify Leave: <%= pl.getTeacherName() %></h5>
                                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                                </div>
                                                                <div class="modal-body">
                                                                    <p><strong>Requested Date:</strong> <%= pl.getDate() %></p>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Status (Approve/Reject)</label>
                                                                        <select name="status" class="form-select form-select-sm">
                                                                            <option value="<%= pl.getStatus() %>" selected>Approve as <%= pl.getStatus() %></option>
                                                                            <option value="Absent">Reject (Mark Absent)</option>
                                                                            <option value="Present">Present</option>
                                                                        </select>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">Admin Notes</label>
                                                                        <textarea name="notes" class="form-control" rows="2"><%= pl.getAdminNotes() != null ? pl.getAdminNotes() : "" %></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer">
                                                                    <button type="submit" class="btn btn-primary">Save & Verify</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } } else { %>
                                        <tr><td colspan="6" class="text-center text-muted py-4">No pending leave applications.</td></tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
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

