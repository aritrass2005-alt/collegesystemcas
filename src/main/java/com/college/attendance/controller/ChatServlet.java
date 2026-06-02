package com.college.attendance.controller;

import com.college.attendance.dao.ChatDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Admin;
import com.college.attendance.model.ChatGroup;
import com.college.attendance.model.ChatParticipant;
import com.college.attendance.model.Teacher;
import com.college.attendance.util.ValidationUtil;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/chatApi")
public class ChatServlet extends HttpServlet {
    private ChatDAO chatDAO = new ChatDAO();
    private TeacherDAO teacherDAO = new TeacherDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(401);
            return;
        }

        String action = ValidationUtil.clean(request.getParameter("action"));
        response.setContentType("application/json");

        try {
            if ("getGroups".equals(action)) {
                String role = getChatRole(session);
                int userId = getUserId(session);
                List<ChatGroup> groups = chatDAO.getUserGroups(role, userId);
                response.getWriter().write(gson.toJson(groups));
            } else if ("getParticipants".equals(action)) {
                int groupId = Integer.parseInt(ValidationUtil.clean(request.getParameter("groupId")));
                List<ChatParticipant> participants = chatDAO.getParticipants(groupId);
                response.getWriter().write(gson.toJson(participants));
            } else if ("getMessages".equals(action)) {
                int groupId = Integer.parseInt(ValidationUtil.clean(request.getParameter("groupId")));
                response.getWriter().write(gson.toJson(chatDAO.getMessages(groupId, 50)));
            } else if ("getPublicKey".equals(action)) {
                String uType = ValidationUtil.clean(request.getParameter("userType"));
                int uId = Integer.parseInt(ValidationUtil.clean(request.getParameter("userId")));
                Map<String, String> res = new HashMap<>();
                res.put("publicKey", chatDAO.getPublicKey(uType, uId));
                response.getWriter().write(gson.toJson(res));
            } else if ("getGroupKey".equals(action)) {
                int groupId = Integer.parseInt(ValidationUtil.clean(request.getParameter("groupId")));
                String uType = getChatRole(session);
                int uId = getUserId(session);
                Map<String, String> res = new HashMap<>();
                res.put("encryptedGroupKey", chatDAO.getGroupKey(groupId, uType, uId));
                response.getWriter().write(gson.toJson(res));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(401);
            return;
        }

        String action = ValidationUtil.clean(request.getParameter("action"));
        response.setContentType("application/json");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            if ("createGroup".equals(action)) {
                if (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role"))) {
                    response.setStatus(403);
                    return;
                }
                String dept = ValidationUtil.cleanUpper(request.getParameter("department"));
                int adminId = getUserId(session);

                ChatGroup existing = chatDAO.getGroupForDepartment(dept);
                if (existing != null) {
                    Map<String, Object> res = new HashMap<>();
                    res.put("success", false);
                    res.put("message", "Group already exists for " + dept);
                    response.getWriter().write(gson.toJson(res));
                    return;
                }

                ChatGroup newGroup = chatDAO.createGroup(dept, adminId);
                if (newGroup != null) {
                    // Add admin
                    chatDAO.addParticipant(newGroup.getId(), "Admin", adminId);
                    
                    // Find all teachers and coordinators related to this dept
                    List<Teacher> deptTeachers = teacherDAO.getTeachersForDepartmentChat(dept);
                    for (Teacher t : deptTeachers) {
                        if (teacherDAO.isCoordinator(t.getId())) {
                            chatDAO.addParticipant(newGroup.getId(), "Coordinator", t.getId());
                        } else {
                            chatDAO.addParticipant(newGroup.getId(), "Teacher", t.getId());
                        }
                    }

                    Map<String, Object> res = new HashMap<>();
                    res.put("success", true);
                    res.put("group", newGroup);
                    response.getWriter().write(gson.toJson(res));
                } else {
                    response.setStatus(500);
                }
            } else if ("storePublicKey".equals(action)) {
                String pubKey = request.getParameter("publicKey");
                String role = getChatRole(session);
                int userId = getUserId(session);
                boolean success = chatDAO.storePublicKey(role, userId, pubKey);
                Map<String, Boolean> res = new HashMap<>();
                res.put("success", success);
                response.getWriter().write(gson.toJson(res));
            } else if ("storeGroupKey".equals(action)) {
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                String uType = request.getParameter("userType");
                int uId = Integer.parseInt(request.getParameter("userId"));
                String encKey = request.getParameter("encryptedKey");
                boolean success = chatDAO.storeGroupKey(groupId, uType, uId, encKey);
                Map<String, Boolean> res = new HashMap<>();
                res.put("success", success);
                response.getWriter().write(gson.toJson(res));
            } else if ("deleteGroup".equals(action)) {
                if (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role"))) {
                    response.setStatus(403);
                    return;
                }
                int groupId = Integer.parseInt(request.getParameter("groupId"));
                boolean success = chatDAO.deleteGroup(groupId);
                Map<String, Boolean> res = new HashMap<>();
                res.put("success", success);
                response.getWriter().write(gson.toJson(res));
            } else if ("deleteMessage".equals(action)) {
                int messageId = Integer.parseInt(request.getParameter("messageId"));
                String userType = getChatRole(session);
                int userId = getUserId(session);
                boolean isAdmin = "Admin".equals(session.getAttribute("role")) || "SuperAdmin".equals(session.getAttribute("role"));
                boolean success = chatDAO.deleteMessage(messageId, userType, userId, isAdmin);
                Map<String, Boolean> res = new HashMap<>();
                res.put("success", success);
                response.getWriter().write(gson.toJson(res));
            } else if ("clearMyKeys".equals(action)) {
                // User is re-registering their device keys (RSA key was regenerated)
                // 1. Upload the new public key
                String pubKey = request.getParameter("publicKey");
                String role = getChatRole(session);
                int userId = getUserId(session);
                if (pubKey != null && !pubKey.isEmpty()) {
                    chatDAO.storePublicKey(role, userId, pubKey);
                }
                // 2. Clear all stale group_keys entries so hasKey returns false
                //    and admins/other members can auto-re-share
                boolean cleared = chatDAO.clearAllUserGroupKeys(role, userId);
                Map<String, Object> res = new HashMap<>();
                res.put("success", cleared);
                res.put("message", cleared ? "Keys cleared. Re-share will happen automatically when an admin opens the group." : "Failed to clear keys.");
                response.getWriter().write(gson.toJson(res));
            }
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorRes = new HashMap<>();
            errorRes.put("success", false);
            errorRes.put("message", "Server error: " + e.getMessage());
            response.setStatus(500);
            response.getWriter().write(gson.toJson(errorRes));
        }
    }

    private int getUserId(HttpSession session) {
        Object user = session.getAttribute("user");
        if (user instanceof Admin) return ((Admin) user).getId();
        if (user instanceof Teacher) return ((Teacher) user).getId();
        // Students shouldn't access this
        return -1;
    }

    private String getChatRole(HttpSession session) {
        String role = (String) session.getAttribute("role");
        Boolean isCoord = (Boolean) session.getAttribute("isCoordinator");
        if ("Teacher".equals(role) && isCoord != null && isCoord) {
            return "Coordinator";
        }
        return role;
    }
}
