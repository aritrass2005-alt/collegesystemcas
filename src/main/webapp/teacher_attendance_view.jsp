<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Subject" %>
<%@ page import="com.college.attendance.model.Attendance" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    List<Attendance> records = (List<Attendance>) request.getAttribute("records");
    String selectedSubject = (String) request.getAttribute("selectedSubject");
    String selectedDate = (String) request.getAttribute("selectedDate");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Attendance History - Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .radio-btn-group input[type="radio"] {
            display: none;
        }
        .radio-btn-group label {
            cursor: pointer;
            padding: 4px 14px;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            user-select: none;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.2s;
        }
        .radio-btn-group input[type="radio"]:checked + label.present-label {
            background-color: #198754 !important;
            color: white !important;
            border-color: #198754 !important;
            box-shadow: 0 3px 8px rgba(25, 135, 84, 0.2);
        }
        .radio-btn-group input[type="radio"]:checked + label.absent-label {
            background-color: #dc3545 !important;
            color: white !important;
            border-color: #dc3545 !important;
            box-shadow: 0 3px 8px rgba(220, 53, 69, 0.2);
        }
        .radio-btn-group label:hover {
            background-color: #f8f9fa;
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

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Attendance History</h3>

            <% if(request.getParameter("error") != null || request.getAttribute("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show mb-4">
                    <i class="bi bi-exclamation-octagon-fill me-2"></i>
                    <%= request.getParameter("error") != null ? request.getParameter("error") : request.getAttribute("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show mb-4">
                    <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <!-- Search Logs Panel -->
            <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius);">
                <h5 class="fw-bold mb-3">Retrieve Attendance History</h5>
                <form action="teacherAttendanceView" method="get" class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label text-muted small fw-bold">Select Subject</label>
                        <select name="subject_id" class="form-select" required>
                            <option value="">-- Choose Subject --</option>
                            <% if(subjects != null) { 
                                for(Subject sub : subjects) { 
                                    boolean isSel = selectedSubject != null && selectedSubject.equals(String.valueOf(sub.getId()));
                            %>
                                <option value="<%= sub.getId() %>" <%= isSel ? "selected" : "" %>>
                                    <%= sub.getSubjectCode() %> - <%= sub.getName() %> (Yr <%= sub.getYear() %>, Sec <%= sub.getSection() != null && !sub.getSection().isEmpty() ? sub.getSection() : "All" %>)
                                </option>
                            <%  } 
                               } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label text-muted small fw-bold">Select Date</label>
                        <input type="date" name="date" class="form-control" value="<%= selectedDate != null ? selectedDate : "" %>" required>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary-custom w-100 py-2">
                            <i class="bi bi-search me-2"></i>Retrieve History
                        </button>
                    </div>
                </form>
            </div>

            <!-- Attendance Records Table -->
            <% if(selectedSubject != null && selectedDate != null) { %>
                <div class="card border-0 shadow-sm custom-table">
                    <div class="card-header bg-white border-0 pt-4 pb-0">
                        <h5 class="fw-bold mb-1">Attendance Log for <span class="text-primary"><%= selectedDate %></span></h5>
                        <p class="text-muted small mb-0">View student attendance. You can appeal to Admin for corrections if needed.</p>
                    </div>
                    <div class="card-body mt-3">
                        <% if(records != null && !records.isEmpty()) { %>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th>Roll No</th>
                                                <th>Student Name</th>
                                                <th class="text-center" style="width: 30%">Status</th>
                                                <th class="text-end" style="width: 30%">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for(Attendance record : records) { 
                                                boolean canEdit = "Approved".equals(record.getAppealStatus()) && !record.isAdminEdited();
                                                boolean pending = "Pending".equals(record.getAppealStatus());
                                                boolean adminLocked = record.isAdminEdited() || record.isLocked();
                                            %>
                                                <tr>
                                                    <td class="fw-bold"><%= record.getStudentRollNo() %></td>
                                                    <td>
                                                        <div class="d-flex align-items-center gap-2">
                                                            <img src="https://ui-avatars.com/api/?name=<%= record.getStudentName() %>&background=e8e8e8&color=555&bold=true" 
                                                                 style="width: 32px; height: 32px; border-radius: 50%;">
                                                            <span class="fw-semibold"><%= record.getStudentName() %></span>
                                                        </div>
                                                    </td>
                                                    <td class="text-center">
                                                        <% if(canEdit) { %>
                                                            <form action="teacherAttendanceView" method="post" class="d-flex justify-content-center align-items-center m-0 gap-2">
                                                                <input type="hidden" name="action" value="update">
                                                                <input type="hidden" name="subject_id" value="<%= selectedSubject %>">
                                                                <input type="hidden" name="date" value="<%= selectedDate %>">
                                                                <input type="hidden" name="attendanceId" value="<%= record.getId() %>">
                                                                <div class="radio-btn-group d-inline-flex gap-1">
                                                                    <input type="radio" id="p_<%= record.getId() %>" name="status_<%= record.getId() %>" value="Present" <%= "Present".equals(record.getStatus()) ? "checked" : "" %>>
                                                                    <label for="p_<%= record.getId() %>" class="present-label text-success">Present</label>
                                                                    
                                                                    <input type="radio" id="a_<%= record.getId() %>" name="status_<%= record.getId() %>" value="Absent" <%= "Absent".equals(record.getStatus()) ? "checked" : "" %>>
                                                                    <label for="a_<%= record.getId() %>" class="absent-label text-danger">Absent</label>
                                                                </div>
                                                                <button type="submit" class="btn btn-sm btn-success fw-bold"><i class="bi bi-check-lg"></i> Save</button>
                                                            </form>
                                                        <% } else { %>
                                                            <div class="radio-btn-group d-inline-flex gap-2">
                                                                <input type="radio" id="p_<%= record.getId() %>" name="status_<%= record.getId() %>" value="Present" <%= "Present".equals(record.getStatus()) ? "checked" : "" %> disabled>
                                                                <label for="p_<%= record.getId() %>" class="present-label text-success">Present</label>
                                                                
                                                                <input type="radio" id="a_<%= record.getId() %>" name="status_<%= record.getId() %>" value="Absent" <%= "Absent".equals(record.getStatus()) ? "checked" : "" %> disabled>
                                                                <label for="a_<%= record.getId() %>" class="absent-label text-danger">Absent</label>
                                                            </div>
                                                        <% } %>
                                                    </td>
                                                    <td class="text-end">
                                                        <% if(adminLocked) { %>
                                                            <span class="badge bg-secondary text-white p-2 rounded-pill"><i class="bi bi-lock-fill me-1"></i> Locked by Admin</span>
                                                        <% } else if(pending) { %>
                                                            <span class="badge bg-warning text-dark p-2 rounded-pill"><i class="bi bi-hourglass-split me-1"></i> Appeal Pending</span>
                                                        <% } else if(canEdit) { %>
                                                            <span class="badge bg-success text-white p-2 rounded-pill"><i class="bi bi-check-circle me-1"></i> Appeal Approved</span>
                                                        <% } else { %>
                                                            <form action="teacherAttendanceView" method="post" class="m-0" onsubmit="return confirm('Are you sure you want to appeal to change this attendance record?');">
                                                                <input type="hidden" name="action" value="appeal">
                                                                <input type="hidden" name="subject_id" value="<%= selectedSubject %>">
                                                                <input type="hidden" name="date" value="<%= selectedDate %>">
                                                                <input type="hidden" name="attendanceId" value="<%= record.getId() %>">
                                                                <button type="submit" class="btn btn-sm btn-outline-primary"><i class="bi bi-exclamation-circle me-1"></i> Appeal for Change</button>
                                                            </form>
                                                        <% } %>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                        <% } else { %>
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-calendar-x fs-1 text-muted d-block mb-3"></i>
                                <h6>No attendance records found for this date.</h6>
                                <p class="small">Ensure the correct subject and date are selected, or that attendance has been taken for this day.</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
