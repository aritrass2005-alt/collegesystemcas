package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import com.college.attendance.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/coordinatorStudents")
public class CoordinatorStudentServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role")) || isCoordinator == null || !isCoordinator) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<Student> students = new ArrayList<>();
        String sql = "SELECT s.* FROM student s " +
                     "JOIN coordinator c ON s.department = c.department AND s.year = c.year " +
                     "AND (c.section IS NULL OR c.section = '' OR s.section = c.section) " +
                     "WHERE c.teacher_id = ? " +
                     "ORDER BY s.roll_no";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacher.getId());
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Student s = new Student();
                    s.setId(rs.getInt("id"));
                    s.setRollNo(rs.getString("roll_no"));
                    s.setName(rs.getString("name"));
                    s.setEmail(rs.getString("email"));
                    s.setPhone(rs.getString("phone"));
                    s.setDepartment(rs.getString("department"));
                    s.setYear(rs.getInt("year"));
                    s.setSection(rs.getString("section"));
                    s.setParentName(rs.getString("parent_name"));
                    s.setParentPhone(rs.getString("parent_phone"));
                    s.setParentEmail(rs.getString("parent_email"));
                    students.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("students", students);
        request.getRequestDispatcher("coordinator_students.jsp").forward(request, response);
    }
}
