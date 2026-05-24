<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Coordinator" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Coordinator> coordinators = (List<Coordinator>) request.getAttribute("coordinators");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Coordinators - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .coord-avatar {
            width: 42px; height: 42px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 1rem; color: #fff;
            background: linear-gradient(135deg, #667eea, #764ba2);
            flex-shrink: 0;
        }
        .remove-btn {
            transition: all 0.2s ease;
        }
        .remove-btn:hover {
            background: #dc3545 !important;
            color: #fff !important;
            border-color: #dc3545 !important;
            transform: scale(1.05);
        }
        .coord-row { transition: background 0.2s; }
        .coord-row:hover { background: rgba(102,126,234,0.04); }
        .stats-card {
            border-radius: 16px;
            border: none;
            padding: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.06);
        }
        .stats-icon {
            width: 52px; height: 52px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem;
        }
        #searchInput:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102,126,234,0.15);
        }
        .empty-state { padding: 4rem 2rem; text-align: center; color: #adb5bd; }
        .empty-state i { font-size: 3.5rem; display: block; margin-bottom: 1rem; opacity: 0.4; }
    </style>
</head>
<body>
    <jsp:include page="includes/admin_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <div class="container-fluid p-0">

            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1"><i class="bi bi-person-badge-fill text-primary me-2"></i>Manage Coordinators</h3>
                    <p class="text-muted mb-0 small">Assign, edit, and remove coordinator roles</p>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-primary-custom" onclick="prepareAddCoordinator()">
                        <i class="bi bi-person-plus me-1"></i> Assign Coordinator
                    </button>
                    <a href="manageTeachers" class="btn btn-outline-secondary">
                        <i class="bi bi-person-video3 me-1"></i> Go to Teachers
                    </a>
                </div>
            </div>

            <!-- Alerts -->
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

            <!-- Stats Row -->
            <%
                int totalCoords = (coordinators != null) ? coordinators.size() : 0;
                java.util.Set<Integer> uniqueTeachers = new java.util.HashSet<>();
                java.util.Set<String> uniqueDepts = new java.util.HashSet<>();
                if (coordinators != null) {
                    for (Coordinator c : coordinators) {
                        uniqueTeachers.add(c.getTeacherId());
                        uniqueDepts.add(c.getDepartment());
                    }
                }
            %>
            <div class="row g-3 mb-4">
                <div class="col-sm-4">
                    <div class="stats-card bg-white">
                        <div class="stats-icon" style="background:rgba(102,126,234,0.12);">
                            <i class="bi bi-person-badge" style="color:#667eea;"></i>
                        </div>
                        <div>
                            <div class="fs-2 fw-bold"><%= totalCoords %></div>
                            <div class="text-muted small">Total Assignments</div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="stats-card bg-white">
                        <div class="stats-icon" style="background:rgba(13,202,240,0.12);">
                            <i class="bi bi-people-fill" style="color:#0dcaf0;"></i>
                        </div>
                        <div>
                            <div class="fs-2 fw-bold"><%= uniqueTeachers.size() %></div>
                            <div class="text-muted small">Unique Coordinators</div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="stats-card bg-white">
                        <div class="stats-icon" style="background:rgba(25,135,84,0.12);">
                            <i class="bi bi-building" style="color:#198754;"></i>
                        </div>
                        <div>
                            <div class="fs-2 fw-bold"><%= uniqueDepts.size() %></div>
                            <div class="text-muted small">Departments Covered</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Search Bar -->
            <div class="card border-0 shadow-sm mb-4" style="border-radius:16px;">
                <div class="card-body p-3">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-0"><i class="bi bi-search text-muted"></i></span>
                        <input type="text" id="searchInput" class="form-control bg-light border-0 shadow-none"
                               placeholder="Search by teacher name, department, or section..." oninput="filterTable()">
                    </div>
                </div>
            </div>

            <!-- Coordinator Table -->
            <div class="card border-0 shadow-sm" style="border-radius:16px; overflow:hidden;">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="coordTable">
                        <thead style="background:linear-gradient(135deg,#f8f9fa,#e9ecef);">
                            <tr>
                                <th class="ps-4 py-3 border-0 text-muted small fw-bold text-uppercase" style="letter-spacing:.5px;">#</th>
                                <th class="py-3 border-0 text-muted small fw-bold text-uppercase" style="letter-spacing:.5px;">Teacher</th>
                                <th class="py-3 border-0 text-muted small fw-bold text-uppercase" style="letter-spacing:.5px;">Department</th>
                                <th class="py-3 border-0 text-muted small fw-bold text-uppercase" style="letter-spacing:.5px;">Year</th>
                                <th class="py-3 border-0 text-muted small fw-bold text-uppercase" style="letter-spacing:.5px;">Section</th>
                                <th class="py-3 border-0 text-muted small fw-bold text-uppercase text-center" style="letter-spacing:.5px;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="coordTableBody">
                        <% if (coordinators != null && !coordinators.isEmpty()) {
                               int idx = 1;
                               for (Coordinator c : coordinators) {
                                   String initials = c.getTeacherName() != null && c.getTeacherName().length() > 0
                                       ? String.valueOf(c.getTeacherName().charAt(0)).toUpperCase() : "?";
                                   String section = (c.getSection() == null || c.getSection().isEmpty()) ? "All" : c.getSection();
                        %>
                            <tr class="coord-row" data-name="<%= c.getTeacherName() %>" data-dept="<%= c.getDepartment() %>" data-sec="<%= section %>">
                                <td class="ps-4 text-muted small"><%= idx++ %></td>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="coord-avatar"><%= initials %></div>
                                        <div>
                                            <p class="mb-0 fw-semibold"><%= c.getTeacherName() %></p>
                                            <small class="text-muted">Teacher ID: <%= c.getTeacherId() %></small>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge rounded-pill px-3 py-2" style="background:rgba(102,126,234,0.1);color:#667eea;font-weight:600;">
                                        <i class="bi bi-building me-1"></i><%= c.getDepartment() %>
                                    </span>
                                </td>
                                <td>
                                    <span class="badge rounded-pill px-3 py-2 bg-light text-dark border fw-semibold">
                                        Year <%= c.getYear() %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("All".equals(section)) { %>
                                        <span class="badge rounded-pill px-3 py-2" style="background:rgba(13,202,240,0.1);color:#0dcaf0;font-weight:600;">All Sections</span>
                                    <% } else { %>
                                        <span class="badge rounded-pill px-3 py-2" style="background:rgba(25,135,84,0.1);color:#198754;font-weight:600;">Section <%= section %></span>
                                    <% } %>
                                </td>
                                <td class="text-center">
                                    <div class="d-flex gap-2 justify-content-center">
                                        <button class="btn btn-sm btn-outline-primary px-3" 
                                                onclick="editCoordinator(<%= c.getId() %>, <%= c.getTeacherId() %>, '<%= c.getDepartment() %>', <%= c.getYear() %>, '<%= section %>')">
                                            <i class="bi bi-pencil me-1"></i> Edit
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger remove-btn px-3"
                                                onclick="confirmRemove(<%= c.getId() %>, '<%= c.getTeacherName() %>', '<%= c.getDepartment() %>', 'Year <%= c.getYear() %>', '<%= section %>')">
                                            <i class="bi bi-x-circle me-1"></i> Remove
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr>
                                <td colspan="6">
                                    <div class="empty-state">
                                        <i class="bi bi-person-badge"></i>
                                        <h5 class="text-muted fw-semibold">No Coordinators Assigned</h5>
                                        <p class="small text-muted">Go to <a href="manageTeachers">Manage Teachers</a> to assign coordinator roles.</p>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <!-- Remove Confirmation Modal -->
    <div class="modal fade" id="removeModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg" style="border-radius:20px; overflow:hidden;">
                <div class="modal-header border-0 p-4" style="background:linear-gradient(135deg,#dc3545,#c82333);">
                    <div class="d-flex align-items-center gap-3">
                        <div style="width:44px;height:44px;background:rgba(255,255,255,0.2);border-radius:12px;display:flex;align-items:center;justify-content:center;">
                            <i class="bi bi-exclamation-triangle-fill text-white fs-5"></i>
                        </div>
                        <div>
                            <h5 class="modal-title fw-bold text-white mb-0">Remove Coordinator</h5>
                            <small class="text-white opacity-75">This action cannot be undone</small>
                        </div>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="mb-3 text-muted">You are about to remove the coordinator role for:</p>
                    <div class="p-3 rounded-3 mb-3" style="background:#f8f9fa;border:1px solid #e9ecef;">
                        <div class="row g-2">
                            <div class="col-6">
                                <small class="text-muted d-block">Teacher</small>
                                <strong id="modalTeacherName" class="text-dark">—</strong>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Department</small>
                                <strong id="modalDept" class="text-dark">—</strong>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Year</small>
                                <strong id="modalYear" class="text-dark">—</strong>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Section</small>
                                <strong id="modalSection" class="text-dark">—</strong>
                            </div>
                        </div>
                    </div>
                    <p class="text-muted small mb-0">The teacher will lose coordinator access for this assignment. Their other roles and data will not be affected.</p>
                </div>
                <div class="modal-footer border-0 px-4 pb-4 pt-0 gap-2">
                    <button type="button" class="btn btn-light px-4 rounded-pill" data-bs-dismiss="modal">Cancel</button>
                    <form action="manageCoordinator" method="post" id="removeForm">
                        <input type="hidden" name="action" value="remove">
                        <input type="hidden" name="id" id="removeId">
                        <button type="submit" class="btn btn-danger px-4 rounded-pill fw-semibold">
                            <i class="bi bi-x-circle me-1"></i> Yes, Remove
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Assign/Edit Coordinator Modal -->
    <div class="modal fade" id="coordinatorModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold" id="coordModalTitle">Assign Coordinator</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="manageCoordinator" method="post" id="coordForm">
                        <input type="hidden" name="action" id="coordAction" value="assign">
                        <input type="hidden" name="id" id="coordId">
                        
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Select Teacher</label>
                            <select name="teacher_id" id="coordTeacherId" class="form-select" required>
                                <option value="">-- Choose Teacher --</option>
                                <% java.util.List<com.college.attendance.model.Teacher> teachers = (java.util.List<com.college.attendance.model.Teacher>) request.getAttribute("teachers");
                                   if(teachers!=null){ for(com.college.attendance.model.Teacher t:teachers){ %>
                                    <option value="<%= t.getId() %>"><%= t.getName() %> (<%= t.getDepartment() %>)</option>
                                <% }} %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Department</label>
                            <select name="department" id="coordDept" class="form-select" required>
                                <option value="">-- Choose Dept --</option>
                                <% java.util.List<com.college.attendance.model.ConfigData> departments = (java.util.List<com.college.attendance.model.ConfigData>) request.getAttribute("departments");
                                   if(departments!=null){ for(com.college.attendance.model.ConfigData c:departments){ %>
                                    <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                <% }} %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Year</label>
                            <select name="year" id="coordYear" class="form-select" required>
                                <option value="">-- Choose Year --</option>
                                <% java.util.List<com.college.attendance.model.ConfigData> years = (java.util.List<com.college.attendance.model.ConfigData>) request.getAttribute("years");
                                   if(years!=null){ for(com.college.attendance.model.ConfigData c:years){ %>
                                    <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                <% }} %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Section</label>
                            <select name="section" id="coordSection" class="form-select">
                                <option value="">All Sections</option>
                                <% java.util.List<com.college.attendance.model.ConfigData> sections = (java.util.List<com.college.attendance.model.ConfigData>) request.getAttribute("sections");
                                   if(sections!=null){ for(com.college.attendance.model.ConfigData c:sections){ %>
                                    <option value="<%= c.getName() %>"><%= c.getName() %></option>
                                <% }} %>
                            </select>
                            <div class="form-text">Leave blank to assign all sections.</div>
                        </div>
                        <div class="mt-4">
                            <button type="submit" class="btn-cas-primary w-100 py-2" id="coordSubmitBtn">Save Coordinator Assignment</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function prepareAddCoordinator() {
            document.getElementById('coordModalTitle').innerText = 'Assign Coordinator';
            document.getElementById('coordAction').value = 'assign';
            document.getElementById('coordForm').reset();
            document.getElementById('coordSubmitBtn').innerText = 'Save Coordinator Assignment';
            new bootstrap.Modal(document.getElementById('coordinatorModal')).show();
        }

        function editCoordinator(id, teacherId, dept, year, section) {
            document.getElementById('coordModalTitle').innerText = 'Edit Coordinator';
            document.getElementById('coordAction').value = 'update';
            document.getElementById('coordId').value = id;
            document.getElementById('coordTeacherId').value = teacherId;
            document.getElementById('coordDept').value = dept;
            document.getElementById('coordYear').value = year;
            document.getElementById('coordSection').value = (section === 'All' ? '' : section);
            document.getElementById('coordSubmitBtn').innerText = 'Update Assignment';
            new bootstrap.Modal(document.getElementById('coordinatorModal')).show();
        }

        function confirmRemove(id, name, dept, year, section) {
            document.getElementById('removeId').value = id;
            document.getElementById('modalTeacherName').textContent = name;
            document.getElementById('modalDept').textContent = dept;
            document.getElementById('modalYear').textContent = year;
            document.getElementById('modalSection').textContent = section;
            new bootstrap.Modal(document.getElementById('removeModal')).show();
        }

        function filterTable() {
            const query = document.getElementById('searchInput').value.toLowerCase();
            const rows = document.querySelectorAll('#coordTableBody tr.coord-row');
            let visible = 0;
            rows.forEach(row => {
                const name = row.dataset.name?.toLowerCase() || '';
                const dept = row.dataset.dept?.toLowerCase() || '';
                const sec  = row.dataset.sec?.toLowerCase()  || '';
                if (name.includes(query) || dept.includes(query) || sec.includes(query)) {
                    row.style.display = '';
                    visible++;
                } else {
                    row.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
