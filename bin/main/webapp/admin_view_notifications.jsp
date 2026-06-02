<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%@ page import="com.college.attendance.model.Notification" %>
<%@ page import="com.college.attendance.dao.NotificationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("user");
    if (currentAdmin == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }

    NotificationDAO notifDAO = new NotificationDAO();
    List<Notification> notifications = notifDAO.getNotificationsForUser(currentAdmin.getId(), "Admin");
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    // Mark as read mechanism if ID passed
    String markRead = request.getParameter("markRead");
    if (markRead != null && !markRead.isEmpty()) {
        try {
            notifDAO.markAsRead(Integer.parseInt(markRead), currentAdmin.getId(), "Admin");
            response.sendRedirect("admin_view_notifications.jsp");
            return;
        } catch(Exception e){}
    }

    // Clear all mechanism
    String clearAll = request.getParameter("clearAll");
    if ("true".equals(clearAll)) {
        try {
            notifDAO.deleteAllNotificationsForUser(currentAdmin.getId(), "Admin");
            response.sendRedirect("admin_view_notifications.jsp");
            return;
        } catch(Exception e){}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Notifications – CAS Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="css/theme.css" rel="stylesheet">
</head>
<body class="dashboard-body">

    <jsp:include page="includes/admin_sidebar.jsp" />

    <div id="content-wrapper">
        <jsp:include page="includes/admin_header.jsp" />

        <main class="container-fluid p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="fw-bold mb-0">System Notifications</h2>
                <% if (notifications != null && !notifications.isEmpty()) { %>
                    <a href="admin_view_notifications.jsp?clearAll=true" class="btn btn-outline-danger btn-sm" onclick="return confirm('Are you sure you want to clear all notifications?');">
                        <i class="bi bi-trash3"></i> Clear All
                    </a>
                <% } %>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card shadow-sm border-0">
                        <div class="card-body p-0">
                            <div class="list-group list-group-flush">
                                <% if (notifications != null && !notifications.isEmpty()) {
                                    for (Notification n : notifications) { %>
                                    <div class="list-group-item p-4 <%= !n.isRead() ? "bg-light" : "" %>">
                                        <div class="d-flex w-100 justify-content-between align-items-start">
                                            <div class="me-3">
                                                <div class="icon-circle <%= !n.isRead() ? "bg-primary text-white" : "bg-secondary text-white opacity-50" %>" style="width:40px; height:40px; border-radius:50%; display:flex; align-items:center; justify-content:center;">
                                                    <i class="bi bi-bell-fill"></i>
                                                </div>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="d-flex w-100 justify-content-between">
                                                    <h6 class="mb-1 fw-bold <%= !n.isRead() ? "text-dark" : "text-muted" %>"><%= n.getTitle() %></h6>
                                                    <small class="text-muted"><%= sdf.format(n.getCreatedAt()) %></small>
                                                </div>
                                                <p class="mb-1 <%= !n.isRead() ? "text-dark" : "text-muted" %>"><%= n.getMessage() %></p>
                                                <small class="text-muted">From: <%= n.getSenderName() %> (<%= n.getSenderRole() %>)</small>
                                                <% if (n.getAttachmentPath() != null && !n.getAttachmentPath().isEmpty()) { %>
                                                    <div class="mt-2">
                                                        <a href="<%= request.getContextPath() %>/<%= n.getAttachmentPath() %>" target="_blank" class="btn btn-sm btn-outline-secondary">
                                                            <i class="bi bi-paperclip me-1"></i>View Attachment
                                                        </a>
                                                    </div>
                                                <% } %>
                                            </div>
                                            <% if (!n.isRead()) { %>
                                                <a href="admin_view_notifications.jsp?markRead=<%= n.getId() %>" class="btn btn-sm btn-light ms-3" title="Mark as Read">
                                                    <i class="bi bi-check2-all text-primary"></i>
                                                </a>
                                            <% } %>
                                        </div>
                                    </div>
                                <% } } else { %>
                                    <div class="p-5 text-center text-muted">
                                        <i class="bi bi-bell-slash display-4 mb-3 d-block"></i>
                                        <h5>No Notifications</h5>
                                        <p>You're all caught up!</p>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
