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
    <title>Verify OTP &ndash; CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        body { background: #f8f9fa; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .setup-card { background: white; border-radius: var(--radius-xl); padding: 2.5rem; box-shadow: 0 10px 30px rgba(0,0,0,0.08); width: 100%; max-width: 450px; text-align: center; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(30,58,95,0.07); }
        .otp-input { letter-spacing: 0.5rem; font-size: 1.5rem; text-align: center; font-weight: bold; }
    </style>
</head>
<body>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-md-6 col-lg-5">
            <div class="setup-card mx-auto">
                <div class="mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle bg-primary bg-opacity-10 text-primary mb-3" style="width: 70px; height: 70px;">
                        <i class="bi bi-shield-lock fs-1"></i>
                    </div>
                    <h4 class="fw-bold">Verify Guardian Phone</h4>
                    <p class="text-muted small">Please enter the 6-digit OTP sent to the guardian's phone number.</p>
                </div>

                <% if(session.getAttribute("setup_msg") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 rounded-3 small text-start">
                        <i class="bi bi-check-circle-fill me-2"></i><%= session.getAttribute("setup_msg") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <% if(request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 rounded-3 small text-start">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="studentOtp" method="post">
                    <div class="mb-4 text-start">
                        <label class="form-label small fw-bold text-muted">Enter OTP</label>
                        <input type="text" name="otp" class="form-control otp-input" maxlength="6" required autocomplete="off">
                    </div>

                    <button type="submit" class="btn-cas-primary w-100 py-2 mb-3">
                        Verify &amp; Continue <i class="bi bi-check2-circle ms-1"></i>
                    </button>
                    
                    <a href="studentSetup" class="text-decoration-none small">Go back and edit details</a>
                </form>
                
                <!-- Display OTP on screen for testing purposes -->
                <div class="mt-4 p-2 bg-light rounded text-start" style="font-size:0.75rem; border:1px dashed #ccc;">
                    <strong>[MOCK SMS API]</strong> For testing, your OTP is: <span class="text-danger fw-bold"><%= session.getAttribute("pending_otp") %></span>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
