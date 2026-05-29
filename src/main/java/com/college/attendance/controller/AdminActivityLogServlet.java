package com.college.attendance.controller;

import com.college.attendance.dao.ActivityLogDAO;
import com.college.attendance.model.ActivityLog;
import com.college.attendance.model.Admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminLogs")
public class AdminActivityLogServlet extends HttpServlet {
    private ActivityLogDAO logDAO = new ActivityLogDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Admin currentAdmin = (Admin) session.getAttribute("user");
        
        if (currentAdmin == null || session.getAttribute("role") == null || !((String)session.getAttribute("role")).contains("Admin")) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<ActivityLog> logs = logDAO.getRecentLogs(200); // Fetch last 200 logs
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("admin_activity_log.jsp").forward(request, response);
    }
}
