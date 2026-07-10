package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.model.Student;
import com.college.attendance.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

@WebServlet("/studentSetup")
public class StudentSetupServlet extends HttpServlet {
    private StudentDAO studentDAO = new StudentDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        Student student = (Student) session.getAttribute("user");
        
        // If already completed and verified, redirect to dashboard
        if (student.isProfileCompleted() && student.isParentVerified()) {
            response.sendRedirect("studentDashboard");
            return;
        }

        // If OTP is already generated and pending verification, send to OTP page
        if (session.getAttribute("pending_otp") != null) {
            response.sendRedirect("studentOtp");
            return;
        }

        request.getRequestDispatcher("student_setup.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        Student student = (Student) session.getAttribute("user");

        String phone       = ValidationUtil.clean(request.getParameter("phone"));
        String address     = ValidationUtil.sanitizeText(request.getParameter("address"));
        String parentName  = ValidationUtil.clean(request.getParameter("parent_name"));
        String parentEmail = ValidationUtil.clean(request.getParameter("parent_email"));
        String parentPhone = ValidationUtil.clean(request.getParameter("parent_phone"));

        StringBuilder errors = new StringBuilder();
        if (phone == null || !ValidationUtil.isValidPhone(phone)) errors.append("Valid phone is required. ");
        if (address == null || address.trim().isEmpty()) errors.append("Address is required. ");
        if (parentName == null || !ValidationUtil.isValidName(parentName)) errors.append("Valid parent name is required. ");
        if (parentEmail != null && !parentEmail.trim().isEmpty() && !ValidationUtil.isValidEmail(parentEmail)) errors.append("Invalid parent email. ");
        if (parentPhone == null || !ValidationUtil.isValidPhone(parentPhone)) errors.append("Valid parent phone is required. ");
        if (phone != null && phone.equals(parentPhone)) errors.append("Student phone and guardian phone cannot be the same. ");

        if (errors.length() > 0) {
            request.setAttribute("error", errors.toString());
            request.getRequestDispatcher("student_setup.jsp").forward(request, response);
            return;
        }

        // Update student object
        student.setPhone(phone);
        student.setParentName(parentName);
        student.setParentEmail(parentEmail);
        student.setParentPhone(parentPhone);
        
        // We do not set it to completed in DB yet until OTP is verified.
        // Or we can save to DB and keep verified=false
        studentDAO.updateStudent(student, address);
        
        // Re-fetch the student to ensure session is updated or just use the current object
        
        // Generate OTP
        String otp = String.format("%06d", new Random().nextInt(999999));
        
        // MOCK SMS SENDING
        System.out.println("==================================================");
        System.out.println("SMS SENT TO PARENT PHONE: " + parentPhone);
        System.out.println("MOCK OTP FOR STUDENT " + student.getName() + " IS: " + otp);
        System.out.println("==================================================");

        // Store OTP in session
        session.setAttribute("pending_otp", otp);
        
        // Put a flash message that SMS is sent
        session.setAttribute("setup_msg", "An OTP has been sent to your parent's phone number.");

        response.sendRedirect("studentOtp");
    }
}
