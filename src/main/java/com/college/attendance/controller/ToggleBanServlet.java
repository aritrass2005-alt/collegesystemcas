package com.college.attendance.controller;

import com.college.attendance.dao.UserDAO;
import com.college.attendance.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/toggleBan")
public class ToggleBanServlet extends HttpServlet {
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || (!"Admin".equals(session.getAttribute("role"))
                    && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String userIdStr  = ValidationUtil.clean(request.getParameter("userId"));
        String userRole   = ValidationUtil.clean(request.getParameter("userRole"));
        String bannedStr  = ValidationUtil.clean(request.getParameter("isBanned"));

        // Validate all inputs
        if (!ValidationUtil.isPositiveInt(userIdStr)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID.");
            return;
        }
        // Only Student or Teacher can be banned — prevent tampering to ban admins
        if (!"Student".equalsIgnoreCase(userRole) && !"Teacher".equalsIgnoreCase(userRole)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid role for ban operation.");
            return;
        }
        if (bannedStr == null || (!bannedStr.equals("true") && !bannedStr.equals("false"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ban status.");
            return;
        }

        int     userId   = Integer.parseInt(userIdStr);
        boolean isBanned = Boolean.parseBoolean(bannedStr);

        // Safe referer redirect (guard against open-redirect)
        String referer = ValidationUtil.safeRedirectUrl(request.getHeader("Referer"), "admin_dashboard.jsp");

        try {
            boolean success = userDAO.toggleBanStatus(userId, userRole, isBanned);
            if (success) {
                response.sendRedirect(referer + (referer.contains("?") ? "&" : "?") + "msg=Ban+status+updated");
            } else {
                response.sendRedirect(referer + (referer.contains("?") ? "&" : "?") + "error=Failed+to+update+ban+status");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(referer + (referer.contains("?") ? "&" : "?") + "error=System+error+occurred");
        }
    }
}
