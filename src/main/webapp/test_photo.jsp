<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.college.attendance.model.Teacher" %>
<%
    Teacher teacher = (Teacher) session.getAttribute("user");
    if (teacher != null) {
        out.println("Teacher profile photo is: [" + teacher.getProfilePhoto() + "]");
    } else {
        out.println("No teacher in session");
    }
%>
