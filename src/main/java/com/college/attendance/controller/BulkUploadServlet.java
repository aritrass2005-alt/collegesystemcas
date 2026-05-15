package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Student;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/bulkUpload")
@MultipartConfig
public class BulkUploadServlet extends HttpServlet {
    private StudentDAO studentDAO = new StudentDAO();
    private TeacherDAO teacherDAO = new TeacherDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        if (type != null) {
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + type + "_sample.csv\"");
            PrintWriter out = response.getWriter();
            if ("student".equals(type)) {
                out.println("RollNo,Name,Email,Phone,Department,Year,Section,DOB_DDMMYYYY");
                out.println("CS202301,John Doe,john@example.com,1234567890,Computer Science,1,A,15082005");
            } else if ("teacher".equals(type)) {
                out.println("Name,Email,Phone,Department");
                out.println("Jane Smith,jane@example.com,0987654321,Computer Science");
            }
            out.flush();
            return;
        }
        request.getRequestDispatcher("admin_bulk_upload.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String uploadType = request.getParameter("uploadType");
        Part filePart = request.getPart("csvFile");

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("bulkUpload?error=Please select a valid CSV file");
            return;
        }

        try (InputStream is = filePart.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
             
            String line = reader.readLine(); // Skip header
            int successCount = 0;
            int failCount = 0;

            if ("student".equals(uploadType)) {
                List<Student> students = new ArrayList<>();
                List<String> dobs = new ArrayList<>();
                
                while ((line = reader.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] data = line.split(",");
                    if (data.length >= 8) {
                        Student s = new Student();
                        s.setRollNo(data[0].trim());
                        s.setName(data[1].trim());
                        s.setEmail(data[2].trim());
                        s.setPhone(data[3].trim());
                        s.setDepartment(data[4].trim());
                        s.setYear(Integer.parseInt(data[5].trim()));
                        s.setSection(data[6].trim());
                        students.add(s);
                        dobs.add(data[7].trim());
                    } else {
                        failCount++;
                    }
                }
                
                if (!students.isEmpty() && studentDAO.addStudentsBulk(students, dobs)) {
                    successCount = students.size();
                } else {
                    failCount += students.size();
                }
                
            } else if ("teacher".equals(uploadType)) {
                while ((line = reader.readLine()) != null) {
                    if (line.trim().isEmpty()) continue;
                    String[] data = line.split(",");
                    if (data.length >= 4) {
                        Teacher t = new Teacher();
                        t.setName(data[0].trim());
                        t.setEmail(data[1].trim());
                        t.setPhone(data[2].trim());
                        t.setDepartment(data[3].trim());
                        if (teacherDAO.addTeacher(t)) {
                            successCount++;
                        } else {
                            failCount++;
                        }
                    } else {
                        failCount++;
                    }
                }
            }

            response.sendRedirect("bulkUpload?msg=Upload completed: " + successCount + " successful, " + failCount + " failed.");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("bulkUpload?error=An error occurred during upload. Please check the CSV format.");
        }
    }
}
