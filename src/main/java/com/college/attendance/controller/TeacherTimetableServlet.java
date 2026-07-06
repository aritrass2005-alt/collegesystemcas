package com.college.attendance.controller;

import com.college.attendance.dao.TimetableDAO;
import com.college.attendance.model.Teacher;
import com.college.attendance.model.Timetable;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/teacherTimetable")
public class TeacherTimetableServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?msg=Please login first.");
            return;
        }

        TimetableDAO timetableDAO = new TimetableDAO();
        List<Timetable> teacherTimetable = timetableDAO.getTimetableForTeacher(teacher.getId());
        request.setAttribute("teacherTimetable", teacherTimetable);

        request.getRequestDispatcher("teacher_timetable.jsp").forward(request, response);
    }
}
