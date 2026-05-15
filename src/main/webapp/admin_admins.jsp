<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%@ page import="java.util.List" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("user");
    if (currentAdmin == null || !"SuperAdmin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access. SuperAdmin only.");
        return;
    }
    List<Admin> admins = (List<Admin>) request.getAttribute("admins");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Administrators</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/admin_theme.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold m-0">Manage Administrators</h3>
                <button type="button" class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addAdminModal">
                    <i class="bi bi-person-plus"></i> Add New Admin
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

            <div class="card custom-table border-0 shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (admins != null && !admins.isEmpty()) { 
                                for(Admin admin : admins) { %>
                                <tr>
                                    <td><%= admin.getId() %></td>
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <img src="https://ui-avatars.com/api/?name=<%= admin.getName() %>&background=random" class="rounded-circle" width="35" height="35">
                                            <span class="fw-medium"><%= admin.getName() %></span>
                                        </div>
                                    </td>
                                    <td><%= admin.getEmail() %></td>
                                    <td>
                                        <span class="badge <%= "SuperAdmin".equals(admin.getRole()) ? "bg-danger" : "bg-primary" %> rounded-pill">
                                            <%= admin.getRole() %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (!admin.getEmail().equals(currentAdmin.getEmail())) { %>
                                            <a href="manageAdmins?action=delete&id=<%= admin.getId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this admin?');">
                                                <i class="bi bi-trash"></i>
                                            </a>
                                        <% } else { %>
                                            <span class="badge bg-secondary">Current User</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <%  } 
                               } else { %>
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">No administrators found.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Admin Modal -->
    <div class="modal fade" id="addAdminModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content" style="border-radius: var(--card-radius); border: none;">
                <div class="modal-header border-bottom-0 pb-0">
                    <h5 class="modal-title fw-bold">Add Administrator</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="manageAdmins" method="post">
                        <div class="mb-3">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email Address</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" name="password" class="form-control" required minlength="6">
                        </div>
                        <div class="mb-4">
                            <label class="form-label">Role</label>
                            <select name="role" class="form-select" required>
                                <option value="Admin">Admin</option>
                                <option value="SuperAdmin">SuperAdmin</option>
                            </select>
                        </div>
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-light flex-grow-1" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary-custom flex-grow-1">Create Admin</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
