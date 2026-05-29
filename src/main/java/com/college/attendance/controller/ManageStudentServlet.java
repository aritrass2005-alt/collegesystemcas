package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Student;
import com.college.attendance.util.ValidationUtil;

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
        if ("delete".equals(action)) {
            String idStr = ValidationUtil.clean(request.getParameter("id"));
            if (!ValidationUtil.isPositiveInt(idStr)) {
                response.sendRedirect("manageStudents?error=Invalid+student+ID");
                return;
            }
            int id = Integer.parseInt(idStr);
            if (studentDAO.deleteStudent(id)) {
                response.sendRedirect("manageStudents?msg=Student+deleted+successfully");
            } else {
                response.sendRedirect("manageStudents?error=Failed+to+delete+student");
            }
            return;
        }

        String dept      = ValidationUtil.clean(request.getParameter("department"));
        String yearStr   = ValidationUtil.clean(request.getParameter("year"));
        String section   = ValidationUtil.clean(request.getParameter("section"));
        String subjectId = ValidationUtil.clean(request.getParameter("subject_id"));

        int year = 0;
        if (yearStr != null) {
            year = ValidationUtil.parseIntSafe(yearStr, 0);
            if (year != 0 && !ValidationUtil.isValidAcademicYear(year)) {
                response.sendRedirect("manageStudents?error=Invalid+year");
                return;
            }
        }

        List<Student> students = studentDAO.getStudentsByFilter(dept, year, section, subjectId);

        request.setAttribute("students",    students);
        request.setAttribute("departments", configDAO.getAll("department"));
        request.setAttribute("years",       configDAO.getAll("academic_year"));
        request.setAttribute("sections",    configDAO.getAll("section"));
        request.setAttribute("subjects",    subjectDAO.getAllSubjects());
        request.setAttribute("selDept",     dept);
        request.setAttribute("selYear",     yearStr);
        request.setAttribute("selSec",      section);
        request.setAttribute("selSub",      subjectId);

        request.getRequestDispatcher("admin_students.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !isAdmin(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = ValidationUtil.clean(request.getParameter("action"));
        
        if ("promote".equals(action)) {
            String pDept = ValidationUtil.clean(request.getParameter("promote_department"));
            String pYearStr = ValidationUtil.clean(request.getParameter("promote_year"));
            int pYear = ValidationUtil.parseIntSafe(pYearStr, 0);
            
            boolean success = studentDAO.promoteStudents(pDept, pYear);
            if (success) {
                response.sendRedirect("manageStudents?msg=Students+promoted+successfully");
            } else {
                response.sendRedirect("manageStudents?error=Failed+to+promote+students");
            }
            return;
        }

        if (action == null || (!action.equals("add") && !action.equals("update"))) {
            response.sendRedirect("manageStudents?error=Invalid+action");
            return;
        }

        // ── Field extraction and validation ──────────────────────────────────
        String rollNo  = ValidationUtil.clean(request.getParameter("roll_no"));
        String name    = ValidationUtil.clean(request.getParameter("name"));
        String email   = ValidationUtil.clean(request.getParameter("email"));
        String phone   = ValidationUtil.clean(request.getParameter("phone"));
        String dept    = ValidationUtil.clean(request.getParameter("department"));
        String yearStr = ValidationUtil.clean(request.getParameter("year"));
        String section = ValidationUtil.clean(request.getParameter("section"));
        String address = ValidationUtil.sanitizeText(request.getParameter("address"));

        StringBuilder errors = new StringBuilder();

        if (!ValidationUtil.isValidRollNo(rollNo))  errors.append("Invalid Roll No. ");
        if (!ValidationUtil.isValidName(name))       errors.append("Invalid name. ");
        if (!ValidationUtil.isValidEmail(email))     errors.append("Invalid email. ");
        if (phone != null && !ValidationUtil.isValidPhone(phone)) errors.append("Invalid phone. ");
        if (dept == null || dept.isEmpty())          errors.append("Department required. ");

        int year = ValidationUtil.parseIntSafe(yearStr, 0);
        if (!ValidationUtil.isValidAcademicYear(year)) errors.append("Invalid year (1-4). ");

        if (errors.length() > 0) {
            response.sendRedirect("manageStudents?error=" + java.net.URLEncoder.encode(errors.toString(), "UTF-8"));
            return;
        }

        Student s = new Student();
        s.setRollNo(rollNo);
        s.setName(name);
        s.setEmail(email);
        s.setPhone(phone);
        s.setDepartment(dept);
        s.setYear(year);
        s.setSection(section);

        boolean success = false;
        
        String dob = ValidationUtil.clean(request.getParameter("dob"));
        if (dob != null) dob = dob.replace("-", "");
        if (dob != null && !dob.isEmpty() && !ValidationUtil.isValidDob(dob)) {
            response.sendRedirect("manageStudents?error=Invalid+date+of+birth+format");
            return;
        }
        s.setDob(dob);

        if ("add".equals(action)) {
            success = studentDAO.addStudent(s, dob, address);
        } else {
            String idStr = ValidationUtil.clean(request.getParameter("id"));
            if (!ValidationUtil.isPositiveInt(idStr)) {
                response.sendRedirect("manageStudents?error=Invalid+student+ID");
                return;
            }
            s.setId(Integer.parseInt(idStr));
            success = studentDAO.updateStudent(s, address);
        }

        if (success) {
            response.sendRedirect("manageStudents?msg=Student+" + ("add".equals(action) ? "added" : "updated") + "+successfully");
        } else {
            response.sendRedirect("manageStudents?error=Failed+to+process+student+request");
        }
    }
}
