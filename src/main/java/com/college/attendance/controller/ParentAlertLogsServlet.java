package com.college.attendance.controller;

import com.college.attendance.dao.ParentAlertLogDAO;
import com.college.attendance.model.ParentAlertLog;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/parentAlertLogs")
public class ParentAlertLogsServlet extends HttpServlet {
    private ParentAlertLogDAO logDAO = new ParentAlertLogDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role) && !"SuperAdmin".equals(role) && !"Teacher".equals(role)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        List<ParentAlertLog> logs = logDAO.getAllLogs();
        request.setAttribute("logs", logs);
        
        request.getRequestDispatcher("parent_alert_logs.jsp").forward(request, response);
    }
}
