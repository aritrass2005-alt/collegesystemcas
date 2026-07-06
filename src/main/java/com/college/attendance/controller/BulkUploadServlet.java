package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;
import com.college.attendance.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/bulkUpload")
@MultipartConfig(maxFileSize = 1024 * 1024 * 2) // 2 MB max CSV
public class BulkUploadServlet extends HttpServlet {
    private StudentDAO studentDAO = new StudentDAO();
    private TeacherDAO teacherDAO = new TeacherDAO();

    private boolean isAdmin(HttpSession session) {
        return session.getAttribute("user") != null
                && ("Admin".equals(session.getAttribute("role"))
                    || "SuperAdmin".equals(session.getAttribute("role")));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String type = ValidationUtil.clean(request.getParameter("type"));
        if ("student".equals(type) || "teacher".equals(type)) {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + type + "_sample.csv\"");
            PrintWriter out = response.getWriter();
            if ("student".equals(type)) {
                out.println("RollNo,Name,Email,Phone,Department,Year,Section,DOB_DDMMYYYY");
                out.println("CS202301,John Doe,john@example.com,9876543210,Computer Science,1,A,15082005");
            } else {
                out.println("Name,Email,Phone,Department");
                out.println("Jane Smith,jane@example.com,9876543210,Computer Science");
            }
            out.flush();
            return;
        }
        request.getRequestDispatcher("admin_bulk_upload.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String uploadType = ValidationUtil.clean(request.getParameter("uploadType"));
        if (!"student".equals(uploadType) && !"teacher".equals(uploadType)) {
            response.sendRedirect("bulkUpload?error=Invalid+upload+type");
            return;
        }

        Part filePart = request.getPart("csvFile");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("bulkUpload?error=Please+select+a+valid+CSV+file");
            return;
        }

        // Validate extension
        String csvFileName = filePart.getSubmittedFileName();
        if (csvFileName == null || !csvFileName.toLowerCase().endsWith(".csv")) {
            response.sendRedirect("bulkUpload?error=Only+.csv+files+allowed");
            return;
        }

        int successCount = 0;
        int failCount    = 0;

        try (InputStream is = filePart.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {

            reader.readLine(); // skip header row

            String line;
            if ("student".equals(uploadType)) {
                List<Student> students = new ArrayList<>();
                List<String>  dobs     = new ArrayList<>();

                while ((line = reader.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] data = line.split(",", -1);
                    if (data.length < 8) { failCount++; continue; }

                    String rollNo = data[0].trim();
                    String name   = data[1].trim();
                    String email  = data[2].trim();
                    String phone  = data[3].trim();
                    String dept   = data[4].trim();
                    String yearS  = data[5].trim();
                    String sect   = data[6].trim();
                    String dob    = data[7].trim();

                    // Row-level validation
                    if (!ValidationUtil.isValidRollNo(rollNo)
                            || !ValidationUtil.isValidName(name)
                            || !ValidationUtil.isValidEmail(email)
                            || !ValidationUtil.isValidPhone(phone)
                            || dept.isEmpty()
                            || !ValidationUtil.isValidDob(dob)) {
                        failCount++;
                        continue;
                    }
                    int year = ValidationUtil.parseIntSafe(yearS, 0);
                    if (!ValidationUtil.isValidAcademicYear(year)) { failCount++; continue; }

                    Student s = new Student();
                    s.setRollNo(rollNo);
                    s.setName(name);
                    s.setEmail(email);
                    s.setPhone(phone);
                    s.setDepartment(dept);
                    s.setYear(year);
                    s.setSection(sect);
                    students.add(s);
                    dobs.add(dob);
                }

                if (!students.isEmpty() && studentDAO.addStudentsBulk(students, dobs)) {
                    successCount = students.size();
                } else {
                    failCount += students.size();
                }

            } else { // teacher
                while ((line = reader.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] data = line.split(",", -1);
                    if (data.length < 4) { failCount++; continue; }

                    String name  = data[0].trim();
                    String email = data[1].trim();
                    String phone = data[2].trim();
                    String dept  = data[3].trim();

                    if (!ValidationUtil.isValidName(name)
                            || !ValidationUtil.isValidEmail(email)
                            || !ValidationUtil.isValidPhone(phone)
                            || dept.isEmpty()) {
                        failCount++;
                        continue;
                    }

                    Teacher t = new Teacher();
                    t.setName(name);
                    t.setEmail(email);
                    t.setPhone(phone);
                    t.setDepartment(dept);
                    if (teacherDAO.addTeacher(t)) successCount++;
                    else failCount++;
                }
            }

            response.sendRedirect("bulkUpload?msg=Upload+complete:+" + successCount + "+succeeded,+" + failCount + "+failed");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("bulkUpload?error=Error+during+upload.+Check+CSV+format.");
        }
    }
}
