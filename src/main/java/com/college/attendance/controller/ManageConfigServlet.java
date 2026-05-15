package com.college.attendance.controller;

import com.college.attendance.dao.ConfigDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/manageConfig")
public class ManageConfigServlet extends HttpServlet {
    private ConfigDAO configDAO = new ConfigDAO();

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
        
        request.getRequestDispatcher("admin_config.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
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
