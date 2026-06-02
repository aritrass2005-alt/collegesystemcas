package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceReviewDAO;
import com.college.attendance.model.AttendanceReview;
import com.college.attendance.model.ReviewChat;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;

@WebServlet("/reviewChat")
@MultipartConfig(maxFileSize = 25 * 1024 * 1024)
public class ReviewChatServlet extends HttpServlet {
    private AttendanceReviewDAO reviewDAO;

    public void init() {
        reviewDAO = new AttendanceReviewDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        
        if (role == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int reviewId = Integer.parseInt(request.getParameter("id"));
            AttendanceReview review = reviewDAO.getReviewById(reviewId);
            
            if (review == null) {
                response.sendRedirect(request.getHeader("Referer") + "?error=Review not found.");
                return;
            }

            request.setAttribute("review", review);
            request.setAttribute("chats", reviewDAO.getChatByReviewId(reviewId));
            
            boolean isCoordinator = false;
            if ("Teacher".equals(role)) {
                Boolean isCoordAttr = (Boolean) session.getAttribute("isCoordinator");
                isCoordinator = (isCoordAttr != null && isCoordAttr);
            }

            // Wait, if it's coordinator, we should mark status as In Review if it was Pending
            if (isCoordinator && "Pending".equals(review.getStatus())) {
                Teacher coordinator = (Teacher) session.getAttribute("user");
                reviewDAO.updateReviewStatus(reviewId, "In Review", coordinator.getId());
                review.setStatus("In Review");
            }
            
            request.getRequestDispatcher("review_chat.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getHeader("Referer") + "?error=Invalid review ID.");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        
        if (role == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        boolean isCoordinator = false;
        if ("Teacher".equals(role)) {
            Boolean isCoordAttr = (Boolean) session.getAttribute("isCoordinator");
            isCoordinator = (isCoordAttr != null && isCoordAttr);
        }

        String action = request.getParameter("action");
        try {
            int reviewId = Integer.parseInt(request.getParameter("reviewId"));
            AttendanceReview review = reviewDAO.getReviewById(reviewId);
            
            if ("sendMessage".equals(action)) {
                String message = request.getParameter("message");
                
                ReviewChat chat = new ReviewChat();
                chat.setReviewId(reviewId);
                chat.setMessage(message);
                
                if ("Student".equals(role)) {
                    Student student = (Student) session.getAttribute("user");
                    chat.setSenderType("Student");
                    chat.setSenderId(student.getId());
                } else if (isCoordinator) {
                    Teacher coordinator = (Teacher) session.getAttribute("user");
                    chat.setSenderType("Coordinator");
                    chat.setSenderId(coordinator.getId());
                }
                
                Part filePart = request.getPart("attachment");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = System.currentTimeMillis() + "_" + getFileName(filePart);
                    String uploadDir = System.getProperty("user.home") + File.separator + "cas_uploads" + File.separator + "uploads";
                    new File(uploadDir).mkdirs();
                    filePart.write(uploadDir + File.separator + fileName);
                    chat.setProofPath("uploads/" + fileName);
                }
                
                reviewDAO.addChatMessage(chat);
                response.sendRedirect("reviewChat?id=" + reviewId);
                
            } else if ("updateStatus".equals(action) && isCoordinator) {
                String newStatus = request.getParameter("status"); // Approved or Rejected
                Teacher coordinator = (Teacher) session.getAttribute("user");
                
                reviewDAO.updateReviewStatus(reviewId, newStatus, coordinator.getId());
                
                if ("Approved".equals(newStatus)) {
                    // Automatically notify Teachers and Admin
                    // We'll call the NotificationDAO here
                    com.college.attendance.dao.NotificationDAO notifDAO = new com.college.attendance.dao.NotificationDAO();
                    String title = "Attendance Review Approved";
                    String msg = "Coordinator " + coordinator.getName() + " approved the attendance review for " + review.getStudentName() + " (" + review.getStudentRollNo() + ") on " + review.getReviewDate() + ". Please update attendance accordingly.";
                    
                    // Notify Admin
                    notifDAO.sendNotification("System", "System", 1, "Admin", title, msg, null);
                    
                    // Notify Teacher if subject specific, else notify all teachers of student
                    if (review.getSubjectId() > 0) {
                        com.college.attendance.dao.SubjectDAO subDao = new com.college.attendance.dao.SubjectDAO();
                        com.college.attendance.model.Subject sub = subDao.getSubjectById(review.getSubjectId());
                        if (sub != null && sub.getTeacherId() > 0) {
                            notifDAO.sendNotification("System", "System", sub.getTeacherId(), "Teacher", title, msg, null);
                        }
                    } else {
                        String sql = "SELECT DISTINCT sub.teacher_id FROM subject sub JOIN student s ON sub.department = s.department AND sub.year = s.year AND (sub.section IS NULL OR sub.section = '' OR sub.section = s.section) WHERE s.id = ?";
                        try (java.sql.Connection conn = com.college.attendance.util.DBConnection.getConnection();
                             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setInt(1, review.getStudentId());
                            try (java.sql.ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    int tid = rs.getInt("teacher_id");
                                    if (tid > 0) {
                                        notifDAO.sendNotification("System", "System", tid, "Teacher", title, msg, null);
                                    }
                                }
                            }
                        } catch (Exception e) {}
                    }
                    
                    // Notify Student
                    notifDAO.sendNotification(coordinator.getName(), "Coordinator", review.getStudentId(), "Student", "Review Approved", "Your attendance review for " + review.getReviewDate() + " has been approved.", null);
                } else if ("Rejected".equals(newStatus)) {
                    com.college.attendance.dao.NotificationDAO notifDAO = new com.college.attendance.dao.NotificationDAO();
                    notifDAO.sendNotification(coordinator.getName(), "Coordinator", review.getStudentId(), "Student", "Review Rejected", "Your attendance review for " + review.getReviewDate() + " has been rejected.", null);
                }
                
                response.sendRedirect("reviewChat?id=" + reviewId + "&msg=Status updated successfully.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getHeader("Referer") + "?error=An error occurred.");
        }
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "attachment";
    }
}
