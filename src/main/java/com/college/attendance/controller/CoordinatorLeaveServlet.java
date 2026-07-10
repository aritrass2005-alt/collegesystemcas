package com.college.attendance.controller;

import com.college.attendance.dao.LeaveApplicationDAO;
import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.LeaveApplication;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/coordinatorLeaves")
public class CoordinatorLeaveServlet extends HttpServlet {
    private LeaveApplicationDAO leaveDAO = new LeaveApplicationDAO();
    private AttendanceDAO attendanceDAO = new AttendanceDAO();
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role")) || isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<LeaveApplication> leaves = leaveDAO.getLeavesForCoordinator(teacher.getId());

        request.setAttribute("leaves", leaves);
        request.getRequestDispatcher("coordinator_leaves.jsp").forward(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role")) || isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        int leaveId = Integer.parseInt(request.getParameter("leaveId"));

        if ("Approve".equals(action) || "Reject".equals(action)) {
            String newStatus = "Approve".equals(action) ? "Approved" : "Rejected";
            leaveDAO.updateLeaveStatus(leaveId, newStatus);
            
            if ("Approve".equals(action)) {
                LeaveApplication leave = leaveDAO.getLeaveById(leaveId);
                if (leave != null) {
                    attendanceDAO.markLeaveDays(leave.getStudentId(), leave.getStartDate(), leave.getEndDate());
                }
            }
        }
        
        response.sendRedirect("coordinatorLeaves?msg=Leave application " + action.toLowerCase() + "d successfully");
    }
}
