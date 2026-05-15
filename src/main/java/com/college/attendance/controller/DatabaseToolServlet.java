package com.college.attendance.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

@WebServlet("/dbTools")
@MultipartConfig
public class DatabaseToolServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"SuperAdmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");
        if ("backup".equals(action)) {
            try {
                String tempDir = System.getProperty("java.io.tmpdir");
                String backupPath = tempDir + File.separator + "college_attendance_backup.sql";
                
                // Construct mysqldump command
                ProcessBuilder pb = new ProcessBuilder(
                    "mysqldump",
                    "-u", "root",
                    "-p123456",
                    "--result-file=" + backupPath,
                    "college_attendance"
                );
                
                Process p = pb.start();
                int exitCode = p.waitFor();
                
                if (exitCode == 0) {
                    File file = new File(backupPath);
                    response.setContentType("application/sql");
                    response.setHeader("Content-Disposition", "attachment; filename=\"backup_" + System.currentTimeMillis() + ".sql\"");
                    response.setContentLength((int) file.length());
                    
                    try (InputStream in = new java.io.FileInputStream(file);
                         OutputStream out = response.getOutputStream()) {
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = in.read(buffer)) != -1) {
                            out.write(buffer, 0, bytesRead);
                        }
                    }
                    file.delete(); // Clean up
                    return;
                } else {
                    response.sendRedirect("admin_db_tools.jsp?error=Failed to generate backup. Exit code: " + exitCode);
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin_db_tools.jsp?error=Error occurred during backup: " + e.getMessage());
            }
        } else {
            response.sendRedirect("admin_db_tools.jsp");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"SuperAdmin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        Part filePart = request.getPart("sqlFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("admin_db_tools.jsp?error=Please select a valid SQL file");
            return;
        }

        try {
            String tempDir = System.getProperty("java.io.tmpdir");
            String restorePath = tempDir + File.separator + "restore_temp.sql";
            filePart.write(restorePath);
            
            // Construct mysql restore command.
            // On Windows, using cmd /c type file | mysql is often more reliable than `<` due to ProcessBuilder limitations.
            ProcessBuilder pb = new ProcessBuilder(
                "cmd.exe", "/c",
                "mysql -u root -p123456 college_attendance < \"" + restorePath + "\""
            );
            
            Process p = pb.start();
            int exitCode = p.waitFor();
            
            new File(restorePath).delete(); // Clean up
            
            if (exitCode == 0) {
                response.sendRedirect("admin_db_tools.jsp?msg=Database restored successfully");
            } else {
                response.sendRedirect("admin_db_tools.jsp?error=Failed to restore database. Exit code: " + exitCode);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_db_tools.jsp?error=Error occurred during restore: " + e.getMessage());
        }
    }
}
