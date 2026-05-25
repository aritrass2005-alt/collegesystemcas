package com.college.attendance.controller;

import com.college.attendance.dao.UserDAO;
import com.college.attendance.model.Admin;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import com.college.attendance.dao.CoordinatorDAO;
import com.college.attendance.util.ValidationUtil;

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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Redirect already-logged-in users
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            String role = (String) session.getAttribute("role");
            if ("Student".equals(role)) response.sendRedirect("studentDashboard");
            else if ("Teacher".equals(role)) response.sendRedirect("teacher_dashboard.jsp");
            else response.sendRedirect("admin_dashboard.jsp");
            return;
        }
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String identifier = ValidationUtil.clean(request.getParameter("identifier"));
        String password   = request.getParameter("password");
        String role       = ValidationUtil.clean(request.getParameter("role"));

        // ── Basic field validation ──────────────────────────────────────────
        if (identifier == null || password == null || role == null) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        if (!ValidationUtil.isValidRole(role)) {
            request.setAttribute("error", "Invalid role selected.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        if (password.length() < 4 || password.length() > 128) {
            request.setAttribute("error", "Invalid credentials.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();

        if ("Admin".equals(role)) {
            if (!ValidationUtil.isValidEmail(identifier)) {
                request.setAttribute("error", "Invalid email format.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            Admin admin = userDAO.authenticateAdmin(identifier, password);
            if (admin != null) {
                // Regenerate session to prevent session fixation
                session.invalidate();
                session = request.getSession(true);
                session.setAttribute("user", admin);
                session.setAttribute("role", admin.getRole());
                session.setMaxInactiveInterval(3600); // 1 hour
                response.sendRedirect("admin_dashboard.jsp");
                return;
            }
        } else if ("Teacher".equals(role)) {
            if (!ValidationUtil.isValidEmail(identifier)) {
                request.setAttribute("error", "Invalid email format.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
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
                session.invalidate();
                session = request.getSession(true);
                session.setAttribute("user", teacher);
                session.setAttribute("role", "Teacher");
                session.setMaxInactiveInterval(3600);
                if (coordinatorDAO.isCoordinator(teacher.getId())) {
                    session.setAttribute("isCoordinator", true);
                }
                response.sendRedirect("teacher_dashboard.jsp");
                return;
            }
        } else if ("Student".equals(role)) {
            if (!ValidationUtil.isValidRollNo(identifier)) {
                request.setAttribute("error", "Invalid Roll No format.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            Student student = userDAO.authenticateStudent(identifier, password);
            if (student != null) {
                if (student.isBanned()) {
                    request.setAttribute("error", "Your account has been banned by the Administrator.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
                session.invalidate();
                session = request.getSession(true);
                session.setAttribute("user", student);
                session.setAttribute("role", "Student");
                session.setMaxInactiveInterval(3600);
                response.sendRedirect("studentDashboard");
                return;
            }
        }

        // Generic failure message — don't reveal which field was wrong
        request.setAttribute("error", "Invalid credentials. Please check your details and try again.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
