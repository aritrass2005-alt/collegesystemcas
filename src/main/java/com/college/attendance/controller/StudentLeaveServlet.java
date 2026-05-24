package com.college.attendance.controller;

import com.college.attendance.dao.LeaveApplicationDAO;
import com.college.attendance.model.LeaveApplication;
import com.college.attendance.model.Student;

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
import java.util.List;
import java.util.UUID;

@WebServlet("/studentLeave")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 15
)
public class StudentLeaveServlet extends HttpServlet {
    private LeaveApplicationDAO leaveDAO = new LeaveApplicationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<LeaveApplication> leaves = leaveDAO.getLeavesByStudent(student.getId());
        request.setAttribute("leaves", leaves);
        
        request.getRequestDispatcher("student_leave.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String reason = request.getParameter("reason");
        String startDate = request.getParameter("start_date");
        String endDate = request.getParameter("end_date");
        boolean declaration = request.getParameter("declaration") != null;
        
        String proofPath = ""; 
        try {
            Part filePart = request.getPart("proof");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = UUID.randomUUID().toString() + "_" + filePart.getSubmittedFileName().replaceAll("[^a-zA-Z0-9\\.\\-]", "_");
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "leaves";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                
                filePart.write(uploadPath + File.separator + fileName);
                proofPath = "uploads/leaves/" + fileName;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        LeaveApplication leave = new LeaveApplication();
        leave.setStudentId(student.getId());
        leave.setReason(reason);
        leave.setStartDate(startDate);
        leave.setEndDate(endDate);
        leave.setDeclaration(declaration);
        leave.setProofPath(proofPath);

        boolean success = leaveDAO.submitLeave(leave);
        
        if (success) {
            response.sendRedirect("studentLeave?msg=Leave application submitted successfully");
        } else {
            response.sendRedirect("studentLeave?error=Failed to submit leave application");
        }
    }
}
