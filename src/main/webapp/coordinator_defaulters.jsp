<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.DefaulterRecord" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<DefaulterRecord> defaulters = (List<DefaulterRecord>) request.getAttribute("defaulters");
    Double currentThreshold = (Double) request.getAttribute("currentThreshold");
    if (currentThreshold == null) currentThreshold = 75.0;
    String startDate = (String) request.getAttribute("startDate");
    if (startDate == null) startDate = "";
    String endDate = (String) request.getAttribute("endDate");
    if (endDate == null) endDate = "";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Section Defaulter List - Coordinator</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .progress { height: 12px; border-radius: 6px; }
        .progress-bar-critical  { background-color: #dc3545; }
        .progress-bar-warning-zone { background-color: #fd7e14; }
        .filter-row { display: flex; flex-wrap: wrap; gap: 12px; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; }
        .filter-group label { font-size: 0.75rem; font-weight: 600; color: #6c757d; margin-bottom: 4px; }
    </style>
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- Main Content -->
    <div id="main-content" style="margin-left:260px; min-height:100vh; background:#f0f2f8;">
        
        <!-- Header Include -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="container-fluid p-0">
            <% if (request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Overall Section Defaulter List</h3>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-warning d-print-none fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#publishModal">
                        <i class="bi bi-bell-fill me-2"></i>Notify Defaulters
                    </button>
                    <button onclick="window.print()" class="btn btn-outline-primary d-print-none">
                        <i class="bi bi-printer me-2"></i>Print Report
                    </button>
                </div>
            </div>

            <!-- Publish Modal -->
            <div class="modal fade" id="publishModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content border-0 shadow">
                        <div class="modal-header bg-warning text-dark border-0">
                            <h5 class="modal-title fw-bold"><i class="bi bi-send-exclamation me-2"></i>Notify Defaulters</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body p-4">
                            <p>Are you sure you want to publish this defaulter list and send a notification to all <strong><%= defaulters != null ? defaulters.size() : 0 %></strong> students currently listed?</p>
                            <div class="alert alert-warning small border-warning">
                                <strong>Notification Details:</strong><br>
                                They will be alerted that their attendance is below <%= currentThreshold %>% 
                                <% if(startDate != null && !startDate.isEmpty()) { %> for the period <%= startDate %> to <%= endDate %><% } else { %> overall <% } %>.
                            </div>
                        </div>
                        <div class="modal-footer border-0 bg-light flex-column align-items-stretch">
                            <form action="publishDefaulters" method="post" class="m-0">
                                <input type="hidden" name="context" value="coordinator">
                                <input type="hidden" name="threshold" value="<%= currentThreshold %>">
                                <input type="hidden" name="startDate" value="<%= startDate %>">
                                <input type="hidden" name="endDate" value="<%= endDate %>">
                                
                                <div class="form-check form-switch mb-3 text-start px-5">
                                    <input class="form-check-input" type="checkbox" name="notifyParents" id="notifyParentsCheck" value="true" checked>
                                    <label class="form-check-label fw-bold text-dark small" for="notifyParentsCheck">
                                        <i class="bi bi-shield-exclamation text-danger me-1"></i>Also notify parents via simulated Email &amp; SMS
                                    </label>
                                    <div class="form-text text-muted" style="font-size: 0.75rem;">
                                        Sends an official low-attendance alert to parents with registered contact information.
                                    </div>
                                </div>
                                
                                <div class="d-flex justify-content-end gap-2 w-100 mt-2">
                                    <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancel</button>
                                    <button type="submit" class="btn btn-warning fw-bold px-4">Publish &amp; Notify</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filters -->
            <div class="card p-4 border-0 shadow-sm mb-4 d-print-none" style="border-radius: var(--card-radius);">
                <form action="coordinatorDefaulterList" method="get">
                <div class="filter-row">
                    <div class="filter-group" style="flex: 1; min-width: 200px;">
                        <label>Search Student</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" id="searchInput" class="form-control border-start-0" placeholder="Type name or roll number...">
                        </div>
                    </div>
                    <div class="filter-group" style="flex: 0 0 110px;">
                        <label>Threshold</label>
                        <div class="input-group">
                            <input type="number" name="threshold" class="form-control text-center" value="<%= currentThreshold %>" min="1" max="100" step="1">
                            <span class="input-group-text">%</span>
                        </div>
                    </div>
                    <div class="filter-group" style="flex: 2; min-width: 280px;">
                        <label>Timespan</label>
                        <div style="display:flex; gap:6px; align-items:center; flex-wrap:nowrap;">
                            <input type="date" name="startDate" class="form-control" value="<%= startDate %>" style="flex:1; min-width:0;">
                            <span class="text-muted fw-semibold">to</span>
                            <input type="date" name="endDate" class="form-control" value="<%= endDate %>" style="flex:1; min-width:0;">
                            <button type="submit" class="btn btn-primary px-3" style="white-space:nowrap; flex-shrink:0;">Apply</button>
                            <a href="coordinatorDefaulterList?threshold=75&startDate=&endDate=" class="btn btn-outline-secondary" style="flex-shrink:0;" title="Reset"><i class="bi bi-arrow-clockwise"></i></a>
                        </div>
                    </div>
                </div>
                </form>
            </div>

            <!-- Table of Defaulters -->
            <div class="card border-0 shadow-sm custom-table">
                <div class="card-header bg-white border-0 pt-4 pb-0">
                    <h5 class="fw-bold mb-0">Overall Defaulters (Below <%= currentThreshold %>%)</h5>
                    <p class="text-muted small mb-0">List of students in your assigned sections failing to maintain overall minimum attendance.</p>
                </div>
                <div class="card-body mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="defaulterTable">
                            <thead>
                                <tr>
                                    <th>Roll No</th>
                                    <th>Student Name</th>
                                    <th>Department</th>
                                    <th>Section</th>
                                    <th class="text-center">Total Classes</th>
                                    <th class="text-center">Attended</th>
                                    <th class="text-center">Percentage</th>
                                    <th style="width: 20%;">Progress</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (defaulters != null && !defaulters.isEmpty()) {
                                    for (DefaulterRecord r : defaulters) { 
                                        String pctColor = r.getPercentage() < currentThreshold ? "text-danger fw-bold" : "text-warning fw-bold";
                                        String barClass = r.getPercentage() < currentThreshold ? "progress-bar-critical" : "progress-bar-warning-zone";
                                %>
                                    <tr class="defaulter-row">
                                        <td class="fw-bold"><%= r.getStudentRollNo() %></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="https://ui-avatars.com/api/?name=<%= r.getStudentName() %>&background=ffebeb&color=dc3545&bold=true" 
                                                     style="width: 32px; height: 32px; border-radius: 50%;">
                                                <span class="fw-semibold search-name"><%= r.getStudentName() %></span>
                                            </div>
                                        </td>
                                        <td><span class="small fw-semibold text-muted"><%= r.getStudentDepartment() %></span></td>
                                        <td><span class="badge bg-light text-dark border"><%= r.getStudentSection() != null && !r.getStudentSection().isEmpty() ? r.getStudentSection() : "All" %></span></td>
                                        <td class="text-center"><%= r.getTotalClasses() %></td>
                                        <td class="text-center text-success fw-bold"><%= r.getAttendedClasses() %></td>
                                        <td class="text-center <%= pctColor %>"><%= String.format("%.2f", r.getPercentage()) %>%</td>
                                        <td>
                                            <div class="progress">
                                                <div class="progress-bar <%= barClass %>" role="progressbar" style="width: <%= r.getPercentage() %>%;" aria-valuenow="<%= r.getPercentage() %>" aria-valuemin="0" aria-valuemax="100"></div>
                                            </div>
                                        </td>
                                    </tr>
                                <% }
                                } else { %>
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">No defaulters found! Everyone is above <%= currentThreshold %>%.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.getElementById("searchInput");
            const rows = document.querySelectorAll(".defaulter-row");

            function filterTable() {
                const query = searchInput.value.toLowerCase().trim();

                rows.forEach(row => {
                    const rollNo = row.cells[0].innerText.toLowerCase();
                    const name = row.querySelector(".search-name").innerText.toLowerCase();

                    if (rollNo.includes(query) || name.includes(query)) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            }

            if(searchInput) searchInput.addEventListener("input", filterTable);
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

