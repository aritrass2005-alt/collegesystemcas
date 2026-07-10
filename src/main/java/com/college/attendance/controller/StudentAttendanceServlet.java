package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.AttendanceSummary;
import com.college.attendance.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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

        // Enforce profile completion and parent verification
        if (!student.isProfileCompleted() || !student.isParentVerified()) {
            response.sendRedirect("studentSetup");
            return;
        }

        List<AttendanceSummary> attendanceSummary = attendanceDAO.getStudentAttendanceSummary(student.getId());
        request.setAttribute("attendanceSummary", attendanceSummary);

        request.getRequestDispatcher("student_attendance.jsp").forward(request, response);
    }
}
