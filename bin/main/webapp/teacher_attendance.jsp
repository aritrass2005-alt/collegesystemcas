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
    <title>Take Attendance - Teacher</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .radio-btn-group input[type="radio"] {
            display: none;
        }
        .radio-btn-group label {
            cursor: pointer;
            padding: 5px 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
            user-select: none;
        }
        .radio-btn-group input[type="radio"]:checked + label.present-label {
            background-color: #198754;
            color: white;
            border-color: #198754;
        }
        .radio-btn-group input[type="radio"]:checked + label.absent-label {
            background-color: #dc3545;
            color: white;
            border-color: #dc3545;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="teacher_dashboard.jsp">Teacher Dashboard</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-light">Welcome, <%= teacher.getName() %></span>
                <a href="logout" class="btn btn-outline-danger btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h3>Take Daily Attendance</h3>
        <hr>
        
        <% if(request.getParameter("error") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>
        <% if(request.getParameter("msg") != null) { %>
            <div class="alert alert-success"><%= request.getParameter("msg") %></div>
        <% } %>

        <!-- Subject and Section Selection Form -->
        <div class="card mb-4 shadow-sm">
            <div class="card-body bg-light">
                <form action="takeAttendance" method="get" class="row g-3 align-items-center">
                    <div class="col-auto">
                        <label class="fw-bold">Select Class / Subject:</label>
                    </div>
                    <div class="col-auto">
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
                    <div class="col-auto">
                        <label class="fw-bold">Section:</label>
                    </div>
                    <div class="col-auto">
                        <select name="section" class="form-select" required>
                            <option value="">-- Choose Section --</option>
                            <% if(availableSections != null) { 
                                for(String sec : availableSections) { %>
                                    <option value="<%= sec %>" <%= sec.equals(selectedSection) ? "selected" : "" %>><%= sec %></option>
                            <%  }
                               } %>
                        </select>
                    </div>
                    <div class="col-auto">
                        <button type="submit" class="btn btn-primary">Load Students</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Student List Form -->
        <% if(selectedSubject != null && selectedSection != null) { %>
            <form action="takeAttendance" method="post">
                <input type="hidden" name="subjectId" value="<%= selectedSubject.getId() %>">
                
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5>Students Enrolled: <%= students != null ? students.size() : 0 %></h5>
                    <div class="text-muted"><strong>Date:</strong> <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %></div>
                </div>

                <div class="table-responsive shadow-sm">
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th>Roll No</th>
                                <th>Student Name</th>
                                <th class="text-center">Attendance Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(students != null && !students.isEmpty()) { 
                                for(Student s : students) { %>
                            <tr>
                                <td><%= s.getRollNo() %></td>
                                <td><%= s.getName() %></td>
                                <td class="text-center">
                                    <input type="hidden" name="studentIds" value="<%= s.getId() %>">
                                    <div class="radio-btn-group">
                                        <!-- Default is Present -->
                                        <input type="radio" id="p_<%= s.getId() %>" name="status_<%= s.getId() %>" value="Present" checked>
                                        <label for="p_<%= s.getId() %>" class="present-label fw-bold me-2">Present</label>
                                        
                                        <input type="radio" id="a_<%= s.getId() %>" name="status_<%= s.getId() %>" value="Absent">
                                        <label for="a_<%= s.getId() %>" class="absent-label fw-bold">Absent</label>
                                    </div>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            <tr><td colspan="3" class="text-center">No active students found for this class.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <% if(students != null && !students.isEmpty()) { %>
                <div class="text-end mt-3 mb-5">
                    <button type="submit" class="btn btn-primary btn-lg fw-bold px-5">Submit Attendance</button>
                </div>
                <% } %>
            </form>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
