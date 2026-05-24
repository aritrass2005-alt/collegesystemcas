<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?error=Unauthorized Access");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("students");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Section Students - Coordinator</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- Main Content -->
    <div id="main-content" style="margin-left:260px; min-height:100vh; background:#f0f2f8;">
        
        <!-- Header Include -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Coordinator Section Students</h3>
            </div>

            <!-- Table of Students -->
            <div class="card border-0 shadow-sm custom-table">
                <div class="card-header bg-white border-0 pt-4 pb-0">
                    <h5 class="fw-bold mb-0">Students in your assigned sections</h5>
                </div>
                <div class="card-body mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="studentTable">
                            <thead>
                                <tr>
                                    <th>Roll No</th>
                                    <th>Student Name</th>
                                    <th>Email</th>
                                    <th>Department</th>
                                    <th>Year</th>
                                    <th>Section</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (students != null && !students.isEmpty()) {
                                    for (Student s : students) { 
                                %>
                                    <tr>
                                        <td class="fw-bold"><%= s.getRollNo() %></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="https://ui-avatars.com/api/?name=<%= s.getName() %>&background=random" 
                                                     style="width: 32px; height: 32px; border-radius: 50%;">
                                                <span class="fw-semibold"><%= s.getName() %></span>
                                            </div>
                                        </td>
                                        <td><%= s.getEmail() %></td>
                                        <td><%= s.getDepartment() %></td>
                                        <td><%= s.getYear() %></td>
                                        <td><span class="badge bg-light text-dark border"><%= s.getSection() != null && !s.getSection().isEmpty() ? s.getSection() : "All" %></span></td>
                                    </tr>
                                <% }
                                } else { %>
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">No students found in your assigned sections.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
