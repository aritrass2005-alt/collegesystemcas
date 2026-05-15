package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.model.Attendance;
import com.college.attendance.model.Student;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        // 1. Load subjects for this teacher
        List<Subject> subjects = subjectDAO.getSubjectsByTeacher(teacher.getId());
        request.setAttribute("subjects", subjects);

        // Fetch dynamic distinct sections from the database
        List<String> availableSections = studentDAO.getAvailableSections();
        request.setAttribute("availableSections", availableSections);

        // 2. If a subject and section are selected, load the corresponding students
        String subjectIdStr = request.getParameter("subjectId");
        String section = request.getParameter("section");
        
        if (subjectIdStr != null && !subjectIdStr.isEmpty()) {
            int subjectId = Integer.parseInt(subjectIdStr);
            Subject selectedSubject = subjectDAO.getSubjectById(subjectId);
            
            if (selectedSubject != null && selectedSubject.getTeacherId() == teacher.getId()) {
                request.setAttribute("selectedSubject", selectedSubject);
                
                if (section != null && !section.isEmpty()) {
                    request.setAttribute("selectedSection", section);
                    List<Student> students = studentDAO.getStudentsForSubject(selectedSubject.getDepartment(), selectedSubject.getYear(), section);
                    request.setAttribute("students", students);
                }
            } else {
                request.setAttribute("error", "Invalid subject selection.");
            }
        }

        request.getRequestDispatcher("teacher_attendance.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Teacher teacher = (Teacher) request.getSession().getAttribute("user");
        if (teacher == null || !"Teacher".equals(request.getSession().getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        String subjectIdStr = request.getParameter("subjectId");
        if (subjectIdStr == null || subjectIdStr.isEmpty()) {
            response.sendRedirect("takeAttendance?error=No subject selected");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        String[] studentIds = request.getParameterValues("studentIds");
        
        if (studentIds == null || studentIds.length == 0) {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&error=No students found to mark attendance.");
            return;
        }

        List<Attendance> records = new ArrayList<>();
        
        for (String idStr : studentIds) {
            int studentId = Integer.parseInt(idStr);
            // The radio button name is dynamic: status_1, status_2, etc.
            String status = request.getParameter("status_" + studentId); 
            
            if (status != null) {
                Attendance att = new Attendance();
                att.setStudentId(studentId);
                att.setSubjectId(subjectId);
                att.setStatus(status);
                records.add(att);
            }
        }

        boolean success = attendanceDAO.submitAttendance(records);
        
        if (success) {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&msg=Attendance submitted successfully for " + records.size() + " students.");
        } else {
            response.sendRedirect("takeAttendance?subjectId=" + subjectId + "&error=Failed to submit attendance.");
        }
    }
}
