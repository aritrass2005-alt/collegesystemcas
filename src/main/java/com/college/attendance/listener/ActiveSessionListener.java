package com.college.attendance.listener;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import javax.servlet.http.HttpSessionAttributeListener;
import javax.servlet.http.HttpSessionBindingEvent;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@WebListener
public class ActiveSessionListener implements HttpSessionListener, HttpSessionAttributeListener {
    // Stores session IDs of logged in users
    private static final Set<String> loggedInSessions = ConcurrentHashMap.newKeySet();

    @Override
    public void attributeAdded(HttpSessionBindingEvent event) {
        if ("user".equals(event.getName())) {
            loggedInSessions.add(event.getSession().getId());
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
                loggedInSessions.add(event.getSession().getId());
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
}
