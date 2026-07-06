package com.college.attendance.controller;

import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Teacher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/registerTeacher")
public class TeacherRegisterServlet extends HttpServlet {
    private TeacherDAO teacherDAO;

    public void init() {
        teacherDAO = new TeacherDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String department = request.getParameter("department");
        String password = request.getParameter("password");
        
        Teacher t = new Teacher();
        t.setName(name);
        t.setEmail(email);
        t.setPhone(phone);
        t.setDepartment(department);
        
        boolean success = teacherDAO.registerTeacher(t, password);
        
        if (success) {
            response.sendRedirect("login.jsp?msg=Registration successful! Please wait for admin approval to log in.");
        } else {
            response.sendRedirect("teacher_register.jsp?error=Registration failed. Email may already exist.");
        }
    }
}
