package com.college.attendance.controller;

import com.college.attendance.dao.TimetableDAO;
import com.college.attendance.model.Student;
import com.college.attendance.model.Timetable;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/studentTimetable")
public class StudentTimetableServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");
        
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }

        TimetableDAO timetableDAO = new TimetableDAO();
        List<Timetable> studentTimetable = timetableDAO.getTimetableForStudent(student.getDepartment(), student.getYear(), student.getSection());
        request.setAttribute("studentTimetable", studentTimetable);

        request.getRequestDispatcher("student_timetable.jsp").forward(request, response);
    }
}
