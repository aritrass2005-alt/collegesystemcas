<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.FacultyAttendance" %>
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
            
            <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius); background: white;">
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

            <div class="card custom-table p-4 border-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
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
                                            String badgeClass = "secondary";
                                            if("Present".equalsIgnoreCase(fa.getStatus())) badgeClass="success";
                                            else if("Absent".equalsIgnoreCase(fa.getStatus())) badgeClass="danger";
                                            else if("Half Day".equalsIgnoreCase(fa.getStatus())) badgeClass="warning text-dark";
                                        %>
                                        <span class="badge bg-<%= badgeClass %>"><%= fa.getStatus() %></span>
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
                                        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editModal<%= fa.getId() %>">
                                            <i class="bi bi-pencil-square"></i> Verify
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
                                                                <select name="status" class="form-select">
                                                                    <option value="Present" <%= "Present".equals(fa.getStatus())?"selected":"" %>>Present</option>
                                                                    <option value="Half Day" <%= "Half Day".equals(fa.getStatus())?"selected":"" %>>Half Day</option>
                                                                    <option value="Absent" <%= "Absent".equals(fa.getStatus())?"selected":"" %>>Absent</option>
                                                                    <option value="On Leave" <%= "On Leave".equals(fa.getStatus())?"selected":"" %>>On Leave</option>
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
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
