package com.college.attendance.controller;

import com.college.attendance.dao.ChatDAO;
import com.college.attendance.model.ChatMessage;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet("/chatUpload")
@MultipartConfig(maxFileSize = 20 * 1024 * 1024, maxRequestSize = 25 * 1024 * 1024) // 20MB max
public class ChatUploadServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "chat_uploads";
    private final ChatDAO chatDAO = new ChatDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(401);
            return;
        }

        response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try {
            // Determine user info
            String role = (String) session.getAttribute("role");
            Boolean isCoord = (Boolean) session.getAttribute("isCoordinator");
            String userType = ("Teacher".equals(role) && isCoord != null && isCoord) ? "Coordinator" : role;

            int userId = -1;
            Object user = session.getAttribute("user");
            if (user instanceof com.college.attendance.model.Admin)
                userId = ((com.college.attendance.model.Admin) user).getId();
            else if (user instanceof com.college.attendance.model.Teacher)
                userId = ((com.college.attendance.model.Teacher) user).getId();

            int groupId = Integer.parseInt(request.getParameter("groupId"));
            String msgType = request.getParameter("messageType"); // "image", "file", "voice"

            Part filePart = request.getPart("file");
            if (filePart == null) {
                response.getWriter().write(gson.toJson(Map.of("success", false, "message", "No file")));
                return;
            }

            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : "";
            String savedName = UUID.randomUUID().toString() + ext;

            // Save upload directory inside webapp
            String appPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            Files.createDirectories(Paths.get(appPath));
            filePart.write(appPath + File.separator + savedName);

            // Detect type if not given
            if (msgType == null || msgType.isEmpty()) {
                String mime = filePart.getContentType();
                if (mime != null && mime.startsWith("image/")) msgType = "image";
                else if (mime != null && mime.startsWith("audio/")) msgType = "voice";
                else msgType = "file";
            }

            String fileUrl = UPLOAD_DIR + "/" + savedName;

            // Save to DB and broadcast
            ChatMessage saved = chatDAO.saveFileMessage(groupId, userType, userId, msgType, fileUrl, originalName);

            if (saved != null) {
                // Populate sender name
                String table = "Admin".equals(userType) ? "admin" : "teacher";
                saved.setSenderName(chatDAO.getUserNamePublic(table, userId));
                saved.setSenderDetails(msgType.equals("Admin") ? "Administrator" : "");

                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", saved);
                response.getWriter().write(gson.toJson(result));
            } else {
                response.getWriter().write(gson.toJson(Map.of("success", false, "message", "DB error")));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write(gson.toJson(Map.of("success", false, "message", e.getMessage())));
        }
    }
}
