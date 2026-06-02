<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.college.attendance.util.DBConnection" %>
<%
    try (Connection conn = DBConnection.getConnection()) {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("ALTER TABLE review_chat ADD COLUMN attachment_path VARCHAR(255) DEFAULT NULL;");
            out.println("Column added successfully!");
        }
    } catch (Exception e) {
        if (e.getMessage().contains("Duplicate column name")) {
            out.println("Column already exists.");
        } else {
            out.println("Error: " + e.getMessage());
        }
    }
%>
