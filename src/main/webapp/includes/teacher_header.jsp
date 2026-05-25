<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher currentTeacher = (Teacher) session.getAttribute("user");
    String teacherName = currentTeacher != null ? currentTeacher.getName() : "Faculty Member";
    String teacherDept = currentTeacher != null ? currentTeacher.getDepartment() : "Faculty";
    String teacherEmail = currentTeacher != null ? currentTeacher.getEmail() : "";
    String photoUrl = currentTeacher != null && currentTeacher.getProfilePhoto() != null && !currentTeacher.getProfilePhoto().isEmpty() && !"null".equals(currentTeacher.getProfilePhoto())
        ? currentTeacher.getProfilePhoto()
        : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(teacherName, "UTF-8") + "&background=1e3a5f&color=fff&bold=true";
%>
<header class="top-header">
    <div class="header-left">
        <button class="toggle-btn" id="sidebarToggle">
            <i class="bi bi-list"></i>
        </button>
        <div class="header-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" placeholder="Search students, subjects...">
        </div>
    </div>
    <div class="header-right">
        <!-- Coordinator switch button -->
        <% if (session.getAttribute("isCoordinator") != null && (Boolean) session.getAttribute("isCoordinator")) { %>
        <a href="coordinatorDashboard" class="switch-view-btn">
            <i class="bi bi-speedometer2"></i>
            <span class="d-none d-md-inline">Coordinator View</span>
        </a>
        <% } %>

        <!-- Datetime -->
        <div class="datetime-widget d-none d-lg-flex">
            <i class="bi bi-calendar3"></i> <span id="currentDate"></span>
            <i class="bi bi-clock ms-2"></i> <span id="currentTime"></span>
        </div>

        <!-- Profile -->
        <div style="position:relative;">
            <div class="profile-btn" id="profileBtn" onclick="toggleProfileMenu()">
                <img src="<%= photoUrl %>" alt="Profile Photo">
                <div class="d-none d-md-block" style="pointer-events:none;">
                    <div class="profile-name"><%= teacherName %></div>
                    <div class="profile-role"><%= teacherDept %></div>
                </div>
                <i class="bi bi-chevron-down" style="font-size:0.75rem; color:var(--text-muted); pointer-events:none;"></i>
            </div>
            <div id="profileMenu" class="profile-dropdown-menu">
                <div class="dropdown-header">
                    <div class="name"><%= teacherName %></div>
                    <div class="email"><%= teacherEmail %></div>
                </div>
                <a href="teacherProfile"><i class="bi bi-person-circle"></i> My Profile</a>
                <a href="logout" class="logout-item"><i class="bi bi-box-arrow-right"></i> Logout</a>
            </div>
        </div>
    </div>
</header>

<script>
function toggleProfileMenu() {
    document.getElementById('profileMenu').classList.toggle('open');
}

document.addEventListener('click', function(e) {
    var btn  = document.getElementById('profileBtn');
    var menu = document.getElementById('profileMenu');
    if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.remove('open');
    }
});

function updateDateTime() {
    var now = new Date();
    var dateEl = document.getElementById('currentDate');
    var timeEl = document.getElementById('currentTime');
    if (dateEl) dateEl.innerText = now.toLocaleDateString('en-US', { weekday:'short', year:'numeric', month:'short', day:'numeric' });
    if (timeEl) timeEl.innerText = now.toLocaleTimeString('en-US', { hour:'2-digit', minute:'2-digit', second:'2-digit' });
}
setInterval(updateDateTime, 1000);
updateDateTime();

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
