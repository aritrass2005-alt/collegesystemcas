package com.college.attendance.controller;

import com.college.attendance.dao.FacultyAttendanceDAO;
import com.college.attendance.model.FacultyAttendance;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/facultyAttendance")
public class FacultyAttendanceServlet extends HttpServlet {
    private FacultyAttendanceDAO dao = new FacultyAttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        if ("checkin".equals(action)) {
            dao.checkIn(teacher.getId());
            response.sendRedirect("teacher_dashboard.jsp?msg=Checked In Successfully");
            return;
        } else if ("checkout".equals(action)) {
            dao.checkOut(teacher.getId());
            response.sendRedirect("teacher_dashboard.jsp?msg=Checked Out Successfully");
            return;
        }

        // Default view: Calendar and history
        List<FacultyAttendance> history = dao.getHistoryByTeacher(teacher.getId());
        request.setAttribute("history", history);
        request.getRequestDispatcher("teacher_my_attendance.jsp").forward(request, response);
    }
}
