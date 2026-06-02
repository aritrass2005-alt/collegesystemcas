package com.college.attendance.websocket;

import com.college.attendance.dao.ChatDAO;
import com.college.attendance.model.ChatMessage;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chat/{groupId}/{userType}/{userId}")
public class ChatEndpoint {

    private static final Map<Integer, Set<Session>> groupSessions = new ConcurrentHashMap<>();
    private static final ChatDAO chatDAO = new ChatDAO();
    private static final Gson gson = new Gson();

    @OnOpen
    public void onOpen(Session session, @PathParam("groupId") int groupId, @PathParam("userType") String userType, @PathParam("userId") int userId) {
        groupSessions.computeIfAbsent(groupId, k -> Collections.synchronizedSet(new HashSet<>())).add(session);
        session.getUserProperties().put("groupId", groupId);
        session.getUserProperties().put("userType", userType);
        session.getUserProperties().put("userId", userId);
        System.out.println("WebSocket Connected: Group " + groupId + ", User " + userType + " " + userId);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            int groupId = (int) session.getUserProperties().get("groupId");
            String senderType = (String) session.getUserProperties().get("userType");
            int senderId = (int) session.getUserProperties().get("userId");

            JsonObject json = gson.fromJson(message, JsonObject.class);
            String msgType = json.has("type") ? json.get("type").getAsString() : "chat";

            // --- Call notification & Key requests: broadcast directly, no DB save ---
            if ("call-started".equals(msgType) || "call-ended".equals(msgType) || "key-request".equals(msgType) || "key-shared".equals(msgType)) {
                json.addProperty("senderType", senderType);
                json.addProperty("senderId", senderId);
                String broadcastStr = gson.toJson(json);
                Set<Session> sessions = groupSessions.get(groupId);
                if (sessions != null) {
                    synchronized (sessions) {
                        for (Session s : sessions) {
                            if (s.isOpen() && s != session) { // don't echo back to caller
                                s.getBasicRemote().sendText(broadcastStr);
                            }
                        }
                    }
                }
                return;
            }

            // --- File/Media message notification: broadcast directly ---
            if ("file-message".equals(msgType)) {
                JsonObject msgObj = json.getAsJsonObject("message");
                if (msgObj != null) {
                    String broadcastStr = gson.toJson(msgObj);
                    Set<Session> sessions = groupSessions.get(groupId);
                    if (sessions != null) {
                        synchronized (sessions) {
                            for (Session s : sessions) {
                                if (s.isOpen() && s != session) { // sender already rendered it locally
                                    s.getBasicRemote().sendText(broadcastStr);
                                }
                            }
                        }
                    }
                }
                return;
            }

            // --- Regular encrypted text message ---
            String encryptedContent = json.has("encryptedContent")
                                        ? json.get("encryptedContent").getAsString()
                                        : json.get("content").getAsString();
            String iv = json.get("iv").getAsString();

            // Save to DB
            ChatMessage savedMsg = chatDAO.saveMessage(groupId, senderType, senderId, encryptedContent, iv);
            if (savedMsg != null) {
                // Populate sender details for broadcast
                List<ChatMessage> list = chatDAO.getMessages(groupId, 1);
                if (!list.isEmpty()) {
                    String broadcastStr = gson.toJson(list.get(0));
                    
                    // Broadcast to everyone in group
                    Set<Session> sessions = groupSessions.get(groupId);
                    if (sessions != null) {
                        synchronized (sessions) {
                            for (Session s : sessions) {
                                if (s.isOpen()) {
                                    s.getBasicRemote().sendText(broadcastStr);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @OnClose
    public void onClose(Session session) {
        int groupId = (int) session.getUserProperties().get("groupId");
        Set<Session> sessions = groupSessions.get(groupId);
        if (sessions != null) {
            sessions.remove(session);
        }
        System.out.println("WebSocket Closed: Group " + groupId);
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("WebSocket Error on session " + session.getId() + ": " + throwable.getMessage());
    }
}
