package com.college.attendance.controller;

import com.college.attendance.dao.SubjectDAO;
import com.college.attendance.dao.TimetableDAO;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Teacher;
import com.college.attendance.model.Subject;
import com.college.attendance.model.Timetable;
import com.college.attendance.model.ConfigData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Time;
import java.util.List;

@WebServlet("/manageTimetable")
public class AdminTimetableServlet extends HttpServlet {
    private TimetableDAO timetableDAO;
    private SubjectDAO   subjectDAO;
    private ConfigDAO    configDAO;
    private TeacherDAO   teacherDAO;

    public void init() {
        timetableDAO = new TimetableDAO();
        subjectDAO   = new SubjectDAO();
        configDAO    = new ConfigDAO();
        teacherDAO   = new TeacherDAO();
    }

    // ── Guard ──────────────────────────────────────────────────────────────────
    private boolean isAuthorized(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String role = (String) session.getAttribute("role");
        return role != null && (role.equals("Admin") || role.equals("SuperAdmin"));
    }

    // ── GET ────────────────────────────────────────────────────────────────────
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthorized(request)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String filterDept    = request.getParameter("dept");
        String filterYear    = request.getParameter("year");
        String filterSection = request.getParameter("section");

        // Load timetables – filtered or all
        List<Timetable> timetables;
        if (filterDept != null && !filterDept.isEmpty()) {
            int yr = 0;
            try { yr = Integer.parseInt(filterYear); } catch (Exception ignored) {}
            timetables = timetableDAO.getTimetablesByGroup(filterDept, yr, filterSection);
        } else {
            timetables = timetableDAO.getAllTimetables();
        }

        // Subjects filtered by current group for the add-slot dropdown
        List<Subject> subjects;
        if (filterDept != null && !filterDept.isEmpty()) {
            
            subjects = subjectDAO.getSubjectsByFilter(filterDept, filterYear, filterSection);
        } else {
            subjects = subjectDAO.getAllSubjects();
        }

        List<ConfigData> departments = configDAO.getAll("department");
        List<ConfigData> sections    = configDAO.getAll("section");
        List<ConfigData> years       = configDAO.getAll("academic_year");
        List<Teacher> teachers = teacherDAO.getTeachersByFilter(filterDept, 0, null, null);

        request.setAttribute("timetables",   timetables);
        request.setAttribute("subjects",     subjects);
        request.setAttribute("departments",  departments);
        request.setAttribute("sections",     sections);
        request.setAttribute("years",        years);
        request.setAttribute("teachers", teachers);
        request.setAttribute("filterDept",    filterDept);
        request.setAttribute("filterYear",    filterYear);
        request.setAttribute("filterSection", filterSection);

        request.getRequestDispatcher("admin_timetable.jsp").forward(request, response);
    }

    // ── POST ───────────────────────────────────────────────────────────────────
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthorized(request)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");
        String redirectBase = buildRedirectBase(request);

        if ("add_slot".equals(action)) {
            try {
                int    subjectId   = Integer.parseInt(request.getParameter("subject_id"));
                String dayOfWeek   = request.getParameter("day_of_week");
                String startStr    = request.getParameter("start_time");
                String endStr      = request.getParameter("end_time");
                String roomNo      = request.getParameter("room_no");
                String teacherIdStr = request.getParameter("teacher_id");

                if (startStr.length() == 5) startStr += ":00";
                if (endStr.length()   == 5) endStr   += ":00";

                Timetable t = new Timetable();
                t.setSubjectId(subjectId);
                t.setDayOfWeek(dayOfWeek);
                t.setStartTime(Time.valueOf(startStr));
                t.setEndTime(Time.valueOf(endStr));
                t.setRoomNo(roomNo);
                if (teacherIdStr != null && !teacherIdStr.isEmpty()) { t.setTeacherId(Integer.parseInt(teacherIdStr)); }

                boolean success = timetableDAO.addTimetable(t);
                response.sendRedirect("manageTimetable?" + redirectBase +
                        (success ? "&msg=Slot+added+successfully" : "&error=Failed+to+add+slot"));
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("manageTimetable?" + redirectBase + "&error=Invalid+input");
            }

        } else if ("delete_slot".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                timetableDAO.deleteTimetable(id);
                response.sendRedirect("manageTimetable?" + redirectBase + "&msg=Slot+deleted");
            } catch (NumberFormatException e) {
                response.sendRedirect("manageTimetable?" + redirectBase + "&error=Invalid+ID");
            }

        } else if ("clear_group".equals(action)) {
            try {
                String dept    = request.getParameter("dept");
                int    year    = Integer.parseInt(request.getParameter("year"));
                String section = request.getParameter("section");
                timetableDAO.deleteTimetablesByGroup(dept, year, section);
                response.sendRedirect("manageTimetable?" + redirectBase + "&msg=Routine+cleared");
            } catch (Exception e) {
                response.sendRedirect("manageTimetable?" + redirectBase + "&error=Failed+to+clear");
            }

        } else {
            response.sendRedirect("manageTimetable");
        }
    }

    private String buildRedirectBase(HttpServletRequest req) {
        StringBuilder sb = new StringBuilder();
        String dept = req.getParameter("dept");
        String year = req.getParameter("year");
        String sec  = req.getParameter("section");
        if (dept != null && !dept.isEmpty()) sb.append("dept=").append(dept).append("&");
        if (year != null && !year.isEmpty()) sb.append("year=").append(year).append("&");
        if (sec  != null && !sec.isEmpty())  sb.append("section=").append(sec).append("&");
        // strip trailing &
        String s = sb.toString();
        if (s.endsWith("&")) s = s.substring(0, s.length() - 1);
        return s;
    }
}

