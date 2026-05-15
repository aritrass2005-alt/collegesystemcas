package com.college.attendance.controller;

import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/manageTeachers")
public class ManageTeacherServlet extends HttpServlet {
    private TeacherDAO teacherDAO = new TeacherDAO();
    private ConfigDAO configDAO = new ConfigDAO();
    private SubjectDAO subjectDAO = new SubjectDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("approve".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            teacherDAO.approveTeacher(id);
            response.sendRedirect("manageTeachers?msg=Teacher approved");
            return;
        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (teacherDAO.deleteTeacher(id)) {
                response.sendRedirect("manageTeachers?msg=Teacher deleted successfully");
            } else {
                response.sendRedirect("manageTeachers?error=Failed to delete teacher");
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

        List<Teacher> teachers = teacherDAO.getTeachersByFilter(dept, year, section, subjectId);

        request.setAttribute("teachers", teachers);
        request.setAttribute("departments", configDAO.getAll("department"));
        request.setAttribute("years", configDAO.getAll("academic_year"));
        request.setAttribute("sections", configDAO.getAll("section"));
        request.setAttribute("subjects", subjectDAO.getAllSubjects());

        request.setAttribute("selDept", dept);
        request.setAttribute("selYear", yearStr);
        request.setAttribute("selSec", section);
        request.setAttribute("selSub", subjectId);

        request.getRequestDispatcher("admin_teachers.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        
        Teacher t = new Teacher();
        t.setName(request.getParameter("name"));
        t.setEmail(request.getParameter("email"));
        t.setPhone(request.getParameter("phone"));
        t.setDepartment(request.getParameter("department"));

        boolean success = false;
        if ("add".equals(action)) {
            success = teacherDAO.addTeacher(t);
        } else if ("update".equals(action)) {
            t.setId(Integer.parseInt(request.getParameter("id")));
            success = teacherDAO.updateTeacher(t);
        }

        if (success) {
            response.sendRedirect("manageTeachers?msg=Teacher " + (action.equals("add") ? "added" : "updated") + " successfully");
        } else {
            response.sendRedirect("manageTeachers?error=Failed to process teacher request");
        }
    }
}
