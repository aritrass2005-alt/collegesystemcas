package com.college.attendance.listener;

import com.college.attendance.dao.SystemSettingsDAO;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class MaintenanceFilter implements Filter {
    private final SystemSettingsDAO systemSettingsDAO = new SystemSettingsDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        
        // 1. If maintenance mode is NOT active, proceed normally
        if (!systemSettingsDAO.isMaintenanceMode()) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Resolve target URI to check bypasses
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String relativePath = uri.substring(contextPath.length());

        // 3. Determine if the request is for static assets or resources
        boolean isStaticAsset = relativePath.endsWith(".css") || 
                                relativePath.endsWith(".js") || 
                                relativePath.endsWith(".png") || 
                                relativePath.endsWith(".jpg") || 
                                relativePath.endsWith(".jpeg") || 
                                relativePath.endsWith(".gif") || 
                                relativePath.endsWith(".svg") || 
                                relativePath.endsWith(".ico") || 
                                relativePath.endsWith(".woff") || 
                                relativePath.endsWith(".woff2") || 
                                relativePath.endsWith(".ttf") || 
                                relativePath.contains("/css/") || 
                                relativePath.contains("/js/") || 
                                relativePath.contains("/img/") || 
                                relativePath.contains("/includes/");

        // 4. Determine if the request is an authentication or maintenance page path
        boolean isAuthOrMaintenancePath = relativePath.equals("/login.jsp") || 
                                          relativePath.equals("/login") || 
                                          relativePath.equals("/logout") || 
                                          relativePath.equals("/maintenance.jsp");

        if (isStaticAsset || isAuthOrMaintenancePath) {
            chain.doFilter(request, response);
            return;
        }

        // 5. Bypass if user is logged in as SuperAdmin
        HttpSession session = request.getSession(false);
        if (session != null && "SuperAdmin".equals(session.getAttribute("role"))) {
            chain.doFilter(request, response);
            return;
        }

        // 6. Handle AJAX vs Standard requests
        String ajaxHeader = request.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equalsIgnoreCase(ajaxHeader)) {
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE, "System is under scheduled maintenance.");
            return;
        }

        // 7. Redirect to maintenance landing page
        response.sendRedirect(contextPath + "/maintenance.jsp");
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
