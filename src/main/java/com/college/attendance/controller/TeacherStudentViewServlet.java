package com.college.attendance.controller;

import com.college.attendance.dao.StudentDAO;
import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Student;
import com.college.attendance.model.AttendanceSummary;
import com.college.attendance.model.Teacher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/teacherStudentView")
public class TeacherStudentViewServlet extends HttpServlet {
    private StudentDAO studentDAO;
    private AttendanceDAO attendanceDAO;

    public void init() {
        studentDAO = new StudentDAO();
        attendanceDAO = new AttendanceDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        List<Student> students = studentDAO.getStudentsByTeacher(teacher.getId());
        request.setAttribute("students", students);

        String studentIdStr = request.getParameter("studentId");
        if (studentIdStr != null && !studentIdStr.isEmpty()) {
            try {
                int studentId = Integer.parseInt(studentIdStr);
                boolean allowed = false;
                Student selectedStudent = null;
                for (Student s : students) {
                    if (s.getId() == studentId) {
                        allowed = true;
                        selectedStudent = s;
                        break;
                    }
                }

                if (allowed && selectedStudent != null) {
                    List<AttendanceSummary> summaryList = attendanceDAO.getStudentAttendanceSummary(studentId);
                    request.setAttribute("selectedStudent", selectedStudent);
                    request.setAttribute("attendanceSummary", summaryList);
                } else {
                    request.setAttribute("error", "Access to student details denied or student not found.");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid Student ID.");
            }
        }

        request.getRequestDispatcher("teacher_student_view.jsp").forward(request, response);
    }
}
