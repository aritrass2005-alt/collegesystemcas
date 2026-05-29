<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.AttendanceSummary" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("students");
    Student selectedStudent = (Student) request.getAttribute("selectedStudent");
    List<AttendanceSummary> summaries = (List<AttendanceSummary>) request.getAttribute("attendanceSummary");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Directory - Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .progress {
            height: 10px;
            border-radius: 5px;
        }
        .progress-bar-defaulter {
            background-color: #dc3545; /* Red */
        }
        .progress-bar-warning-zone {
            background-color: #ffc107; /* Yellow */
        }
        .progress-bar-good {
            background-color: #198754; /* Green */
        }
        .student-item {
            cursor: pointer;
            transition: all 0.2s;
        }
        .student-item:hover, .student-item.active {
            background-color: rgba(30, 58, 95, 0.05) !important;
            border-left: 4px solid var(--primary) !important;
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
            <h3 class="fw-bold mb-4">Student Directory</h3>

            <% if(request.getAttribute("error") != null) { %>
                <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
            <% } %>

            <div class="row g-4 h-100">
                <!-- Left Column: Student List -->
                <div class="<%= selectedStudent != null ? "col-lg-4" : "col-lg-5" %> d-print-none">
                    <div class="card border-0 shadow-sm" style="border-radius: var(--card-radius); height: calc(100vh - 140px); display: flex; flex-direction: column;">
                        <!-- Search & Filter Header -->
                        <div class="card-header bg-white border-bottom p-4" style="border-radius: var(--card-radius) var(--card-radius) 0 0;">
                            <h5 class="fw-bold mb-3 d-flex align-items-center gap-2">
                                <i class="bi bi-people-fill text-primary"></i> Directory
                            </h5>
                            <div class="d-flex flex-column gap-2">
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-muted"></i></span>
                                    <input type="text" id="searchInput" class="form-control bg-light border-start-0" placeholder="Search name or roll...">
                                </div>
                                <select id="sectionFilter" class="form-select form-select-sm bg-light">
                                    <option value="">-- All Sections --</option>
                                    <option value="A">Section A</option>
                                    <option value="B">Section B</option>
                                    <option value="C">Section C</option>
                                    <option value="K1">Section K1</option>
                                </select>
                            </div>
                        </div>

                        <!-- Scrollable Student List -->
                        <div class="card-body p-0" style="overflow-y: auto; flex: 1;">
                            <div class="list-group list-group-flush" id="studentList">
                                <% if (students != null && !students.isEmpty()) {
                                    for (Student s : students) {
                                        boolean isActive = selectedStudent != null && selectedStudent.getId() == s.getId();
                                %>
                                    <a href="teacherStudentView?studentId=<%= s.getId() %>" 
                                       class="list-group-item list-group-item-action border-bottom py-3 px-4 student-item <%= isActive ? "active" : "" %>"
                                       data-section="<%= s.getSection() %>">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="position-relative">
                                                    <% 
                                                        String stuPhotoUrl = (s.getProfilePhoto() != null && !s.getProfilePhoto().isEmpty() && !"null".equals(s.getProfilePhoto())) 
                                                            ? s.getProfilePhoto() 
                                                            : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(s.getName(), "UTF-8") + "&background=" + (isActive ? "fff" : "1e3a5f") + "&color=" + (isActive ? "1e3a5f" : "fff") + "&bold=true";
                                                    %>
                                                    <img src="<%= stuPhotoUrl %>" 
                                                         style="width: 42px; height: 42px; border-radius: 50%; box-shadow: 0 4px 10px rgba(0,0,0,0.1); object-fit: cover;">
                                                    <span class="position-absolute bottom-0 end-0 p-1 bg-success border border-light rounded-circle" style="width:10px; height:10px;"></span>
                                                </div>
                                                <div>
                                                    <h6 class="mb-0 fw-bold search-name" style="<%= isActive ? "color: var(--primary);" : "" %>"><%= s.getName() %></h6>
                                                    <small class="text-muted search-roll"><i class="bi bi-person-badge me-1"></i><%= s.getRollNo() %></small>
                                                </div>
                                            </div>
                                            <span class="badge <%= isActive ? "bg-primary text-white" : "bg-light text-dark" %> border rounded-pill px-3">
                                                Sec <%= s.getSection() != null && !s.getSection().isEmpty() ? s.getSection() : "All" %>
                                            </span>
                                        </div>
                                    </a>
                                <% }
                                } else { %>
                                    <div class="text-center py-5 px-4 text-muted">
                                        <i class="bi bi-inbox fs-1 text-light mb-3 d-block"></i>
                                        <h6 class="fw-bold">No Students Assigned</h6>
                                        <small>You do not currently have any students assigned to your courses.</small>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Student Details -->
                <% if (selectedStudent != null) { %>
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm" style="border-radius: var(--card-radius); background: white; height: calc(100vh - 140px); display: flex; flex-direction: column;">
                            
                            <!-- Profile Header -->
                            <div class="card-header border-bottom p-5 position-relative text-white" style="background: linear-gradient(135deg, var(--primary), var(--primary-dark)); border-radius: var(--card-radius) var(--card-radius) 0 0; overflow: hidden;">
                                <div class="position-absolute top-0 end-0 p-3 opacity-25">
                                    <i class="bi bi-mortarboard-fill" style="font-size: 8rem;"></i>
                                </div>
                                <div class="d-flex justify-content-between align-items-start position-relative z-index-1">
                                    <div class="d-flex align-items-center gap-4">
                                        <% 
                                            String selPhotoUrl = (selectedStudent.getProfilePhoto() != null && !selectedStudent.getProfilePhoto().isEmpty() && !"null".equals(selectedStudent.getProfilePhoto())) 
                                                ? selectedStudent.getProfilePhoto() 
                                                : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(selectedStudent.getName(), "UTF-8") + "&background=fff&color=1e3a5f&bold=true";
                                        %>
                                        <img src="<%= selPhotoUrl %>" 
                                             style="width: 80px; height: 80px; border-radius: 50%; border: 4px solid rgba(255,255,255,0.3); box-shadow: 0 8px 16px rgba(0,0,0,0.2); object-fit: cover;">
                                        <div>
                                            <h3 class="fw-bold mb-1"><%= selectedStudent.getName() %></h3>
                                            <div class="d-flex gap-2 align-items-center">
                                                <span class="badge bg-white text-primary fw-bold px-3 py-1 rounded-pill"><i class="bi bi-hash me-1"></i><%= selectedStudent.getRollNo() %></span>
                                                <span class="badge bg-dark bg-opacity-25 border border-light rounded-pill px-3 py-1">Year <%= selectedStudent.getYear() %></span>
                                            </div>
                                        </div>
                                    </div>
                                    <a href="teacherStudentView" class="btn btn-sm btn-light rounded-circle shadow-sm d-print-none" style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;" aria-label="Close">
                                        <i class="bi bi-x-lg text-dark"></i>
                                    </a>
                                </div>
                            </div>

                            <!-- Scrollable Content -->
                            <div class="card-body p-4 p-md-5" style="overflow-y: auto; flex: 1;">
                                
                                <h6 class="fw-bold text-uppercase text-muted mb-4" style="letter-spacing: 1px; font-size: 0.8rem;"><i class="bi bi-person-vcard me-2"></i>Contact & Enrollment</h6>
                                <div class="row g-4 mb-5">
                                    <div class="col-sm-6 col-md-3">
                                        <div class="p-3 bg-light rounded-3 h-100 border border-white shadow-sm">
                                            <small class="text-muted d-block mb-1"><i class="bi bi-building me-1"></i>Department</small>
                                            <span class="fw-bold text-dark"><%= selectedStudent.getDepartment() %></span>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-3">
                                        <div class="p-3 bg-light rounded-3 h-100 border border-white shadow-sm">
                                            <small class="text-muted d-block mb-1"><i class="bi bi-diagram-3 me-1"></i>Section</small>
                                            <span class="fw-bold text-dark">Section <%= selectedStudent.getSection() %></span>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-3">
                                        <div class="p-3 bg-light rounded-3 h-100 border border-white shadow-sm text-break">
                                            <small class="text-muted d-block mb-1"><i class="bi bi-envelope-at me-1"></i>Email</small>
                                            <span class="fw-bold text-dark" style="font-size: 0.9rem;"><%= selectedStudent.getEmail() %></span>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 col-md-3">
                                        <div class="p-3 bg-light rounded-3 h-100 border border-white shadow-sm">
                                            <small class="text-muted d-block mb-1"><i class="bi bi-telephone me-1"></i>Phone</small>
                                            <span class="fw-bold text-dark"><%= selectedStudent.getPhone() != null && !selectedStudent.getPhone().isEmpty() ? selectedStudent.getPhone() : "Not Provided" %></span>
                                        </div>
                                    </div>
                                </div>

                                <div class="d-flex justify-content-between align-items-end border-bottom pb-2 mb-4">
                                    <h6 class="fw-bold text-uppercase text-muted mb-0" style="letter-spacing: 1px; font-size: 0.8rem;"><i class="bi bi-graph-up me-2"></i>Attendance Overview</h6>
                                    <button onclick="window.print()" class="btn btn-sm btn-outline-primary rounded-pill px-3 d-print-none fw-bold">
                                        <i class="bi bi-printer me-1"></i> Print
                                    </button>
                                </div>
                                
                                <div class="table-responsive bg-white rounded-3 border shadow-sm">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-light">
                                            <tr>
                                                <th class="ps-4 border-0 text-muted small fw-bold">Subject</th>
                                                <th class="text-center border-0 text-muted small fw-bold">Total</th>
                                                <th class="text-center border-0 text-muted small fw-bold">Attended</th>
                                                <th class="text-center border-0 text-muted small fw-bold" style="width: 35%;">Progress</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (summaries != null && !summaries.isEmpty()) {
                                                for (AttendanceSummary summary : summaries) { 
                                                    double p = summary.getPercentage();
                                                    String barClass = "bg-success";
                                                    if (p < 75.0) barClass = "bg-danger";
                                                    else if (p < 80.0) barClass = "bg-warning";
                                            %>
                                                <tr>
                                                    <td class="ps-4 py-3 border-light">
                                                        <div class="fw-bold text-dark"><%= summary.getSubjectCode() %></div>
                                                        <small class="text-muted d-block text-truncate" style="max-width: 150px;"><%= summary.getSubjectName() %></small>
                                                    </td>
                                                    <td class="text-center fw-semibold text-secondary border-light"><%= summary.getTotalClasses() %></td>
                                                    <td class="text-center fw-bold text-success border-light"><%= summary.getAttendedClasses() %></td>
                                                    <td class="pe-4 border-light">
                                                        <div class="d-flex align-items-center gap-2">
                                                            <div class="progress flex-grow-1" style="height: 8px; background-color: #f0f0f0;">
                                                                <div class="progress-bar <%= barClass %> rounded-pill" role="progressbar" style="width: <%= p %>%;" aria-valuenow="<%= p %>" aria-valuemin="0" aria-valuemax="100"></div>
                                                            </div>
                                                            <span class="fw-bold small <%= p < 75 ? "text-danger" : "text-dark" %>" style="min-width: 45px; text-align: right;"><%= String.format("%.0f", p) %>%</span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% }
                                            } else { %>
                                                <tr>
                                                    <td colspan="4" class="text-center text-muted py-5">
                                                        <i class="bi bi-calendar-x fs-2 d-block mb-2 text-light"></i>
                                                        No attendance history available for this student.
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } else { %>
                    <div class="col-lg-7 d-none d-lg-block">
                        <div class="card border-0 shadow-sm text-center d-flex flex-column align-items-center justify-content-center" 
                             style="border-radius: var(--card-radius); background: linear-gradient(180deg, #ffffff, #f8f9fa); height: calc(100vh - 140px);">
                            <div class="p-4 rounded-circle mb-4" style="background: rgba(123, 44, 191, 0.05); width: 120px; height: 120px; display: flex; align-items: center; justify-content: center;">
                                <img src="https://illustrations.popsy.co/amber/student-going-to-school.svg" alt="Select Student" style="width: 100px; opacity: 0.8;">
                            </div>
                            <h4 class="fw-bold text-dark mb-2">Select a Student</h4>
                            <p class="text-muted" style="max-width: 350px;">Choose a student from the directory on the left to view their detailed attendance records, academic progress, and contact info.</p>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.getElementById("searchInput");
            const sectionFilter = document.getElementById("sectionFilter");
            const studentList = document.getElementById("studentList");
            const studentItems = studentList.querySelectorAll(".student-item");

            function filterStudents() {
                const query = searchInput.value.toLowerCase().trim();
                const selectedSection = sectionFilter.value.toLowerCase();

                studentItems.forEach(item => {
                    const name = item.querySelector(".search-name").innerText.toLowerCase();
                    const roll = item.querySelector(".search-roll").innerText.toLowerCase();
                    const section = item.getAttribute("data-section").toLowerCase();

                    const matchesSearch = name.includes(query) || roll.includes(query);
                    const matchesSection = !selectedSection || section === selectedSection;

                    if (matchesSearch && matchesSection) {
                        item.style.setProperty("display", "block", "important");
                    } else {
                        item.style.setProperty("display", "none", "important");
                    }
                });
            }

            if(searchInput) searchInput.addEventListener("input", filterStudents);
            if(sectionFilter) sectionFilter.addEventListener("change", filterStudents);
        });
    </script>
</body>
</html>
