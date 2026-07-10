package com.college.attendance.controller;

import com.college.attendance.model.Teacher;
import com.college.attendance.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/teacherProfile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class TeacherProfileServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("remove_photo".equals(action)) {
            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement stmt = conn.prepareStatement("UPDATE teacher SET profile_photo=NULL WHERE id=?");
                stmt.setInt(1, teacher.getId());
                stmt.executeUpdate();
                teacher.setProfilePhoto(null);
                session.setAttribute("user", teacher);
                response.sendRedirect("teacherProfile?msg=Profile photo removed");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("teacher_profile.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name  = request.getParameter("name");
        String phone = request.getParameter("phone");
        String newPass = request.getParameter("new_password");

        String photoPath = null;
        Part photoPart = request.getPart("profile_photo");
        if (photoPart != null && photoPart.getSize() > 0) {
            String fileName = "teacher_" + teacher.getId() + "_" + System.currentTimeMillis() + getExtension(photoPart.getSubmittedFileName());
            String uploadDir = getServletContext().getRealPath("/") + "img" + File.separator + "profiles";
            new File(uploadDir).mkdirs();
            photoPart.write(uploadDir + File.separator + fileName);
            photoPath = "img/profiles/" + fileName;
        }

        try (Connection conn = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE teacher SET name=?, phone=?");
            if (photoPath != null) sql.append(", profile_photo=?");
            if (newPass != null && !newPass.trim().isEmpty()) sql.append(", password=?");
            sql.append(" WHERE id=?");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            stmt.setString(idx++, name);
            stmt.setString(idx++, phone);
            if (photoPath != null) stmt.setString(idx++, photoPath);
            if (newPass != null && !newPass.trim().isEmpty()) {
                stmt.setString(idx++, org.mindrot.jbcrypt.BCrypt.hashpw(newPass, org.mindrot.jbcrypt.BCrypt.gensalt()));
            }
            stmt.setInt(idx, teacher.getId());
            stmt.executeUpdate();

            teacher.setName(name);
            teacher.setPhone(phone);
            if (photoPath != null) teacher.setProfilePhoto(photoPath);
            session.setAttribute("user", teacher);

            response.sendRedirect("teacherProfile?msg=Profile updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("teacherProfile?error=Failed to update profile");
        }
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf("."));
    }
}
