package com.college.attendance.controller;

import com.college.attendance.dao.NotificationDAO;
import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Admin;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.List;

@WebServlet("/sendNotification")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 15)
public class SendNotificationServlet extends HttpServlet {
    private NotificationDAO notificationDAO;
    private StudentDAO studentDAO;
    private AttendanceDAO attendanceDAO;

    public void init() {
        notificationDAO = new NotificationDAO();
        studentDAO = new StudentDAO();
        attendanceDAO = new AttendanceDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (role == null || (!"Admin".equals(role) && !"SuperAdmin".equals(role) && !"Teacher".equals(role))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Only coordinators or admins can send notifications
        if ("Teacher".equals(role) && !Boolean.TRUE.equals(session.getAttribute("isCoordinator"))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Only coordinators can send notifications.");
            return;
        }

        String senderName = "System";
        String senderRole = "System";

        if ("Admin".equals(role) || "SuperAdmin".equals(role)) {
            Admin admin = (Admin) session.getAttribute("user");
            senderName = admin.getName();
            senderRole = "Admin";
        } else {
            Teacher teacher = (Teacher) session.getAttribute("user");
            senderName = teacher.getName();
            senderRole = "Coordinator";
        }

        String targetType = request.getParameter("targetType"); // 'ALL', 'DEFAULTERS', 'SPECIFIC'
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        
        // Custom threshold
        double threshold = 75.0;
        String customThreshold = request.getParameter("defaulterThreshold");
        if (customThreshold != null && !customThreshold.isEmpty()) {
            try { threshold = Double.parseDouble(customThreshold); } catch (Exception e) {}
        }

        try {
            String attachmentPath = null;
            Part filePart = request.getPart("attachment");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName().replaceAll("[^a-zA-Z0-9.-]", "_");
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "notices";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                filePart.write(uploadPath + File.separator + fileName);
                attachmentPath = "uploads/notices/" + fileName;
            }

            int successCount = 0;

            if ("SPECIFIC".equals(targetType)) {
                int studentId = Integer.parseInt(request.getParameter("studentId"));
                if (notificationDAO.sendNotification(senderName, senderRole, studentId, title, message, attachmentPath)) {
                    successCount++;
                }
            } else {
                // Group notification
                String dept = request.getParameter("department");
                int year = Integer.parseInt(request.getParameter("year"));
                String section = request.getParameter("section");
                if (section == null || section.isEmpty() || "All".equalsIgnoreCase(section)) {
                    section = null;
                }

                List<Student> students = studentDAO.getStudentsByFilter(dept, year, section, null);
                for (Student s : students) {
                    if ("DEFAULTERS".equals(targetType)) {
                        double attendance = attendanceDAO.getStudentAttendancePercentage(s.getId());
                        if (attendance >= threshold) {
                            continue; // Skip non-defaulters based on custom threshold
                        }
                    }
                    if (notificationDAO.sendNotification(senderName, senderRole, s.getId(), title, message, attachmentPath)) {
                        successCount++;
                    }
                }
            }

            String referer = request.getHeader("Referer");
            if (referer == null || referer.isEmpty()) {
                referer = "coordinator_notifications.jsp";
            }
            String redirectUrl;
            String msg = "Notification sent successfully to " + successCount + " students.";
            if (referer.contains("?")) {
                redirectUrl = referer + "&msg=" + java.net.URLEncoder.encode(msg, "UTF-8");
            } else {
                redirectUrl = referer + "?msg=" + java.net.URLEncoder.encode(msg, "UTF-8");
            }
            response.sendRedirect(redirectUrl);

        } catch (Exception e) {
            e.printStackTrace();
            String referer = request.getHeader("Referer");
            if (referer == null || referer.isEmpty()) {
                referer = "coordinator_notifications.jsp";
            }
            String redirectUrl;
            String errMsg = "Failed to send notifications.";
            if (referer.contains("?")) {
                redirectUrl = referer + "&error=" + java.net.URLEncoder.encode(errMsg, "UTF-8");
            } else {
                redirectUrl = referer + "?error=" + java.net.URLEncoder.encode(errMsg, "UTF-8");
            }
            response.sendRedirect(redirectUrl);
        }
    }
}
