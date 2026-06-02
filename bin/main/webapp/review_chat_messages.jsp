<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.ReviewChat" %>
<%@ page import="com.college.attendance.dao.AttendanceReviewDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null) {
        out.print("SESSION_EXPIRED");
        return;
    }
    
    boolean isCoordinator = false;
    if ("Teacher".equals(role)) {
        Boolean isCoordAttr = (Boolean) session.getAttribute("isCoordinator");
        isCoordinator = (isCoordAttr != null && isCoordAttr);
    }
    
    int reviewId = Integer.parseInt(request.getParameter("id"));
    AttendanceReviewDAO reviewDAO = new AttendanceReviewDAO();
    List<ReviewChat> chats = reviewDAO.getChatByReviewId(reviewId);
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, hh:mm a");
    
    if (chats != null && !chats.isEmpty()) {
        for (ReviewChat chat : chats) {
            boolean isMine = (isCoordinator && "Coordinator".equals(chat.getSenderType())) || (!isCoordinator && "Student".equals(chat.getSenderType()));
%>
        <div class="chat-bubble <%= isMine ? "chat-mine" : "chat-other" %>">
            <% if (!isMine) { %>
                <div class="fw-bold" style="font-size: 0.8rem; margin-bottom: 2px;"><%= chat.getSenderName() %> (<%= chat.getSenderType() %>)</div>
            <% } %>
            
            <% if (chat.getMessage() != null && !chat.getMessage().trim().isEmpty()) { %>
                <div><%= chat.getMessage() %></div>
            <% } %>
            
            <% if (chat.getProofPath() != null && !chat.getProofPath().isEmpty()) { 
                String ext = chat.getProofPath().substring(chat.getProofPath().lastIndexOf('.') + 1).toLowerCase();
            %>
                <div class="mt-2">
                <% if (ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || ext.equals("gif") || ext.equals("webp")) { %>
                    <a href="<%= chat.getProofPath() %>" target="_blank">
                        <img src="<%= chat.getProofPath() %>" alt="Attachment" style="max-width: 100%; max-height: 150px; border-radius: 8px;">
                    </a>
                <% } else if (ext.equals("mp4") || ext.equals("webm") || ext.equals("ogg")) { %>
                    <video controls style="max-width: 100%; max-height: 150px; border-radius: 8px;">
                        <source src="<%= chat.getProofPath() %>" type="video/<%= ext %>">
                    </video>
                <% } else { %>
                    <a href="<%= chat.getProofPath() %>" target="_blank" class="btn btn-sm btn-light text-dark" style="font-size:0.75rem;">
                        <i class="bi bi-file-earmark-arrow-down-fill me-1"></i> View Attachment
                    </a>
                <% } %>
                </div>
            <% } %>
            
            <div class="chat-time text-end"><%= sdf.format(chat.getCreatedAt()) %></div>
        </div>
<% 
        } 
    } else { 
%>
        <div class="text-center text-muted my-auto py-5">No messages yet. Send a message to start discussion.</div>
<% } %>
