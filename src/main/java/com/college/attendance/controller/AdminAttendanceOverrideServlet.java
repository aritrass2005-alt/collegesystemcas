package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminAttendance")
public class AdminAttendanceOverrideServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO = new AttendanceDAO();
    private SubjectDAO subjectDAO = new SubjectDAO();

    private boolean isAdmin(HttpSession session) {
        return session.getAttribute("user") != null
                && ("Admin".equals(session.getAttribute("role"))
                    || "SuperAdmin".equals(session.getAttribute("role")));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String subjectIdStr = ValidationUtil.clean(request.getParameter("subject_id"));
        String dateStr      = ValidationUtil.clean(request.getParameter("date"));

        if (subjectIdStr != null && dateStr != null) {
            if (!ValidationUtil.isPositiveInt(subjectIdStr)) {
                request.setAttribute("error", "Invalid subject ID.");
            } else if (!ValidationUtil.isValidDate(dateStr)) {
                request.setAttribute("error", "Invalid date format.");
            } else {
                int subjectId = Integer.parseInt(subjectIdStr);
                List<Attendance> records = attendanceDAO.getAttendanceBySubjectAndDate(subjectId, dateStr);
                request.setAttribute("records",          records);
                request.setAttribute("selectedSubject",  subjectIdStr);
                request.setAttribute("selectedDate",     dateStr);
            }
        }

        request.setAttribute("subjects", subjectDAO.getAllSubjects());
        request.getRequestDispatcher("admin_attendance.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String approveAppealIdStr = ValidationUtil.clean(request.getParameter("approveAppeal"));
        String action             = ValidationUtil.clean(request.getParameter("action"));
        String subjectId          = ValidationUtil.clean(request.getParameter("subject_id"));
        String date               = ValidationUtil.clean(request.getParameter("date"));

        // Validate redirect context params
        if (!ValidationUtil.isPositiveInt(subjectId) || !ValidationUtil.isValidDate(date)) {
            response.sendRedirect("adminAttendance?error=Invalid+parameters");
            return;
        }

        if (approveAppealIdStr != null && !approveAppealIdStr.isEmpty()) {
            if (!ValidationUtil.isPositiveInt(approveAppealIdStr)) {
                response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&error=Invalid+appeal+ID");
                return;
            }
            int attendanceId = Integer.parseInt(approveAppealIdStr);
            if (attendanceDAO.approveAppeal(attendanceId)) {
                response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&msg=Appeal+approved+successfully");
            } else {
                response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&error=Failed+to+approve+appeal");
            }
            return;
        }

        if ("updateAll".equals(action)) {
            String[] attendanceIds = request.getParameterValues("attendanceId");
            if (attendanceIds != null) {
                int updated = 0;
                for (String idStr : attendanceIds) {
                    if (!ValidationUtil.isPositiveInt(idStr)) continue;
                    int id = Integer.parseInt(idStr);
                    String status = ValidationUtil.clean(request.getParameter("status_" + id));

                    // Whitelist: only Present or Absent allowed for admin override
                    if (!"Present".equals(status) && !"Absent".equals(status)) continue;

                    Attendance a = attendanceDAO.getAttendanceById(id);
                    if (a != null && !a.isAdminEdited() && !a.getStatus().equals(status)) {
                        if (attendanceDAO.updateAttendanceByAdmin(id, status)) updated++;
                    }
                }
                response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&msg=Locked+" + updated + "+records");
            } else {
                response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&error=No+records+to+update");
            }
        } else {
            response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date);
        }
    }
}
