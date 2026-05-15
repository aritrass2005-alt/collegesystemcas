<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Teacher> teachers = (List<Teacher>) request.getAttribute("teachers");
    List<ConfigData> departments = (List<ConfigData>) request.getAttribute("departments");
    List<ConfigData> years = (List<ConfigData>) request.getAttribute("years");
    List<ConfigData> sections = (List<ConfigData>) request.getAttribute("sections");
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Teachers - Admin</title>
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
                <h3 class="fw-bold mb-0">Manage Teachers</h3>
                <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#teacherModal" onclick="prepareAddTeacher()">
                    <i class="bi bi-person-plus"></i> Add Teacher
                </button>
            </div>

            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <!-- Filters -->
            <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius);">
                <form action="manageTeachers" method="get" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label text-muted small">Department</label>
                        <select name="department" class="form-select">
                            <option value="">All Departments</option>
                            <% if(departments!=null){ for(ConfigData c:departments){ %>
                                <option value="<%= c.getName() %>" <%= c.getName().equals(request.getAttribute("selDept")) ? "selected" : "" %>><%= c.getName() %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small">Year</label>
                        <select name="year" class="form-select">
                            <option value="">All Years</option>
                            <% if(years!=null){ for(ConfigData c:years){ %>
                                <option value="<%= c.getName() %>" <%= c.getName().equals(request.getAttribute("selYear")) ? "selected" : "" %>><%= c.getName() %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label text-muted small">Section</label>
                        <select name="section" class="form-select">
                            <option value="">All Sections</option>
                            <% if(sections!=null){ for(ConfigData c:sections){ %>
                                <option value="<%= c.getName() %>" <%= c.getName().equals(request.getAttribute("selSec")) ? "selected" : "" %>><%= c.getName() %></option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label text-muted small">Subject</label>
                        <select name="subject_id" class="form-select">
                            <option value="">All Subjects</option>
                            <% if(subjects!=null){ for(Subject s:subjects){ 
                                String sid = String.valueOf(s.getId());
                            %>
                                <option value="<%= s.getId() %>" <%= sid.equals(request.getAttribute("selSub")) ? "selected" : "" %>><%= s.getName() %> (<%= s.getSubjectCode() %>)</option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary-custom w-100"><i class="bi bi-funnel"></i> Filter</button>
                    </div>
                </form>
            </div>

            <!-- Teacher List -->
            <div class="card custom-table border-0 shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Department</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(teachers != null && !teachers.isEmpty()) { 
                                for(Teacher t : teachers) { %>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="https://ui-avatars.com/api/?name=<%= t.getName() %>&background=random" class="rounded-circle" width="35" height="35">
                                        <span class="fw-medium"><%= t.getName() %></span>
                                    </div>
                                </td>
                                <td><%= t.getEmail() %></td>
                                <td><span class="badge bg-light text-dark border"><%= t.getDepartment() %></span></td>
                                <td>
                                    <% if(t.isApproved()) { %>
                                        <span class="badge bg-success rounded-pill">Approved</span>
                                    <% } else { %>
                                        <span class="badge bg-warning text-dark rounded-pill">Pending</span>
                                    <% } %>
                                </td>
                                 <td>
                                     <div class="d-flex gap-2">
                                         <% if(!t.isApproved()) { %>
                                             <a href="manageTeachers?action=approve&id=<%= t.getId() %>" class="btn btn-sm btn-success">Approve</a>
                                         <% } %>
                                         <button class="btn btn-sm btn-outline-primary" 
                                             onclick='editTeacher(<%= new com.google.gson.Gson().toJson(t) %>)'>
                                             <i class="bi bi-pencil"></i>
                                         </button>
                                         <a href="manageTeachers?action=delete&id=<%= t.getId() %>" 
                                            class="btn btn-sm btn-outline-danger" 
                                            onclick="return confirm('Are you sure you want to delete this teacher?')">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                     </div>
                                 </td>
                            </tr>
                            <%  } 
                               } else { %>
                            <tr><td colspan="5" class="text-center py-4 text-muted">No teachers found matching filters.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Teacher Modal (Add/Edit) -->
    <div class="modal fade" id="teacherModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="modalTitle">Add Teacher</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="manageTeachers" method="post" id="teacherForm">
                        <input type="hidden" name="action" id="formAction" value="add">
                        <input type="hidden" name="id" id="teacherId">
                        
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Full Name</label>
                            <input type="text" name="name" id="teacherName" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Email Address</label>
                            <input type="email" name="email" id="teacherEmail" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Phone Number</label>
                            <input type="text" name="phone" id="teacherPhone" class="form-control">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Department</label>
                            <select name="department" id="teacherDept" class="form-select" required>
                                <% if(departments!=null){ for(ConfigData c:departments){ %>
                                    <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                <% }} %>
                            </select>
                        </div>
                        <div class="mt-4">
                            <button type="submit" class="btn btn-primary-custom w-100 py-2">Save Teacher</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function prepareAddTeacher() {
            document.getElementById('modalTitle').innerText = 'Add New Teacher';
            document.getElementById('formAction').value = 'add';
            document.getElementById('teacherForm').reset();
        }

        function editTeacher(teacher) {
            document.getElementById('modalTitle').innerText = 'Edit Teacher';
            document.getElementById('formAction').value = 'update';
            document.getElementById('teacherId').value = teacher.id;
            document.getElementById('teacherName').value = teacher.name;
            document.getElementById('teacherEmail').value = teacher.email;
            document.getElementById('teacherPhone').value = teacher.phone || '';
            document.getElementById('teacherDept').value = teacher.department;
            
            var modal = new bootstrap.Modal(document.getElementById('teacherModal'));
            modal.show();
        }
    </script>
</body>
</html>
