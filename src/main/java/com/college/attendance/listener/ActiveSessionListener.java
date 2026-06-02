package com.college.attendance.listener;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import javax.servlet.http.HttpSessionAttributeListener;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSession;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@WebListener
public class ActiveSessionListener implements HttpSessionListener, HttpSessionAttributeListener {
    // Stores session IDs of logged in users
    private static final Set<String> loggedInSessions = ConcurrentHashMap.newKeySet();
    // Maps sessionId -> role for role-based tracking
    private static final Map<String, String> sessionRoles = new ConcurrentHashMap<>();

    @Override
    public void attributeAdded(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            String sessionId = event.getSession().getId();
            loggedInSessions.add(sessionId);
            String role = (String) event.getSession().getAttribute("role");
            if (role != null) {
                sessionRoles.put(sessionId, role);
            }
        }
        if ("role".equals(event.getName())) {
            String sessionId = event.getSession().getId();
            sessionRoles.put(sessionId, (String) event.getValue());
        }
    }

    @Override
    public void attributeRemoved(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            String sessionId = event.getSession().getId();
            loggedInSessions.remove(sessionId);
            sessionRoles.remove(sessionId);
        }
    }

    @Override
    public void attributeReplaced(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            if (event.getValue() != null) {
                loggedInSessions.add(event.getSession().getId());
            } else {
                String sessionId = event.getSession().getId();
                loggedInSessions.remove(sessionId);
                sessionRoles.remove(sessionId);
            }
        }
        if ("role".equals(event.getName())) {
            sessionRoles.put(event.getSession().getId(), (String) event.getValue());
        }
    }

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // We only care when the "user" attribute is added
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        String sessionId = se.getSession().getId();
        loggedInSessions.remove(sessionId);
        sessionRoles.remove(sessionId);
    }

    public static int getActiveSessions() {
        return loggedInSessions.size();
    }

    public static int getActiveStudentSessions() {
        int count = 0;
        for (String role : sessionRoles.values()) {
            if ("Student".equals(role)) count++;
        }
        return count;
    }

    public static int getActiveTeacherSessions() {
        int count = 0;
        for (String role : sessionRoles.values()) {
            if ("Teacher".equals(role)) count++;
        }
        return count;
    }

    public static int getActiveAdminSessions() {
        int count = 0;
        for (String role : sessionRoles.values()) {
            if ("Admin".equals(role) || "SuperAdmin".equals(role)) count++;
        }
        return count;
    }

    public static Map<String, String> getSessionRoles() {
        return sessionRoles;
    }
}
