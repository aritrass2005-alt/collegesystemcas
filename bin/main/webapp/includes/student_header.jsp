<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Student" %>
<%@ page import="com.college.attendance.dao.NotificationDAO" %>
<%
    Student currentStudent = (Student) session.getAttribute("user");
    String studentName = currentStudent != null ? currentStudent.getName() : "Student";
    String photoUrl = currentStudent != null && currentStudent.getProfilePhoto() != null && !currentStudent.getProfilePhoto().isEmpty() && !"null".equals(currentStudent.getProfilePhoto())
        ? currentStudent.getProfilePhoto()
        : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(studentName, "UTF-8") + "&background=1e3a5f&color=fff&bold=true";
    
    int unreadNotifs = 0;
    if (currentStudent != null) {
        NotificationDAO nDao = new NotificationDAO();
        unreadNotifs = nDao.getUnreadCount(currentStudent.getId());
    }
%>
<header class="top-header">
    <div class="header-left d-flex align-items-center gap-3">
        <button type="button" id="sidebarCollapse" class="toggle-btn" onclick="toggleSidebar()">
            <i class="bi bi-list"></i>
        </button>
        <!-- Datetime -->
        <div class="datetime-widget d-none d-lg-flex m-0">
            <i class="bi bi-calendar3"></i> <span id="currentDate" class="ms-1"></span>
            <i class="bi bi-clock ms-3"></i> <span id="currentTime" class="ms-1"></span>
        </div>
    </div>
    <div class="header-right d-flex align-items-center gap-3">
        <!-- Notifications -->
        <a href="student_notifications.jsp" class="position-relative text-dark" style="text-decoration: none;">
            <i class="bi bi-bell fs-5 text-muted"></i>
            <% if (unreadNotifs > 0) { %>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 0.6rem;">
                <%= unreadNotifs %>
            </span>
            <% } %>
        </a>
        <!-- Profile -->
        <div style="position:relative;">
            <div class="profile-btn" id="profileBtn" onclick="toggleProfileMenu()">
                <img src="<%= photoUrl %>" alt="Profile Photo">
                <div class="d-none d-md-block">
                    <div class="profile-name"><%= studentName %></div>
                    <div class="profile-role">Student</div>
                </div>
                <i class="bi bi-chevron-down" style="font-size:0.75rem; color:var(--text-muted); pointer-events:none;"></i>
            </div>
            <div id="profileMenu" class="profile-dropdown-menu">
                <div class="dropdown-header">
                    <div class="name"><%= studentName %></div>
                    <div class="email"><%= currentStudent != null ? currentStudent.getRollNo() : "" %></div>
                </div>
                <a href="studentProfile"><i class="bi bi-person-circle"></i> My Profile</a>
                <a href="logout" class="logout-item"><i class="bi bi-box-arrow-right"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<script>
function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    const wrapper = document.getElementById('content-wrapper');
    if (sidebar) sidebar.classList.toggle('open');
    if (wrapper) wrapper.classList.toggle('expanded');
}

function toggleProfileMenu() {
    document.getElementById('profileMenu').classList.toggle('open');
}

document.addEventListener('click', function(e) {
    const btn  = document.getElementById('profileBtn');
    const menu = document.getElementById('profileMenu');
    if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.remove('open');
    }
});

function updateDateTime() {
    var now = new Date();
    var d = document.getElementById('currentDate');
    var t = document.getElementById('currentTime');
    if (d) d.innerText = now.toLocaleDateString('en-US', { weekday:'short', year:'numeric', month:'short', day:'numeric' });
    if (t) t.innerText = now.toLocaleTimeString('en-US', { hour:'2-digit', minute:'2-digit', second:'2-digit' });
}
setInterval(updateDateTime, 1000);
updateDateTime();
</script>
