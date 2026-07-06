package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.Student;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Teacher;
import com.college.attendance.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/takeAttendance")
public class TakeAttendanceServlet extends HttpServlet {
    private SubjectDAO subjectDAO;
    private StudentDAO studentDAO;
    private AttendanceDAO attendanceDAO;

    public void init() {
        subjectDAO = new SubjectDAO();
        studentDAO = new StudentDAO();
        attendanceDAO = new AttendanceDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Teacher teacher = (Teacher) request.getSession().getAttribute("user");
        if (teacher == null || !"Teacher".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        List<Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        request.setAttribute("subjects", subjects);

        List<String> availableSections = studentDAO.getAvailableSections();
        request.setAttribute("availableSections", availableSections);

        String subjectIdStr = ValidationUtil.clean(request.getParameter("subjectId"));
        String section      = ValidationUtil.clean(request.getParameter("section"));

        if (subjectIdStr != null) {
            if (!ValidationUtil.isPositiveInt(subjectIdStr)) {
                request.setAttribute("error", "Invalid subject selection.");
                request.getRequestDispatcher("teacher_attendance.jsp").forward(request, response);
                return;
            }
            int subjectId = Integer.parseInt(subjectIdStr);
            Subject selectedSubject = subjectDAO.getSubjectById(subjectId);

            // Ownership check — teacher can only view their own subject
            if (selectedSubject != null && selectedSubject.getTeacherId() == teacher.getId()) {
                request.setAttribute("selectedSubject", selectedSubject);

                if (section != null && !section.isEmpty()) {
                    // Validate section is alphanumeric
                    if (!ValidationUtil.isValidAlphanumeric(section)) {
                        request.setAttribute("error", "Invalid section value.");
                        request.getRequestDispatcher("teacher_attendance.jsp").forward(request, response);
                        return;
                    }
                    request.setAttribute("selectedSection", section);
                    List<Student> students = studentDAO.getStudentsForSubject(
                            selectedSubject.getDepartment(), selectedSubject.getYear(), section);

                    if (students != null && !students.isEmpty()) {
                        List<Integer> studentIds = new ArrayList<>();
                        for (Student s : students) studentIds.add(s.getId());
                        boolean alreadySubmitted = attendanceDAO.isAttendanceSubmittedForStudents(
                                subjectId, studentIds,
                                new java.sql.Date(System.currentTimeMillis()).toString());
                        if (alreadySubmitted) {
                            request.setAttribute("error", "Attendance has already been submitted today. Contact admin for modifications.");
                            request.setAttribute("alreadySubmitted", true);
                        }
                    }
                    request.setAttribute("students", students);
                }
            } else {
                request.setAttribute("error", "Invalid subject selection or access denied.");
            }
        }

        request.getRequestDispatcher("teacher_attendance.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Teacher teacher = (Teacher) request.getSession().getAttribute("user");
        if (teacher == null || !"Teacher".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String subjectIdStr = ValidationUtil.clean(request.getParameter("subjectId"));
        if (!ValidationUtil.isPositiveInt(subjectIdStr)) {
            response.sendRedirect("takeAttendance?error=Invalid+subject+selected");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);

        // Ownership re-verification on POST (cannot be bypassed)
        Subject subject = subjectDAO.getSubjectById(subjectId);
        if (subject == null || subject.getTeacherId() != teacher.getId()) {
            response.sendRedirect("takeAttendance?error=Access+denied");
            return;
        }

        String[] studentIds = request.getParameterValues("studentIds");
        if (studentIds == null || studentIds.length == 0) {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&error=No+students+found");
            return;
        }

        List<Attendance> records = new ArrayList<>();
        for (String idStr : studentIds) {
            if (!ValidationUtil.isPositiveInt(idStr)) continue; // skip invalid IDs
            int studentId = Integer.parseInt(idStr);
            String status = ValidationUtil.clean(request.getParameter("status_" + studentId));

            if (!ValidationUtil.isValidStatus(status)) continue; // only Present/Absent/Leave

            Attendance att = new Attendance();
            att.setStudentId(studentId);
            att.setSubjectId(subjectId);
            att.setStatus(status);
            records.add(att);
        }

        if (records.isEmpty()) {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&error=No+valid+attendance+records");
            return;
        }

        List<Integer> sIds = new ArrayList<>();
        for (Attendance a : records) sIds.add(a.getStudentId());

        if (attendanceDAO.isAttendanceSubmittedForStudents(
                subjectId, sIds, new java.sql.Date(System.currentTimeMillis()).toString())) {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&error=Attendance+already+submitted+for+today");
            return;
        }

        boolean success = attendanceDAO.submitAttendance(records);
        if (success) {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&msg=Attendance+submitted+for+" + records.size() + "+students");
        } else {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&error=Failed+to+submit+attendance");
        }
    }
}
