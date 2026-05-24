package com.college.attendance.controller;

import com.college.attendance.dao.UserDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/toggleBan")
public class ToggleBanServlet extends HttpServlet {
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String userRole = request.getParameter("userRole"); // 'Student' or 'Teacher'
            boolean isBanned = Boolean.parseBoolean(request.getParameter("isBanned"));

            boolean success = userDAO.toggleBanStatus(userId, userRole, isBanned);
            if (success) {
                response.sendRedirect(request.getHeader("Referer") + "?msg=Account ban status updated.");
            } else {
                response.sendRedirect(request.getHeader("Referer") + "?error=Failed to update account ban status.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getHeader("Referer") + "?error=System error occurred.");
        }
    }
}
