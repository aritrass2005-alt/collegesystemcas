package com.college.attendance.controller;

import com.college.attendance.util.SystemConfigManager;
import com.college.attendance.listener.ActiveSessionListener;
import com.college.attendance.dao.ActivityLogDAO;
import com.college.attendance.model.Admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/systemControl")
public class SystemControlServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = session != null ? (String) session.getAttribute("role") : null;
        if (!"Admin".equals(role) && !"SuperAdmin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Return JSON status for AJAX polling
        String action = request.getParameter("action");
        if ("status".equals(action)) {
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            SystemConfigManager config = SystemConfigManager.getInstance();
            out.print("{");
            out.print("\"maintenanceMode\":" + config.isMaintenanceMode() + ",");
            out.print("\"maxActiveSessions\":" + config.getMaxActiveSessions() + ",");
            out.print("\"activeSessions\":" + ActiveSessionListener.getActiveSessions() + ",");
            out.print("\"activeStudents\":" + ActiveSessionListener.getActiveStudentSessions() + ",");
            out.print("\"activeTeachers\":" + ActiveSessionListener.getActiveTeacherSessions() + ",");
            out.print("\"activeAdmins\":" + ActiveSessionListener.getActiveAdminSessions());
            out.print("}");
            return;
        }

        // Forward to admin system control page
        request.setAttribute("maintenanceMode", SystemConfigManager.getInstance().isMaintenanceMode());
        request.setAttribute("maxActiveSessions", SystemConfigManager.getInstance().getMaxActiveSessions());
        request.setAttribute("activeSessions", ActiveSessionListener.getActiveSessions());
        request.setAttribute("activeStudents", ActiveSessionListener.getActiveStudentSessions());
        request.setAttribute("activeTeachers", ActiveSessionListener.getActiveTeacherSessions());
        request.setAttribute("activeAdmins", ActiveSessionListener.getActiveAdminSessions());
        request.getRequestDispatcher("admin_system_control.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = session != null ? (String) session.getAttribute("role") : null;

        String action = request.getParameter("action");
        Admin admin = session != null ? (Admin) session.getAttribute("user") : null;
        String adminName = admin != null ? admin.getName() : "System";

        if ("toggle_maintenance".equals(action)) {
            // Only SuperAdmin can toggle maintenance
            if (!"SuperAdmin".equals(role)) {
                response.sendRedirect("systemControl?error=Only+SuperAdmin+can+toggle+maintenance+mode.");
                return;
            }
            SystemConfigManager config = SystemConfigManager.getInstance();
            boolean newState = !config.isMaintenanceMode();
            config.setMaintenanceMode(newState);
            ActivityLogDAO.log("SuperAdmin", adminName, (newState ? "Enabled" : "Disabled") + " maintenance mode");
            response.sendRedirect("systemControl?msg=Maintenance+mode+" + (newState ? "ENABLED" : "DISABLED") + "+successfully.");

        } else if ("set_session_cap".equals(action)) {
            if (!"Admin".equals(role) && !"SuperAdmin".equals(role)) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
            try {
                int cap = Integer.parseInt(request.getParameter("maxSessions"));
                if (cap < 0) cap = 0;
                SystemConfigManager.getInstance().setMaxActiveSessions(cap);
                ActivityLogDAO.log(role, adminName, "Set max active sessions to " + (cap == 0 ? "unlimited" : cap));
                response.sendRedirect("systemControl?msg=Session+cap+set+to+" + (cap == 0 ? "unlimited" : cap) + ".");
            } catch (NumberFormatException e) {
                response.sendRedirect("systemControl?error=Invalid+number.");
            }

        } else {
            response.sendRedirect("systemControl");
        }
    }
}
