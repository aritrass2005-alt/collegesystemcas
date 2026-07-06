<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String photo = teacher.getProfilePhoto();
    String photoUrl = (photo != null && !photo.isEmpty() && !"null".equals(photo)) ? photo : null;
    String avatarUrl = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(teacher.getName(), "UTF-8") + "&background=667eea&color=fff&bold=true&size=200";
    boolean isCoord = Boolean.TRUE.equals(session.getAttribute("isCoordinator"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Profile - Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .profile-hero {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 24px; padding: 2.5rem; color: white;
            box-shadow: 0 15px 40px rgba(118,75,162,0.25);
        }
        .photo-ring {
            width: 120px; height: 120px; border-radius: 50%;
            object-fit: cover; border: 4px solid rgba(255,255,255,0.5);
            box-shadow: 0 8px 25px rgba(0,0,0,0.3);
        }
        .photo-edit-btn {
            position: absolute; bottom: 4px; right: 4px;
            width: 32px; height: 32px; border-radius: 50%;
            background: #f59e0b; border: 2px solid white;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; font-size: 0.8rem; color: white; transition: transform 0.2s;
        }
        .photo-edit-btn:hover { transform: scale(1.15); }
        .form-control:focus { border-color: #667eea; box-shadow: 0 0 0 3px rgba(102,126,234,0.15); }
        .role-badge { background: rgba(255,255,255,0.2); color:white; border-radius:50px; padding:5px 14px; font-size:0.8rem; font-weight:600; }
    </style>
</head>
<body>
    <jsp:include page="includes/teacher_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/teacher_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4"><i class="bi bi-person-circle text-primary me-2"></i>My Profile</h3>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getParameter("error") %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <div class="row g-4">
                <!-- Profile Hero -->
                <div class="col-lg-4">
                    <div class="profile-hero text-center mb-4">
                        <div class="position-relative d-inline-block mb-3">
                            <img id="previewPhoto" src="<%= photoUrl != null ? photoUrl : avatarUrl %>" alt="Profile" class="photo-ring">
                            <label for="photoInput" class="photo-edit-btn" title="Change photo">
                                <i class="bi bi-camera-fill"></i>
                            </label>
                        </div>
                        <% if (photoUrl != null) { %>
                            <div class="mb-3">
                                <a href="teacherProfile?action=remove_photo" class="btn btn-sm btn-outline-light text-white rounded-pill py-1 px-3 border border-light" style="font-size: 0.75rem; background: rgba(255,255,255,0.15);"><i class="bi bi-trash me-1"></i> Remove Photo</a>
                            </div>
                        <% } %>
                        <h4 class="fw-bold mb-1"><%= teacher.getName() %></h4>
                        <p class="opacity-75 small mb-3"><%= teacher.getEmail() %></p>
                        <div class="d-flex flex-wrap justify-content-center gap-2">
                            <span class="role-badge"><i class="bi bi-person-video3 me-1"></i>Faculty</span>
                            <% if (isCoord) { %><span class="role-badge" style="background:rgba(13,202,240,0.3);"><i class="bi bi-person-badge me-1"></i>Coordinator</span><% } %>
                            <% if (teacher.getDepartment() != null) { %><span class="role-badge"><i class="bi bi-building me-1"></i><%= teacher.getDepartment() %></span><% } %>
                        </div>
                    </div>

                    <div class="card border-0 shadow-sm p-4" style="border-radius:16px;">
                        <h6 class="fw-bold text-muted text-uppercase mb-3" style="font-size:0.72rem;letter-spacing:1px;">Account Info</h6>
                        <div class="mb-2"><small class="text-muted">Email</small><p class="fw-semibold mb-0 small"><%= teacher.getEmail() %></p></div>
                        <div class="mb-2"><small class="text-muted">Status</small><p class="mb-0"><span class="badge bg-success">Approved</span></p></div>
                        <% if (isCoord) { %>
                        <div class="mt-3 pt-3 border-top">
                            <a href="coordinatorDashboard" class="btn btn-info text-white w-100 rounded-pill fw-bold">
                                <i class="bi bi-speedometer2 me-2"></i>Coordinator Dashboard
                            </a>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Edit Form -->
                <div class="col-lg-8">
                    <form action="teacherProfile" method="post" enctype="multipart/form-data" id="profileForm">
                        <input type="file" name="profile_photo" id="photoInput" accept="image/*" style="display:none" onchange="previewImage(this)">

                        <div class="card border-0 shadow-sm p-4 mb-4" style="border-radius:16px;">
                            <h6 class="fw-bold mb-4" style="color:#667eea;"><i class="bi bi-pencil-square me-2"></i>Personal Information</h6>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Full Name</label>
                                    <input type="text" name="name" class="form-control" value="<%= teacher.getName() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Phone Number</label>
                                    <input type="text" name="phone" class="form-control" value="<%= teacher.getPhone() != null ? teacher.getPhone() : "" %>">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Department <span class="text-muted">(read-only)</span></label>
                                    <input type="text" class="form-control bg-light" value="<%= teacher.getDepartment() != null ? teacher.getDepartment() : "" %>" readonly>
                                </div>
                            </div>
                        </div>

                        <div class="card border-0 shadow-sm p-4 mb-4" style="border-radius:16px;">
                            <h6 class="fw-bold mb-4" style="color:#667eea;"><i class="bi bi-lock me-2"></i>Change Password</h6>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">New Password</label>
                                    <input type="password" name="new_password" class="form-control" placeholder="Leave blank to keep current">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Confirm Password</label>
                                    <input type="password" id="confirmPass" class="form-control" placeholder="Confirm new password">
                                </div>
                            </div>
                        </div>

                        <div class="d-flex gap-3">
                            <button type="submit" class="btn btn-primary-custom fw-bold px-5 py-2 rounded-pill">
                                <i class="bi bi-check2-circle me-2"></i>Save Changes
                            </button>
                            <a href="teacher_dashboard.jsp" class="btn btn-light fw-bold px-4 py-2 rounded-pill">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function previewImage(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = e => document.getElementById('previewPhoto').src = e.target.result;
            reader.readAsDataURL(input.files[0]);
        }
    }
    document.getElementById('profileForm').addEventListener('submit', function(e) {
        const np = document.querySelector('[name="new_password"]').value;
        const cp = document.getElementById('confirmPass').value;
        if (np && np !== cp) { e.preventDefault(); alert('Passwords do not match!'); }
    });
</script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        setTimeout(function() {
            var alerts = document.querySelectorAll(".alert, .alert-custom");
            alerts.forEach(function(alert) {
                alert.style.transition = "opacity 0.5s ease";
                alert.style.opacity = "0";
                setTimeout(function() { alert.remove(); }, 500);
            });
        }, 3000);
    });
</script>
</body>
</html>

