<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Subject" %>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    Subject selectedSubject = (Subject) request.getAttribute("selectedSubject");
    String selectedSection = (String) request.getAttribute("selectedSection");
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<String> availableSections = (List<String>) request.getAttribute("availableSections");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Take Attendance - Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .radio-btn-group input[type="radio"] {
            display: none;
        }
        .radio-btn-group label {
            cursor: pointer;
            padding: 6px 16px;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            user-select: none;
            font-weight: 600;
            transition: all 0.2s;
        }
        .radio-btn-group input[type="radio"]:checked + label.present-label {
            background-color: #198754 !important;
            color: white !important;
            border-color: #198754 !important;
            box-shadow: 0 4px 12px rgba(25, 135, 84, 0.25);
        }
        .radio-btn-group input[type="radio"]:checked + label.absent-label {
            background-color: #dc3545 !important;
            color: white !important;
            border-color: #dc3545 !important;
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.25);
        }
        .radio-btn-group label:hover {
            background-color: #f8f9fa;
        }
        .radio-btn-group input[type="radio"]:checked + label:hover {
            opacity: 0.95;
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
            <h3 class="fw-bold mb-4">Take Daily Attendance</h3>
            
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show mb-4">
                    <i class="bi bi-exclamation-octagon-fill me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show mb-4">
                    <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <!-- Subject and Section Selection Card -->
            <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius);">
                <h5 class="fw-bold mb-3">Class & Subject Selection</h5>
                <form action="takeAttendance" method="get" class="row g-3 align-items-end">
                    <div class="col-md-5">
                        <label class="form-label text-muted small fw-bold">Select Assigned Subject</label>
                        <select name="subjectId" class="form-select" required>
                            <option value="">-- Choose Subject --</option>
                            <% if(subjects != null) { 
                                for(Subject sub : subjects) { 
                                    boolean isSelected = selectedSubject != null && selectedSubject.getId() == sub.getId();
                            %>
                                <option value="<%= sub.getId() %>" <%= isSelected ? "selected" : "" %>>
                                    <%= sub.getSubjectCode() %> - <%= sub.getName() %> (Year <%= sub.getYear() %>, <%= sub.getDepartment() %>)
                                </option>
                            <%  } 
                               } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label text-muted small fw-bold">Section</label>
                        <select name="section" class="form-select" required>
                            <option value="">-- Choose Section --</option>
                            <% if(availableSections != null) { 
                                for(String sec : availableSections) { %>
                                    <option value="<%= sec %>" <%= sec.equals(selectedSection) ? "selected" : "" %>><%= sec %></option>
                            <%  }
                               } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary-custom w-100 py-2">
                            <i class="bi bi-people me-2"></i>Load Students
                        </button>
                    </div>
                </form>
            </div>

            <!-- Student List Form -->
            <% if(selectedSubject != null && selectedSection != null) { %>
                <div class="card border-0 shadow-sm custom-table">
                    <div class="card-header bg-white border-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                        <div>
                            <h5 class="fw-bold mb-1">Students Enrolled: <span class="text-primary"><%= students != null ? students.size() : 0 %></span></h5>
                            <small class="text-muted"><%= selectedSubject.getName() %> (<%= selectedSubject.getSubjectCode() %>) - Section <%= selectedSection %></small>
                        </div>
                        <div class="datetime-widget py-1 px-3" style="font-size: 0.9rem;">
                            <i class="bi bi-calendar-event me-1"></i> <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %>
                        </div>
                    </div>
                    
                    <div class="card-body mt-3">
                        <form action="takeAttendance" method="post">
                            <input type="hidden" name="subjectId" value="<%= selectedSubject.getId() %>">
                            
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width: 20%">Roll No</th>
                                            <th>Student Name</th>
                                            <th class="text-center" style="width: 40%">Attendance Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if(students != null && !students.isEmpty()) { 
                                            for(Student s : students) { %>
                                        <tr>
                                            <td class="fw-bold text-dark"><%= s.getRollNo() %></td>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="https://ui-avatars.com/api/?name=<%= s.getName() %>&background=e0b1cb&color=7b2cbf&bold=true" 
                                                         style="width: 32px; height: 32px; border-radius: 50%;">
                                                    <span class="fw-semibold"><%= s.getName() %></span>
                                                </div>
                                            </td>
                                            <td class="text-center">
                                                <input type="hidden" name="studentIds" value="<%= s.getId() %>">
                                                <div class="radio-btn-group d-inline-flex gap-2">
                                                    <!-- Default is Present -->
                                                    <input type="radio" id="p_<%= s.getId() %>" name="status_<%= s.getId() %>" value="Present" checked <%= request.getAttribute("alreadySubmitted") != null ? "disabled" : "" %>>
                                                    <label for="p_<%= s.getId() %>" class="present-label text-success present-btn">Present</label>
                                                    
                                                    <input type="radio" id="a_<%= s.getId() %>" name="status_<%= s.getId() %>" value="Absent" <%= request.getAttribute("alreadySubmitted") != null ? "disabled" : "" %>>
                                                    <label for="a_<%= s.getId() %>" class="absent-label text-danger absent-btn">Absent</label>
                                                </div>
                                            </td>
                                        </tr>
                                        <%  } 
                                           } else { %>
                                        <tr>
                                            <td colspan="3" class="text-center text-muted py-4">No active students found for this class.</td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>

                            <% if(students != null && !students.isEmpty()) { 
                                   if (request.getAttribute("alreadySubmitted") == null) { %>
                                <div class="text-end mt-4">
                                    <button type="submit" class="btn btn-primary-custom fw-bold px-5 py-2">
                                        <i class="bi bi-cloud-upload me-2"></i>Submit Attendance
                                    </button>
                                </div>
                            <%     } else { %>
                                <div class="alert alert-info mt-4">
                                    <i class="bi bi-info-circle me-2"></i> Attendance has been locked. Only an administrator can modify it now.
                                </div>
                            <%     }
                               } %>
                        </form>
                    </div>
                </div>
            <% } %>
            
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
