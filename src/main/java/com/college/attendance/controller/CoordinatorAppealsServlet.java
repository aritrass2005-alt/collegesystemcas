package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.CoordinatorDAO;
import com.college.attendance.dao.NotificationDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.Coordinator;
import com.college.attendance.model.Teacher;
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

/**
 * Servlet for coordinators to review student recheck appeals
 * for students in their assigned sections.
 * Only coordinators can see guardian contact info (call/message).
 */
@WebServlet("/coordinatorAppeals")
public class CoordinatorAppealsServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO;
    private CoordinatorDAO coordinatorDAO;
    private NotificationDAO notificationDAO;

    public void init() {
        attendanceDAO = new AttendanceDAO();
        coordinatorDAO = new CoordinatorDAO();
        notificationDAO = new NotificationDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        // Verify coordinator role
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
        if (isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp?error=Coordinator access required");
            return;
        }

        // Fetch pending appeals for students in coordinator's assigned sections
        List<Attendance> pendingAppeals = attendanceDAO.getPendingStudentAppealsForCoordinatorSection(teacher.getId());

        // Fetch history of resolved appeals for coordinator's sections
        List<Attendance> appealHistory = attendanceDAO.getStudentAppealHistoryForCoordinator(teacher.getId());

        // Fetch coordinator notifications
        List<Notification> notifications = notificationDAO.getNotificationsForTeacher(teacher.getId());

        request.setAttribute("pendingAppeals", pendingAppeals);
        request.setAttribute("appealHistory", appealHistory);
        request.setAttribute("notifications", notifications);

        // Mark notification as read if requested
        String markReadId = request.getParameter("readNotifId");
        if (markReadId != null && !markReadId.isEmpty()) {
            try {
                notificationDAO.markAsReadForTeacher(Integer.parseInt(markReadId), teacher.getId());
                response.sendRedirect("coordinatorAppeals?msg=Notification marked as read");
                return;
            } catch (Exception ignored) {}
        }

        request.getRequestDispatcher("coordinator_appeals.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        // Verify coordinator role
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
        if (isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp?error=Coordinator access required");
            return;
        }

        String action = request.getParameter("action");
        String attendanceIdStr = request.getParameter("attendanceId");
        String remarks = request.getParameter("remarks");

        if (attendanceIdStr == null || attendanceIdStr.isEmpty() || action == null || action.isEmpty()) {
            response.sendRedirect("coordinatorAppeals?error=Missing parameters.");
            return;
        }

        try {
            int attendanceId = Integer.parseInt(attendanceIdStr);
            Attendance a = attendanceDAO.getAttendanceById(attendanceId);

            if (a == null) {
                response.sendRedirect("coordinatorAppeals?error=Attendance record not found.");
                return;
            }

            // Verify student is in coordinator's assigned section
            List<Coordinator> assignments = coordinatorDAO.getCoordinatorAssignments(teacher.getId());
            boolean allowed = false;
            for (Coordinator c : assignments) {
                // Need to check student's department, year, section against coordinator's assignment
                // We fetch fresh attendance record that has student info
                // For simplicity, re-check through pending appeals list
                List<Attendance> pending = attendanceDAO.getPendingStudentAppealsForCoordinatorSection(teacher.getId());
                for (Attendance pa : pending) {
                    if (pa.getId() == attendanceId) {
                        allowed = true;
                        break;
                    }
                }
                if (allowed) break;
            }

            // Also check in history (for edge cases where appeal was just resolved)
            if (!allowed) {
                List<Attendance> history = attendanceDAO.getStudentAppealHistoryForCoordinator(teacher.getId());
                for (Attendance ha : history) {
                    if (ha.getId() == attendanceId) {
                        allowed = true;
                        break;
                    }
                }
            }

            if (!allowed) {
                response.sendRedirect("coordinatorAppeals?error=Permission denied. Student not in your section.");
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
                      " has been approved by Coordinator " + teacher.getName() +
                      ". Your status has been updated to Present.\nCoordinator's Remarks: " + (remarks != null ? remarks : "None");
            } else if ("reject".equalsIgnoreCase(action)) {
                status = "Rejected";
                title = "Attendance Appeal Rejected";
                SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
                msg = "Your attendance appeal for the class on " + sdf.format(a.getDateTime()) +
                      " has been rejected by Coordinator " + teacher.getName() +
                      ".\nCoordinator's Remarks: " + (remarks != null ? remarks : "None");
            } else {
                response.sendRedirect("coordinatorAppeals?error=Invalid action.");
                return;
            }

            if (attendanceDAO.verifyStudentAppeal(attendanceId, status, remarks)) {
                // Send notification to student
                notificationDAO.sendNotificationToRole(
                    teacher.getName(),
                    "Coordinator",
                    a.getStudentId(),
                    "Student",
                    title,
                    msg,
                    null
                );
                response.sendRedirect("coordinatorAppeals?msg=Appeal processed successfully and student notified.");
            } else {
                response.sendRedirect("coordinatorAppeals?error=Failed to process appeal.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("coordinatorAppeals?error=An error occurred while processing.");
        }
    }
}
