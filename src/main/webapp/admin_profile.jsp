<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%
    Admin admin = (Admin) session.getAttribute("user");
    if (admin == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/admin_theme.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">My Profile</h3>

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

            <div class="row">
                <div class="col-md-6 mb-4">
                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                        <h5 class="fw-bold mb-4">Update Details</h5>
                        <form action="adminProfile" method="post">
                            <input type="hidden" name="action" value="updateProfile">
                            <div class="mb-3">
                                <label class="form-label">Name</label>
                                <input type="text" name="name" class="form-control" value="<%= admin.getName() %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-control" value="<%= admin.getEmail() %>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label text-muted">Role</label>
                                <input type="text" class="form-control" value="<%= admin.getRole() %>" disabled>
                            </div>
                            <button type="submit" class="btn btn-primary-custom w-100">Save Changes</button>
                        </form>
                    </div>
                </div>

                <div class="col-md-6 mb-4">
                    <div class="card p-4 border-0 shadow-sm" style="border-radius: var(--card-radius);">
                        <h5 class="fw-bold mb-4">Change Password</h5>
                        <form action="adminProfile" method="post">
                            <input type="hidden" name="action" value="updatePassword">
                            <div class="mb-3">
                                <label class="form-label">New Password</label>
                                <input type="password" name="newPassword" class="form-control" required minlength="6">
                            </div>
                            <button type="submit" class="btn btn-danger w-100" style="border-radius: 8px;">Update Password</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
