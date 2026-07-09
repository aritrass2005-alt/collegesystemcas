<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <title>Parent Alerts - Coming Soon - CAS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        .coming-soon-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: calc(100vh - 120px);
            padding: 2rem;
        }
        .coming-soon-card {
            text-align: center;
            max-width: 520px;
            padding: 3rem 2.5rem;
            border-radius: 20px;
            background: linear-gradient(135deg, #ffffff 0%, #f8faff 100%);
            border: 1px solid rgba(30, 58, 95, 0.08);
            box-shadow: 0 8px 40px rgba(30, 58, 95, 0.08);
            position: relative;
            overflow: hidden;
        }
        .coming-soon-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #1e3a5f, #4f9cf9, #1e3a5f);
            background-size: 200% 100%;
            animation: shimmer 3s ease-in-out infinite;
        }
        @keyframes shimmer {
            0%, 100% { background-position: 200% 0; }
            50% { background-position: -200% 0; }
        }
        .coming-soon-icon {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: linear-gradient(135deg, #e3f0ff 0%, #d0e4ff 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2.2rem;
            color: #1e3a5f;
            animation: pulse-icon 2.5s ease-in-out infinite;
        }
        @keyframes pulse-icon {
            0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(79, 156, 249, 0.2); }
            50% { transform: scale(1.05); box-shadow: 0 0 0 15px rgba(79, 156, 249, 0); }
        }
        .coming-soon-title {
            font-size: 1.6rem;
            font-weight: 700;
            color: #1e3a5f;
            margin-bottom: 0.75rem;
        }
        .coming-soon-desc {
            color: #6c7a8d;
            font-size: 0.95rem;
            line-height: 1.7;
            margin-bottom: 1.5rem;
        }
        .feature-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            justify-content: center;
            margin-bottom: 1.5rem;
        }
        .feature-chip {
            background: rgba(79, 156, 249, 0.08);
            border: 1px solid rgba(79, 156, 249, 0.15);
            color: #1e3a5f;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .coming-soon-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: linear-gradient(135deg, #fff3cd 0%, #ffeeba 100%);
            color: #856404;
            border: 1px solid #ffc107;
            padding: 8px 18px;
            border-radius: 25px;
            font-size: 0.8rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            text-transform: uppercase;
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

        <div class="coming-soon-wrapper">
            <div class="coming-soon-card">
                <div class="coming-soon-icon">
                    <i class="bi bi-send-exclamation"></i>
                </div>
                <h2 class="coming-soon-title">Parent Alerts & Notifications</h2>
                <p class="coming-soon-desc">
                    We're building an integrated parent notification system that will allow teachers and coordinators to 
                    send automated email and SMS alerts to parents regarding student attendance and academic progress.
                </p>
                <div class="feature-chips">
                    <span class="feature-chip"><i class="bi bi-envelope-fill"></i> Email Alerts</span>
                    <span class="feature-chip"><i class="bi bi-chat-text-fill"></i> SMS Notifications</span>
                    <span class="feature-chip"><i class="bi bi-graph-down-arrow"></i> Low Attendance Warnings</span>
                    <span class="feature-chip"><i class="bi bi-clock-history"></i> Alert History & Logs</span>
                </div>
                <div class="coming-soon-badge">
                    <i class="bi bi-hourglass-split"></i>
                    Coming Soon
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
