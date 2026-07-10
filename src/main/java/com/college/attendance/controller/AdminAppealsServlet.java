package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Attendance;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/adminAppeals")
public class AdminAppealsServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO = new AttendanceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null ||
            (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Attendance> pendingAppeals = attendanceDAO.getPendingAppeals();
        request.setAttribute("pendingAppeals", pendingAppeals);
        request.getRequestDispatcher("admin_appeals.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null ||
            (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        int attendanceId = Integer.parseInt(request.getParameter("attendanceId"));

        if ("approve".equals(action)) {
            // Approve = set appeal_status to 'Approved' so teacher can then edit
            if (attendanceDAO.approveAppeal(attendanceId)) {
                response.sendRedirect("adminAppeals?msg=Appeal approved. Teacher can now edit the record.");
            } else {
                response.sendRedirect("adminAppeals?error=Failed to approve appeal.");
            }
        } else if ("reject".equals(action)) {
            // Reject = clear appeal_status back to null
            if (attendanceDAO.rejectAppeal(attendanceId)) {
                response.sendRedirect("adminAppeals?msg=Appeal rejected successfully.");
            } else {
                response.sendRedirect("adminAppeals?error=Failed to reject appeal.");
            }
        } else if ("adminEdit".equals(action)) {
            // Admin edits directly and locks the record permanently
            String status = request.getParameter("newStatus");
            if (attendanceDAO.updateAttendanceByAdmin(attendanceId, status)) {
                response.sendRedirect("adminAppeals?msg=Attendance updated and locked by Admin.");
            } else {
                response.sendRedirect("adminAppeals?error=Failed to update attendance.");
            }
        } else {
            response.sendRedirect("adminAppeals");
        }
    }
}
