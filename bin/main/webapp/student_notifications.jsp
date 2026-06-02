<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.model.Notification" %>
<%@ page import="com.college.attendance.dao.NotificationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Student currentStudent = (Student) session.getAttribute("user");
    if (currentStudent == null || !"Student".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    NotificationDAO notifDAO = new NotificationDAO();
    List<Notification> notifications = notifDAO.getNotificationsForUser(currentStudent.getId(), "Student");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    // Mark as read mechanism if ID passed
    String markRead = request.getParameter("readId");
    if (markRead != null && !markRead.isEmpty()) {
        try {
            notifDAO.markAsRead(Integer.parseInt(markRead), currentStudent.getId(), "Student");
            response.sendRedirect("student_notifications.jsp");
            return;
        } catch(Exception e){}
    }

    // Clear all mechanism
    String clearAll = request.getParameter("clearAll");
    if ("true".equals(clearAll)) {
        try {
            notifDAO.deleteAllNotificationsForUser(currentStudent.getId(), "Student");
            response.sendRedirect("student_notifications.jsp");
            return;
        } catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Notifications - CAS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
</head>
<body class="dashboard-body">
    
    <jsp:include page="includes/student_sidebar.jsp" />

    <div id="content-wrapper">
        <jsp:include page="includes/student_header.jsp" />

        <div class="container-fluid p-0">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Notifications</h3>
                <% if (notifications != null && !notifications.isEmpty()) { %>
                    <a href="student_notifications.jsp?clearAll=true" class="btn btn-outline-danger btn-sm" onclick="return confirm('Are you sure you want to clear all notifications?');">
                        <i class="bi bi-trash3"></i> Clear All
                    </a>
                <% } %>
            </div>

            <div class="row g-4">
                <div class="col-lg-8 mx-auto">
                    <% if (notifications == null || notifications.isEmpty()) { %>
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-bell-slash fs-1 d-block mb-3 opacity-50"></i>
                            <h5 class="fw-bold">No notifications yet</h5>
                            <p>You're all caught up!</p>
                        </div>
                    <% } else { %>
                        <div class="list-group list-group-flush border rounded-3 shadow-sm bg-white">
                            <% for (Notification n : notifications) { 
                                boolean isUnread = !n.isRead();
                            %>
                                <div class="list-group-item p-4 <%= isUnread ? "bg-light border-start border-4 border-primary" : "" %>" style="<%= isUnread ? "" : "border-left: 4px solid transparent;" %>">
                                    <div class="d-flex w-100 justify-content-between align-items-start">
                                        <div class="d-flex gap-3">
                                            <div class="rounded-circle d-flex align-items-center justify-content-center <%= "Admin".equals(n.getSenderRole()) ? "bg-danger text-white" : "bg-primary text-white" %>" style="width: 45px; height: 45px; flex-shrink:0;">
                                                <i class="bi <%= "Admin".equals(n.getSenderRole()) ? "bi-shield-lock-fill" : "bi-person-fill" %> fs-5"></i>
                                            </div>
                                            <div>
                                                <h6 class="mb-1 fw-bold <%= isUnread ? "text-dark" : "text-muted" %>"><%= n.getTitle() %></h6>
                                                <p class="mb-1 <%= isUnread ? "text-dark" : "text-muted" %>"><%= n.getMessage().replace("\n", "<br>") %></p>
                                                <% if (n.getAttachmentPath() != null && !n.getAttachmentPath().isEmpty()) { %>
                                                    <div class="mt-2">
                                                        <a href="<%= request.getContextPath() %>/<%= n.getAttachmentPath() %>" target="_blank" class="btn btn-sm btn-outline-primary rounded-pill">
                                                            <i class="bi bi-paperclip"></i> View Attachment
                                                        </a>
                                                    </div>
                                                <% } %>
                                                <small class="text-muted d-flex align-items-center gap-2 mt-2">
                                                    <i class="bi bi-clock"></i> <%= sdf.format(n.getCreatedAt()) %>
                                                    &bull; 
                                                    <span class="badge <%= "Admin".equals(n.getSenderRole()) ? "bg-danger bg-opacity-10 text-danger" : "bg-primary bg-opacity-10 text-primary" %> border-0">
                                                        Sent by <%= n.getSenderName() %> (<%= n.getSenderRole() %>)
                                                    </span>
                                                </small>
                                            </div>
                                        </div>
                                        <% if (isUnread) { %>
                                            <a href="student_notifications.jsp?readId=<%= n.getId() %>" class="btn btn-sm btn-outline-secondary rounded-pill flex-shrink-0">
                                                <i class="bi bi-check2-all me-1"></i>Mark Read
                                            </a>
                                        <% } %>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
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

