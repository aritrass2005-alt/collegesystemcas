<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%
    Student student = (Student) session.getAttribute("user");
    if (student == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp"); return;
    }
    String photo = student.getProfilePhoto();
    String photoUrl = (photo != null && !photo.isEmpty() && !"null".equals(photo)) ? photo : null;
    String avatarUrl = "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(student.getName(), "UTF-8") + "&background=0dcaf0&color=fff&bold=true&size=200";
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Profile &ndash; CAS Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        body { overflow-x: hidden; }
        .wrapper { display: flex; width: 100%; align-items: stretch; }
        #content-wrapper { width: 100%; min-height: 100vh; }
        .profile-card {
            background: linear-gradient(160deg, #1e3a5f 0%, #0f2240 60%, #071629 100%);
            border-radius: 20px; padding: 2rem; color: white;
            box-shadow: 0 12px 32px rgba(15,34,64,0.25);
            position: relative; overflow: hidden;
        }
        .profile-card::before {
            content: ''; position: absolute;
            width: 220px; height: 220px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%; top: -60px; right: -60px;
        }
        .photo-wrapper { position: relative; width: 120px; height: 120px; margin: 0 auto; }
        .photo-wrapper img {
            width: 120px; height: 120px; border-radius: 50%;
            object-fit: cover; border: 3px solid rgba(255,255,255,0.35);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        }
        .photo-edit-btn {
            position: absolute; bottom: 4px; right: 4px;
            width: 32px; height: 32px; border-radius: 50%;
            background: var(--accent); border: 2px solid white;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; font-size: 0.8rem; color: white;
            transition: transform 0.2s;
        }
        .photo-edit-btn:hover { transform: scale(1.15); }
        .form-section { background: white; border-radius: var(--radius-xl); padding: 1.75rem; border: 1px solid var(--border); box-shadow: var(--shadow-card); }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(30,58,95,0.07); }
        .badge-info-custom {
            background: rgba(255,255,255,0.15); color: white; border-radius: 50px;
            padding: 5px 14px; font-size: 0.80rem; font-weight: 600;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .section-label { color: var(--primary); font-size: 0.85rem; font-weight: 700; margin-bottom: 1rem; }
    </style>
</head>
<body>
<div class="wrapper">
    <jsp:include page="includes/student_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/student_header.jsp" />
        <div class="container-fluid p-4 p-md-5">
            <h3 class="fw-bold mb-4"><i class="bi bi-person-circle text-info me-2"></i>My Profile</h3>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 rounded-3">
                    <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 rounded-3">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <!-- Profile Card -->
                <div class="col-lg-4">
                    <div class="profile-card text-center mb-4">
                        <div class="photo-wrapper mb-3">
                            <img id="previewPhoto" src="<%= photoUrl != null ? photoUrl : avatarUrl %>" alt="Profile Photo">
                            <label for="photoInput" class="photo-edit-btn" title="Change photo">
                                <i class="bi bi-camera-fill"></i>
                            </label>
                        </div>
                        <h4 class="fw-bold mb-1"><%= student.getName() %></h4>
                        <p class="mb-3 opacity-75 small"><%= student.getEmail() %></p>
                        <div class="d-flex flex-wrap justify-content-center gap-2">
                            <span class="badge-info-custom"><i class="bi bi-building me-1"></i><%= student.getDepartment() %></span>
                            <span class="badge-info-custom"><i class="bi bi-calendar me-1"></i>Year <%= student.getYear() %></span>
                            <span class="badge-info-custom"><i class="bi bi-people me-1"></i>Section <%= student.getSection() %></span>
                        </div>
                    </div>

                    <!-- Read-only Info Card -->
                    <div class="form-section">
                        <h6 class="fw-bold text-muted text-uppercase mb-3" style="font-size:0.72rem; letter-spacing:1px;">Academic Info</h6>
                        <div class="mb-3">
                            <small class="text-muted">Roll Number</small>
                            <p class="fw-bold mb-0"><%= student.getRollNo() %></p>
                        </div>
                        <div class="mb-3">
                            <small class="text-muted">Department</small>
                            <p class="fw-bold mb-0"><%= student.getDepartment() %></p>
                        </div>
                        <div class="mb-3">
                            <small class="text-muted">Year & Section</small>
                            <p class="fw-bold mb-0">Year <%= student.getYear() %>, Section <%= student.getSection() %></p>
                        </div>
                    </div>
                </div>

                <!-- Edit Form -->
                <div class="col-lg-8">
                    <form action="studentProfile" method="post" enctype="multipart/form-data" id="profileForm">
                        <input type="file" name="profile_photo" id="photoInput" accept="image/*" style="display:none" onchange="previewImage(this)">

                        <div class="form-section mb-4">
                            <div class="section-label"><i class="bi bi-pencil-square me-2"></i>Personal Information</div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Full Name</label>
                                    <input type="text" name="name" class="form-control" value="<%= student.getName() %>" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Phone Number</label>
                                    <input type="text" name="phone" class="form-control" value="<%= student.getPhone() != null ? student.getPhone() : "" %>">
                                </div>
                                <div class="col-12">
                                    <label class="form-label small fw-bold text-muted">Address</label>
                                    <textarea name="address" class="form-control" rows="3" placeholder="Enter your address"><%= student.getAddress() != null ? student.getAddress() : "" %></textarea>
                                </div>
                            </div>
                        </div>

                        <div class="form-section mb-4">
                            <div class="section-label"><i class="bi bi-lock me-2"></i>Change Password</div>
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
                            <button type="submit" class="btn-cas-primary px-5 py-2">
                                <i class="bi bi-check2-circle me-2"></i>Save Changes
                            </button>
                            <a href="studentDashboard" class="btn-cas-outline px-4 py-2">Cancel</a>
                        </div>
                    </form>
                </div>
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
        if (np && np !== cp) {
            e.preventDefault();
            alert('Passwords do not match!');
        }
    });
</script>
</body>
</html>
