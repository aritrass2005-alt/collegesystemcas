<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Subject" %>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.ConfigData" %>
<%@ page import="java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || (!role.equals("Admin") && !role.equals("SuperAdmin"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<Subject> subjects = (List<Subject>) request.getAttribute("subjects");
    List<Teacher> teachers = (List<Teacher>) request.getAttribute("teachers");
    List<ConfigData> departments = (List<ConfigData>) request.getAttribute("departments");
    List<ConfigData> sections = (List<ConfigData>) request.getAttribute("sections");
    List<ConfigData> years = (List<ConfigData>) request.getAttribute("years");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Subjects - Admin</title>
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
                <h3 class="fw-bold m-0">Subject Management</h3>
                <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addSubjectModal">
                    <i class="bi bi-plus-lg"></i> Add New Subject
                </button>
            </div>

            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show"><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show"><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <div class="card custom-table border-0 shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>Subject Code</th>
                                <th>Name</th>
                                <th>Department</th>
                                <th>Year</th>
                                <th>Section</th>
                                <th>Assigned Teacher</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if(subjects != null && !subjects.isEmpty()) { 
                                for(Subject s : subjects) { %>
                            <tr>
                                <td class="fw-bold text-primary"><%= s.getSubjectCode() %></td>
                                <td><%= s.getName() %></td>
                                <td><span class="badge bg-light text-dark border"><%= s.getDepartment() %></span></td>
                                <td><%= s.getYear() %></td>
                                <td><%= s.getSection() != null ? s.getSection() : "N/A" %></td>
                                <td>
                                    <% if(s.getTeacherName() != null) { %>
                                        <div class="d-flex align-items-center gap-2">
                                            <i class="bi bi-person-badge text-success"></i>
                                            <span><%= s.getTeacherName() %></span>
                                        </div>
                                    <% } else { %>
                                        <span class="text-danger"><i class="bi bi-exclamation-circle"></i> Unassigned</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            <tr><td colspan="6" class="text-center py-4 text-muted">No subjects found.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Subject Modal -->
    <div class="modal fade" id="addSubjectModal" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content border-0" style="border-radius: var(--card-radius);">
          <form action="manageSubjects" method="post">
              <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold">Add New Subject</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
              </div>
              <div class="modal-body p-4">
                  <input type="hidden" name="action" value="add_subject">
                  
                  <div class="row g-3">
                      <div class="col-md-6">
                          <label class="form-label">Subject Code</label>
                          <input type="text" name="subjectCode" class="form-control" required placeholder="e.g. CS201">
                      </div>
                      <div class="col-md-6">
                          <label class="form-label">Subject Name</label>
                          <input type="text" name="name" class="form-control" required>
                      </div>
                      <div class="col-md-12">
                          <label class="form-label">Department</label>
                          <select name="department" class="form-select" required>
                              <option value="">Select Department</option>
                              <% if(departments != null) { for(ConfigData c : departments) { %>
                                  <option value="<%= c.getName() %>"><%= c.getName() %></option>
                              <% }} %>
                          </select>
                      </div>
                      <div class="col-md-6">
                          <label class="form-label">Year</label>
                          <select name="year" class="form-select" required>
                              <option value="">Select Year</option>
                              <% if(years != null) { for(ConfigData c : years) { %>
                                  <option value="<%= c.getName() %>"><%= c.getName() %></option>
                              <% }} %>
                          </select>
                      </div>
                      <div class="col-md-6">
                          <label class="form-label">Section</label>
                          <select name="section" class="form-select" required>
                              <option value="">Select Section</option>
                              <% if(sections != null) { for(ConfigData c : sections) { %>
                                  <option value="<%= c.getName() %>"><%= c.getName() %></option>
                              <% }} %>
                          </select>
                      </div>
                      <div class="col-md-12">
                          <label class="form-label">Assign Teacher</label>
                          <select name="teacherId" class="form-select" required>
                              <option value="">Select Teacher</option>
                              <% if(teachers != null) {
                                  for(Teacher t : teachers) {
                                      if(t.isApproved()) { %>
                                          <option value="<%= t.getId() %>"><%= t.getName() %> (<%= t.getDepartment() %>)</option>
                              <%      }
                                  }
                                 } %>
                          </select>
                      </div>
                  </div>
              </div>
              <div class="modal-footer border-top-0 pt-0">
                <button type="submit" class="btn btn-primary-custom w-100">Save Subject</button>
              </div>
          </form>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
