package com.college.attendance.controller;

import com.college.attendance.dao.FacultyAttendanceDAO;
import com.college.attendance.model.FacultyAttendance;
import com.college.attendance.model.Teacher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
        List<Teacher> absentRecords = dao.getAbsentFaculty(targetDate, deptParam);
        List<FacultyAttendance> pendingLeaves = dao.getPendingLeaves();
        
        request.setAttribute("records", records);
        request.setAttribute("absentRecords", absentRecords);
        request.setAttribute("pendingLeaves", pendingLeaves);
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
            String action = request.getParameter("action");
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");
            
            com.college.attendance.model.Admin admin = (com.college.attendance.model.Admin) session.getAttribute("user");
            
            if ("add".equals(action)) {
                int teacherId = Integer.parseInt(request.getParameter("teacherId"));
                Date targetDate = Date.valueOf(request.getParameter("targetDate"));
                dao.addAttendanceByAdmin(teacherId, targetDate, status, notes);
                com.college.attendance.dao.ActivityLogDAO.log(admin.getRole(), admin.getName(), "Added faculty attendance for Teacher ID " + teacherId + " on " + targetDate + " as " + status);
            } else {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.updateAttendanceByAdmin(id, status, notes);
                com.college.attendance.dao.ActivityLogDAO.log(admin.getRole(), admin.getName(), "Verified/Updated faculty attendance ID " + id + " to " + status);
            }
            
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
