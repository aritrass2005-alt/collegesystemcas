package com.college.attendance.websocket;

import com.college.attendance.model.Admin;
import com.college.attendance.model.Teacher;

import javax.servlet.http.HttpSession;
import javax.websocket.HandshakeResponse;
import javax.websocket.server.HandshakeRequest;
import javax.websocket.server.ServerEndpointConfig;

/**
 * Configurator that copies HTTP session attributes into the WebSocket session
 * so that the ChatWebSocket endpoint can identify the logged-in user.
 */
public class ChatWebSocketConfigurator extends ServerEndpointConfig.Configurator {

    @Override
    public void modifyHandshake(ServerEndpointConfig sec, HandshakeRequest request, HandshakeResponse response) {
        HttpSession httpSession = (HttpSession) request.getHttpSession();
        if (httpSession != null) {
            Object user = httpSession.getAttribute("user");
            String role = (String) httpSession.getAttribute("role");

            if (user != null && role != null) {
                String userId = null;
                String userName = null;

                if (user instanceof Admin) {
                    Admin admin = (Admin) user;
                    userId = String.valueOf(admin.getId());
                    userName = admin.getName();
                } else if (user instanceof Teacher) {
                    Teacher teacher = (Teacher) user;
                    userId = String.valueOf(teacher.getId());
                    userName = teacher.getName();
                    // A coordinator is still a Teacher in the session
                    Boolean isCoord = (Boolean) httpSession.getAttribute("isCoordinator");
                    // Keep role as "Teacher" for chat — coordinators chat as teachers
                }

                if (userId != null) {
                    sec.getUserProperties().put("userRole", role);
                    sec.getUserProperties().put("userId", userId);
                    sec.getUserProperties().put("userName", userName);
                }
            }
        }
    }
}
