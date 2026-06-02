<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.college.attendance.util.DBConnection" %>
<%
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT id, name, profile_photo FROM teacher");
        ResultSet rs = ps.executeQuery();
        while(rs.next()) {
            out.println("ID: " + rs.getInt("id") + ", Name: " + rs.getString("name") + ", Photo: [" + rs.getString("profile_photo") + "]<br>");
        }
    } catch (Exception e) {
        out.println(e.toString());
    }
%>
