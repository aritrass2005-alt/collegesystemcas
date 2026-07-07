<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp"); return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Profile Setup &ndash; CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        body { background: #f8f9fa; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .setup-card { background: white; border-radius: var(--radius-xl); padding: 2.5rem; box-shadow: 0 10px 30px rgba(0,0,0,0.08); width: 100%; max-width: 600px; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(30,58,95,0.07); }
        .section-label { color: var(--primary); font-size: 0.9rem; font-weight: 700; margin-bottom: 1rem; border-bottom: 2px solid var(--border); padding-bottom: 0.5rem; }
    </style>
</head>
<body>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-8 col-lg-7">
            <div class="setup-card mx-auto">
                <div class="text-center mb-4">
                    <h3 class="fw-bold"><i class="bi bi-person-lines-fill text-primary me-2"></i>Complete Your Profile</h3>
                    <p class="text-muted small">Please provide the missing details to continue.</p>
                </div>

                <% if(request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 rounded-3">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="studentSetup" method="post">
                    <div class="mb-4">
                        <div class="section-label">Your Details</div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-muted">Phone Number</label>
                                <input type="text" name="phone" class="form-control" value="<%= student.getPhone() != null ? student.getPhone() : "" %>" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold text-muted">Address</label>
                                <textarea name="address" class="form-control" rows="2" required><%= student.getAddress() != null ? student.getAddress() : "" %></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="section-label">Guardian / Parent Details</div>
                        <p class="small text-muted mb-3">An OTP will be sent to the parent's phone number for verification.</p>
                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label small fw-bold text-muted">Guardian Name</label>
                                <input type="text" name="parent_name" class="form-control" value="<%= student.getParentName() != null ? student.getParentName() : "" %>" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-muted">Guardian Phone</label>
                                <input type="text" name="parent_phone" class="form-control" value="<%= student.getParentPhone() != null ? student.getParentPhone() : "" %>" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-muted">Guardian Email (Optional)</label>
                                <input type="email" name="parent_email" class="form-control" value="<%= student.getParentEmail() != null ? student.getParentEmail() : "" %>">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="btn-cas-primary w-100 py-2">
                        Send OTP for Verification <i class="bi bi-arrow-right ms-2"></i>
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
