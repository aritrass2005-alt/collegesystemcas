<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Coordinator" %>
<%@ page import="com.college.attendance.dao.CoordinatorDAO" %>
<%@ page import="java.util.List" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role")) || !Boolean.TRUE.equals(session.getAttribute("isCoordinator"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    CoordinatorDAO coordinatorDAO = new CoordinatorDAO();
    List<Coordinator> assignments = coordinatorDAO.getCoordinatorAssignments(teacher.getId());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Send Notices - CAS Coordinator</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body>
    
    <!-- Sidebar Include -->
    <jsp:include page="includes/coordinator_sidebar.jsp" />

    <!-- Main Content -->
    <div id="content-wrapper">
        
        <!-- Header Include -->
        <jsp:include page="includes/coordinator_header.jsp" />

        <div class="container-fluid p-0">
            <h3 class="fw-bold mb-4">Send Notices</h3>
            
            <% if(request.getParameter("msg") != null) { %>
                <div class="alert alert-success alert-dismissible fade show shadow-sm border-0"><i class="bi bi-check-circle me-2"></i><%= request.getParameter("msg") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0"><i class="bi bi-exclamation-triangle me-2"></i><%= request.getParameter("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
            <% } %>

            <div class="card border-0 shadow-sm" style="border-radius: var(--card-radius);">
                <div class="card-header bg-white border-bottom p-4">
                    <h5 class="fw-bold mb-0 text-primary"><i class="bi bi-send-fill me-2"></i>Broadcast Message</h5>
                </div>
                <div class="card-body p-4">
                    <form action="sendNotification" method="post" id="notificationForm" enctype="multipart/form-data">
                        
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label fw-bold text-dark">Select Assigned Class</label>
                                <select class="form-select bg-light" name="classSelection" id="classSelection" required>
                                    <option value="" disabled selected>-- Choose a class --</option>
                                    <% for (Coordinator c : assignments) { 
                                        String val = c.getDepartment() + "|" + c.getYear() + "|" + (c.getSection() != null ? c.getSection() : "All");
                                        String label = c.getDepartment() + " - Year " + c.getYear() + (c.getSection() != null && !c.getSection().isEmpty() ? " (Sec " + c.getSection() + ")" : "");
                                    %>
                                        <option value="<%= val %>"><%= label %></option>
                                    <% } %>
                                </select>
                                <input type="hidden" name="department" id="hiddenDept">
                                <input type="hidden" name="year" id="hiddenYear">
                                <input type="hidden" name="section" id="hiddenSection">
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark d-block">Target Audience</label>
                            <div class="btn-group w-100" role="group">
                                <input type="radio" class="btn-check" name="targetType" id="targetAll" value="ALL" checked>
                                <label class="btn btn-outline-primary" for="targetAll"><i class="bi bi-people me-2"></i>All Students</label>
                                
                                <input type="radio" class="btn-check" name="targetType" id="targetDefaulters" value="DEFAULTERS">
                                <label class="btn btn-outline-danger" for="targetDefaulters"><i class="bi bi-exclamation-octagon me-2"></i>Only Defaulters</label>

                                <input type="radio" class="btn-check" name="targetType" id="targetSpecific" value="SPECIFIC">
                                <label class="btn btn-outline-secondary" for="targetSpecific"><i class="bi bi-person me-2"></i>Specific Student</label>
                            </div>
                        </div>

                        <div class="mb-4 d-none" id="thresholdDiv">
                            <label class="form-label fw-bold text-dark">Defaulter Threshold (%)</label>
                            <input type="number" step="0.1" class="form-control bg-light" name="defaulterThreshold" id="defaulterThreshold" value="75" placeholder="e.g. 75">
                        </div>

                        <div class="mb-4 d-none" id="specificStudentDiv">
                            <label class="form-label fw-bold text-dark">Student ID / Roll No</label>
                            <input type="number" class="form-control bg-light" name="studentId" placeholder="Enter precise Student DB ID (will be improved to dropdown later)">
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-bold text-dark">Notification Title</label>
                            <input type="text" class="form-control bg-light" name="title" required placeholder="e.g. Warning: Low Attendance">
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark">Message content</label>
                            <textarea class="form-control bg-light" name="message" rows="4" required placeholder="Type your message here..."></textarea>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark"><i class="bi bi-paperclip me-1"></i>Attach Document (Optional)</label>
                            <input type="file" class="form-control bg-light" name="attachment">
                            <div class="form-text">Supported formats: PDF, Images, Word (Max 10MB)</div>
                        </div>

                        <button type="submit" class="btn btn-primary px-5 fw-bold" style="border-radius: 8px;"><i class="bi bi-send me-2"></i>Send Notice</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('classSelection').addEventListener('change', function() {
            let parts = this.value.split('|');
            document.getElementById('hiddenDept').value = parts[0];
            document.getElementById('hiddenYear').value = parts[1];
            document.getElementById('hiddenSection').value = parts[2] === 'All' ? '' : parts[2];
        });

        const radios = document.querySelectorAll('input[name="targetType"]');
        const specificDiv = document.getElementById('specificStudentDiv');
        const thresholdDiv = document.getElementById('thresholdDiv');

        radios.forEach(radio => {
            radio.addEventListener('change', function() {
                if(this.value === 'SPECIFIC') {
                    specificDiv.classList.remove('d-none');
                    specificDiv.querySelector('input').required = true;
                    thresholdDiv.classList.add('d-none');
                    document.getElementById('defaulterThreshold').required = false;
                } else if(this.value === 'DEFAULTERS') {
                    specificDiv.classList.add('d-none');
                    specificDiv.querySelector('input').required = false;
                    thresholdDiv.classList.remove('d-none');
                    document.getElementById('defaulterThreshold').required = true;
                } else {
                    specificDiv.classList.add('d-none');
                    specificDiv.querySelector('input').required = false;
                    thresholdDiv.classList.add('d-none');
                    document.getElementById('defaulterThreshold').required = false;
                }
            });
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

