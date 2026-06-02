<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher coordTeacherHeader = (Teacher) session.getAttribute("user");
    String coordName  = coordTeacherHeader != null ? coordTeacherHeader.getName() : "Coordinator";
    String coordEmail = coordTeacherHeader != null ? coordTeacherHeader.getEmail() : "";
    String headerPhotoUrl = coordTeacherHeader != null && coordTeacherHeader.getProfilePhoto() != null && !coordTeacherHeader.getProfilePhoto().isEmpty() && !"null".equals(coordTeacherHeader.getProfilePhoto())
        ? coordTeacherHeader.getProfilePhoto()
        : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(coordName, "UTF-8") + "&background=1e3a5f&color=fff&bold=true";
        
    int unreadNotifs = 0;
    if (coordTeacherHeader != null) {
        com.college.attendance.dao.NotificationDAO nDao = new com.college.attendance.dao.NotificationDAO();
        unreadNotifs = nDao.getUnreadCount(coordTeacherHeader.getId(), "Teacher");
    }
%>
<header class="top-header">
    <div class="header-left d-flex align-items-center gap-3">
        <button class="toggle-btn" id="coordSidebarToggle" onclick="toggleCoordSidebar()">
            <i class="bi bi-list"></i>
        </button>
        <!-- Datetime -->
        <div class="datetime-widget d-none d-lg-flex m-0">
            <i class="bi bi-calendar3"></i> <span id="coordDate" class="ms-1"></span>
            <i class="bi bi-clock ms-3"></i> <span id="coordTime" class="ms-1"></span>
        </div>
    </div>
    <div class="header-right d-flex align-items-center gap-3">
        <!-- Notifications -->
        <a href="teacher_view_notifications.jsp?view=coordinator" class="position-relative text-dark" style="text-decoration: none;">
            <i class="bi bi-bell fs-5 text-muted"></i>
            <% if (unreadNotifs > 0) { %>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size: 0.6rem;">
                <%= unreadNotifs %>
            </span>
            <% } %>
        </a>
        <!-- Profile -->
        <div style="position:relative;">
            <div class="profile-btn" id="coordProfileBtn" onclick="toggleCoordMenu()">
                <img src="<%= headerPhotoUrl %>" alt="Profile Photo" onerror="this.onerror=null; this.src='https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(coordName, "UTF-8") %>&background=1e3a5f&color=fff&bold=true';">
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

// Universal Search Filter (Event Delegation for reliability)
document.addEventListener("input", function(e) {
    if (e.target && e.target.matches(".header-search input")) {
        var val = e.target.value.toLowerCase().trim();
        
        // Filter Tables
        var tableRows = document.querySelectorAll("table tbody tr");
        tableRows.forEach(function(row) {
            var text = (row.textContent || row.innerText || "").toLowerCase();
            // skip empty state rows
            if (text.indexOf('no data') > -1 || (text.indexOf('no ') > -1 && row.cells && row.cells.length === 1)) return;
            
            if (text.indexOf(val) > -1) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });

        // Filter Cards
        var cards = document.querySelectorAll(".subject-card, .slot-item, .card-item, .user-card");
        cards.forEach(function(card) {
            var text = (card.textContent || card.innerText || "").toLowerCase();
            if (text.indexOf(val) > -1) {
                card.style.display = "";
            } else {
                card.style.display = "none";
            }
        });
    }
});
</script>
