package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceReviewDAO;
import com.college.attendance.dao.CoordinatorDAO;
import com.college.attendance.model.Teacher;
import com.college.attendance.model.Coordinator;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/coordinatorReviews")
public class CoordinatorReviewServlet extends HttpServlet {
    private AttendanceReviewDAO reviewDAO;
    private CoordinatorDAO coordinatorDAO;

    public void init() {
        reviewDAO = new AttendanceReviewDAO();
        coordinatorDAO = new CoordinatorDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher currentTeacher = (Teacher) session.getAttribute("user");
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
        
        if (currentTeacher == null || !"Teacher".equals(session.getAttribute("role")) || isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // Get coordinator details to know which students they manage
            List<Coordinator> coords = coordinatorDAO.getCoordinatorAssignments(currentTeacher.getId());
            if (coords != null && !coords.isEmpty()) {
                Coordinator c = coords.get(0);
                request.setAttribute("reviews", reviewDAO.getReviewsForCoordinator(currentTeacher.getId(), c.getDepartment(), c.getYear(), c.getSection()));
            }
            
            request.getRequestDispatcher("coordinator_reviews.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getHeader("Referer") + "?error=Failed to load review requests.");
        }
    }
}

