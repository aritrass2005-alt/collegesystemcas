package com.college.attendance.listener;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import javax.servlet.http.HttpSessionAttributeListener;
import javax.servlet.http.HttpSessionBindingEvent;
import com.college.attendance.model.SessionInfo;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import com.college.attendance.model.Admin;
import java.util.Collection;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@WebListener
public class ActiveSessionListener implements HttpSessionListener, HttpSessionAttributeListener {
    // Stores session IDs mapped to user info
    private static final Map<String, SessionInfo> loggedInSessions = new ConcurrentHashMap<>();

    private void handleUserAdded(String sessionId, Object userObj) {
        if (userObj == null) return;
        String username = "Unknown";
        String role = "Unknown";
        
        if (userObj instanceof Student) {
            username = ((Student) userObj).getName();
            role = "Student";
        } else if (userObj instanceof Teacher) {
            username = ((Teacher) userObj).getName();
            role = "Teacher";
        } else if (userObj instanceof Admin) {
            username = ((Admin) userObj).getName();
            role = ((Admin) userObj).getRole();
        }
        
        loggedInSessions.put(sessionId, new SessionInfo(sessionId, username, role, new Date()));
    }

    @Override
    public void attributeAdded(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            handleUserAdded(event.getSession().getId(), event.getValue());
        }
    }

    @Override
    public void attributeRemoved(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            loggedInSessions.remove(event.getSession().getId());
        }
    }

    @Override
    public void attributeReplaced(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            if (event.getValue() != null) {
                handleUserAdded(event.getSession().getId(), event.getValue());
            } else {
                loggedInSessions.remove(event.getSession().getId());
            }
        }
    }

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // We only care when the "user" attribute is added
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        loggedInSessions.remove(se.getSession().getId());
    }

    public static int getActiveSessions() {
        return loggedInSessions.size();
    }
    
    public static Collection<SessionInfo> getActiveSessionDetails() {
        return loggedInSessions.values();
    }
}
