<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.DefaulterRecord" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    List<DefaulterRecord> defaulters = (List<DefaulterRecord>) request.getAttribute("defaulters");
    
    // Extract unique subjects for the filter dropdown
    Set<String> uniqueSubjects = new HashSet<>();
    if (defaulters != null) {
        for (DefaulterRecord r : defaulters) {
            uniqueSubjects.add(r.getSubjectCode() + " - " + r.getSubjectName());
        }
    }
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
    <title>Defaulter List - Faculty</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .progress {
            height: 12px;
            border-radius: 6px;
        }
        .progress-bar-critical  { background-color: #dc3545; }
        .progress-bar-warning-zone { background-color: #fd7e14; }
        .filter-row { display: flex; flex-wrap: wrap; gap: 12px; align-items: flex-end; }
        .filter-group { display: flex; flex-direction: column; }
        .filter-group label { font-size: 0.75rem; font-weight: 600; color: #6c757d; margin-bottom: 4px; }
        .filter-date-group { display: flex; align-items: center; gap: 6px; flex: 1; min-width: 0; }
        .filter-date-group input[type=date] { flex: 1; min-width: 0; }
        .filter-actions { display: flex; gap: 6px; flex-shrink: 0; align-items: center; }
    </style>
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/teacher_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="includes/teacher_header.jsp" />

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
                <h3 class="fw-bold mb-0">Defaulter List</h3>
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
                        <div class="modal-footer border-0 bg-light">
                            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancel</button>
                            <form action="publishDefaulters" method="post" class="m-0">
                                <input type="hidden" name="context" value="teacher">
                                <input type="hidden" name="threshold" value="<%= currentThreshold %>">
                                <input type="hidden" name="startDate" value="<%= startDate %>">
                                <input type="hidden" name="endDate" value="<%= endDate %>">
                                <button type="submit" class="btn btn-warning fw-bold px-4">Publish & Notify</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filters -->
            <div class="card p-4 border-0 shadow-sm mb-4 d-print-none" style="border-radius: var(--card-radius);">
                <form action="teacherDefaulterList" method="get">
                <div class="filter-row">
                    <!-- Search -->
                    <div class="filter-group" style="flex: 0 0 220px;">
                        <label>Search Student</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" id="searchInput" class="form-control border-start-0" placeholder="Search...">
                        </div>
                    </div>
                    <!-- Subject Filter -->
                    <div class="filter-group" style="flex: 0 0 200px;">
                        <label>Filter by Subject</label>
                        <select id="subjectFilter" class="form-select">
                            <option value="">-- All Subjects --</option>
                            <% for (String subStr : uniqueSubjects) { %>
                                <option value="<%= subStr %>"><%= subStr %></option>
                            <% } %>
                        </select>
                    </div>
                    <!-- Threshold -->
                    <div class="filter-group" style="flex: 0 0 110px;">
                        <label>Threshold</label>
                        <div class="input-group">
                            <input type="number" name="threshold" class="form-control text-center" value="<%= currentThreshold %>" min="1" max="100" step="1">
                            <span class="input-group-text">%</span>
                        </div>
                    </div>
                    <!-- Date Range + Actions -->
                    <div class="filter-group" style="flex: 1; min-width: 280px;">
                        <label>Timespan</label>
                        <div style="display:flex; gap:6px; align-items:center; flex-wrap:nowrap;">
                            <input type="date" name="startDate" class="form-control" value="<%= startDate %>" style="flex:1; min-width:0;">
                            <span class="text-muted fw-semibold">to</span>
                            <input type="date" name="endDate" class="form-control" value="<%= endDate %>" style="flex:1; min-width:0;">
                            <button type="submit" class="btn btn-primary px-3" style="white-space:nowrap; flex-shrink:0;">Apply</button>
                            <a href="teacherDefaulterList?threshold=75&startDate=&endDate=" class="btn btn-outline-secondary" style="flex-shrink:0;" title="Reset"><i class="bi bi-arrow-clockwise"></i></a>
                        </div>
                    </div>
                </div>
                </form>
            </div>

            <!-- Table of Defaulters -->
            <div class="card border-0 shadow-sm custom-table">
                <div class="card-header bg-white border-0 pt-4 pb-0">
                    <h5 class="fw-bold mb-0">Attendance Defaulters (Below <%= currentThreshold %>%)</h5>
                    <p class="text-muted small mb-0">List of students currently failing to maintain minimum attendance criteria in your subjects.</p>
                </div>
                <div class="card-body mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="defaulterTable">
                            <thead>
                                <tr>
                                    <th>Roll No</th>
                                    <th>Student Name</th>
                                    <th>Section</th>
                                    <th>Subject</th>
                                    <th class="text-center">Classes</th>
                                    <th class="text-center">Attended</th>
                                    <th class="text-center">Percentage</th>
                                    <th style="width: 20%;">Progress</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (defaulters != null && !defaulters.isEmpty()) {
                                    for (DefaulterRecord r : defaulters) { 
                                        String subjectDisplay = r.getSubjectCode() + " - " + r.getSubjectName();
                                        String pctColor = r.getPercentage() < currentThreshold ? "text-danger fw-bold" : "text-warning fw-bold";
                                        String barClass = r.getPercentage() < currentThreshold ? "progress-bar-critical" : "progress-bar-warning-zone";
                                %>
                                    <tr class="defaulter-row" data-subject="<%= subjectDisplay %>" data-percentage="<%= r.getPercentage() %>">
                                        <td class="fw-bold"><%= r.getStudentRollNo() %></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="https://ui-avatars.com/api/?name=<%= r.getStudentName() %>&background=ffebeb&color=dc3545&bold=true" 
                                                     style="width: 32px; height: 32px; border-radius: 50%;">
                                                <span class="fw-semibold search-name"><%= r.getStudentName() %></span>
                                            </div>
                                        </td>
                                        <td><span class="badge bg-light text-dark border"><%= r.getStudentSection() != null && !r.getStudentSection().isEmpty() ? r.getStudentSection() : "All" %></span></td>
                                        <td><span class="small fw-semibold text-muted"><%= subjectDisplay %></span></td>
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
                                        <td colspan="8" class="text-center text-muted py-4">No defaulters found under your assigned subjects! Everyone is above <%= currentThreshold %>%.</td>
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
            const subjectFilter = document.getElementById("subjectFilter");
            const criticalFilter = document.getElementById("criticalFilter");
            const rows = document.querySelectorAll(".defaulter-row");

            function filterTable() {
                const query = searchInput.value.toLowerCase().trim();
                const selectedSubject = subjectFilter.value;

                rows.forEach(row => {
                    const rollNo = row.cells[0].innerText.toLowerCase();
                    const name = row.querySelector(".search-name").innerText.toLowerCase();
                    const subject = row.getAttribute("data-subject");

                    const matchesSearch = rollNo.includes(query) || name.includes(query);
                    const matchesSubject = !selectedSubject || subject === selectedSubject;

                    if (matchesSearch && matchesSubject) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            }

            if(searchInput) searchInput.addEventListener("input", filterTable);
            if(subjectFilter) subjectFilter.addEventListener("change", filterTable);
        });
    </script>
</body>
</html>
