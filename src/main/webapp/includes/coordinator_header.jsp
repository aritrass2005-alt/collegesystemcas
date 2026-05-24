<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher coordTeacherHeader = (Teacher) session.getAttribute("user");
    String coordName  = coordTeacherHeader != null ? coordTeacherHeader.getName() : "Coordinator";
    String coordEmail = coordTeacherHeader != null ? coordTeacherHeader.getEmail() : "";
    String headerPhotoUrl = coordTeacherHeader != null && coordTeacherHeader.getProfilePhoto() != null && !coordTeacherHeader.getProfilePhoto().isEmpty() && !"null".equals(coordTeacherHeader.getProfilePhoto())
        ? coordTeacherHeader.getProfilePhoto()
        : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(coordName, "UTF-8") + "&background=1e3a5f&color=fff&bold=true";
%>
<header class="top-header">
    <div class="header-left">
        <button class="toggle-btn" id="coordSidebarToggle" onclick="toggleCoordSidebar()">
            <i class="bi bi-list"></i>
        </button>
        <div class="header-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" placeholder="Search students...">
        </div>
    </div>
    <div class="header-right">
        <div class="datetime-widget d-none d-lg-flex">
            <i class="bi bi-calendar3"></i> <span id="coordDate"></span>
            <i class="bi bi-clock ms-2"></i> <span id="coordTime"></span>
        </div>
        <!-- Profile -->
        <div style="position:relative;">
            <div class="profile-btn" id="coordProfileBtn" onclick="toggleCoordMenu()">
                <img src="<%= headerPhotoUrl %>" alt="Profile Photo">
                <div class="d-none d-md-block" style="pointer-events:none;">
                    <div class="profile-name"><%= coordName %></div>
                    <div class="profile-role">Coordinator</div>
                </div>
                <i class="bi bi-chevron-down" style="font-size:0.75rem; color:var(--text-muted); pointer-events:none;"></i>
            </div>
            <div id="coordProfileMenu" class="profile-dropdown-menu">
                <div class="dropdown-header">
                    <div class="name"><%= coordName %></div>
                    <div class="email"><%= coordEmail %></div>
                </div>
                <a href="teacherProfile"><i class="bi bi-person-circle"></i> My Profile</a>
                <a href="logout" class="logout-item"><i class="bi bi-box-arrow-right"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<script>
function toggleCoordSidebar() {
    var sidebar = document.getElementById('coord-sidebar');
    var wrapper = document.getElementById('content-wrapper');
    if (sidebar) sidebar.classList.toggle('open');
    if (wrapper) wrapper.classList.toggle('expanded');
}

function toggleCoordMenu() {
    document.getElementById('coordProfileMenu').classList.toggle('open');
}

document.addEventListener('click', function(e) {
    var btn  = document.getElementById('coordProfileBtn');
    var menu = document.getElementById('coordProfileMenu');
    if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.remove('open');
    }
});

function updateCoordDateTime() {
    var now = new Date();
    var d = document.getElementById('coordDate');
    var t = document.getElementById('coordTime');
    if (d) d.innerText = now.toLocaleDateString('en-US', { weekday:'short', year:'numeric', month:'short', day:'numeric' });
    if (t) t.innerText = now.toLocaleTimeString('en-US', { hour:'2-digit', minute:'2-digit', second:'2-digit' });
}
setInterval(updateCoordDateTime, 1000);
updateCoordDateTime();
</script>
