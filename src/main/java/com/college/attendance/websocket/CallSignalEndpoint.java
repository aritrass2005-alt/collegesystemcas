package com.college.attendance.websocket;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.util.Collections;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebRTC Signaling Server for departmental video calls.
 * Handles offer, answer, ICE candidates, and call control signals.
 */
@ServerEndpoint("/callSignal/{groupId}/{userId}")
public class CallSignalEndpoint {

    // groupId -> set of sessions in that call room
    private static final Map<Integer, Set<Session>> rooms = new ConcurrentHashMap<>();
    private static final Gson gson = new Gson();

    @OnOpen
    public void onOpen(Session session, @PathParam("groupId") int groupId, @PathParam("userId") int userId) {
        rooms.computeIfAbsent(groupId, k -> Collections.synchronizedSet(new HashSet<>())).add(session);
        session.getUserProperties().put("groupId", groupId);
        session.getUserProperties().put("userId", userId);
        System.out.println("Call Signal Connected: Room " + groupId + ", User " + userId);
    }

    @OnMessage
    public void onMessage(String message, Session senderSession) {
        try {
            int groupId = (int) senderSession.getUserProperties().get("groupId");
            int senderId = (int) senderSession.getUserProperties().get("userId");

            JsonObject json = gson.fromJson(message, JsonObject.class);
            // Add sender ID so receiver knows who's calling
            json.addProperty("fromUserId", senderId);
            String outMsg = gson.toJson(json);

            String type = json.has("type") ? json.get("type").getAsString() : "";

            Set<Session> room = rooms.get(groupId);
            if (room == null) return;

            synchronized (room) {
                for (Session s : room) {
                    if (!s.isOpen()) continue;

                    // For targeted messages (answer, ice), only send to the intended recipient
                    if (json.has("targetUserId")) {
                        int target = json.get("targetUserId").getAsInt();
                        int sid = (int) s.getUserProperties().get("userId");
                        if (sid == target) {
                            s.getBasicRemote().sendText(outMsg);
                        }
                    } else {
                        // Broadcast to everyone except sender (offers, join/leave notifications)
                        if (s != senderSession) {
                            s.getBasicRemote().sendText(outMsg);
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
        int userId = (int) session.getUserProperties().get("userId");
        Set<Session> room = rooms.get(groupId);
        if (room != null) {
            room.remove(session);
            // Notify others that this user left the call
            JsonObject leaveMsg = new JsonObject();
            leaveMsg.addProperty("type", "user-left");
            leaveMsg.addProperty("fromUserId", userId);
            String msg = gson.toJson(leaveMsg);
            synchronized (room) {
                for (Session s : room) {
                    if (s.isOpen()) {
                        try { s.getBasicRemote().sendText(msg); } catch (Exception ignored) {}
                    }
                }
            }
        }
        System.out.println("Call Signal Closed: Room " + groupId + ", User " + userId);
    }

    @OnError
    public void onError(Session session, Throwable t) {
        System.err.println("Call Signal Error: " + t.getMessage());
    }

    public static int getRoomSize(int groupId) {
        Set<Session> room = rooms.get(groupId);
        return room == null ? 0 : room.size();
    }
}
