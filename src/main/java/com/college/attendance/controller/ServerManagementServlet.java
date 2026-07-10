package com.college.attendance.controller;

import com.college.attendance.dao.SystemSettingsDAO;
import com.college.attendance.listener.ActiveSessionListener;
import com.college.attendance.model.SessionInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collection;

@WebServlet("/serverManagement")
public class ServerManagementServlet extends HttpServlet {
    private SystemSettingsDAO systemSettingsDAO = new SystemSettingsDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || !"SuperAdmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Access+denied.+Super+Admin+only.");
            return;
        }

        boolean maintenanceMode = systemSettingsDAO.isMaintenanceMode();
        int maxTrafficLimit = systemSettingsDAO.getMaxTrafficLimit();
        Collection<SessionInfo> activeSessions = ActiveSessionListener.getActiveSessionDetails();

        request.setAttribute("maintenanceMode", maintenanceMode);
        request.setAttribute("maxTrafficLimit", maxTrafficLimit);
        request.setAttribute("activeSessions", activeSessions);

        request.getRequestDispatcher("admin_server_management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || !"SuperAdmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Access+denied.+Super+Admin+only.");
            return;
        }

        String action = request.getParameter("action");
        if ("toggleMaintenance".equals(action)) {
            boolean enable = Boolean.parseBoolean(request.getParameter("enable"));
            systemSettingsDAO.setMaintenanceMode(enable);
            response.sendRedirect("serverManagement?msg=Maintenance+mode+" + (enable ? "enabled" : "disabled") + "+successfully.");
        } else if ("updateTrafficLimit".equals(action)) {
            try {
                int limit = Integer.parseInt(request.getParameter("maxTrafficLimit"));
                if (limit < 1) limit = 1;
                systemSettingsDAO.setMaxTrafficLimit(limit);
                response.sendRedirect("serverManagement?msg=Max+traffic+limit+updated+to+" + limit);
            } catch (Exception e) {
                response.sendRedirect("serverManagement?error=Invalid+traffic+limit+value.");
            }
        } else {
            response.sendRedirect("serverManagement");
        }
    }
}
