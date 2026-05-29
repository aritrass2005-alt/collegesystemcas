<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%@ page import="com.college.attendance.model.FacultyAttendance" %>
<%@ page import="com.college.attendance.dao.FacultyAttendanceDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Teacher currentTeacher = (Teacher) session.getAttribute("user");
    boolean isCheckedIn = false;
    boolean isCheckedOut = false;
    String checkInTimeStr = "";
    if (currentTeacher != null) {
        FacultyAttendanceDAO fDao = new FacultyAttendanceDAO();
        FacultyAttendance myTodayAttendance = fDao.getTodayAttendance(currentTeacher.getId());
        isCheckedIn = (myTodayAttendance != null && myTodayAttendance.getCheckInTime() != null);
        isCheckedOut = (myTodayAttendance != null && myTodayAttendance.getCheckOutTime() != null);
        if (isCheckedIn) {
            checkInTimeStr = new SimpleDateFormat("hh:mm a").format(myTodayAttendance.getCheckInTime());
        }
    }
    String teacherName = currentTeacher != null ? currentTeacher.getName() : "Faculty Member";
    String teacherDept = currentTeacher != null ? currentTeacher.getDepartment() : "Faculty";
    String teacherEmail = currentTeacher != null ? currentTeacher.getEmail() : "";
    String photoUrl = currentTeacher != null && currentTeacher.getProfilePhoto() != null && !currentTeacher.getProfilePhoto().isEmpty() && !"null".equals(currentTeacher.getProfilePhoto())
        ? currentTeacher.getProfilePhoto()
        : "https://ui-avatars.com/api/?name=" + java.net.URLEncoder.encode(teacherName, "UTF-8") + "&background=1e3a5f&color=fff&bold=true";
%>
<header class="top-header">
    <div class="header-left d-flex align-items-center gap-3">
        <button class="toggle-btn" id="sidebarToggle">
            <i class="bi bi-list"></i>
        </button>
        <!-- Datetime -->
        <div class="datetime-widget d-none d-lg-flex m-0">
            <i class="bi bi-calendar3"></i> <span id="currentDate" class="ms-1"></span>
            <i class="bi bi-clock ms-3"></i> <span id="currentTime" class="ms-1"></span>
        </div>
    </div>
    <div class="header-right">
        <!-- Coordinator switch button -->
        <% if (session.getAttribute("isCoordinator") != null && (Boolean) session.getAttribute("isCoordinator")) { %>
        <a href="coordinatorDashboard" class="switch-view-btn me-3">
            <i class="bi bi-speedometer2"></i>
            <span class="d-none d-md-inline">Coordinator View</span>
        </a>
        <% } %>

        <!-- Check-in Status -->
        <% if (currentTeacher != null) { %>
        <div class="d-none d-lg-flex align-items-center me-3 bg-white border rounded shadow-sm px-3" style="height: 42px;">
            <div class="d-flex flex-column justify-content-center border-end pe-3 me-3" style="min-width: 90px;">
                <% if (isCheckedOut) { %>
                    <span class="badge bg-secondary" style="font-size: 0.65rem; margin-bottom: 2px;">Shift Complete</span>
                    <small class="text-muted fw-bold" style="font-size: 0.65rem; line-height: 1;">DONE</small>
                <% } else if (isCheckedIn) { %>
                    <span class="badge bg-success" style="font-size: 0.65rem; margin-bottom: 2px;">Checked In</span>
                    <small class="text-muted fw-bold" style="font-size: 0.65rem; line-height: 1;">IN: <%= checkInTimeStr %></small>
                <% } else { %>
                    <span class="badge bg-warning text-dark" style="font-size: 0.65rem; margin-bottom: 2px;">Pending</span>
                    <small class="text-muted fw-bold" style="font-size: 0.65rem; line-height: 1;">WAITING</small>
                <% } %>
            </div>
            <div class="d-flex align-items-center">
                <% if (!isCheckedIn) { %>
                    <a href="facultyAttendance?action=checkin" class="btn btn-primary-custom rounded-pill fw-bold" style="font-size: 0.75rem; padding: 0.25rem 1rem;"><i class="bi bi-box-arrow-in-right me-1"></i> Check In</a>
                <% } else if (!isCheckedOut) { %>
                    <a href="facultyAttendance?action=checkout" class="btn btn-danger rounded-pill fw-bold" style="font-size: 0.75rem; padding: 0.25rem 1rem;"><i class="bi bi-box-arrow-right me-1"></i> Check Out</a>
                <% } else { %>
                    <i class="bi bi-check2-all text-success fs-5"></i>
                <% } %>
            </div>
        </div>
        <% } %>

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
