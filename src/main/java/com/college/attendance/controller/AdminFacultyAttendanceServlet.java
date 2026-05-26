package com.college.attendance.controller;

import com.college.attendance.dao.FacultyAttendanceDAO;
import com.college.attendance.model.FacultyAttendance;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/adminFacultyAttendance")
public class AdminFacultyAttendanceServlet extends HttpServlet {
    private FacultyAttendanceDAO dao = new FacultyAttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        
        if (role == null || (!"Admin".equals(role) && !"SuperAdmin".equals(role))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String dateParam = request.getParameter("date");
        String deptParam = request.getParameter("department");

        Date targetDate = null;
        if (dateParam != null && !dateParam.isEmpty()) {
            try {
                targetDate = Date.valueOf(dateParam);
            } catch (Exception e) {}
        } else {
            targetDate = new Date(System.currentTimeMillis()); // Default to today
        }

        List<FacultyAttendance> records = dao.getAllFacultyAttendance(targetDate, deptParam);
        
        request.setAttribute("records", records);
        request.setAttribute("targetDate", targetDate);
        request.setAttribute("department", deptParam);
        
        request.getRequestDispatcher("admin_faculty_attendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        
        if (role == null || (!"Admin".equals(role) && !"SuperAdmin".equals(role))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");
            
            dao.updateAttendanceByAdmin(id, status, notes);
            
            String dateParam = request.getParameter("currentDate");
            String deptParam = request.getParameter("currentDept");
            
            String redirectUrl = "adminFacultyAttendance?";
            if (dateParam != null && !dateParam.isEmpty()) redirectUrl += "date=" + dateParam + "&";
            if (deptParam != null && !deptParam.isEmpty()) redirectUrl += "department=" + deptParam;
            
            response.sendRedirect(redirectUrl + "&msg=Updated Successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminFacultyAttendance?error=Update Failed");
        }
    }
}
