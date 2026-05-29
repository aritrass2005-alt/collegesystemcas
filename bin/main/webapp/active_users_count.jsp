<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.listener.ActiveSessionListener" %>
<%= ActiveSessionListener.getActiveSessions() %>
