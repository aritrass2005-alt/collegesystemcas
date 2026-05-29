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
    List<Subject>    subjects    = (List<Subject>)    request.getAttribute("subjects");
    List<Teacher>    teachers    = (List<Teacher>)    request.getAttribute("teachers");
    List<ConfigData> departments = (List<ConfigData>) request.getAttribute("departments");
    List<ConfigData> sections    = (List<ConfigData>) request.getAttribute("sections");
    List<ConfigData> years       = (List<ConfigData>) request.getAttribute("years");
    Subject editSubject          = (Subject)          request.getAttribute("editSubject");

    String filterDept    = (String) request.getAttribute("filterDept");
    String filterYear    = (String) request.getAttribute("filterYear");
    String filterSection = (String) request.getAttribute("filterSection");
    if (filterDept    == null) filterDept    = "";
    if (filterYear    == null) filterYear    = "";
    if (filterSection == null) filterSection = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Subject Management - CAS Admin</title>
    <meta name="description" content="Manage college subjects with department, year, section filters and teacher assignments.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=3" rel="stylesheet">
    <style>
        /* ── Filter Bar ── */
        .filter-bar {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 16px 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: flex-end;
            gap: 12px;
            flex-wrap: wrap;
            box-shadow: var(--shadow-card);
        }
        .filter-bar .filter-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
            min-width: 140px;
        }
        .filter-bar label {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-muted);
        }
        /* ── Subject Cards grid ── */
        .subject-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 16px; }
        .subject-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 18px 20px;
            box-shadow: var(--shadow-card);
            transition: transform 0.18s, box-shadow 0.18s;
            position: relative;
        }
        .subject-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(15,34,64,0.12); }
        .subject-card-code {
            font-size: 0.72rem;
            font-weight: 700;
            color: var(--accent);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 4px;
        }
        .subject-card-name {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text-heading);
            margin-bottom: 10px;
        }
        .subject-card-tags { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 10px; }
        .tag {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 10px;
            border-radius: 50px;
            font-size: 0.72rem;
            font-weight: 600;
        }
        .tag-dept  { background: rgba(30,58,95,0.08);  color: var(--primary); }
        .tag-year  { background: rgba(79,156,249,0.12); color: #2563eb; }
        .tag-sec   { background: rgba(20,184,166,0.10); color: #0d9488; }
        .subject-card-teacher {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.83rem;
            color: var(--text-body);
            padding: 8px 0 4px;
            border-top: 1px solid var(--border);
        }
        .subject-card-teacher i { color: #16a34a; }
        .subject-card-alt { font-size: 0.78rem; color: var(--text-muted); margin-top: 2px; padding-left: 24px; }
        .subject-card-actions { display: flex; gap: 6px; margin-top: 12px; }

        /* ── Stats summary ── */
        .stats-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 14px;
            background: rgba(30,58,95,0.06);
            border: 1px solid rgba(30,58,95,0.1);
            border-radius: 50px;
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--primary);
        }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 60px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 3rem; margin-bottom: 12px; display: block; opacity: 0.3; }

        /* ── Modal enhancements ── */
        .modal-content { border-radius: var(--radius-xl) !important; border: 0; }
        .modal-header  { background: linear-gradient(135deg,#1e3a5f,#0f2240); border-radius: var(--radius-xl) var(--radius-xl) 0 0 !important; padding: 20px 24px; }
        .modal-title   { color: #fff; font-weight: 700; }
        .btn-close-white { filter: invert(1) grayscale(100%) brightness(200%); }
        .modal-body    { padding: 24px; }
        .modal-footer  { border-top: 1px solid var(--border); padding: 14px 24px; }
        .form-section-label {
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-muted);
            border-bottom: 1px solid var(--border);
            padding-bottom: 6px;
            margin-bottom: 14px;
        }

        /* active filter highlight */
        .filter-active { border-color: var(--primary) !important; background: rgba(30,58,95,0.04) !important; }
    </style>
</head>
<body>
<jsp:include page="includes/admin_sidebar.jsp" />
<div id="content-wrapper">
    <jsp:include page="includes/admin_header.jsp" />

    <div class="container-fluid p-0">

        <!-- Page Title -->
        <div class="page-title-row">
            <div>
                <h1 class="page-title"><i class="bi bi-journal-bookmark-fill me-2 text-primary"></i>Subject Management</h1>
                <p class="page-subtitle">Manage subjects across departments, years, and sections</p>
            </div>
            <div class="d-flex gap-2">
                <% if (!filterDept.isEmpty() || !filterYear.isEmpty() || !filterSection.isEmpty()) { %>
                <span class="stats-pill">
                    <i class="bi bi-funnel-fill"></i>
                    <%= subjects != null ? subjects.size() : 0 %> filtered
                </span>
                <% } %>
                <button class="btn-cas-primary" id="btnAddSubject" data-bs-toggle="modal" data-bs-target="#subjectModal">
                    <i class="bi bi-plus-lg"></i> Add Subject
                </button>
            </div>
        </div>

        <!-- Alerts -->
        <% if (request.getParameter("error") != null) { %>
            <div class="alert-cas alert-cas-error mb-3"><i class="bi bi-exclamation-circle-fill"></i> <%= request.getParameter("error") %>
                <button onclick="this.parentElement.remove()" style="float:right;background:none;border:none;cursor:pointer;font-size:1.1rem;">&times;</button>
            </div>
        <% } %>
        <% if (request.getParameter("msg") != null) { %>
            <div class="alert-cas alert-cas-success mb-3"><i class="bi bi-check-circle-fill"></i> <%= request.getParameter("msg") %>
                <button onclick="this.parentElement.remove()" style="float:right;background:none;border:none;cursor:pointer;font-size:1.1rem;">&times;</button>
            </div>
        <% } %>

        <!-- Filter Bar -->
        <form id="filterForm" action="manageSubjects" method="get" class="filter-bar">
            <div class="filter-group">
                <label><i class="bi bi-building"></i> Department</label>
                <select name="dept" class="form-select form-select-sm <%= !filterDept.isEmpty() ? "filter-active" : "" %>" onchange="document.getElementById('filterForm').submit()">
                    <option value="">All Departments</option>
                    <% if (departments != null) { for (ConfigData d : departments) { %>
                        <option value="<%= d.getName() %>" <%= filterDept.equals(d.getName()) ? "selected" : "" %>><%= d.getName() %></option>
                    <% }} %>
                </select>
            </div>
            <div class="filter-group">
                <label><i class="bi bi-calendar3"></i> Year</label>
                <select name="year" class="form-select form-select-sm <%= !filterYear.isEmpty() ? "filter-active" : "" %>" onchange="document.getElementById('filterForm').submit()">
                    <option value="">All Years</option>
                    <% if (years != null) { for (ConfigData y : years) { %>
                        <option value="<%= y.getName() %>" <%= filterYear.equals(y.getName()) ? "selected" : "" %>><%= y.getName() %></option>
                    <% }} %>
                </select>
            </div>
            <div class="filter-group">
                <label><i class="bi bi-grid-3x3-gap"></i> Section</label>
                <select name="section" class="form-select form-select-sm <%= !filterSection.isEmpty() ? "filter-active" : "" %>" onchange="document.getElementById('filterForm').submit()">
                    <option value="">All Sections</option>
                    <% if (sections != null) { for (ConfigData s : sections) { %>
                        <option value="<%= s.getName() %>" <%= filterSection.equals(s.getName()) ? "selected" : "" %>><%= s.getName() %></option>
                    <% }} %>
                </select>
            </div>
            <% if (!filterDept.isEmpty() || !filterYear.isEmpty() || !filterSection.isEmpty()) { %>
            <div class="filter-group" style="justify-content:flex-end;">
                <a href="manageSubjects" class="btn btn-sm btn-outline-secondary" style="border-radius:6px;">
                    <i class="bi bi-x-lg"></i> Clear
                </a>
            </div>
            <% } %>
        </form>

        <!-- Subject Cards -->
        <% if (subjects != null && !subjects.isEmpty()) { %>
        <div class="subject-cards">
            <% for (Subject s : subjects) { %>
            <div class="subject-card">
                <div class="subject-card-code"><i class="bi bi-hash"></i><%= s.getSubjectCode() %></div>
                <div class="subject-card-name"><%= s.getName() %></div>
                <div class="subject-card-tags">
                    <span class="tag tag-dept"><i class="bi bi-building"></i><%= s.getDepartment() %></span>
                    <span class="tag tag-year"><i class="bi bi-calendar3"></i>Year <%= s.getYear() %></span>
                    <% if (s.getSection() != null && !s.getSection().isEmpty()) { %>
                    <span class="tag tag-sec"><i class="bi bi-grid-3x3-gap"></i>Sec <%= s.getSection() %></span>
                    <% } %>
                </div>
                <div class="subject-card-teacher">
                    <% if (s.getTeacherName() != null) { %>
                        <i class="bi bi-person-badge-fill"></i>
                        <span class="fw-600"><%= s.getTeacherName() %></span>
                    <% } else { %>
                        <i class="bi bi-person-x text-danger"></i>
                        <span class="text-danger">No teacher assigned</span>
                    <% } %>
                </div>
                <% if (s.getAltTeacherName() != null && !s.getAltTeacherName().isEmpty()) { %>
                <div class="subject-card-alt"><i class="bi bi-person-lines-fill me-1 text-muted"></i>Alt: <%= s.getAltTeacherName() %></div>
                <% } %>
                <div class="subject-card-actions">
                    <button class="btn btn-sm btn-outline-primary flex-fill"
                        onclick="openEdit(<%= s.getId() %>, '<%= escapeJs(s.getSubjectCode()) %>', '<%= escapeJs(s.getName()) %>',
                                          '<%= escapeJs(s.getDepartment()) %>', '<%= s.getYear() %>', '<%= escapeJs(s.getSection() != null ? s.getSection() : "") %>',
                                          <%= s.getTeacherId() %>, <%= s.getAltTeacherId() %>)">
                        <i class="bi bi-pencil-fill"></i> Edit
                    </button>
                    <button class="btn btn-sm btn-outline-danger"
                        onclick="confirmDelete(<%= s.getId() %>, '<%= escapeJs(s.getName()) %>')">
                        <i class="bi bi-trash3-fill"></i>
                    </button>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="empty-state">
            <i class="bi bi-journal-x"></i>
            <h5 class="fw-bold">No Subjects Found</h5>
            <p>Add a new subject or adjust the filters above.</p>
        </div>
        <% } %>
    </div>
</div>

<!-- ══════════════════════════════════════════════════════════════════════ -->
<!-- Subject Modal (Add / Edit) -->
<!-- ══════════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="subjectModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <form id="subjectForm" action="manageSubjects" method="post">
        <input type="hidden" name="action" id="modalAction" value="add_subject">
        <input type="hidden" name="id" id="modalId" value="">
        <!-- preserve current filters -->
        <input type="hidden" name="dept"    value="<%= filterDept %>">
        <input type="hidden" name="year"    value="<%= filterYear %>">
        <input type="hidden" name="section" value="<%= filterSection %>">

        <div class="modal-header">
            <h5 class="modal-title" id="modalTitle"><i class="bi bi-journal-plus me-2"></i>Add New Subject</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
            <!-- Identity -->
            <div class="form-section-label">Subject Identity</div>
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <label class="form-label small fw-semibold">Subject Code *</label>
                    <input type="text" name="subjectCode" id="modalCode" class="form-control" required placeholder="e.g. CS201">
                </div>
                <div class="col-md-8">
                    <label class="form-label small fw-semibold">Subject Name *</label>
                    <input type="text" name="name" id="modalName" class="form-control" required placeholder="e.g. Data Structures">
                </div>
            </div>

            <!-- Classification -->
            <div class="form-section-label">Classification</div>
            <div class="row g-3 mb-4">
                <div class="col-md-4">
                    <label class="form-label small fw-semibold">Department *</label>
                    <select name="department" id="modalDept" class="form-select" required>
                        <option value="">Select Department</option>
                        <% if (departments != null) { for (ConfigData d : departments) { %>
                            <option value="<%= d.getName() %>"><%= d.getName() %></option>
                        <% }} %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label small fw-semibold">Year *</label>
                    <select name="year" id="modalYear" class="form-select" required>
                        <option value="">Select Year</option>
                        <% if (years != null) { for (ConfigData y : years) { %>
                            <option value="<%= y.getName() %>"><%= y.getName() %></option>
                        <% }} %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label small fw-semibold">Section</label>
                    <select name="section" id="modalSection" class="form-select">
                        <option value="">All / None</option>
                        <% if (sections != null) { for (ConfigData s : sections) { %>
                            <option value="<%= s.getName() %>"><%= s.getName() %></option>
                        <% }} %>
                    </select>
                </div>
            </div>

            <!-- Teachers -->
            <div class="form-section-label">Teacher Assignment</div>
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label small fw-semibold">Primary Teacher</label>
                    <select name="teacherId" id="modalTeacher" class="form-select">
                        <option value="0">— Unassigned —</option>
                        <% if (teachers != null) { for (Teacher t : teachers) { if (t.isApproved()) { %>
                            <option value="<%= t.getId() %>"><%= t.getName() %> (<%= t.getDepartment() %>)</option>
                        <% }}} %>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label small fw-semibold">Alternative Teacher <span class="text-muted">(optional)</span></label>
                    <select name="altTeacherId" id="modalAltTeacher" class="form-select">
                        <option value="0">— None —</option>
                        <% if (teachers != null) { for (Teacher t : teachers) { if (t.isApproved()) { %>
                            <option value="<%= t.getId() %>"><%= t.getName() %> (<%= t.getDepartment() %>)</option>
                        <% }}} %>
                    </select>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-cas-outline" data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn-cas-primary" id="modalSubmitBtn"><i class="bi bi-save2-fill"></i> Save Subject</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Delete Confirm Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
        <div class="modal-header" style="background:#dc2626; border-radius: var(--radius-xl) var(--radius-xl) 0 0;">
            <h5 class="modal-title" style="color:#fff;"><i class="bi bi-exclamation-triangle-fill me-2"></i>Confirm Delete</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body text-center py-4">
            <p class="mb-0">Delete subject <strong id="deleteSubjectName"></strong>?</p>
            <p class="text-muted small mt-1">This may affect timetable entries.</p>
        </div>
        <div class="modal-footer justify-content-center">
            <form action="manageSubjects" method="post">
                <input type="hidden" name="action" value="delete_subject">
                <input type="hidden" name="id" id="deleteSubjectId">
                <input type="hidden" name="dept"    value="<%= filterDept %>">
                <input type="hidden" name="year"    value="<%= filterYear %>">
                <input type="hidden" name="section" value="<%= filterSection %>">
                <button type="button" class="btn btn-secondary btn-sm me-2" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-danger btn-sm"><i class="bi bi-trash3-fill"></i> Delete</button>
            </form>
        </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openEdit(id, code, name, dept, year, section, teacherId, altTeacherId) {
    document.getElementById('modalAction').value    = 'update_subject';
    document.getElementById('modalId').value        = id;
    document.getElementById('modalCode').value      = code;
    document.getElementById('modalName').value      = name;
    document.getElementById('modalTitle').innerHTML = '<i class="bi bi-pencil-fill me-2"></i>Edit Subject';
    document.getElementById('modalSubmitBtn').innerHTML = '<i class="bi bi-save2-fill"></i> Update Subject';

    setSelectVal('modalDept',       dept);
    setSelectVal('modalYear',       year);
    setSelectVal('modalSection',    section);
    setSelectVal('modalTeacher',    teacherId);
    setSelectVal('modalAltTeacher', altTeacherId);

    new bootstrap.Modal(document.getElementById('subjectModal')).show();
}

function setSelectVal(id, val) {
    var sel = document.getElementById(id);
    for (var i = 0; i < sel.options.length; i++) {
        if (sel.options[i].value == val) { sel.selectedIndex = i; return; }
    }
}

function confirmDelete(id, name) {
    document.getElementById('deleteSubjectId').value   = id;
    document.getElementById('deleteSubjectName').textContent = name;
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}

// Reset modal on Add button click
document.getElementById('btnAddSubject').addEventListener('click', function() {
    document.getElementById('modalAction').value    = 'add_subject';
    document.getElementById('modalId').value        = '';
    document.getElementById('subjectForm').reset();
    document.getElementById('modalTitle').innerHTML = '<i class="bi bi-journal-plus me-2"></i>Add New Subject';
    document.getElementById('modalSubmitBtn').innerHTML = '<i class="bi bi-save2-fill"></i> Save Subject';
    // Pre-fill from current filters
    setSelectVal('modalDept',    '<%= filterDept %>');
    setSelectVal('modalYear',    '<%= filterYear %>');
    setSelectVal('modalSection', '<%= filterSection %>');
});

// Auto-dismiss alerts
setTimeout(function() {
    document.querySelectorAll('.alert-cas').forEach(function(el){ el.style.opacity='0'; setTimeout(function(){el.remove();},400); });
}, 5000);
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
<%!
    private String escapeJs(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("'","\\'").replace("\"","\\\"");
    }
%>

