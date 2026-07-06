<%@ page import="com.college.attendance.dao.ChatDAO" %>
<%@ page import="java.util.List" %>
<%
    ChatDAO chatDAO = new ChatDAO();
    List<String> depts = chatDAO.getAllDepartments();
    if (depts == null) {
        out.println("depts is null");
    } else if (depts.isEmpty()) {
        out.println("depts is empty");
    } else {
        for (String d : depts) {
            out.println("DEPT: " + d);
        }
    }
%>
