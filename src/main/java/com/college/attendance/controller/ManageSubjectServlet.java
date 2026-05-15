package com.college.attendance.controller;

import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/manageSubjects")
public class ManageSubjectServlet extends HttpServlet {
    private SubjectDAO subjectDAO;
    private TeacherDAO teacherDAO;

    public void init() {
        subjectDAO = new SubjectDAO();
        teacherDAO = new TeacherDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("Admin") && !role.equals("SuperAdmin"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<Subject> subjects = subjectDAO.getAllSubjects();
        List<Teacher> teachers = teacherDAO.getAllTeachers(); // For the dropdown when adding a subject
        
        com.college.attendance.dao.ConfigDAO configDAO = new com.college.attendance.dao.ConfigDAO();
        request.setAttribute("departments", configDAO.getAll("department"));
        request.setAttribute("sections", configDAO.getAll("section"));
        request.setAttribute("years", configDAO.getAll("academic_year"));

        request.setAttribute("subjects", subjects);
        request.setAttribute("teachers", teachers);

        request.getRequestDispatcher("admin_subjects.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("add_subject".equals(action)) {
            Subject s = new Subject();
            s.setSubjectCode(request.getParameter("subjectCode"));
            s.setName(request.getParameter("name"));
            s.setDepartment(request.getParameter("department"));
            s.setYear(Integer.parseInt(request.getParameter("year")));
            s.setSection(request.getParameter("section"));
            s.setTeacherId(Integer.parseInt(request.getParameter("teacherId")));
            
            boolean success = subjectDAO.addSubject(s);
            response.sendRedirect("manageSubjects?msg=" + (success ? "Subject added successfully." : "Failed to add subject."));
        }
    }
}
