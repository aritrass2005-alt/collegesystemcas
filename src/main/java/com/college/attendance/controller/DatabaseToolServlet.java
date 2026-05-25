package com.college.attendance.controller;

import com.college.attendance.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.*;
import java.nio.file.Files;

@WebServlet("/dbTools")
@MultipartConfig
public class DatabaseToolServlet extends HttpServlet {

    private boolean isSuperAdmin(HttpSession session) {
        return "SuperAdmin".equals(session.getAttribute("role"));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isSuperAdmin(session)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String action = ValidationUtil.clean(request.getParameter("action"));
        if ("backup".equals(action)) {
            File tempFile = null;
            try {
                tempFile = File.createTempFile("cas_backup_", ".sql");
                String backupPath = tempFile.getAbsolutePath();

                // NOTE: Credentials should come from a config file in production.
                // Hardcoded only because this is a single-instance academic app.
                ProcessBuilder pb = new ProcessBuilder(
                    "mysqldump",
                    "-u", "root",
                    "-p123456",
                    "--result-file=" + backupPath,
                    "college_attendance"
                );
                pb.redirectErrorStream(true);
                Process p = pb.start();
                // Consume output to prevent process from hanging
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
                    while (reader.readLine() != null) { /* drain */ }
                }
                int exitCode = p.waitFor();

                if (exitCode == 0 && tempFile.length() > 0) {
                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition",
                        "attachment; filename=\"backup_" + System.currentTimeMillis() + ".sql\"");
                    response.setContentLengthLong(tempFile.length());
                    Files.copy(tempFile.toPath(), response.getOutputStream());
                } else {
                    response.sendRedirect("admin_db_tools.jsp?error=Backup+failed.+Exit+code:+" + exitCode);
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("admin_db_tools.jsp?error=Backup+error:+" +
                    java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "unknown", "UTF-8"));
            } finally {
                if (tempFile != null) tempFile.delete();
            }
        } else {
            response.sendRedirect("admin_db_tools.jsp");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isSuperAdmin(session)) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        Part filePart = request.getPart("sqlFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("admin_db_tools.jsp?error=Please+select+a+valid+SQL+file");
            return;
        }

        // Validate extension
        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || !fileName.toLowerCase().endsWith(".sql")) {
            response.sendRedirect("admin_db_tools.jsp?error=Only+.sql+files+are+allowed");
            return;
        }

        // Limit file size to 50 MB for restore
        if (filePart.getSize() > 50L * 1024 * 1024) {
            response.sendRedirect("admin_db_tools.jsp?error=File+too+large+(max+50MB)");
            return;
        }

        File tempFile = null;
        try {
            tempFile = File.createTempFile("cas_restore_", ".sql");
            filePart.write(tempFile.getAbsolutePath());

            // Use separate arg list to avoid shell injection from the filename
            ProcessBuilder pb = new ProcessBuilder(
                "mysql",
                "-u", "root",
                "-p123456",
                "college_attendance"
            );
            pb.redirectInput(tempFile);
            pb.redirectErrorStream(true);

            Process p = pb.start();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
                while (reader.readLine() != null) { /* drain */ }
            }
            int exitCode = p.waitFor();

            if (exitCode == 0) {
                response.sendRedirect("admin_db_tools.jsp?msg=Database+restored+successfully");
            } else {
                response.sendRedirect("admin_db_tools.jsp?error=Restore+failed.+Exit+code:+" + exitCode);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin_db_tools.jsp?error=Restore+error:+" +
                java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "unknown", "UTF-8"));
        } finally {
            if (tempFile != null) tempFile.delete();
        }
    }
}
