<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Subject" %>
<%@ page import="com.college.attendance.dao.SubjectDAO" %>
<%@ page import="com.college.attendance.dao.AttendanceDAO" %>

<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }

    SubjectDAO subjectDAO = new SubjectDAO();
    AttendanceDAO attendanceDAO = new AttendanceDAO();

    List<Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
    int subjectCount = subjects.size();
    int studentCount = attendanceDAO.getStudentCountForTeacher(teacher.getId());
    
    Double sessionThreshold = (Double) session.getAttribute("defaulterThreshold");
    double threshold = sessionThreshold != null ? sessionThreshold : 75.0;
    
    int defaulterCount = attendanceDAO.getDefaulterCountForTeacher(teacher.getId(), threshold);
    double avgAttendance = attendanceDAO.getAverageAttendanceForTeacher(teacher.getId());


%>
<!DOCTYPE html>
<html>
<head>
    <title>Faculty Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/teacher_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="includes/teacher_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Faculty Dashboard</h3>
            
            <div class="row g-4 mb-4">
                <div class="col-md-3">
                    <a href="teacherAttendanceView" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Assigned Subjects</p>
                                <h3><%= subjectCount %></h3>
                            </div>
                            <div class="metric-icon bg-purple-light">
                                <i class="bi bi-book"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="teacherStudentView" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Active Students</p>
                                <h3><%= studentCount %></h3>
                            </div>
                            <div class="metric-icon bg-blue-light">
                                <i class="bi bi-mortarboard"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="teacherDefaulterList" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Defaulters (&lt; <%= threshold %>%)</p>
                                <h3><%= defaulterCount %></h3>
                            </div>
                            <div class="metric-icon bg-orange-light">
                                <i class="bi bi-exclamation-triangle-fill text-danger"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="teacherAttendanceView" style="text-decoration:none; color:inherit; display:block;">
                        <div class="metric-card">
                            <div class="metric-info">
                                <p>Avg. Attendance</p>
                                <h3><%= avgAttendance %>%</h3>
                            </div>
                            <div class="metric-icon bg-green-light">
                                <i class="bi bi-graph-up-arrow"></i>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
            
            <div class="row g-4">
                <!-- Assigned Subjects Table -->
                <div class="col-md-8">
                    <div class="card custom-table p-4 border-0">
                        <h5 class="fw-bold mb-3">My Assigned Subjects</h5>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>Code</th>
                                        <th>Subject Name</th>
                                        <th>Dept & Year</th>
                                        <th>Section</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (subjects != null && !subjects.isEmpty()) {
                                        for (Subject sub : subjects) { %>
                                            <tr>
                                                <td class="fw-bold"><%= sub.getSubjectCode() %></td>
                                                <td><%= sub.getName() %></td>
                                                <td><%= sub.getDepartment() %> - Yr <%= sub.getYear() %></td>
                                                <td><span class="badge bg-light text-dark border"><%= sub.getSection() != null && !sub.getSection().isEmpty() ? sub.getSection() : "All" %></span></td>
                                                <td>
                                                    <div class="d-flex gap-2">
                                                        <a href="takeAttendance?subjectId=<%= sub.getId() %>&section=<%= sub.getSection() != null ? sub.getSection() : "" %>" class="btn btn-sm btn-primary-custom">
                                                            <i class="bi bi-calendar-plus me-1"></i> Attendance
                                                        </a>
                                                        <a href="teacherAttendanceView?subject_id=<%= sub.getId() %>" class="btn btn-sm btn-outline-secondary">
                                                            <i class="bi bi-clock-history"></i> History
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% }
                                    } else { %>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted py-4">No subjects assigned yet.</td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Actions / Alerts -->
                <div class="col-md-4">
                    <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius); background: white;">
                        <h5 class="fw-bold mb-3">Quick Actions</h5>
                        <div class="d-grid gap-2">
                            <a href="takeAttendance" class="btn btn-primary-custom text-start d-flex align-items-center justify-content-between p-3">
                                <div>
                                    <i class="bi bi-calendar-plus fs-5 me-2"></i>
                                    <span class="fw-bold">Take Daily Attendance</span>
                                </div>
                                <i class="bi bi-chevron-right"></i>
                            </a>
                            <a href="teacherDefaulterList" class="btn btn-danger text-start d-flex align-items-center justify-content-between p-3" style="background-color: #fff1f2; color: #e11d48; border: 1px solid #fecdd3;">
                                <div>
                                    <i class="bi bi-exclamation-triangle fs-5 me-2"></i>
                                    <span class="fw-bold">View Defaulter List</span>
                                </div>
                                <i class="bi bi-chevron-right"></i>
                            </a>
                            <a href="teacherStudentView" class="btn btn-warning text-start d-flex align-items-center justify-content-between p-3" style="background-color: #fef3c7; color: #d97706; border: 1px solid #fde68a;">
                                <div>
                                    <i class="bi bi-mortarboard fs-5 me-2"></i>
                                    <span class="fw-bold">Student Directory</span>
                                </div>
                                <i class="bi bi-chevron-right"></i>
                            </a>
                            <a href="teacherAttendanceView" class="btn btn-info text-start d-flex align-items-center justify-content-between p-3" style="background-color: #ecfeff; color: #0891b2; border: 1px solid #cffafe;">
                                <div>
                                    <i class="bi bi-calendar-check fs-5 me-2"></i>
                                    <span class="fw-bold">Edit Attendance Logs</span>
                                </div>
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
