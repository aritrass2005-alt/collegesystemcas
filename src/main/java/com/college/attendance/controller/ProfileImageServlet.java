package com.college.attendance.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

@WebServlet("/img/profiles/*")
public class ProfileImageServlet extends HttpServlet {
    private static final String UPLOAD_DIR = System.getProperty("user.home") + File.separator + "cas_uploads" + File.separator + "profiles";

    @Override
    public void init() throws ServletException {
        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filename = request.getPathInfo();
        if (filename == null || "/".equals(filename)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File imageFile = new File(UPLOAD_DIR, filename);
        if (!imageFile.exists()) {
            // Also fallback to the default images if it's there?
            // If the request was for something not in the external directory, it might just 404 because the default servlet is bypassed.
            // But usually profile images are uniquely named.
            // We can forward to default default-avatar.png if needed. Let's just return 404.
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(imageFile.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLength((int) imageFile.length());

        Files.copy(imageFile.toPath(), response.getOutputStream());
    }
}
