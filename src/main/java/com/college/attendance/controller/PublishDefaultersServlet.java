package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.NotificationDAO;
import com.college.attendance.model.DefaulterRecord;
import com.college.attendance.model.Teacher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/publishDefaulters")
public class PublishDefaultersServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO = new AttendanceDAO();
    private NotificationDAO notificationDAO = new NotificationDAO();
    private com.college.attendance.dao.StudentDAO studentDAO = new com.college.attendance.dao.StudentDAO();

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
        boolean notifyParents = "true".equals(request.getParameter("notifyParents"));
        
        // Security check: Only coordinators can send parent alerts
        if (!("coordinator".equals(context) && Boolean.TRUE.equals(isCoordinator))) {
            notifyParents = false;
        }
        
        List<DefaulterRecord> defaulters;
        String senderRole = "Faculty";
        
        if ("coordinator".equals(context) && Boolean.TRUE.equals(isCoordinator)) {
            defaulters = attendanceDAO.getDefaultersForCoordinator(teacher.getId(), threshold, startDate, endDate);
            senderRole = "Coordinator";
        } else {
            defaulters = attendanceDAO.getDefaultersForTeacher(teacher.getId(), threshold, startDate, endDate);
        }

        int successCount = 0;
        int parentSuccessCount = 0;
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

                if (notificationDAO.sendNotification(teacher.getName(), senderRole, dr.getStudentId(), title, message, null)) {
                    successCount++;
                }

                if (notifyParents) {
                    com.college.attendance.model.Student student = studentDAO.getStudentById(dr.getStudentId());
                    if (student != null) {
                        String datePeriod = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) 
                                            ? (startDate + " to " + endDate) 
                                            : "overall";
                        if (com.college.attendance.util.AlertService.sendParentAlert(student, dr.getPercentage(), threshold, datePeriod, teacher.getName(), senderRole)) {
                            parentSuccessCount++;
                        }
                    }
                }
            }
        }

        String msg = "Successfully notified " + successCount + " defaulter students.";
        if (notifyParents) {
            msg += " Sent " + parentSuccessCount + " parent alerts.";
        }
        String referer = request.getHeader("Referer");
        if (referer == null || referer.isEmpty()) {
            referer = "teacherDefaulterList";
        }
        String redirectUrl;
        if (referer.contains("?")) {
            redirectUrl = referer + "&msg=" + java.net.URLEncoder.encode(msg, "UTF-8");
        } else {
            redirectUrl = referer + "?msg=" + java.net.URLEncoder.encode(msg, "UTF-8");
        }
        response.sendRedirect(redirectUrl);
    }
}
