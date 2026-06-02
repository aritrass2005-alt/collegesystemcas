<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.college.attendance.util.DBConnection" %>
<!DOCTYPE html>
<html>
<body>
    <h2>Chat Messages</h2>
    <table border="1">
        <tr><th>ID</th><th>GroupID</th><th>SenderType</th><th>SenderID</th><th>Content</th></tr>
        <%
            try (Connection conn = DBConnection.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT * FROM chat_message")) {
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getInt("group_id") %></td>
            <td><%= rs.getString("sender_type") %></td>
            <td><%= rs.getInt("sender_id") %></td>
            <td><%= rs.getString("encrypted_content") %></td>
        </tr>
        <%
                }
            } catch(Exception e) {
                out.print("Error: " + e.getMessage());
            }
        %>
    </table>
</body>
</html>
