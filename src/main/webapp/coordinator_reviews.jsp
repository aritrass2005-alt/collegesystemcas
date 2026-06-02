<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.AttendanceReview" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Teacher currentTeacher = (Teacher) session.getAttribute("user");
    Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
    if (currentTeacher == null || !"Teacher".equals(session.getAttribute("role")) || isCoordinator == null || !isCoordinator) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<AttendanceReview> reviews = (List<AttendanceReview>) request.getAttribute("reviews");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Reviews – CAS Coordinator</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/theme.css">
</head>
<body class="dashboard-body">
    <!-- Sidebar -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        <!-- Top Header -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="container-fluid p-4 p-md-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">Student Attendance Reviews</h2>
            </div>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="card shadow-sm border-0">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Student</th>
                                    <th>Subject</th>
                                    <th>Date in Question</th>
                                    <th>Status</th>
                                    <th>Requested On</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (reviews != null && !reviews.isEmpty()) {
                                    for (AttendanceReview review : reviews) { %>
                                    <tr>
                                        <td>
                                            <div class="fw-bold"><%= review.getStudentName() %></div>
                                            <div class="small text-muted"><%= review.getStudentRollNo() %></div>
                                        </td>
                                        <td><%= review.getSubjectName() != null ? review.getSubjectName() : "All Subjects / Full Day" %></td>
                                        <td><%= sdf.format(review.getReviewDate()) %></td>
                                        <td>
                                            <% if("Pending".equals(review.getStatus())) { %>
                                                <span class="badge bg-warning text-dark"><i class="bi bi-hourglass-split me-1"></i>Pending</span>
                                            <% } else if("In Review".equals(review.getStatus())) { %>
                                                <span class="badge bg-info"><i class="bi bi-search me-1"></i>In Review</span>
                                            <% } else if("Approved".equals(review.getStatus())) { %>
                                                <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Approved</span>
                                            <% } else { %>
                                                <span class="badge bg-danger"><i class="bi bi-x-circle me-1"></i>Rejected</span>
                                            <% } %>
                                        </td>
                                        <td><%= sdf.format(review.getCreatedAt()) %></td>
                                        <td>
                                            <a href="reviewChat?id=<%= review.getId() %>" class="btn btn-sm btn-outline-primary">
                                                <i class="bi bi-chat-dots me-1"></i>Review Request
                                            </a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr>
                                        <td colspan="6" class="text-center py-4 text-muted">No review requests found for your assigned class.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
