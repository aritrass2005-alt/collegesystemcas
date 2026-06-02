<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.AttendanceReview" %>
<%@ page import="com.college.attendance.model.Subject" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Student currentStudent = (Student) session.getAttribute("user");
    if (currentStudent == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<AttendanceReview> reviews = (List<AttendanceReview>) request.getAttribute("reviews");
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Reviews – CAS</title>
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
    <jsp:include page="includes/student_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        <!-- Top Header -->
        <jsp:include page="includes/student_header.jsp" />

        <div class="container-fluid p-4 p-md-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">Attendance Reviews</h2>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#requestReviewModal">
                    <i class="bi bi-plus-circle me-2"></i>Request Review
                </button>
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
                                        <td><%= review.getSubjectName() != null ? review.getSubjectName() : "All Subjects / Full Day" %></td>
                                        <td><%= sdf.format(review.getReviewDate()) %></td>
                                        <td>
                                            <% if("Pending".equals(review.getStatus())) { %>
                                                <span class="badge bg-warning text-dark"><i class="bi bi-hourglass-split me-1"></i>Pending</span>
                                            <% } else if("In Review".equals(review.getStatus())) { %>
                                                <span class="badge bg-info"><i class="bi bi-search me-1"></i>In Review</span>
                                            <% } else if("Approved".equals(review.getStatus())) { %>
                                                <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Approved</span>
                                            <% } else if("Done".equals(review.getStatus())) { %>
                                                <span class="badge bg-secondary"><i class="bi bi-check2-all me-1"></i>Done</span>
                                            <% } else { %>
                                                <span class="badge bg-danger"><i class="bi bi-x-circle me-1"></i>Rejected</span>
                                            <% } %>
                                        </td>
                                        <td><%= sdf.format(review.getCreatedAt()) %></td>
                                        <td>
                                            <div class="d-flex gap-2">
                                                <a href="reviewChat?id=<%= review.getId() %>" class="btn btn-sm btn-outline-primary">
                                                    <i class="bi bi-chat-dots me-1"></i>View Chat
                                                </a>
                                                <% if ("Pending".equals(review.getStatus()) || "In Review".equals(review.getStatus())) { %>
                                                <form action="studentReviews" method="post" class="m-0" onsubmit="return confirm('Are you sure you want to delete this review request?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="reviewId" value="<%= review.getId() %>">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete Review"><i class="bi bi-trash"></i></button>
                                                </form>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr>
                                        <td colspan="5" class="text-center py-4 text-muted">You have no review requests.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Request Review Modal -->
    <div class="modal fade" id="requestReviewModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Request Attendance Review</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" data-bs-dismiss="modal"></button>
                </div>
                <form action="studentReviews" method="post">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Subject</label>
                            <select name="subjectId" class="form-select">
                                <option value="">-- All Subjects / Full Day --</option>
                                <% if(subjects != null) { for(Subject s : subjects) { %>
                                    <option value="<%= s.getId() %>"><%= s.getName() %> (<%= s.getSubjectCode() %>)</option>
                                <% } } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Date (Only absent dates allowed)</label>
                            <select name="reviewDate" class="form-select" required>
                                <option value="">-- Select Date --</option>
                                <% 
                                   List<String> absentDates = (List<String>) request.getAttribute("absentDates");
                                   if (absentDates != null && !absentDates.isEmpty()) {
                                       for(String d : absentDates) { 
                                %>
                                    <option value="<%= d %>"><%= d %></option>
                                <%     } 
                                   } else { 
                                %>
                                    <option value="" disabled>No absent dates available</option>
                                <% } %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Reason</label>
                            <textarea name="reason" class="form-control" rows="3" required placeholder="Explain why you are requesting a review..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Submit Request</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
