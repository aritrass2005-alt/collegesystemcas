package com.college.attendance.controller;

import com.college.attendance.dao.CoordinatorDAO;
import com.college.attendance.model.Coordinator;
import com.college.attendance.dao.TeacherDAO;
import com.college.attendance.model.Teacher;
import com.college.attendance.dao.ConfigDAO;
import com.college.attendance.model.ConfigData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

import java.util.List;

@WebServlet("/manageCoordinator")
public class ManageCoordinatorServlet extends HttpServlet {
    private CoordinatorDAO coordinatorDAO = new CoordinatorDAO();
    private TeacherDAO teacherDAO = new TeacherDAO();
    private ConfigDAO configDAO = new ConfigDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }
        List<Coordinator> coordinators = coordinatorDAO.getAllCoordinators();
        List<Teacher> teachers = teacherDAO.getAllTeachers();
        List<ConfigData> departments = configDAO.getAll("department");
        List<ConfigData> years = configDAO.getAll("academic_year");
        List<ConfigData> sections = configDAO.getAll("section");
        
        request.setAttribute("coordinators", coordinators);
        request.setAttribute("teachers", teachers);
        request.setAttribute("departments", departments);
        request.setAttribute("years", years);
        request.setAttribute("sections", sections);
        request.getRequestDispatcher("admin_coordinators.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null || (!"Admin".equals(session.getAttribute("role")) && !"SuperAdmin".equals(session.getAttribute("role")))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("assign".equals(action)) {
            int teacherId = Integer.parseInt(request.getParameter("teacher_id"));
            String department = request.getParameter("department");
            int year = Integer.parseInt(request.getParameter("year"));
            String section = request.getParameter("section");
            
            boolean success = coordinatorDAO.addCoordinatorRole(teacherId, department, year, section);
            if (success) {
                response.sendRedirect("manageCoordinator?msg=Coordinator assigned successfully");
            } else {
                response.sendRedirect("manageCoordinator?error=Failed to assign coordinator");
            }
        } else if ("remove".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = coordinatorDAO.removeCoordinatorRole(id);
            if (success) {
                response.sendRedirect("manageCoordinator?msg=Coordinator removed successfully");
            } else {
                response.sendRedirect("manageCoordinator?error=Failed to remove coordinator");
            }
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            int teacherId = Integer.parseInt(request.getParameter("teacher_id"));
            String department = request.getParameter("department");
            int year = Integer.parseInt(request.getParameter("year"));
            String section = request.getParameter("section");
            
            boolean success = coordinatorDAO.updateCoordinatorRole(id, teacherId, department, year, section);
            if (success) {
                response.sendRedirect("manageCoordinator?msg=Coordinator updated successfully");
            } else {
                response.sendRedirect("manageCoordinator?error=Failed to update coordinator");
            }
        }
    }
}
