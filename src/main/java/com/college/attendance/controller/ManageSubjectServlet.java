package com.college.attendance.controller;

import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Teacher;
import com.college.attendance.model.ConfigData;

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
    private ConfigDAO configDAO;

    public void init() {
        subjectDAO = new SubjectDAO();
        teacherDAO = new TeacherDAO();
        configDAO  = new ConfigDAO();
        // Ensure the alt_teacher_id column exists (safe no-op if already present)
        subjectDAO.ensureAltTeacherColumn();
    }

    // ── Guard ──────────────────────────────────────────────────────────────────
    private boolean isAuthorized(HttpServletRequest request) {
        String role = (String) request.getSession().getAttribute("role");
        return role != null && (role.equals("Admin") || role.equals("SuperAdmin"));
    }

    // ── GET ────────────────────────────────────────────────────────────────────
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthorized(request)) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String filterDept    = request.getParameter("dept");
        String filterYear    = request.getParameter("year");
        String filterSection = request.getParameter("section");

        List<Subject> subjects;
        if ((filterDept != null && !filterDept.isEmpty())
                || (filterYear != null && !filterYear.isEmpty())
                || (filterSection != null && !filterSection.isEmpty())) {
            subjects = subjectDAO.getSubjectsByFilter(filterDept, filterYear, filterSection);
        } else {
            subjects = subjectDAO.getAllSubjects();
        }

        List<Teacher>    teachers    = teacherDAO.getAllTeachers();
        List<ConfigData> departments = configDAO.getAll("department");
        List<ConfigData> sections    = configDAO.getAll("section");
        List<ConfigData> years       = configDAO.getAll("academic_year");

        // Pass edit target if editing
        String editId = request.getParameter("edit");
        if (editId != null && !editId.isEmpty()) {
            try {
                Subject editSubject = subjectDAO.getSubjectById(Integer.parseInt(editId));
                request.setAttribute("editSubject", editSubject);
            } catch (NumberFormatException ignored) {}
        }

        request.setAttribute("subjects",    subjects);
        request.setAttribute("teachers",    teachers);
        request.setAttribute("departments", departments);
        request.setAttribute("sections",    sections);
        request.setAttribute("years",       years);
        request.setAttribute("filterDept",    filterDept);
        request.setAttribute("filterYear",    filterYear);
        request.setAttribute("filterSection", filterSection);

        request.getRequestDispatcher("admin_subjects.jsp").forward(request, response);
    }

    // ── POST ───────────────────────────────────────────────────────────────────
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthorized(request)) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String action = request.getParameter("action");

        if ("add_subject".equals(action)) {
            Subject s = buildSubjectFromRequest(request);
            boolean success = subjectDAO.addSubject(s);
            response.sendRedirect("manageSubjects?msg=" +
                    (success ? "Subject added successfully." : "Failed to add subject.") +
                    buildFilterParams(request));

        } else if ("update_subject".equals(action)) {
            Subject s = buildSubjectFromRequest(request);
            try { s.setId(Integer.parseInt(request.getParameter("id"))); }
            catch (NumberFormatException ignored) {}
            boolean success = subjectDAO.updateSubject(s);
            response.sendRedirect("manageSubjects?msg=" +
                    (success ? "Subject updated." : "Update failed.") +
                    buildFilterParams(request));

        } else if ("delete_subject".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean success = subjectDAO.deleteSubject(id);
                response.sendRedirect("manageSubjects?msg=" +
                        (success ? "Subject deleted." : "Delete failed.") +
                        buildFilterParams(request));
            } catch (NumberFormatException e) {
                response.sendRedirect("manageSubjects?error=Invalid+subject+ID");
            }
        } else {
            response.sendRedirect("manageSubjects");
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────────
    private Subject buildSubjectFromRequest(HttpServletRequest req) {
        Subject s = new Subject();
        s.setSubjectCode(req.getParameter("subjectCode"));
        s.setName(req.getParameter("name"));
        s.setDepartment(req.getParameter("department"));
        try { s.setYear(Integer.parseInt(req.getParameter("year"))); } catch (Exception ignored) {}
        s.setSection(req.getParameter("section"));
        try { s.setTeacherId(Integer.parseInt(req.getParameter("teacherId"))); } catch (Exception ignored) {}
        try { s.setAltTeacherId(Integer.parseInt(req.getParameter("altTeacherId"))); } catch (Exception ignored) {}
        return s;
    }

    private String buildFilterParams(HttpServletRequest req) {
        StringBuilder sb = new StringBuilder();
        if (req.getParameter("filterDept") != null && !req.getParameter("filterDept").isEmpty())
            sb.append("&dept=").append(req.getParameter("filterDept"));
        if (req.getParameter("filterYear") != null && !req.getParameter("filterYear").isEmpty())
            sb.append("&year=").append(req.getParameter("filterYear"));
        if (req.getParameter("filterSection") != null && !req.getParameter("filterSection").isEmpty())
            sb.append("&section=").append(req.getParameter("filterSection"));
        return sb.toString();
    }
}
