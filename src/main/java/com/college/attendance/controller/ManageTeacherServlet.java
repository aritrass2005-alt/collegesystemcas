package com.college.attendance.controller;

import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Teacher;
import com.college.attendance.util.ValidationUtil;

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
    private ConfigDAO configDAO   = new ConfigDAO();
    private SubjectDAO subjectDAO = new SubjectDAO();

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

        String action = ValidationUtil.clean(request.getParameter("action"));
        if ("approve".equals(action)) {
            String idStr = ValidationUtil.clean(request.getParameter("id"));
            if (!ValidationUtil.isPositiveInt(idStr)) {
                response.sendRedirect("manageTeachers?error=Invalid+teacher+ID");
                return;
            }
            if (teacherDAO.approveTeacher(Integer.parseInt(idStr))) {
                response.sendRedirect("manageTeachers?msg=Teacher+approved");
            } else {
                response.sendRedirect("manageTeachers?error=Failed+to+approve+teacher");
            }
            return;
        } else if ("delete".equals(action)) {
            String idStr = ValidationUtil.clean(request.getParameter("id"));
            if (!ValidationUtil.isPositiveInt(idStr)) {
                response.sendRedirect("manageTeachers?error=Invalid+teacher+ID");
                return;
            }
            if (teacherDAO.deleteTeacher(Integer.parseInt(idStr))) {
                response.sendRedirect("manageTeachers?msg=Teacher+deleted+successfully");
            } else {
                response.sendRedirect("manageTeachers?error=Failed+to+delete+teacher");
            }
            return;
        }

        String dept    = ValidationUtil.clean(request.getParameter("department"));
        String yearStr = ValidationUtil.clean(request.getParameter("year"));
        String section = ValidationUtil.clean(request.getParameter("section"));
        String subjectId = ValidationUtil.clean(request.getParameter("subject_id"));

        int year = 0;
        if (yearStr != null) {
            year = ValidationUtil.parseIntSafe(yearStr, 0);
        }

        List<Teacher> teachers = teacherDAO.getTeachersByFilter(dept, year, section, subjectId);
        
        String filter = ValidationUtil.clean(request.getParameter("filter"));
        if ("pending".equals(filter)) {
            teachers.removeIf(Teacher::isApproved);
        }
        
        request.setAttribute("teachers",    teachers);
        request.setAttribute("departments", configDAO.getAll("department"));
        request.setAttribute("years",       configDAO.getAll("academic_year"));
        request.setAttribute("sections",    configDAO.getAll("section"));
        request.setAttribute("subjects",    subjectDAO.getAllSubjects());
        request.setAttribute("selDept",     dept);
        request.setAttribute("selYear",     yearStr);
        request.setAttribute("selSec",      section);
        request.setAttribute("selSub",      subjectId);

        request.getRequestDispatcher("admin_teachers.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = ValidationUtil.clean(request.getParameter("action"));
        if (action == null || (!action.equals("add") && !action.equals("update"))) {
            response.sendRedirect("manageTeachers?error=Invalid+action");
            return;
        }

        String name  = ValidationUtil.clean(request.getParameter("name"));
        String email = ValidationUtil.clean(request.getParameter("email"));
        String phone = ValidationUtil.clean(request.getParameter("phone"));
        String dept  = ValidationUtil.clean(request.getParameter("department"));

        StringBuilder errors = new StringBuilder();
        if (!ValidationUtil.isValidName(name))   errors.append("Invalid name. ");
        if (!ValidationUtil.isValidEmail(email)) errors.append("Invalid email. ");
        if (phone != null && !ValidationUtil.isValidPhone(phone)) errors.append("Invalid phone. ");
        if (dept == null || dept.isEmpty())      errors.append("Department required. ");

        if (errors.length() > 0) {
            response.sendRedirect("manageTeachers?error=" + java.net.URLEncoder.encode(errors.toString(), "UTF-8"));
            return;
        }

        Teacher t = new Teacher();
        t.setName(name);
        t.setEmail(email);
        t.setPhone(phone);
        t.setDepartment(dept);

        boolean success = false;
        if ("add".equals(action)) {
            success = teacherDAO.addTeacher(t);
        } else {
            String idStr = ValidationUtil.clean(request.getParameter("id"));
            if (!ValidationUtil.isPositiveInt(idStr)) {
                response.sendRedirect("manageTeachers?error=Invalid+teacher+ID");
                return;
            }
            t.setId(Integer.parseInt(idStr));
            success = teacherDAO.updateTeacher(t);
        }

        if (success) {
            response.sendRedirect("manageTeachers?msg=Teacher+" + ("add".equals(action) ? "added" : "updated") + "+successfully");
        } else {
            response.sendRedirect("manageTeachers?error=Failed+to+process+teacher+request");
        }
    }
}
