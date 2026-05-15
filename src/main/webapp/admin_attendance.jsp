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
    <link href="css/admin_theme.css" rel="stylesheet">
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
            <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius);">
                <form action="adminAttendance" method="get" class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label text-muted small">Select Subject</label>
                        <select name="subject_id" class="form-select" required>
                            <option value="">-- Choose Subject --</option>
                            <% if(subjects!=null){ for(Subject s:subjects){ 
                                String sid = String.valueOf(s.getId());
                            %>
                                <option value="<%= s.getId() %>" <%= sid.equals(request.getAttribute("selectedSubject")) ? "selected" : "" %>><%= s.getName() %> (<%= s.getSubjectCode() %>)</option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label text-muted small">Select Date</label>
                        <input type="date" name="date" class="form-control" required value="<%= request.getAttribute("selectedDate") != null ? request.getAttribute("selectedDate") : "" %>">
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary-custom w-100">Fetch Records</button>
                    </div>
                </form>
            </div>

            <!-- Attendance Records -->
            <% if (request.getAttribute("selectedSubject") != null && request.getAttribute("selectedDate") != null) { %>
                <div class="card custom-table border-0 shadow-sm">
                    <div class="card-header bg-white border-0 pt-4 pb-0">
                        <h5 class="fw-bold mb-0">Records for <%= request.getAttribute("selectedDate") %></h5>
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
                                            <% for(Attendance a : records) { %>
                                            <tr>
                                                <input type="hidden" name="attendanceId" value="<%= a.getId() %>">
                                                <td class="fw-bold"><%= a.getStudentRollNo() %></td>
                                                <td><%= a.getStudentName() %></td>
                                                <td>
                                                    <% if("Present".equals(a.getStatus())) { %>
                                                        <span class="badge bg-success">Present</span>
                                                    <% } else { %>
                                                        <span class="badge bg-danger">Absent</span>
                                                    <% } %>
                                                    <% if(a.isLocked()) { %>
                                                        <span class="badge bg-secondary ms-2" title="Teacher Locked"><i class="bi bi-lock-fill"></i></span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <select name="status_<%= a.getId() %>" class="form-select form-select-sm" style="width: 130px;">
                                                        <option value="Present" <%= "Present".equals(a.getStatus()) ? "selected" : "" %>>Present</option>
                                                        <option value="Absent" <%= "Absent".equals(a.getStatus()) ? "selected" : "" %>>Absent</option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                <div class="mt-4 text-end">
                                    <button type="submit" class="btn btn-warning fw-bold px-4">Update All Records</button>
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
</body>
</html>
