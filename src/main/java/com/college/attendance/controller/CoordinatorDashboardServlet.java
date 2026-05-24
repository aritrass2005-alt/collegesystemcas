package com.college.attendance.controller;

import com.college.attendance.dao.CoordinatorDAO;
import com.college.attendance.dao.LeaveApplicationDAO;
import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Coordinator;
import com.college.attendance.model.LeaveApplication;
import com.college.attendance.model.DefaulterRecord;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/coordinatorDashboard")
public class CoordinatorDashboardServlet extends HttpServlet {
    private CoordinatorDAO coordinatorDAO = new CoordinatorDAO();
    private LeaveApplicationDAO leaveDAO  = new LeaveApplicationDAO();
    private AttendanceDAO attendanceDAO   = new AttendanceDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");

        if (teacher == null || !"Teacher".equals(session.getAttribute("role")) || isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        // Get all coordinator assignments for this teacher
        List<Coordinator> assignments = coordinatorDAO.getCoordinatorAssignments(teacher.getId());

        // Determine active class context (from param or session default)
        String activeAssignmentIdStr = request.getParameter("assignmentId");
        Integer activeAssignmentId = null;
        if (activeAssignmentIdStr != null) {
            try { activeAssignmentId = Integer.parseInt(activeAssignmentIdStr); } catch (NumberFormatException ignored) {}
            session.setAttribute("activeCoordAssignmentId", activeAssignmentId);
        } else {
            activeAssignmentId = (Integer) session.getAttribute("activeCoordAssignmentId");
        }

        Coordinator activeAssignment = null;
        if (assignments != null && !assignments.isEmpty()) {
            if (activeAssignmentId != null) {
                for (Coordinator c : assignments) {
                    if (c.getId() == activeAssignmentId) { activeAssignment = c; break; }
                }
            }
            if (activeAssignment == null) {
                activeAssignment = assignments.get(0); // default to first
                session.setAttribute("activeCoordAssignmentId", activeAssignment.getId());
            }
        }

        // Load data for the active assignment
        List<LeaveApplication> leaves = leaveDAO.getLeavesForCoordinator(teacher.getId());
        List<DefaulterRecord> defaulters = null;
        int studentCount = 0;
        int pendingLeaves = 0;

        if (activeAssignment != null) {
            Double sessionThreshold = (Double) session.getAttribute("defaulterThreshold");
            double threshold = sessionThreshold != null ? sessionThreshold : 75.0;

            defaulters = attendanceDAO.getDefaultersForSection(
                activeAssignment.getDepartment(), activeAssignment.getYear(),
                activeAssignment.getSection(), threshold);
            request.setAttribute("currentThreshold", threshold);
            studentCount = getStudentCount(activeAssignment);
            if (leaves != null) {
                for (LeaveApplication l : leaves) { if ("Pending".equals(l.getStatus())) pendingLeaves++; }
            }
        }

        request.setAttribute("assignments", assignments);
        request.setAttribute("activeAssignment", activeAssignment);
        request.setAttribute("leaves", leaves);
        request.setAttribute("defaulters", defaulters);
        request.setAttribute("studentCount", studentCount);
        request.setAttribute("pendingLeaves", pendingLeaves);

        request.getRequestDispatcher("coordinator_dashboard.jsp").forward(request, response);
    }

    private int getStudentCount(Coordinator c) {
        try (java.sql.Connection conn = com.college.attendance.util.DBConnection.getConnection()) {
            String sql = "SELECT COUNT(*) FROM student WHERE department=? AND year=? AND (? IS NULL OR ?='' OR section=?)";
            java.sql.PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, c.getDepartment());
            stmt.setInt(2, c.getYear());
            String sec = (c.getSection() == null || c.getSection().isEmpty()) ? null : c.getSection();
            stmt.setString(3, sec); stmt.setString(4, sec); stmt.setString(5, sec);
            java.sql.ResultSet rs = stmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}
