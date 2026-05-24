package com.college.attendance.controller;

import com.college.attendance.dao.UserDAO;
import com.college.attendance.model.Admin;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import com.college.attendance.dao.CoordinatorDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO;
    private CoordinatorDAO coordinatorDAO;

    public void init() {
        userDAO = new UserDAO();
        coordinatorDAO = new CoordinatorDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String identifier = request.getParameter("identifier"); // Email or Roll No
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        HttpSession session = request.getSession();

        if ("Admin".equals(role)) {
            Admin admin = userDAO.authenticateAdmin(identifier, password);
            if (admin != null) {
                session.setAttribute("user", admin);
                session.setAttribute("role", admin.getRole()); // SuperAdmin or Admin
                response.sendRedirect("admin_dashboard.jsp");
                return;
            }
        } else if ("Teacher".equals(role)) {
            Teacher teacher = userDAO.authenticateTeacher(identifier, password);
            if (teacher != null) {
                if (teacher.isBanned()) {
                    request.setAttribute("error", "Your account has been banned by the Administrator.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                if (!teacher.isApproved()) {
                    request.setAttribute("error", "Your account is pending admin approval.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                session.setAttribute("user", teacher);
                session.setAttribute("role", "Teacher");
                if (coordinatorDAO.isCoordinator(teacher.getId())) {
                    session.setAttribute("isCoordinator", true);
                }
                response.sendRedirect("teacher_dashboard.jsp");
                return;
            }
        } else if ("Student".equals(role)) {
            Student student = userDAO.authenticateStudent(identifier, password);
            if (student != null) {
                if (student.isBanned()) {
                    request.setAttribute("error", "Your account has been banned by the Administrator.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                session.setAttribute("user", student);
                session.setAttribute("role", "Student");
                response.sendRedirect("studentDashboard");
                return;
            }
        }

        // Authentication failed
        request.setAttribute("error", "Invalid credentials or role.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
