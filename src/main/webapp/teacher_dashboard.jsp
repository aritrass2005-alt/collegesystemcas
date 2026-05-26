<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Subject" %>
<%@ page import="com.college.attendance.dao.SubjectDAO" %>
<%@ page import="com.college.attendance.dao.AttendanceDAO" %>

<%@ page import="java.util.List" %>
<%@ page import="com.college.attendance.model.FacultyAttendance" %>
<%@ page import="com.college.attendance.dao.FacultyAttendanceDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
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

    FacultyAttendanceDAO fDao = new FacultyAttendanceDAO();
    FacultyAttendance myTodayAttendance = fDao.getTodayAttendance(teacher.getId());
    boolean isCheckedIn = (myTodayAttendance != null && myTodayAttendance.getCheckInTime() != null);
    boolean isCheckedOut = (myTodayAttendance != null && myTodayAttendance.getCheckOutTime() != null);
    SimpleDateFormat timeFmt = new SimpleDateFormat("hh:mm a");

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
            <% if (request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show mx-4 mt-4">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center px-4 pt-4 mb-4">
                <h3 class="fw-bold m-0">Faculty Dashboard</h3>
                
                <div class="d-flex gap-3 align-items-center mt-3 mt-md-0 p-3 rounded" style="background: white; border: 1px solid var(--border); box-shadow: var(--shadow-sm);">
                    <div class="me-3">
                        <small class="text-muted d-block fw-bold mb-1">Today's Status</small>
                        <% if (isCheckedOut) { %>
                            <span class="badge bg-secondary px-3 py-2 fs-6"><i class="bi bi-calendar-check me-1"></i> Shift Complete</span>
                        <% } else if (isCheckedIn) { %>
                            <span class="badge bg-success px-3 py-2 fs-6"><i class="bi bi-check-circle me-1"></i> Checked In</span>
                            <small class="text-muted ms-2 d-block mt-1">In at: <%= timeFmt.format(myTodayAttendance.getCheckInTime()) %></small>
                        <% } else { %>
                            <span class="badge bg-warning text-dark px-3 py-2 fs-6"><i class="bi bi-clock me-1"></i> Pending Check-In</span>
                        <% } %>
                    </div>
                    
                    <div>
                        <% if (!isCheckedIn) { %>
                            <a href="facultyAttendance?action=checkin" class="btn btn-primary-custom shadow-sm"><i class="bi bi-box-arrow-in-right me-1"></i> Check In</a>
                        <% } else if (!isCheckedOut) { %>
                            <a href="facultyAttendance?action=checkout" class="btn btn-danger shadow-sm"><i class="bi bi-box-arrow-right me-1"></i> Check Out</a>
                        <% } else { %>
                            <button class="btn btn-secondary shadow-sm" disabled>Done for Today</button>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <div class="row g-4 mb-4 px-4">
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
            
            <div class="row g-4 px-4">
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
