package com.college.attendance.controller;

import com.college.attendance.dao.UserDAO;
import com.college.attendance.model.Admin;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/adminProfile")
public class AdminProfileServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }
        request.getRequestDispatcher("admin_profile.jsp").forward(request, response);
    }


    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Admin admin = (Admin) session.getAttribute("user");
        if (admin == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("updateProfile".equals(action)) {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            
            if (userDAO.updateAdminProfile(admin.getId(), name, email)) {
                admin.setName(name);
                admin.setEmail(email);
                session.setAttribute("user", admin);
                response.sendRedirect("admin_profile.jsp?msg=Profile updated successfully");
            } else {
                response.sendRedirect("admin_profile.jsp?error=Failed to update profile");
            }
        } else if ("updatePassword".equals(action)) {
            String newPassword = request.getParameter("newPassword");
            String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
            
            if (userDAO.updateAdminPassword(admin.getId(), hashedPassword)) {
                response.sendRedirect("admin_profile.jsp?msg=Password updated successfully");
            } else {
                response.sendRedirect("admin_profile.jsp?error=Failed to update password");
            }
        }
    }
}
