package com.college.attendance.websocket;

import com.college.attendance.dao.ChatDAO;
import com.college.attendance.model.ChatMessage;
import com.college.attendance.model.ChatParticipant;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint(value = "/ws/chat", configurator = ChatWebSocketConfigurator.class)
public class ChatWebSocket {

    // Maps "Role_Id" -> WebSocket Session
    private static final Map<String, Session> onlineUsers = new ConcurrentHashMap<>();
    private static final ChatDAO chatDAO = new ChatDAO();

    @OnOpen
    public void onOpen(Session session, EndpointConfig config) {
        String userRole = (String) config.getUserProperties().get("userRole");
        String oddsUserId = (String) config.getUserProperties().get("userId");
        String userName = (String) config.getUserProperties().get("userName");

        if (userRole == null || oddsUserId == null) {
            try { session.close(new CloseReason(CloseReason.CloseCodes.VIOLATED_POLICY, "Not authenticated")); } catch (IOException e) {}
            return;
        }

        String userKey = userRole + "_" + oddsUserId;
        session.getUserProperties().put("userKey", userKey);
        session.getUserProperties().put("userRole", userRole);
        session.getUserProperties().put("userId", oddsUserId);
        session.getUserProperties().put("userName", userName);
        
        // Increase WebSocket max text message size to 8MB (to support ~5MB encrypted Base64 files)
        session.setMaxTextMessageBufferSize(8 * 1024 * 1024);

        onlineUsers.put(userKey, session);

        // Broadcast online status
        broadcastOnlineStatus(userKey, true);
        sendOnlineUsersList(session);
        
        // Push offline notification check here if needed in future
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            JsonObject json = JsonParser.parseString(message).getAsJsonObject();
            String type = json.has("type") ? json.get("type").getAsString() : "";

            switch (type) {
                case "CHAT":
                    handleChatMessage(json, session);
                    break;
                case "EDIT":
                    handleEditMessage(json, session);
                    break;
                case "DELETE_FOR_ME":
                    handleDeleteForMe(json, session);
                    break;
                case "DELETE_FOR_EVERYONE":
                    handleDeleteForEveryone(json, session);
                    break;
                case "TYPING":
                    handleTyping(json, session);
                    break;
                case "READ_RECEIPT":
                    handleReadReceipt(json, session);
                    break;
                case "GROUP_CALL_JOIN":
                case "MESH_OFFER":
                case "MESH_ANSWER":
                case "MESH_ICE_CANDIDATE":
                case "GROUP_CALL_LEAVE":
                    handleMeshSignaling(json, session);
                    break;
                case "POLL_CREATED":
                case "POLL_UPDATED":
                case "PIN_UPDATE":
                    handleBroadcast(json, session);
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session) {
        String userKey = (String) session.getUserProperties().get("userKey");
        if (userKey != null) {
            onlineUsers.remove(userKey);
            broadcastOnlineStatus(userKey, false);
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        String userKey = (String) session.getUserProperties().get("userKey");
        System.err.println("WebSocket error for userKey: " + userKey);
        throwable.printStackTrace();
        if (userKey != null) {
            onlineUsers.remove(userKey);
        }
    }

    /**
     * Handle an incoming chat message: save to DB and forward to all conversation participants.
     */
    private void handleChatMessage(JsonObject json, Session session) {
        String userRole = (String) session.getUserProperties().get("userRole");
        String userIdStr = (String) session.getUserProperties().get("userId");
        String userName = (String) session.getUserProperties().get("userName");
        int userId = Integer.parseInt(userIdStr);

        int conversationId = json.get("conversationId").getAsInt();
        String encryptedContent = json.get("content").getAsString();
        String msgType = json.has("messageType") ? json.get("messageType").getAsString() : "TEXT";

        // Authorization check
        if (!chatDAO.isParticipant(conversationId, userRole, userId)) {
            return;
        }

        // Save to database
        ChatMessage msg = new ChatMessage();
        msg.setConversationId(conversationId);
        msg.setSenderRole(userRole);
        msg.setSenderId(userId);
        msg.setEncryptedContent(encryptedContent);
        msg.setMessageType(msgType);
        
        // Handle files if present
        if (json.has("fileUrl")) {
            msg.setFileUrl(json.get("fileUrl").getAsString());
            msg.setFileName(json.get("fileName").getAsString());
        }
        
        long msgId = chatDAO.saveMessage(msg);

        // Build outgoing JSON
        JsonObject outgoing = new JsonObject();
        outgoing.addProperty("type", "CHAT");
        outgoing.addProperty("messageId", msgId);
        outgoing.addProperty("conversationId", conversationId);
        outgoing.addProperty("senderRole", userRole);
        outgoing.addProperty("senderId", userId);
        outgoing.addProperty("senderName", userName);
        outgoing.addProperty("content", encryptedContent);
        outgoing.addProperty("messageType", msgType);
        if (json.has("fileUrl")) {
            outgoing.addProperty("fileUrl", msg.getFileUrl());
            outgoing.addProperty("fileName", msg.getFileName());
        }
        outgoing.addProperty("sentAt", System.currentTimeMillis());
        outgoing.addProperty("status", "SENT"); // Start as sent

        // Send to all online participants of this conversation
        List<ChatParticipant> participants = chatDAO.getParticipants(conversationId);
        String msgStr = outgoing.toString();
        for (ChatParticipant p : participants) {
            String key = p.getUserRole() + "_" + p.getUserId();
            Session targetSession = onlineUsers.get(key);
            if (targetSession != null && targetSession.isOpen()) {
                try {
                    targetSession.getBasicRemote().sendText(msgStr);
                } catch (IOException e) {
                    // Ignore send failures
                }
            } else if (!key.equals(userRole + "_" + userId)) {
                // User is offline. The notification will be picked up when they load conversations API.
                // Could also hook into a push notification system here.
            }
        }
    }

    /**
     * Handle editing a message.
     */
    private void handleEditMessage(JsonObject json, Session session) {
        String userRole = (String) session.getUserProperties().get("userRole");
        String userIdStr = (String) session.getUserProperties().get("userId");
        int userId = Integer.parseInt(userIdStr);

        long messageId = json.get("messageId").getAsLong();
        int conversationId = json.get("conversationId").getAsInt();
        String newEncryptedContent = json.get("content").getAsString();

        System.out.println("[ChatWebSocket] handleEditMessage - messageId: " + messageId +
                           ", conversationId: " + conversationId +
                           ", userRole: " + userRole +
                           ", userId: " + userId +
                           ", content length: " + (newEncryptedContent != null ? newEncryptedContent.length() : 0));

        // Perform edit in DB
        boolean success = chatDAO.editMessage(messageId, userRole, userId, newEncryptedContent);
        System.out.println("[ChatWebSocket] handleEditMessage - DB edit success: " + success);

        if (success) {
            // Build broadcast JSON
            JsonObject outgoing = new JsonObject();
            outgoing.addProperty("type", "EDIT");
            outgoing.addProperty("messageId", messageId);
            outgoing.addProperty("conversationId", conversationId);
            outgoing.addProperty("content", newEncryptedContent);

            // Broadcast to all online participants in the conversation
            List<ChatParticipant> participants = chatDAO.getParticipants(conversationId);
            String msgStr = outgoing.toString();
            for (ChatParticipant p : participants) {
                String key = p.getUserRole() + "_" + p.getUserId();
                Session targetSession = onlineUsers.get(key);
                if (targetSession != null && targetSession.isOpen()) {
                    try {
                        targetSession.getBasicRemote().sendText(msgStr);
                    } catch (IOException e) {}
                }
            }
        } else {
            System.err.println("[ChatWebSocket] handleEditMessage - DB edit failed for messageId " + messageId);
        }
    }

    /**
     * Delete a message locally for the user (Delete for Me).
     */
    private void handleDeleteForMe(JsonObject json, Session session) {
        String userRole = (String) session.getUserProperties().get("userRole");
        String userIdStr = (String) session.getUserProperties().get("userId");
        int userId = Integer.parseInt(userIdStr);
        long messageId = json.get("messageId").getAsLong();
        
        chatDAO.deleteMessageForMe(messageId, userRole, userId);
    }

    /**
     * Delete a message for all participants (Delete for Everyone).
     */
    private void handleDeleteForEveryone(JsonObject json, Session session) {
        String userRole = (String) session.getUserProperties().get("userRole");
        String userIdStr = (String) session.getUserProperties().get("userId");
        int userId = Integer.parseInt(userIdStr);
        
        long messageId = json.get("messageId").getAsLong();
        int conversationId = json.get("conversationId").getAsInt();

        boolean success = chatDAO.deleteMessageForEveryone(messageId, userRole, userId);
        if (success) {
            JsonObject outgoing = new JsonObject();
            outgoing.addProperty("type", "DELETE_FOR_EVERYONE");
            outgoing.addProperty("messageId", messageId);
            outgoing.addProperty("conversationId", conversationId);
            
            // Broadcast to everyone in the conversation
            List<ChatParticipant> participants = chatDAO.getParticipants(conversationId);
            String msgStr = outgoing.toString();
            for (ChatParticipant p : participants) {
                String key = p.getUserRole() + "_" + p.getUserId();
                Session targetSession = onlineUsers.get(key);
                if (targetSession != null && targetSession.isOpen()) {
                    try {
                        targetSession.getBasicRemote().sendText(msgStr);
                    } catch (IOException e) {}
                }
            }
        }
    }

    private void handleReadReceipt(JsonObject json, Session session) {
        String userRole = (String) session.getUserProperties().get("userRole");
        String userIdStr = (String) session.getUserProperties().get("userId");
        int userId = Integer.parseInt(userIdStr);
        
        int conversationId = json.get("conversationId").getAsInt();
        long messageId = json.get("messageId").getAsLong();
        
        // Update DB
        chatDAO.updateLastRead(conversationId, userRole, userId, messageId);
        
        // Broadcast read receipt to others in conversation
        json.addProperty("readByRole", userRole);
        json.addProperty("readById", userId);
        sendToConversationExcept(conversationId, json.toString(), userRole + "_" + userId);
    }

    private void handleTyping(JsonObject json, Session session) {
        String userKey = (String) session.getUserProperties().get("userKey");
        String userName = (String) session.getUserProperties().get("userName");
        int conversationId = json.get("conversationId").getAsInt();

        JsonObject outgoing = new JsonObject();
        outgoing.addProperty("type", "TYPING");
        outgoing.addProperty("conversationId", conversationId);
        outgoing.addProperty("userKey", userKey);
        outgoing.addProperty("userName", userName);

        sendToConversationExcept(conversationId, outgoing.toString(), userKey);
    }

    /**
     * Group Mesh Signaling
     */
    private void handleMeshSignaling(JsonObject json, Session session) {
        String type = json.get("type").getAsString();
        String senderKey = (String) session.getUserProperties().get("userKey");
        String senderName = (String) session.getUserProperties().get("userName");
        
        json.addProperty("senderKey", senderKey);
        json.addProperty("senderName", senderName);
        
        if (type.equals("GROUP_CALL_JOIN") || type.equals("GROUP_CALL_LEAVE")) {
            // Broadcast to the whole group
            int conversationId = json.get("conversationId").getAsInt();
            sendToConversationExcept(conversationId, json.toString(), senderKey);
        } else {
            // Targeted mesh signals (OFFER, ANSWER, ICE)
            String targetKey = json.has("targetKey") ? json.get("targetKey").getAsString() : null;
            if (targetKey != null) {
                Session targetSession = onlineUsers.get(targetKey);
                if (targetSession != null && targetSession.isOpen()) {
                    try {
                        targetSession.getBasicRemote().sendText(json.toString());
                    } catch (IOException e) {}
                }
            }
        }
    }

    private void sendToConversationExcept(int conversationId, String message, String exceptKey) {
        List<ChatParticipant> participants = chatDAO.getParticipants(conversationId);
        for (ChatParticipant p : participants) {
            String key = p.getUserRole() + "_" + p.getUserId();
            if (key.equals(exceptKey)) continue;
            Session s = onlineUsers.get(key);
            if (s != null && s.isOpen()) {
                try {
                    s.getBasicRemote().sendText(message);
                } catch (IOException e) {}
            }
        }
    }

    private void handleBroadcast(JsonObject json, Session session) {
        int conversationId = json.has("conversationId") ? json.get("conversationId").getAsInt() : -1;
        if (conversationId == -1) return;
        String senderKey = (String) session.getUserProperties().get("userKey");
        sendToConversationExcept(conversationId, json.toString(), senderKey);
    }

    private void broadcastOnlineStatus(String userKey, boolean online) {
        JsonObject json = new JsonObject();
        json.addProperty("type", "ONLINE_STATUS");
        json.addProperty("userKey", userKey);
        json.addProperty("online", online);
        String msg = json.toString();

        for (Map.Entry<String, Session> entry : onlineUsers.entrySet()) {
            if (entry.getKey().equals(userKey)) continue;
            Session s = entry.getValue();
            if (s.isOpen()) {
                try {
                    s.getBasicRemote().sendText(msg);
                } catch (IOException e) {}
            }
        }
    }

    private void sendOnlineUsersList(Session session) {
        JsonObject json = new JsonObject();
        json.addProperty("type", "ONLINE_USERS");
        com.google.gson.JsonArray arr = new com.google.gson.JsonArray();
        for (String key : onlineUsers.keySet()) {
            arr.add(key);
        }
        json.add("users", arr);
        try {
            session.getBasicRemote().sendText(json.toString());
        } catch (IOException e) {}
    }
}
