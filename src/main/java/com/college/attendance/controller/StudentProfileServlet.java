package com.college.attendance.controller;

import com.college.attendance.model.Student;
import com.college.attendance.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/studentProfile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB max
public class StudentProfileServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Enforce profile completion and parent verification
        if (!student.isProfileCompleted() || !student.isParentVerified()) {
            response.sendRedirect("studentSetup");
            return;
        }

        String action = request.getParameter("action");
        if ("remove_photo".equals(action)) {
            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement stmt = conn.prepareStatement("UPDATE student SET profile_photo=NULL WHERE id=?");
                stmt.setInt(1, student.getId());
                stmt.executeUpdate();
                student.setProfilePhoto(null);
                session.setAttribute("user", student);
                response.sendRedirect("studentProfile?msg=Profile photo removed");
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        request.getRequestDispatcher("student_profile.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String name    = request.getParameter("name");
        String phone       = request.getParameter("phone");
        String address     = request.getParameter("address");
        String parentName  = request.getParameter("parent_name");
        String parentPhone = request.getParameter("parent_phone");
        String parentEmail = request.getParameter("parent_email");
        String newPass     = request.getParameter("new_password");

        if (phone != null && phone.equals(parentPhone)) {
            response.sendRedirect("studentProfile?error=Student phone and guardian phone cannot be the same.");
            return;
        }

        // Handle photo upload
        String photoPath = null;
        Part photoPart = request.getPart("profile_photo");
        if (photoPart != null && photoPart.getSize() > 0) {
            String fileName = "student_" + student.getId() + "_" + System.currentTimeMillis() + getExtension(photoPart.getSubmittedFileName());
            String uploadDir = getServletContext().getRealPath("/") + "img" + File.separator + "profiles";
            new File(uploadDir).mkdirs();
            photoPart.write(uploadDir + File.separator + fileName);
            photoPath = "img/profiles/" + fileName;
        }

        try (Connection conn = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE student SET name=?, phone=?, address=?, parent_name=?, parent_phone=?, parent_email=?");
            if (photoPath != null) sql.append(", profile_photo=?");
            if (newPass != null && !newPass.trim().isEmpty()) sql.append(", password=?");
            sql.append(" WHERE id=?");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            stmt.setString(idx++, name);
            stmt.setString(idx++, phone);
            stmt.setString(idx++, address);
            stmt.setString(idx++, parentName);
            stmt.setString(idx++, parentPhone);
            stmt.setString(idx++, parentEmail);
            if (photoPath != null) stmt.setString(idx++, photoPath);
            if (newPass != null && !newPass.trim().isEmpty()) {
                stmt.setString(idx++, org.mindrot.jbcrypt.BCrypt.hashpw(newPass, org.mindrot.jbcrypt.BCrypt.gensalt()));
            }
            stmt.setInt(idx, student.getId());
            stmt.executeUpdate();

            // Refresh session object
            student.setName(name);
            student.setPhone(phone);
            student.setAddress(address);
            student.setParentName(parentName);
            student.setParentPhone(parentPhone);
            student.setParentEmail(parentEmail);
            if (photoPath != null) student.setProfilePhoto(photoPath);
            session.setAttribute("user", student);

            response.sendRedirect("studentProfile?msg=Profile updated successfully");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("studentProfile?error=Failed to update profile");
        }
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf("."));
    }
}
