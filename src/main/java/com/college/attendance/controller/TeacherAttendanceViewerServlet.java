package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/teacherAttendanceView")
public class TeacherAttendanceViewerServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO;
    private SubjectDAO subjectDAO;
    private com.college.attendance.dao.NotificationDAO notificationDAO;

    public void init() {
        attendanceDAO = new AttendanceDAO();
        subjectDAO = new SubjectDAO();
        notificationDAO = new com.college.attendance.dao.NotificationDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        request.setAttribute("subjects", subjects);

        String subjectIdStr = request.getParameter("subject_id");
        String dateStr = request.getParameter("date");

        if (subjectIdStr != null && !subjectIdStr.isEmpty() && dateStr != null && !dateStr.isEmpty()) {
            try {
                int subjectId = Integer.parseInt(subjectIdStr);
                
                boolean allowed = false;
                for (Subject s : subjects) {
                    if (s.getId() == subjectId) {
                        allowed = true;
                        break;
                    }
                }

                if (allowed) {
                    List<Attendance> records = attendanceDAO.getAttendanceBySubjectAndDate(subjectId, dateStr);
                    request.setAttribute("records", records);
                    request.setAttribute("selectedSubject", subjectIdStr);
                    request.setAttribute("selectedDate", dateStr);
                } else {
                    request.setAttribute("error", "Access to subject data denied.");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid inputs.");
            }
        }

        request.getRequestDispatcher("teacher_attendance_view.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        String subjectIdStr = request.getParameter("subject_id");
        String dateStr = request.getParameter("date");

        if (subjectIdStr == null || subjectIdStr.isEmpty()) {
            response.sendRedirect("teacherAttendanceView?error=Missing subject.");
            return;
        }

        try {
            int subjectId = Integer.parseInt(subjectIdStr);
            List<Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
            boolean allowed = false;
            for (Subject s : subjects) {
                if (s.getId() == subjectId) {
                    allowed = true;
                    break;
                }
            }

            if (!allowed) {
                response.sendRedirect("teacherAttendanceView?error=Permission denied.");
                return;
            }

            if ("appeal".equals(action)) {
                int attendanceId = Integer.parseInt(request.getParameter("attendanceId"));
                if (attendanceDAO.requestAppeal(attendanceId)) {
                    Attendance a = attendanceDAO.getAttendanceById(attendanceId);
                    String msg = teacher.getName() + " has requested an appeal to edit attendance for " + a.getStudentName() + " (" + a.getStudentRollNo() + ") on " + dateStr;
                    notificationDAO.sendNotification(teacher.getName(), "Faculty", 1, "Attendance Appeal Request", msg, null); // 1 = Admin ID
                    response.sendRedirect("teacherAttendanceView?subject_id=" + subjectId + "&date=" + dateStr + "&msg=Appeal submitted successfully. Awaiting Admin approval.");
                } else {
                    response.sendRedirect("teacherAttendanceView?subject_id=" + subjectId + "&date=" + dateStr + "&error=Failed to submit appeal.");
                }
            } else if ("update".equals(action)) {
                int attendanceId = Integer.parseInt(request.getParameter("attendanceId"));
                String status = request.getParameter("status_" + attendanceId);
                
                Attendance a = attendanceDAO.getAttendanceById(attendanceId);
                if (a != null && "Approved".equals(a.getAppealStatus()) && !a.isAdminEdited()) {
                    if (attendanceDAO.updateAttendanceAndResolveAppeal(attendanceId, status)) {
                        response.sendRedirect("teacherAttendanceView?subject_id=" + subjectId + "&date=" + dateStr + "&msg=Attendance updated successfully.");
                    } else {
                        response.sendRedirect("teacherAttendanceView?subject_id=" + subjectId + "&date=" + dateStr + "&error=Failed to update attendance.");
                    }
                } else {
                    response.sendRedirect("teacherAttendanceView?subject_id=" + subjectId + "&date=" + dateStr + "&error=Not authorized to edit this record.");
                }
            } else {
                response.sendRedirect("teacherAttendanceView?subject_id=" + subjectId + "&date=" + dateStr + "&error=Invalid action.");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("teacherAttendanceView?error=Invalid parameters.");
        }
    }
}
