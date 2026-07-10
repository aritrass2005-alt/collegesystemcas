package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/studentOtp")
public class StudentOtpServlet extends HttpServlet {
    private StudentDAO studentDAO = new StudentDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Must have pending OTP
        if (session.getAttribute("pending_otp") == null) {
            response.sendRedirect("studentSetup");
            return;
        }

        request.getRequestDispatcher("student_otp.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String pendingOtp = (String) session.getAttribute("pending_otp");
        if (pendingOtp == null) {
            response.sendRedirect("studentSetup");
            return;
        }

        String userOtp = request.getParameter("otp");

        if (userOtp != null && userOtp.equals(pendingOtp)) {
            // Success
            Student student = (Student) session.getAttribute("user");
            student.setProfileCompleted(true);
            student.setParentVerified(true);
            
            // We pass null or empty for address in updateStudent? 
            // Wait, updateStudent requires address. Let's get it from DB.
            Student dbStudent = studentDAO.getStudentById(student.getId());
            if (dbStudent != null) {
                // Keep the fields we updated previously in StudentSetupServlet
                dbStudent.setPhone(student.getPhone());
                dbStudent.setParentName(student.getParentName());
                dbStudent.setParentEmail(student.getParentEmail());
                dbStudent.setParentPhone(student.getParentPhone());
                
                dbStudent.setProfileCompleted(true);
                dbStudent.setParentVerified(true);
                
                // We don't have address easily, let's fetch from DB if needed, or update query
                // Actually Student doesn't store address in model properties in this project. Wait, Student model doesn't have address getter! Let's check Student.java.
                // Yes, Student.java does have getAddress()! Wait, I saw it in view_file.
                studentDAO.updateStudent(dbStudent, dbStudent.getAddress());
                
                // Update session object
                session.setAttribute("user", dbStudent);
            }
            
            session.removeAttribute("pending_otp");
            session.removeAttribute("setup_msg");
            
            response.sendRedirect("studentDashboard");
        } else {
            // Fail
            request.setAttribute("error", "Invalid OTP. Please try again.");
            request.getRequestDispatcher("student_otp.jsp").forward(request, response);
        }
    }
}
