package com.college.attendance.controller;

import com.college.attendance.dao.UserDAO;
import com.college.attendance.model.Admin;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/manageAdmins")
public class ManageAdminServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"SuperAdmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            userDAO.deleteAdmin(id);
            response.sendRedirect("manageAdmins");
            return;
        }

        request.setAttribute("admins", userDAO.getAllAdmins());
        request.getRequestDispatcher("admin_admins.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"SuperAdmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        Admin newAdmin = new Admin();
        newAdmin.setName(name);
        newAdmin.setEmail(email);
        newAdmin.setRole(role);

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

        if (userDAO.addAdmin(newAdmin, hashedPassword)) {
            response.sendRedirect("manageAdmins?msg=Admin added successfully");
        } else {
            response.sendRedirect("manageAdmins?error=Failed to add admin");
        }
    }
}
