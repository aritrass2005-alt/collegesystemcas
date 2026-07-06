package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.NotificationDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.Teacher;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet("/teacherAppeals")
public class TeacherAppealsServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO;
    private NotificationDAO notificationDAO;
    private SubjectDAO subjectDAO;

    public void init() {
        attendanceDAO = new AttendanceDAO();
        notificationDAO = new NotificationDAO();
        subjectDAO = new SubjectDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        // Fetch pending appeals for teacher's subjects
        List<Attendance> pendingAppeals = attendanceDAO.getPendingStudentAppealsForTeacher(teacher.getId());
        
        // Fetch history of student appeals
        List<Attendance> appealHistory = attendanceDAO.getStudentAppealHistoryForTeacher(teacher.getId());

        // Fetch teacher system notifications
        List<Notification> notifications = notificationDAO.getNotificationsForTeacher(teacher.getId());

        request.setAttribute("pendingAppeals", pendingAppeals);
        request.setAttribute("appealHistory", appealHistory);
        request.setAttribute("notifications", notifications);

        // Mark read if requested in notifications
        String markReadId = request.getParameter("readNotifId");
        if (markReadId != null && !markReadId.isEmpty()) {
            try {
                notificationDAO.markAsReadForTeacher(Integer.parseInt(markReadId), teacher.getId());
                response.sendRedirect("teacherAppeals?msg=Notification marked as read");
                return;
            } catch (Exception ignored) {}
        }

        request.getRequestDispatcher("teacher_appeals.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        String attendanceIdStr = request.getParameter("attendanceId");
        String remarks = request.getParameter("remarks");

        if (attendanceIdStr == null || attendanceIdStr.isEmpty() || action == null || action.isEmpty()) {
            response.sendRedirect("teacherAppeals?error=Missing parameters.");
            return;
        }

        try {
            int attendanceId = Integer.parseInt(attendanceIdStr);
            Attendance a = attendanceDAO.getAttendanceById(attendanceId);

            if (a == null) {
                response.sendRedirect("teacherAppeals?error=Attendance record not found.");
                return;
            }

            // Verify if teacher is assigned to this subject
            List<Subject> teacherSubjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
            boolean allowed = false;
            for (Subject s : teacherSubjects) {
                if (s.getId() == a.getSubjectId()) {
                    allowed = true;
                    break;
                }
            }

            if (!allowed) {
                response.sendRedirect("teacherAppeals?error=Permission denied.");
                return;
            }

            String status = "Pending";
            String title = "";
            String msg = "";
            
            if ("approve".equalsIgnoreCase(action)) {
                status = "Approved";
                title = "Attendance Appeal Approved";
                SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
                msg = "Your attendance appeal for the class on " + sdf.format(a.getDateTime()) + 
                      " has been approved by " + teacher.getName() + 
                      ". Your status has been updated to Present.\nTeacher's Remarks: " + (remarks != null ? remarks : "None");
            } else if ("reject".equalsIgnoreCase(action)) {
                status = "Rejected";
                title = "Attendance Appeal Rejected";
                SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
                msg = "Your attendance appeal for the class on " + sdf.format(a.getDateTime()) + 
                      " has been rejected by " + teacher.getName() + 
                      ".\nTeacher's Remarks: " + (remarks != null ? remarks : "None");
            } else {
                response.sendRedirect("teacherAppeals?error=Invalid action.");
                return;
            }

            if (attendanceDAO.verifyStudentAppeal(attendanceId, status, remarks)) {
                // Send notification to student
                notificationDAO.sendNotificationToRole(
                    teacher.getName(), 
                    "Teacher", 
                    a.getStudentId(), 
                    "Student", 
                    title, 
                    msg, 
                    null
                );
                response.sendRedirect("teacherAppeals?msg=Appeal processed successfully and student notified.");
            } else {
                response.sendRedirect("teacherAppeals?error=Failed to process appeal.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("teacherAppeals?error=An error occurred while processing.");
        }
    }
}
