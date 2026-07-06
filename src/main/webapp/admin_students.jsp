<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.*" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("students");
    List<ConfigData> departments = (List<ConfigData>) request.getAttribute("departments");
    List<ConfigData> years = (List<ConfigData>) request.getAttribute("years");
    List<ConfigData> sections = (List<ConfigData>) request.getAttribute("sections");
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Students - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Manage Students</h3>
                <div class="d-flex gap-2">
                    <button class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#promoteModal">
                        <i class="bi bi-arrow-up-circle"></i> Auto Promote
                    </button>
                    <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#studentModal" onclick="prepareAddStudent()">
                        <i class="bi bi-person-plus"></i> Add Student
                    </button>
                </div>
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
                <form action="manageStudents" method="get" class="row g-3">
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

            <!-- Student List -->
            <div class="card custom-table border-0 shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>Roll No</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Password (DOB)</th>
                                <th>Dept</th>
                                <th>Year/Sec</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(students != null && !students.isEmpty()) { 
                                for(Student s : students) { 
                                    boolean banned = s.isBanned();
                                    boolean passedOut = "PassedOut".equals(s.getStatus());
                            %>
                            <tr class="<%= banned ? "table-danger opacity-75" : "" %> <%= passedOut ? "opacity-50" : "" %>">
                                <td class="fw-bold"><%= s.getRollNo() %></td>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <img src="https://ui-avatars.com/api/?name=<%= s.getName() %>&background=random" class="rounded-circle" width="35" height="35">
                                        <span class="fw-medium"><%= s.getName() %></span>
                                    </div>
                                </td>
                                <td><%= s.getEmail() %></td>
                                <td><%= s.getPhone() != null ? s.getPhone() : "N/A" %></td>
                                <td><span class="badge bg-secondary"><%= s.getDob() != null ? s.getDob() : "N/A" %></span></td>
                                <td><span class="badge bg-light text-dark border"><%= s.getDepartment() %></span></td>
                                <td>Year <%= s.getYear() %> - Sec <%= s.getSection() %></td>
                                <td>
                                    <% if("PassedOut".equals(s.getStatus())) { %>
                                        <span class="badge bg-secondary">Passed Out</span>
                                    <% } else { %>
                                        <span class="badge bg-success">Active</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <button class="btn btn-sm btn-outline-primary" 
                                            onclick='editStudent(<%= new com.google.gson.Gson().toJson(s) %>)'>
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <form action="toggleBan" method="post" class="m-0 p-0 d-inline" onsubmit="return confirm('Are you sure you want to <%= banned ? "unban" : "ban" %> this student?');">
                                            <input type="hidden" name="userId" value="<%= s.getId() %>">
                                            <input type="hidden" name="userRole" value="Student">
                                            <input type="hidden" name="isBanned" value="<%= !banned %>">
                                            <button type="submit" class="btn btn-sm <%= banned ? "btn-success" : "btn-warning" %>" title="<%= banned ? "Unban Account" : "Ban Account" %>">
                                                <i class="bi <%= banned ? "bi-unlock" : "bi-lock" %>"></i>
                                            </button>
                                        </form>
                                        <a href="manageStudents?action=delete&id=<%= s.getId() %>" 
                                           class="btn btn-sm btn-outline-danger" 
                                           onclick="return confirm('Are you sure you want to delete this student?')">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            <tr><td colspan="6" class="text-center py-4 text-muted">No students found matching filters.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>


    <!-- Student Modal (Add/Edit) -->
    <div class="modal fade" id="studentModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="modalTitle">Add Student</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="manageStudents" method="post" id="studentForm">
                        <input type="hidden" name="action" id="formAction" value="add">
                        <input type="hidden" name="id" id="studentId">
                        
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Roll Number</label>
                                <input type="text" name="roll_no" id="rollNo" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Full Name</label>
                                <input type="text" name="name" id="studentName" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Email Address</label>
                                <input type="email" name="email" id="studentEmail" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold">Phone Number</label>
                                <input type="text" name="phone" id="studentPhone" class="form-control">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Department</label>
                                <select name="department" id="studentDept" class="form-select" required>
                                    <% if(departments!=null){ for(ConfigData c:departments){ %>
                                        <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                    <% }} %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Academic Year</label>
                                <select name="year" id="studentYear" class="form-select" required>
                                    <% if(years!=null){ for(ConfigData c:years){ %>
                                        <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                    <% }} %>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Section</label>
                                <select name="section" id="studentSec" class="form-select" required>
                                    <% if(sections!=null){ for(ConfigData c:sections){ %>
                                        <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                    <% }} %>
                                </select>
                            </div>
                            <div class="col-12" id="dobField">
                                <label class="form-label small fw-bold">Date of Birth (Password)</label>
                                <input type="text" name="dob" id="studentDob" class="form-control" placeholder="e.g. 32012006">
                                <div class="form-text">DOB will be used as the default password. Format should match what students will type.</div>
                            </div>
                            
                            <!-- Parent Details -->
                            <div class="col-12 mt-3 mb-1">
                                <h6 class="fw-bold border-bottom pb-2 text-primary" style="font-size: 0.9rem;"><i class="bi bi-people me-2"></i>Parent / Guardian Details</h6>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Parent Full Name</label>
                                <input type="text" name="parent_name" id="studentParentName" class="form-control" placeholder="e.g. Robert Smith">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Parent Email Address</label>
                                <input type="email" name="parent_email" id="studentParentEmail" class="form-control" placeholder="e.g. parent@email.com">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold">Parent Phone Number</label>
                                <input type="text" name="parent_phone" id="studentParentPhone" class="form-control" placeholder="e.g. 9876543210">
                            </div>

                            <div class="col-12 mt-3">
                                <label class="form-label small fw-bold">Address</label>
                                <textarea name="address" id="studentAddress" class="form-control" rows="2"></textarea>
                            </div>
                        </div>
                        <div class="mt-4">
                            <button type="submit" class="btn btn-primary-custom w-100 py-2">Save Student</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Promote Modal -->
    <div class="modal fade" id="promoteModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold">Auto Promote Students</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="manageStudents" method="post">
                        <input type="hidden" name="action" value="promote">
                        
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Department (Optional)</label>
                            <select name="promote_department" class="form-select">
                                <option value="">All Departments</option>
                                <% if(departments!=null){ for(ConfigData c:departments){ %>
                                    <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                <% }} %>
                            </select>
                            <div class="form-text">Leave as "All Departments" to promote across all departments.</div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Current Year (Optional)</label>
                            <select name="promote_year" class="form-select">
                                <option value="">All Years</option>
                                <option value="1">Year 1</option>
                                <option value="2">Year 2</option>
                                <option value="3">Year 3</option>
                                <option value="4">Year 4</option>
                            </select>
                            <div class="form-text">Select a specific year to promote, or "All Years" to promote 1->2, 2->3, 3->4, and mark 4 as Passed Out.</div>
                        </div>

                        <div class="mt-4">
                            <button type="submit" class="btn btn-warning w-100 py-2" onclick="return confirm('Are you sure you want to promote these students? This action cannot be easily undone.')">Execute Promotion</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function prepareAddStudent() {
            document.getElementById('modalTitle').innerText = 'Add New Student';
            document.getElementById('formAction').value = 'add';
            document.getElementById('studentForm').reset();
            document.getElementById('dobField').style.display = 'block';
            document.getElementById('studentDob').required = true;
            document.getElementById('studentParentName').value = '';
            document.getElementById('studentParentEmail').value = '';
            document.getElementById('studentParentPhone').value = '';
        }

        function editStudent(student) {
            document.getElementById('modalTitle').innerText = 'Edit Student';
            document.getElementById('formAction').value = 'update';
            document.getElementById('studentId').value = student.id;
            document.getElementById('rollNo').value = student.rollNo;
            document.getElementById('studentName').value = student.name;
            document.getElementById('studentEmail').value = student.email;
            document.getElementById('studentPhone').value = student.phone || '';
            document.getElementById('studentDept').value = student.department;
            document.getElementById('studentYear').value = student.year;
            document.getElementById('studentSec').value = student.section;
            document.getElementById('studentAddress').value = student.address || '';
            
            document.getElementById('studentParentName').value = student.parentName || '';
            document.getElementById('studentParentEmail').value = student.parentEmail || '';
            document.getElementById('studentParentPhone').value = student.parentPhone || '';
            
            document.getElementById('dobField').style.display = 'block';
            document.getElementById('studentDob').required = true;
            document.getElementById('studentDob').value = student.dob || '';
            
            var modal = new bootstrap.Modal(document.getElementById('studentModal'));
            modal.show();
        }
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

