<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.ParentAlertLog" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    boolean isCoordinator = session.getAttribute("isCoordinator") != null && (Boolean) session.getAttribute("isCoordinator");
    
    if (!"Admin".equals(role) && !"SuperAdmin".equals(role) && !"Teacher".equals(role)) {
        response.sendRedirect("login.jsp?msg=Unauthorized Access");
        return;
    }
    
    List<ParentAlertLog> logs = (List<ParentAlertLog>) request.getAttribute("logs");
    SimpleDateFormat df = new SimpleDateFormat("MMM dd, yyyy hh:mm a");

    // Dynamic layout styles to match different sidebar structures
    String wrapperId = "content-wrapper";
    String wrapperStyle = "";
    if ("Teacher".equals(role) && isCoordinator) {
        wrapperId = "main-content";
        wrapperStyle = "margin-left:260px; min-height:100vh; background:#f0f2f8;";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Parent Notification Logs - CAS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .badge-email { background-color: #e3f2fd; color: #0d47a1; border: 1px solid #bbdefb; }
        .badge-sms { background-color: #fff3e0; color: #e65100; border: 1px solid #ffe0b2; }
        .badge-both { background-color: #f3e5f5; color: #4a148c; border: 1px solid #e1bee7; }
        .badge-sent { background-color: #e8f5e9; color: #1b5e20; border: 1px solid #c8e6c9; }
        .badge-failed { background-color: #ffebee; color: #b71c1c; border: 1px solid #ffcdd2; }
        .hover-tr:hover { background-color: rgba(30, 58, 95, 0.02) !important; transition: background-color 0.2s ease; }
        .message-preview {
            max-width: 250px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            font-size: 0.85rem;
        }
        .message-textarea {
            font-family: 'Courier New', Courier, monospace;
            font-size: 0.85rem;
            background-color: #f8f9fa;
            border-radius: 6px;
            padding: 12px;
            border: 1px solid #dee2e6;
            white-space: pre-wrap;
            word-break: break-word;
            max-height: 400px;
            overflow-y: auto;
        }
    </style>
</head>
<body>

    <!-- Sidebar Includes -->
    <% 
        if ("Admin".equals(role) || "SuperAdmin".equals(role)) {
    %>
            <jsp:include page="includes/admin_sidebar.jsp" />
    <%
        } else if ("Teacher".equals(role)) {
            if (isCoordinator) {
    %>
                <jsp:include page="includes/coordinator_sidebar.jsp" />
    <%
            } else {
    %>
                <jsp:include page="includes/teacher_sidebar.jsp" />
    <%
            }
        }
    %>

    <!-- Main Content Wrapper -->
    <div id="<%= wrapperId %>" style="<%= wrapperStyle %>">
        
        <!-- Header Includes -->
        <% 
            if ("Admin".equals(role) || "SuperAdmin".equals(role)) {
        %>
                <jsp:include page="includes/admin_header.jsp" />
        <%
            } else if ("Teacher".equals(role)) {
                if (isCoordinator) {
        %>
                    <jsp:include page="includes/coordinator_header.jsp" />
        <%
                } else {
        %>
                    <jsp:include page="includes/teacher_header.jsp" />
        <%
                }
            }
        %>

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1">Parent Alerts &amp; Notifications</h3>
                    <p class="text-muted small mb-0">Audit history of simulated Email and SMS warnings dispatched to parents for low attendance.</p>
                </div>
            </div>

            <!-- Filters & Search -->
            <div class="card p-4 border-0 shadow-sm mb-4" style="border-radius: var(--card-radius);">
                <div class="row g-3">
                    <div class="col-md-5">
                        <label class="form-label text-muted small fw-bold">Search Students or Contacts</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" id="searchInput" class="form-control border-start-0" placeholder="Search roll no, name, email or phone...">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label text-muted small fw-bold">Filter Alert Type</label>
                        <select id="typeFilter" class="form-select">
                            <option value="">All Channels</option>
                            <option value="EMAIL">Email Only</option>
                            <option value="SMS">SMS Only</option>
                            <option value="BOTH">Both Email &amp; SMS</option>
                        </select>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="button" onclick="resetFilters()" class="btn btn-outline-secondary w-100"><i class="bi bi-arrow-clockwise me-1"></i>Reset Filters</button>
                    </div>
                </div>
            </div>

            <!-- Logs List -->
            <div class="card custom-table border-0 shadow-sm">
                <div class="card-header bg-white border-0 pt-4 pb-0">
                    <h5 class="fw-bold mb-0">Dispatched Notification Log</h5>
                </div>
                <div class="card-body mt-3">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" id="logsTable">
                            <thead>
                                <tr>
                                    <th>Dispatched Time</th>
                                    <th>Student Name (Roll)</th>
                                    <th>Parent Contact Details</th>
                                    <th class="text-center">Channel</th>
                                    <th>Sent By</th>
                                    <th class="text-center">Status</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (logs != null && !logs.isEmpty()) {
                                    for (ParentAlertLog log : logs) {
                                %>
                                    <tr class="hover-tr log-row" data-type="<%= log.getAlertType() %>">
                                        <td class="text-nowrap small text-muted"><%= df.format(log.getSentAt()) %></td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <img src="https://ui-avatars.com/api/?name=<%= log.getStudentName() %>&background=e3f2fd&color=0d47a1&bold=true" 
                                                     style="width: 32px; height: 32px; border-radius: 50%;">
                                                <div>
                                                    <span class="fw-semibold search-student-name d-block" style="font-size: 0.9rem;"><%= log.getStudentName() %></span>
                                                    <small class="text-muted search-roll"><%= log.getStudentRollNo() %></small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-size: 0.85rem;">
                                                <span class="fw-semibold text-dark search-parent-name"><%= log.getParentName() %></span>
                                                <div class="text-muted small">
                                                    <% if (log.getParentEmail() != null && !log.getParentEmail().isEmpty()) { %>
                                                        <i class="bi bi-envelope me-1"></i><span class="search-parent-email"><%= log.getParentEmail() %></span><br>
                                                    <% } %>
                                                    <% if (log.getParentPhone() != null && !log.getParentPhone().isEmpty()) { %>
                                                        <i class="bi bi-telephone me-1"></i><span class="search-parent-phone"><%= log.getParentPhone() %></span>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <% if ("EMAIL".equals(log.getAlertType())) { %>
                                                <span class="badge badge-email"><i class="bi bi-envelope-fill me-1"></i>EMAIL</span>
                                            <% } else if ("SMS".equals(log.getAlertType())) { %>
                                                <span class="badge badge-sms"><i class="bi bi-chat-text-fill me-1"></i>SMS</span>
                                            <% } else { %>
                                                <span class="badge badge-both"><i class="bi bi-phone-fill me-1"></i>BOTH</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="fw-semibold text-dark d-block" style="font-size: 0.85rem;"><%= log.getSenderName() %></span>
                                            <small class="badge bg-light text-secondary border small-text"><%= log.getSenderRole() %></small>
                                        </td>
                                        <td class="text-center">
                                            <% if ("SENT".equals(log.getStatus())) { %>
                                                <span class="badge badge-sent"><i class="bi bi-check-circle-fill me-1"></i>SENT</span>
                                            <% } else { %>
                                                <span class="badge badge-failed"><i class="bi bi-exclamation-triangle-fill me-1"></i>FAILED</span>
                                            <% } %>
                                        </td>
                                        <td class="text-center">
                                            <button type="button" class="btn btn-sm btn-outline-primary fw-semibold" 
                                                    onclick='previewMessage(<%= new com.google.gson.Gson().toJson(log) %>)'>
                                                <i class="bi bi-eye"></i> View Alert
                                            </button>
                                        </td>
                                    </tr>
                                <% }
                                } else { %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">No parent alerts have been dispatched yet.</td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Alert Preview Modal -->
    <div class="modal fade" id="messageModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold"><i class="bi bi-envelope-paper me-2 text-primary"></i>Simulated Alert Content</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3 mb-3 text-muted small border-bottom pb-3">
                        <div class="col-md-6">
                            <strong>Student Name:</strong> <span id="modalStudentName" class="text-dark"></span><br>
                            <strong>Roll Number:</strong> <span id="modalRoll" class="text-dark"></span>
                        </div>
                        <div class="col-md-6">
                            <strong>Parent/Guardian:</strong> <span id="modalParentName" class="text-dark"></span><br>
                            <strong>Dispatched Channel:</strong> <span id="modalChannel" class="text-dark"></span>
                        </div>
                    </div>
                    
                    <h6 class="fw-bold text-dark mb-2">Message Body:</h6>
                    <div class="message-textarea" id="modalMessage"></div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-primary px-4 fw-semibold" data-bs-dismiss="modal">Close Preview</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const searchInput = document.getElementById("searchInput");
            const typeFilter = document.getElementById("typeFilter");
            const rows = document.querySelectorAll(".log-row");

            function filterTable() {
                const query = searchInput.value.toLowerCase().trim();
                const selectedType = typeFilter.value;

                rows.forEach(row => {
                    const studentName = row.querySelector(".search-student-name").innerText.toLowerCase();
                    const roll = row.querySelector(".search-roll").innerText.toLowerCase();
                    const parentName = row.querySelector(".search-parent-name").innerText.toLowerCase();
                    
                    const parentEmailNode = row.querySelector(".search-parent-email");
                    const parentEmail = parentEmailNode ? parentEmailNode.innerText.toLowerCase() : "";
                    
                    const parentPhoneNode = row.querySelector(".search-parent-phone");
                    const parentPhone = parentPhoneNode ? parentPhoneNode.innerText.toLowerCase() : "";
                    
                    const type = row.getAttribute("data-type");

                    const matchesSearch = studentName.includes(query) || 
                                          roll.includes(query) || 
                                          parentName.includes(query) || 
                                          parentEmail.includes(query) || 
                                          parentPhone.includes(query);
                                          
                    const matchesType = !selectedType || type === selectedType || (selectedType === "EMAIL" && type === "BOTH") || (selectedType === "SMS" && type === "BOTH");

                    if (matchesSearch && matchesType) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            }

            if(searchInput) searchInput.addEventListener("input", filterTable);
            if(typeFilter) typeFilter.addEventListener("change", filterTable);
        });

        function resetFilters() {
            document.getElementById("searchInput").value = "";
            document.getElementById("typeFilter").value = "";
            
            const rows = document.querySelectorAll(".log-row");
            rows.forEach(row => row.style.display = "");
        }

        function previewMessage(log) {
            document.getElementById("modalStudentName").innerText = log.studentName;
            document.getElementById("modalRoll").innerText = log.studentRollNo;
            document.getElementById("modalParentName").innerText = log.parentName;
            document.getElementById("modalChannel").innerText = log.alertType;
            document.getElementById("modalMessage").innerText = log.message;
            
            var modal = new bootstrap.Modal(document.getElementById('messageModal'));
            modal.show();
        }
    </script>
</body>
</html>
