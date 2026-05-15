<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Admin" %>
<%
    Admin currentAdmin = (Admin) session.getAttribute("user");
%>
<header class="top-header">
    <div class="header-left">
        <button class="toggle-btn" id="sidebarToggle">
            <i class="bi bi-list"></i>
        </button>
        <div class="search-bar d-none d-md-block">
            <input type="text" class="form-control" placeholder="What do you want to find?">
        </div>
    </div>
    <div class="header-right">
        <div class="datetime-widget">
            <i class="bi bi-calendar3"></i> <span id="currentDate"></span>
            <i class="bi bi-clock ms-2"></i> <span id="currentTime"></span>
        </div>
        <!-- Profile Area -->
        <div style="position: relative;">
            <div id="profileBtn" onclick="toggleProfileMenu()" 
                 style="display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 5px 10px; border-radius: 10px; transition: background 0.2s;"
                 onmouseover="this.style.background='rgba(123,44,191,0.06)'" 
                 onmouseout="this.style.background='transparent'">
                <img src="https://ui-avatars.com/api/?name=<%= currentAdmin != null ? currentAdmin.getName() : "Admin" %>&background=7b2cbf&color=fff&bold=true" 
                     style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #7b2cbf; pointer-events: none;">
                <div class="d-none d-md-block" style="pointer-events: none;">
                    <div style="font-weight: 700; font-size: 14px; line-height: 1.2;"><%= currentAdmin != null ? currentAdmin.getName() : "Admin" %></div>
                    <div style="font-size: 12px; color: #6c757d;"><%= currentAdmin != null ? currentAdmin.getRole() : "Admin" %></div>
                </div>
                <i class="bi bi-chevron-down" style="color: #6c757d; font-size: 12px; pointer-events: none;"></i>
            </div>
            <!-- Dropdown Menu -->
            <div id="profileMenu" style="display: none; position: absolute; right: 0; top: calc(100% + 8px); background: white; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.15); min-width: 220px; z-index: 99999; overflow: hidden;">
                <div style="padding: 15px 18px; border-bottom: 1px solid #f0f0f0;">
                    <div style="font-weight: 700; font-size: 15px;"><%= currentAdmin != null ? currentAdmin.getName() : "Admin" %></div>
                    <div style="font-size: 13px; color: #6c757d;"><%= currentAdmin != null ? currentAdmin.getRole() : "Admin" %></div>
                </div>
                <a href="adminProfile" style="display: flex; align-items: center; gap: 10px; padding: 12px 18px; text-decoration: none; color: #333; transition: background 0.15s;" 
                   onmouseover="this.style.background='#f8f6fb'" onmouseout="this.style.background='transparent'">
                    <i class="bi bi-person" style="font-size: 18px; color: #7b2cbf;"></i>
                    <span style="font-weight: 500;">My Profile</span>
                </a>
                <div style="height: 1px; background: #f0f0f0; margin: 0 12px;"></div>
                <a href="logout" style="display: flex; align-items: center; gap: 10px; padding: 12px 18px; text-decoration: none; color: #dc3545; transition: background 0.15s;" 
                   onmouseover="this.style.background='#fff5f5'" onmouseout="this.style.background='transparent'">
                    <i class="bi bi-box-arrow-right" style="font-size: 18px;"></i>
                    <span style="font-weight: 500;">Logout</span>
                </a>
            </div>
        </div>
    </div>
</header>

<script>
    // Profile menu toggle
    function toggleProfileMenu() {
        var menu = document.getElementById('profileMenu');
        if (menu.style.display === 'none' || menu.style.display === '') {
            menu.style.display = 'block';
        } else {
            menu.style.display = 'none';
        }
    }

    // Close menu when clicking anywhere else
    document.addEventListener('click', function(e) {
        var btn = document.getElementById('profileBtn');
        var menu = document.getElementById('profileMenu');
        if (btn && menu && !btn.contains(e.target) && !menu.contains(e.target)) {
            menu.style.display = 'none';
        }
    });

    // Live clock
    function updateDateTime() {
        var now = new Date();
        var dateOptions = { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' };
        document.getElementById('currentDate').innerText = now.toLocaleDateString('en-US', dateOptions);
        var timeOptions = { hour: '2-digit', minute: '2-digit', second: '2-digit' };
        document.getElementById('currentTime').innerText = now.toLocaleTimeString('en-US', timeOptions);
    }
    setInterval(updateDateTime, 1000);
    updateDateTime();
</script>
