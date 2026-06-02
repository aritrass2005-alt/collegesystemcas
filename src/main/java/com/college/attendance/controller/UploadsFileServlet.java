package com.college.attendance.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

@WebServlet("/uploads/*")
public class UploadsFileServlet extends HttpServlet {
    private static final String UPLOAD_DIR = System.getProperty("user.home") + File.separator + "cas_uploads" + File.separator + "uploads";

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

        File file = new File(UPLOAD_DIR, filename);
        if (!file.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLength((int) file.length());

        Files.copy(file.toPath(), response.getOutputStream());
    }
}
