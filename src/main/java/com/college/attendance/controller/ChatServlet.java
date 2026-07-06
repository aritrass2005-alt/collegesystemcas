package com.college.attendance.controller;

import com.college.attendance.dao.ChatDAO;
import com.college.attendance.model.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    private ChatDAO chatDAO;
    private Gson gson;

    @Override
    public void init() {
        chatDAO = new ChatDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role) && !"SuperAdmin".equals(role) && !"Teacher".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("messages".equals(action)) {
            handleGetMessages(request, response, session);
        } else if ("conversations".equals(action)) {
            handleGetConversations(request, response, session);
        } else {
            // Forward to chat page
            int userId = getUserId(session);
            
            if ("Teacher".equals(role)) {
                chatDAO.autoJoinAllDepartmentGroups(userId);
            }
            
            List<ChatConversation> conversations = chatDAO.getConversationsForUser(role, userId);
            request.setAttribute("conversations", conversations);
            request.setAttribute("departments", chatDAO.getAllDepartments());
            request.setAttribute("currentRole", role);
            request.setAttribute("currentUserId", userId);
            request.setAttribute("currentUserName", getUserName(session));
            request.getRequestDispatcher("staff_chat.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendJsonError(response, "Not authenticated");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"Admin".equals(role) && !"SuperAdmin".equals(role) && !"Teacher".equals(role)) {
            sendJsonError(response, "Not authorized");
            return;
        }

        String action = request.getParameter("action");

        if ("createDepartment".equals(action)) {
            handleCreateDepartment(request, response, session);
        } else if ("addMember".equals(action)) {
            handleAddMember(request, response, session);
        } else if ("deleteGroup".equals(action)) {
            handleDeleteGroup(request, response, session);
        } else {
            sendJsonError(response, "Unknown action");
        }
    }

    private void handleGetMessages(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        String role = (String) session.getAttribute("role");
        int userId = getUserId(session);
        int convId = Integer.parseInt(request.getParameter("convId"));
        int limit = 50;
        int offset = 0;
        try { limit = Integer.parseInt(request.getParameter("limit")); } catch (Exception e) {}
        try { offset = Integer.parseInt(request.getParameter("offset")); } catch (Exception e) {}

        if (!chatDAO.isParticipant(convId, role, userId)) {
            sendJsonError(response, "Not authorized");
            return;
        }

        List<ChatMessage> messages = chatDAO.getMessages(convId, limit, offset, role, userId);
        sendJson(response, gson.toJson(messages));
    }

    private void handleGetConversations(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        String role = (String) session.getAttribute("role");
        int userId = getUserId(session);
        
        if ("Teacher".equals(role)) {
            chatDAO.autoJoinAllDepartmentGroups(userId);
        }
        
        List<ChatConversation> conversations = chatDAO.getConversationsForUser(role, userId);
        sendJson(response, gson.toJson(conversations));
    }

    private void handleCreateDepartment(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        String myRole = (String) session.getAttribute("role");
        if (!myRole.equals("Admin") && !myRole.equals("SuperAdmin")) {
            sendJsonError(response, "Only admins can create department groups");
            return;
        }

        int myId = getUserId(session);
        String department = request.getParameter("department");
        String groupName = department + " Department";

        if (department == null || department.trim().isEmpty()) {
            sendJsonError(response, "Department is required");
            return;
        }

        // Prevent duplicates — check if a group already exists for this department
        int existingId = chatDAO.getDepartmentConversationId(department);
        if (existingId > 0) {
            JsonObject result = new JsonObject();
            result.addProperty("success", false);
            result.addProperty("error", "A chat group for '" + department + "' already exists.");
            result.addProperty("conversationId", existingId);
            sendJson(response, result.toString());
            return;
        }

        int convId = chatDAO.createDepartmentGroup(groupName, department, myRole, myId);

        JsonObject result = new JsonObject();
        result.addProperty("success", convId > 0);
        result.addProperty("conversationId", convId);
        sendJson(response, result.toString());
    }

    private void handleAddMember(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        String myRole = (String) session.getAttribute("role");
        if (!myRole.equals("Admin") && !myRole.equals("SuperAdmin")) {
            sendJsonError(response, "Only admins can add members manually");
            return;
        }

        int convId = Integer.parseInt(request.getParameter("convId"));
        String memberRole = request.getParameter("memberRole");
        int memberId = Integer.parseInt(request.getParameter("memberId"));

        boolean success = chatDAO.addParticipant(convId, memberRole, memberId);
        JsonObject result = new JsonObject();
        result.addProperty("success", success);
        sendJson(response, result.toString());
    }

    private void handleDeleteGroup(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        String myRole = (String) session.getAttribute("role");
        if (!myRole.equals("Admin") && !myRole.equals("SuperAdmin")) {
            sendJsonError(response, "Only admins can delete groups");
            return;
        }

        int convId = Integer.parseInt(request.getParameter("convId"));
        boolean success = chatDAO.deleteConversation(convId);
        JsonObject result = new JsonObject();
        result.addProperty("success", success);
        sendJson(response, result.toString());
    }

    private int getUserId(HttpSession session) {
        Object user = session.getAttribute("user");
        if (user instanceof Admin) return ((Admin) user).getId();
        if (user instanceof Teacher) return ((Teacher) user).getId();
        return -1;
    }

    private String getUserName(HttpSession session) {
        Object user = session.getAttribute("user");
        if (user instanceof Admin) return ((Admin) user).getName();
        if (user instanceof Teacher) return ((Teacher) user).getName();
        return "Unknown";
    }

    private void sendJson(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }

    private void sendJsonError(HttpServletResponse response, String error) throws IOException {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("error", error);
        response.setStatus(400);
        sendJson(response, json.toString());
    }
}
