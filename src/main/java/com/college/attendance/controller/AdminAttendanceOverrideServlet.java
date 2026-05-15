package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Attendance;

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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String subjectIdStr = request.getParameter("subject_id");
        String dateStr = request.getParameter("date");

        if (subjectIdStr != null && !subjectIdStr.isEmpty() && dateStr != null && !dateStr.isEmpty()) {
            int subjectId = Integer.parseInt(subjectIdStr);
            List<Attendance> records = attendanceDAO.getAttendanceBySubjectAndDate(subjectId, dateStr);
            request.setAttribute("records", records);
            request.setAttribute("selectedSubject", subjectIdStr);
            request.setAttribute("selectedDate", dateStr);
        }

        request.setAttribute("subjects", subjectDAO.getAllSubjects());
        request.getRequestDispatcher("admin_attendance.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String[] attendanceIds = request.getParameterValues("attendanceId");
        String subjectId = request.getParameter("subject_id");
        String date = request.getParameter("date");

        if (attendanceIds != null) {
            int updated = 0;
            for (String idStr : attendanceIds) {
                int id = Integer.parseInt(idStr);
                String status = request.getParameter("status_" + id);
                if (attendanceDAO.updateAttendanceStatus(id, status)) {
                    updated++;
                }
            }
            response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&msg=Successfully updated " + updated + " records");
        } else {
            response.sendRedirect("adminAttendance?subject_id=" + subjectId + "&date=" + date + "&error=No records found to update");
        }
    }
}
