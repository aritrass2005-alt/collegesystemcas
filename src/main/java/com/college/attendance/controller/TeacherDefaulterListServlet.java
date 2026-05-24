package com.college.attendance.controller;

import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.DefaulterRecord;
import com.college.attendance.model.Teacher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/teacherDefaulterList")
public class TeacherDefaulterListServlet extends HttpServlet {
    private AttendanceDAO attendanceDAO;

    public void init() {
        attendanceDAO = new AttendanceDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Teacher teacher = (Teacher) session.getAttribute("user");
        if (teacher == null || !"Teacher".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized Access");
            return;
        }
        Double sessionThreshold = (Double) session.getAttribute("defaulterThreshold");
        double threshold = sessionThreshold != null ? sessionThreshold : 75.0;

        String startDate = (String) session.getAttribute("defaulterStartDate");
        String endDate = (String) session.getAttribute("defaulterEndDate");

        if (request.getParameter("threshold") != null) {
            String thresholdStr = request.getParameter("threshold");
            try {
                threshold = Double.parseDouble(thresholdStr);
                session.setAttribute("defaulterThreshold", threshold);
                getServletContext().setAttribute("globalDefaulterThreshold", threshold);
            } catch (NumberFormatException e) {
                // ignore
            }
            startDate = request.getParameter("startDate");
            endDate = request.getParameter("endDate");
            session.setAttribute("defaulterStartDate", startDate);
            session.setAttribute("defaulterEndDate", endDate);
        }

        List<DefaulterRecord> defaulters = attendanceDAO.getDefaultersForTeacher(teacher.getId(), threshold, startDate, endDate);
        request.setAttribute("defaulters", defaulters);
        request.setAttribute("currentThreshold", threshold);
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");

        request.getRequestDispatcher("teacher_defaulter_list.jsp").forward(request, response);
    }
}
