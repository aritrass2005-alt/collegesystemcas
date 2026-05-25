package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.AttendanceSummary;
import com.college.attendance.model.Student;
import com.college.attendance.model.DefaulterRecord;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/studentDashboard")
public class StudentDashboardServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO = new AttendanceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        // Fetch subject-wise attendance
        List<AttendanceSummary> subjectSummary = attendanceDAO.getStudentAttendanceSummary(student.getId());
        
        // Fetch month-wise attendance
        List<AttendanceSummary> monthSummary = attendanceDAO.getMonthWiseAttendance(student.getId());
        
        // Fetch full history for the calendar
        List<Attendance> history = attendanceDAO.getStudentAttendanceHistory(student.getId());

        // Calculate overall percentage
        int totalClasses = 0;
        int attendedClasses = 0;
        for (AttendanceSummary s : subjectSummary) {
            totalClasses += s.getTotalClasses();
            attendedClasses += s.getAttendedClasses();
        }
        double overallPercentage = totalClasses > 0 ? ((double) attendedClasses / totalClasses) * 100.0 : 0.0;
        overallPercentage = Math.round(overallPercentage * 100.0) / 100.0;

        // Read the threshold from the application context if set by a teacher/coordinator, otherwise default to 75.0
        Double globalThreshold = (Double) getServletContext().getAttribute("globalDefaulterThreshold");
        double threshold = globalThreshold != null ? globalThreshold : 75.0;

        // Fetch section defaulters
        List<DefaulterRecord> defaulters = attendanceDAO.getDefaultersForSection(
                student.getDepartment(), student.getYear(), student.getSection(), threshold);
        request.setAttribute("currentThreshold", threshold);

        request.setAttribute("subjectSummary", subjectSummary);
        request.setAttribute("monthSummary", monthSummary);
        request.setAttribute("history", history);
        request.setAttribute("overallPercentage", overallPercentage);
        request.setAttribute("defaulters", defaulters);


        request.getRequestDispatcher("student_dashboard.jsp").forward(request, response);
    }
}
