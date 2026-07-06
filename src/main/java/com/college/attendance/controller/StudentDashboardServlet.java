package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.AttendanceSummary;
import com.college.attendance.model.Student;
import com.college.attendance.model.DefaulterRecord;


import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        if ("submitAppeal".equals(action)) {
            String attendanceIdStr = request.getParameter("attendanceId");
            String reason = request.getParameter("reason");

            if (attendanceIdStr != null && !attendanceIdStr.isEmpty() && reason != null && !reason.isEmpty()) {
                try {
                    int attendanceId = Integer.parseInt(attendanceIdStr);
                    
                    Attendance a = attendanceDAO.getAttendanceById(attendanceId);
                    if (a != null && a.getStudentId() == student.getId() && "Absent".equals(a.getStatus())) {
                        
                        if (attendanceDAO.submitStudentAppeal(attendanceId, reason)) {
                            com.college.attendance.dao.SubjectDAO subjectDAO = new com.college.attendance.dao.SubjectDAO();
                            com.college.attendance.model.Subject sub = subjectDAO.getSubjectById(a.getSubjectId());
                            if (sub != null && sub.getTeacherId() > 0) {
                                com.college.attendance.dao.NotificationDAO notificationDAO = new com.college.attendance.dao.NotificationDAO();
                                String notifTitle = "New Student Recheck Appeal";
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy");
                                String formattedDate = sdf.format(a.getDateTime());
                                String notifMessage = "Student " + student.getName() + " (" + student.getRollNo() + ") has submitted a recheck appeal for " + sub.getSubjectCode() + " on " + formattedDate + ".\nReason: " + reason;
                                
                                notificationDAO.sendNotificationToRole(
                                    student.getName(), 
                                    "Student", 
                                    sub.getTeacherId(), 
                                    "Teacher", 
                                    notifTitle, 
                                    notifMessage, 
                                    null
                                );
                            }
                            response.sendRedirect("studentDashboard?msg=Appeal submitted successfully!");
                        } else {
                            response.sendRedirect("studentDashboard?error=Failed to submit appeal. Try again.");
                        }
                    } else {
                        response.sendRedirect("studentDashboard?error=Invalid attendance record.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("studentDashboard?error=An error occurred.");
                }
            } else {
                response.sendRedirect("studentDashboard?error=Missing parameters.");
            }
        } else {
            response.sendRedirect("studentDashboard");
        }
    }
}
