package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.AttendanceSummary;
import com.college.attendance.model.Student;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/viewAttendance")
public class StudentAttendanceServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO;

    public void init() {
        attendanceDAO = new AttendanceDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Student student = (Student) request.getSession().getAttribute("user");
        if (student == null || !"Student".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<AttendanceSummary> attendanceSummary = attendanceDAO.getStudentAttendanceSummary(student.getId());
        request.setAttribute("attendanceSummary", attendanceSummary);

        request.getRequestDispatcher("student_attendance.jsp").forward(request, response);
    }
}
