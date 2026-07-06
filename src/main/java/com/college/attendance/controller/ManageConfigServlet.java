package com.college.attendance.controller;

import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.dao.SystemSettingsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/manageConfig")
public class ManageConfigServlet extends HttpServlet {
    private ConfigDAO configDAO = new ConfigDAO();
    private SystemSettingsDAO systemSettingsDAO = new SystemSettingsDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            String type = request.getParameter("type");
            int id = Integer.parseInt(request.getParameter("id"));
            configDAO.deleteConfig(type, id);
            response.sendRedirect("manageConfig?msg=Item deleted successfully");
            return;
        }

        request.setAttribute("departments", configDAO.getAll("department"));
        request.setAttribute("sections", configDAO.getAll("section"));
        request.setAttribute("years", configDAO.getAll("academic_year"));
        request.setAttribute("maintenanceMode", systemSettingsDAO.isMaintenanceMode());
        
        request.getRequestDispatcher("admin_config.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("toggleMaintenance".equals(action)) {
            if (!"SuperAdmin".equals(session.getAttribute("role"))) {
                response.sendRedirect("manageConfig?error=Access+denied.+Super+Admin+only.");
                return;
            }
            boolean enable = Boolean.parseBoolean(request.getParameter("enable"));
            systemSettingsDAO.setMaintenanceMode(enable);
            response.sendRedirect("manageConfig?msg=Maintenance+mode+" + (enable ? "enabled" : "disabled") + "+successfully.");
            return;
        }

        String type = request.getParameter("type");
        String value = request.getParameter("value");

        if (configDAO.addConfig(type, value)) {
            response.sendRedirect("manageConfig?msg=Added successfully");
        } else {
            response.sendRedirect("manageConfig?error=Failed to add or duplicate entry");
        }
    }
}
