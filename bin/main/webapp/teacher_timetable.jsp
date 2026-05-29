<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.Timetable" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp?msg=Please login first.");
        return;
    }
    List<Timetable> teacherTimetable = (List<Timetable>) request.getAttribute("teacherTimetable");
    String[] DAYS = {"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
    SimpleDateFormat tf = new SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Class Routine</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=3" rel="stylesheet">
    <style>
        /* ── Day grid ── */
        .day-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; }
        .day-col { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); overflow: hidden; box-shadow: var(--shadow-card); }
        .day-col-header { padding: 12px 16px; background: linear-gradient(135deg, #1e3a5f, #0f2240); display: flex; align-items: center; justify-content: space-between; }
        .day-col-header span { color: #fff; font-weight: 700; font-size: .9rem; }
        .day-slots { padding: 10px; }
        
        /* ── Slot Item ── */
        .slot-item { background: var(--bg-input); border: 1px solid var(--border); border-radius: var(--radius-md); padding: 12px 14px; margin-bottom: 8px; display: flex; flex-direction: column; gap: 4px; transition: transform 0.2s, box-shadow 0.2s; }
        .slot-item:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(15,34,64,0.08); }
        .slot-item:last-child { margin-bottom: 0; }
        
        .slot-subject { font-weight: 700; font-size: 0.95rem; color: var(--text-heading); display: flex; justify-content: space-between; align-items: flex-start;}
        .slot-time { font-size: 0.8rem; color: #16a34a; font-weight: 600; margin-top: 2px;}
        
        .slot-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
        .tag { display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 50px; font-size: 0.7rem; font-weight: 600; }
        .tag-dept { background: rgba(30,58,95,0.08); color: var(--primary); }
        .tag-year { background: rgba(79,156,249,0.12); color: #2563eb; }
        .tag-sec { background: rgba(20,184,166,0.10); color: #0d9488; }
        .tag-room { background: rgba(245,158,11,0.10); color: #d97706; }

        .no-slots { text-align: center; padding: 30px 20px; color: var(--text-muted); font-size: 0.85rem; }
        .no-slots i { font-size: 2rem; display: block; margin-bottom: 8px; opacity: 0.4; }
        
        /* ── Header summary ── */
        .routine-summary { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 20px 24px; margin-bottom: 24px; box-shadow: var(--shadow-card); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; }
        .summary-info h5 { margin: 0; font-weight: 700; color: var(--text-heading); }
        .summary-info p { margin: 4px 0 0; color: var(--text-muted); font-size: 0.85rem; }
        .summary-stats { display: flex; gap: 12px; }
        .stat-badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; background: rgba(79,156,249,.12); color: #2563eb; border-radius: 50px; font-size: 0.85rem; font-weight: 600; }
    </style>
</head>
<body>
    <jsp:include page="includes/teacher_sidebar.jsp" />
    <div id="content-wrapper">
        <jsp:include page="includes/teacher_header.jsp" />
        <div class="container-fluid p-0">

            <!-- Page Title -->
            <div class="page-title-row">
                <div>
                    <h1 class="page-title"><i class="bi bi-clock-history me-2 text-primary"></i>My Class Routine</h1>
                    <p class="page-subtitle">Your weekly schedule grouped by day, time, and class</p>
                </div>
            </div>

            <!-- Routine Summary -->
            <div class="routine-summary">
                <div class="summary-info">
                    <h5><i class="bi bi-person-workspace me-2"></i><%= teacher.getName() %>'s Schedule</h5>
                    <p>Department of <%= teacher.getDepartment() %></p>
                </div>
                <div class="summary-stats">
                    <span class="stat-badge"><i class="bi bi-calendar-event"></i> <%= teacherTimetable != null ? teacherTimetable.size() : 0 %> Total Classes</span>
                </div>
            </div>

            <!-- Day Grid -->
            <div class="day-grid">
              <% for(String day : DAYS) {
                   List<Timetable> daySlots = new ArrayList<>();
                   if(teacherTimetable != null) { 
                       for(Timetable t : teacherTimetable) { 
                           if(day.equals(t.getDayOfWeek())) daySlots.add(t); 
                       }
                   }
                   daySlots.sort((a,b) -> { 
                       if(a.getStartTime() == null) return 1; 
                       if(b.getStartTime() == null) return -1; 
                       return a.getStartTime().compareTo(b.getStartTime()); 
                   });
              %>
              <div class="day-col">
                <div class="day-col-header">
                  <span><i class="bi bi-calendar-day me-2"></i><%= day %></span>
                  <span style="font-size: 0.75rem; color: rgba(255,255,255,0.7);"><%= daySlots.size() %> class<%= daySlots.size() == 1 ? "" : "es" %></span>
                </div>
                <div class="day-slots">
                  <% if(daySlots.isEmpty()) { %>
                    <div class="no-slots">
                        <i class="bi bi-cup-hot"></i>
                        No classes scheduled
                    </div>
                  <% } else { for(Timetable t : daySlots) { %>
                    <div class="slot-item">
                      <div class="slot-subject">
                          <span><%= t.getSubjectName() != null ? t.getSubjectName() : "Unknown Subject" %></span>
                          <% if(t.getSubjectCode() != null && !t.getSubjectCode().isEmpty()) { %>
                              <span style="font-size: 0.7rem; font-weight: 500; color: var(--text-muted); background: var(--border); padding: 1px 6px; border-radius: 4px;"><%= t.getSubjectCode() %></span>
                          <% } %>
                      </div>
                      <div class="slot-time"><i class="bi bi-clock me-1"></i><%= t.getStartTime() != null ? tf.format(t.getStartTime()) : "?" %> – <%= t.getEndTime() != null ? tf.format(t.getEndTime()) : "?" %></div>
                      
                      <div class="slot-tags">
                          <% if(t.getDepartment() != null && !t.getDepartment().isEmpty()) { %>
                              <span class="tag tag-dept"><i class="bi bi-building"></i><%= t.getDepartment() %></span>
                          <% } %>
                          <% if(t.getYear() > 0) { %>
                              <span class="tag tag-year"><i class="bi bi-mortarboard"></i>Year <%= t.getYear() %></span>
                          <% } %>
                          <% if(t.getSection() != null && !t.getSection().isEmpty()) { %>
                              <span class="tag tag-sec"><i class="bi bi-grid-3x3-gap"></i>Sec <%= t.getSection() %></span>
                          <% } %>
                          <% if(t.getRoomNo() != null && !t.getRoomNo().isEmpty()) { %>
                              <span class="tag tag-room"><i class="bi bi-door-open"></i>Room <%= t.getRoomNo() %></span>
                          <% } %>
                      </div>
                    </div>
                  <% }} %>
                </div>
              </div>
              <% } %>
            </div>

        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
