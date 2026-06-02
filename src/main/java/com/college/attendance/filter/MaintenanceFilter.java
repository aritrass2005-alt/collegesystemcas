package com.college.attendance.filter;

import com.college.attendance.util.SystemConfigManager;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Blocks ALL requests when maintenance mode is ON.
 * Only SuperAdmin and Admin sessions are allowed through.
 * The login page is still accessible so SuperAdmin can log in and disable maintenance.
 */
@WebFilter(urlPatterns = "/*")
public class MaintenanceFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpRes = (HttpServletResponse) response;
        SystemConfigManager config = SystemConfigManager.getInstance();

        if (!config.isMaintenanceMode()) {
            chain.doFilter(request, response);
            return;
        }

        // Allow static resources and login-related paths
        String uri = httpReq.getRequestURI();
        String ctx = httpReq.getContextPath();
        String path = uri.substring(ctx.length());

        // Always allow: login page, login servlet, logout, static assets, systemControl
        if (path.equals("/login") || path.equals("/login.jsp") || path.equals("/logout")
                || path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/img/")
                || path.equals("/systemControl") || path.equals("/maintenance.jsp")
                || path.startsWith("/index.jsp") || path.equals("/")) {
            chain.doFilter(request, response);
            return;
        }

        // Allow logged-in Admin/SuperAdmin through
        HttpSession session = httpReq.getSession(false);
        if (session != null) {
            String role = (String) session.getAttribute("role");
            if ("Admin".equals(role) || "SuperAdmin".equals(role)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Everyone else sees the maintenance page
        httpRes.setStatus(503);
        httpReq.getRequestDispatcher("/maintenance.jsp").forward(httpReq, httpRes);
    }

    @Override
    public void destroy() {}
}
