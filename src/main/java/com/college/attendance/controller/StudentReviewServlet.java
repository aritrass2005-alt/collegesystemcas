package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceReviewDAO;
import com.college.attendance.model.AttendanceReview;
import com.college.attendance.model.Student;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.college.attendance.dao.SubjectDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/studentReviews")
public class StudentReviewServlet extends HttpServlet {
    private AttendanceReviewDAO reviewDAO;
    private SubjectDAO subjectDAO;

    public void init() {
        reviewDAO = new AttendanceReviewDAO();
        subjectDAO = new SubjectDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student currentStudent = (Student) session.getAttribute("user");
        if (currentStudent == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        com.college.attendance.dao.AttendanceDAO attendanceDAO = new com.college.attendance.dao.AttendanceDAO();
        request.setAttribute("absentDates", attendanceDAO.getAbsentDatesForStudent(currentStudent.getId()));
        
        request.setAttribute("reviews", reviewDAO.getReviewsByStudent(currentStudent.getId()));
        request.setAttribute("subjects", subjectDAO.getSubjectsByFilter(currentStudent.getDepartment(), String.valueOf(currentStudent.getYear()), null));
        request.getRequestDispatcher("student_reviews.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student currentStudent = (Student) session.getAttribute("user");
        if (currentStudent == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equals(action)) {
            try {
                String subjectIdStr = request.getParameter("subjectId");
                int subjectId = (subjectIdStr != null && !subjectIdStr.isEmpty()) ? Integer.parseInt(subjectIdStr) : 0;
                String reviewDateStr = request.getParameter("reviewDate");
                String reason = request.getParameter("reason");

                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date reviewDate = sdf.parse(reviewDateStr);

                if (reviewDAO.hasExistingReview(currentStudent.getId(), subjectId, reviewDate)) {
                    response.sendRedirect("studentReviews?error=You+have+already+appealed+for+this+date+and+subject.");
                    return;
                }

                AttendanceReview review = new AttendanceReview();
                review.setStudentId(currentStudent.getId());
                review.setSubjectId(subjectId);
                review.setReviewDate(reviewDate);
                review.setReason(reason);

                if (reviewDAO.createReview(review)) {
                    // Notify Coordinators
                    com.college.attendance.dao.NotificationDAO notifDAO = new com.college.attendance.dao.NotificationDAO();
                    com.college.attendance.dao.CoordinatorDAO coordDAO = new com.college.attendance.dao.CoordinatorDAO();
                    java.util.List<com.college.attendance.model.Coordinator> coordinators = coordDAO.getAllCoordinators();
                    if (coordinators != null) {
                        for (com.college.attendance.model.Coordinator coord : coordinators) {
                            notifDAO.sendNotification(currentStudent.getName(), "Student", coord.getTeacherId(), "Teacher", "New Review Request", "Student " + currentStudent.getName() + " (" + currentStudent.getRollNo() + ") requested an attendance review for " + reviewDateStr + ".", null);
                        }
                    }
                    response.sendRedirect("studentReviews?msg=Review+request+created+successfully.");
                } else {
                    response.sendRedirect("studentReviews?error=Failed+to+create+review+request.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("studentReviews?error=Invalid input provided.");
            }
        } else if ("delete".equals(action)) {
            try {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                if (reviewDAO.deleteReview(reviewId, currentStudent.getId())) {
                    response.sendRedirect("studentReviews?msg=Review+request+deleted+successfully.");
                } else {
                    response.sendRedirect("studentReviews?error=Failed+to+delete+review+request+or+it+is+already+processed.");
                }
            } catch (Exception e) {
                response.sendRedirect("studentReviews?error=Invalid input provided.");
            }
        }
    }
}
