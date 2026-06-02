package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.NotificationDAO;
import com.college.attendance.model.DefaulterRecord;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/publishDefaulters")
public class PublishDefaultersServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO = new AttendanceDAO();
    private NotificationDAO notificationDAO = new NotificationDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        String role = (String) session.getAttribute("role");
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");

        if (teacher == null || !"Teacher".equals(role)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        double threshold = 75.0;
        try {
            threshold = Double.parseDouble(request.getParameter("threshold"));
        } catch (Exception e) {}

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        String context = request.getParameter("context"); // "teacher" or "coordinator"
        
        List<DefaulterRecord> defaulters;
        String senderRole = "Faculty";
        
        if ("coordinator".equals(context) && Boolean.TRUE.equals(isCoordinator)) {
            defaulters = attendanceDAO.getDefaultersForCoordinator(teacher.getId(), threshold, startDate, endDate);
            senderRole = "Coordinator";
        } else {
            defaulters = attendanceDAO.getDefaultersForTeacher(teacher.getId(), threshold, startDate, endDate);
        }

        int successCount = 0;
        if (defaulters != null) {
            for (DefaulterRecord dr : defaulters) {
                String title = "Attendance Alert: Defaulter List Published";
                String message = String.format("You have been marked as a defaulter. Your attendance is %.2f%% (Below required %.0f%%)", dr.getPercentage(), threshold);
                if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
                    message += String.format(" for the period %s to %s.", startDate, endDate);
                } else {
                    message += " overall.";
                }
                message += " Please check your dashboard for full attendance details.";

                if (notificationDAO.sendNotification(teacher.getName(), senderRole, dr.getStudentId(), "Student", title, message, null)) {
                    successCount++;
                }
            }
        }

        String referer = request.getHeader("Referer");
        if (referer != null) {
            String separator = referer.contains("?") ? "&" : "?";
            response.sendRedirect(referer + separator + "msg=Successfully+notified+" + successCount + "+defaulter+students.");
        } else {
            response.sendRedirect("teacher_dashboard.jsp");
        }
    }
}
