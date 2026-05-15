package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Student;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/manageStudents")
public class ManageStudentServlet extends HttpServlet {
    private StudentDAO studentDAO = new StudentDAO();
    private ConfigDAO configDAO = new ConfigDAO();
    private SubjectDAO subjectDAO = new SubjectDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (studentDAO.deleteStudent(id)) {
                response.sendRedirect("manageStudents?msg=Student deleted successfully");
            } else {
                response.sendRedirect("manageStudents?error=Failed to delete student");
            }
            return;
        }

        String dept = request.getParameter("department");
        String yearStr = request.getParameter("year");
        String section = request.getParameter("section");
        String subjectId = request.getParameter("subject_id");

        int year = 0;
        if (yearStr != null && !yearStr.isEmpty()) {
            year = Integer.parseInt(yearStr);
        }

        List<Student> students = studentDAO.getStudentsByFilter(dept, year, section, subjectId);

        request.setAttribute("students", students);
        request.setAttribute("departments", configDAO.getAll("department"));
        request.setAttribute("years", configDAO.getAll("academic_year"));
        request.setAttribute("sections", configDAO.getAll("section"));
        request.setAttribute("subjects", subjectDAO.getAllSubjects());

        request.setAttribute("selDept", dept);
        request.setAttribute("selYear", yearStr);
        request.setAttribute("selSec", section);
        request.setAttribute("selSub", subjectId);

        request.getRequestDispatcher("admin_students.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        
        Student s = new Student();
        s.setRollNo(request.getParameter("roll_no"));
        s.setName(request.getParameter("name"));
        s.setEmail(request.getParameter("email"));
        s.setPhone(request.getParameter("phone"));
        s.setDepartment(request.getParameter("department"));
        s.setYear(Integer.parseInt(request.getParameter("year")));
        s.setSection(request.getParameter("section"));
        String address = request.getParameter("address");

        boolean success = false;
        if ("add".equals(action)) {
            String dob = request.getParameter("dob").replace("-", ""); // Format: YYYYMMDD or DDMMYYYY
            // Simplified DOB for password: remove hyphens
            success = studentDAO.addStudent(s, dob, address);
        } else if ("update".equals(action)) {
            s.setId(Integer.parseInt(request.getParameter("id")));
            success = studentDAO.updateStudent(s, address);
        }

        if (success) {
            response.sendRedirect("manageStudents?msg=Student " + (action.equals("add") ? "added" : "updated") + " successfully");
        } else {
            response.sendRedirect("manageStudents?error=Failed to process student request");
        }
    }
}
