<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.ConfigData" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<ConfigData> departments = (List<ConfigData>) request.getAttribute("departments");
    List<ConfigData> sections = (List<ConfigData>) request.getAttribute("sections");
    List<ConfigData> years = (List<ConfigData>) request.getAttribute("years");
    Boolean maintenanceMode = (Boolean) request.getAttribute("maintenanceMode");
    if (maintenanceMode == null) maintenanceMode = false;
    String role = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Configuration - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Manage Configuration</h3>

            <% if ("SuperAdmin".equals(role)) { %>
            <!-- Maintenance Mode Card -->
            <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); color: #f8fafc; border-radius: 12px; overflow: hidden;">
                <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="bg-danger bg-opacity-25 text-danger rounded-circle d-flex align-items-center justify-content-center" style="width: 54px; height: 54px; font-size: 1.5rem; box-shadow: 0 0 15px rgba(220, 38, 38, 0.2);">
                            <i class="bi bi-shield-slash"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-1 d-flex align-items-center gap-3">
                                Global Maintenance Mode
                                <% if (maintenanceMode) { %>
                                    <span class="badge bg-danger text-white px-2.5 py-1 fs-6 fw-semibold rounded-pill animate-pulse">Active</span>
                                <% } else { %>
                                    <span class="badge bg-success text-white px-2.5 py-1 fs-6 fw-semibold rounded-pill">Inactive</span>
                                <% } %>
                            </h5>
                            <p class="mb-0 text-secondary" style="font-size: 0.875rem; max-width: 600px;">
                                When active, all Students, Teachers, and normal Admins will be blocked and redirected to the maintenance page. Super Admins bypass this block to manage the platform.
                            </p>
                        </div>
                    </div>
                    <div>
                        <form action="manageConfig" method="post" id="maintenanceForm">
                            <input type="hidden" name="action" value="toggleMaintenance">
                            <input type="hidden" name="enable" value="<%= !maintenanceMode %>">
                            <button type="submit" class="btn <%= maintenanceMode ? "btn-outline-success" : "btn-danger" %> px-4 py-2.5 fw-bold d-flex align-items-center gap-2" style="border-radius: 8px; transition: all 0.3s ease;">
                                <% if (maintenanceMode) { %>
                                    <i class="bi bi-play-fill"></i> Disable Maintenance Mode
                                <% } else { %>
                                    <i class="bi bi-pause-fill"></i> Enable Maintenance Mode
                                <% } %>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <!-- Departments -->
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm custom-table">
                        <div class="card-header bg-white border-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0 text-primary">Departments</h5>
                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#addDeptModal">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </div>
                        <div class="card-body p-0 mt-3">
                            <table class="table table-hover mb-0">
                                <tbody>
                                    <% if (departments != null) { for(ConfigData c : departments) { %>
                                    <tr>
                                        <td class="ps-4"><%= c.getName() %></td>
                                        <td class="text-end pe-4">
                                            <a href="manageConfig?action=delete&type=department&id=<%= c.getId() %>" class="text-danger" onclick="return confirm('Delete?');"><i class="bi bi-trash"></i></a>
                                        </td>
                                    </tr>
                                    <% }} %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Sections -->
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm custom-table">
                        <div class="card-header bg-white border-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0 text-success">Sections</h5>
                            <button class="btn btn-sm btn-outline-success" data-bs-toggle="modal" data-bs-target="#addSecModal">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </div>
                        <div class="card-body p-0 mt-3">
                            <table class="table table-hover mb-0">
                                <tbody>
                                    <% if (sections != null) { for(ConfigData c : sections) { %>
                                    <tr>
                                        <td class="ps-4"><%= c.getName() %></td>
                                        <td class="text-end pe-4">
                                            <a href="manageConfig?action=delete&type=section&id=<%= c.getId() %>" class="text-danger" onclick="return confirm('Delete?');"><i class="bi bi-trash"></i></a>
                                        </td>
                                    </tr>
                                    <% }} %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Years -->
                <div class="col-md-4">
                    <div class="card border-0 shadow-sm custom-table">
                        <div class="card-header bg-white border-0 pt-4 pb-0 d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0 text-warning">Academic Years</h5>
                            <button class="btn btn-sm btn-outline-warning" data-bs-toggle="modal" data-bs-target="#addYearModal">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </div>
                        <div class="card-body p-0 mt-3">
                            <table class="table table-hover mb-0">
                                <tbody>
                                    <% if (years != null) { for(ConfigData c : years) { %>
                                    <tr>
                                        <td class="ps-4"><%= c.getName() %> Year</td>
                                        <td class="text-end pe-4">
                                            <a href="manageConfig?action=delete&type=academic_year&id=<%= c.getId() %>" class="text-danger" onclick="return confirm('Delete?');"><i class="bi bi-trash"></i></a>
                                        </td>
                                    </tr>
                                    <% }} %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="addDeptModal" tabindex="-1">
        <div class="modal-dialog"><div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Add Department</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form action="manageConfig" method="post">
                    <input type="hidden" name="type" value="department">
                    <input type="text" name="value" class="form-control mb-3" placeholder="Department Name" required>
                    <button type="submit" class="btn btn-primary-custom w-100">Add</button>
                </form>
            </div>
        </div></div>
    </div>

    <div class="modal fade" id="addSecModal" tabindex="-1">
        <div class="modal-dialog"><div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Add Section</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form action="manageConfig" method="post">
                    <input type="hidden" name="type" value="section">
                    <input type="text" name="value" class="form-control mb-3" placeholder="Section Name (e.g., A)" required>
                    <button type="submit" class="btn btn-primary-custom w-100">Add</button>
                </form>
            </div>
        </div></div>
    </div>

    <div class="modal fade" id="addYearModal" tabindex="-1">
        <div class="modal-dialog"><div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Add Academic Year</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form action="manageConfig" method="post">
                    <input type="hidden" name="type" value="academic_year">
                    <input type="text" name="value" class="form-control mb-3" placeholder="Year (e.g., 1, 2, 3)" required>
                    <button type="submit" class="btn btn-primary-custom w-100">Add</button>
                </form>
            </div>
        </div></div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
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

