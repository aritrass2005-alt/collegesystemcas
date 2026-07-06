package com.college.attendance.controller;

import com.college.attendance.dao.FacultyAttendanceDAO;
import com.college.attendance.model.FacultyAttendance;
import com.college.attendance.model.Teacher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;
import java.util.List;

@WebServlet("/facultyAttendance")
public class FacultyAttendanceServlet extends HttpServlet {
    private FacultyAttendanceDAO dao = new FacultyAttendanceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        if ("checkin".equals(action)) {
            dao.checkIn(teacher.getId());
            com.college.attendance.dao.ActivityLogDAO.log("Teacher", teacher.getName(), "Checked In");
            response.sendRedirect("teacher_dashboard.jsp?msg=Checked In Successfully");
            return;
        } else if ("checkout".equals(action)) {
            dao.checkOut(teacher.getId());
            com.college.attendance.dao.ActivityLogDAO.log("Teacher", teacher.getName(), "Checked Out");
            response.sendRedirect("teacher_dashboard.jsp?msg=Checked Out Successfully");
            return;
        } else if ("cancel_leave".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                FacultyAttendance fa = dao.getAttendanceById(id);
                if (fa != null && fa.getTeacherId() == teacher.getId() && !fa.isVerifiedByAdmin()) {
                    dao.deleteFacultyLeave(id);
                    com.college.attendance.dao.ActivityLogDAO.log("Teacher", teacher.getName(), "Canceled leave application for " + fa.getDate());
                    response.sendRedirect("facultyAttendance?msg=Leave Canceled Successfully");
                } else {
                    response.sendRedirect("facultyAttendance?error=Cannot cancel this leave");
                }
            } catch (Exception e) {
                response.sendRedirect("facultyAttendance?error=Invalid Request");
            }
            return;
        }

        // Default view: Calendar and history
        List<FacultyAttendance> history = dao.getHistoryByTeacher(teacher.getId());
        request.setAttribute("history", history);
        request.getRequestDispatcher("teacher_my_attendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        if ("apply_leave".equals(action)) {
            try {
                Date startDate = Date.valueOf(request.getParameter("startDate"));
                Date endDate = Date.valueOf(request.getParameter("endDate"));
                String status = request.getParameter("status"); // CL, CCL, EL, etc.
                String notes = request.getParameter("notes");
                
                if (endDate.before(startDate)) {
                    response.sendRedirect("facultyAttendance?error=End Date cannot be before Start Date");
                    return;
                }

                Calendar start = Calendar.getInstance();
                start.setTime(startDate);
                Calendar end = Calendar.getInstance();
                end.setTime(endDate);
                
                boolean success = true;

                while (!start.after(end)) {
                    Date currentDate = new Date(start.getTimeInMillis());
                    boolean inserted = dao.applyLeaveByFaculty(teacher.getId(), currentDate, status, notes);
                    if (!inserted) {
                        success = false;
                    }
                    start.add(Calendar.DATE, 1);
                }

                if (success) {
                    com.college.attendance.dao.ActivityLogDAO.log("Teacher", teacher.getName(), "Applied for leave from " + startDate + " to " + endDate);
                    response.sendRedirect("facultyAttendance?msg=Leave Applied Successfully");
                } else {
                    response.sendRedirect("facultyAttendance?error=Failed to Apply Leave completely");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("facultyAttendance?error=Invalid Date Format");
            }
        }
    }
}
