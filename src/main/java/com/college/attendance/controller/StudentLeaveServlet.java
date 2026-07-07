package com.college.attendance.controller;

import com.college.attendance.dao.LeaveApplicationDAO;
import com.college.attendance.model.LeaveApplication;
import com.college.attendance.model.Student;
import com.college.attendance.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@WebServlet("/studentLeave")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB
    maxFileSize       = 1024 * 1024 * 5,   // 5 MB (reduced from 10)
    maxRequestSize    = 1024 * 1024 * 6
)
public class StudentLeaveServlet extends HttpServlet {
    private LeaveApplicationDAO leaveDAO = new LeaveApplicationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Student student = session != null ? (Student) session.getAttribute("user") : null;
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        // Enforce profile completion and parent verification
        if (!student.isProfileCompleted() || !student.isParentVerified()) {
            response.sendRedirect("studentSetup");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                LeaveApplication leave = leaveDAO.getLeaveById(id);
                // Ensure the student owns this leave application and it is pending
                if (leave != null && leave.getStudentId() == student.getId() && "Pending".equals(leave.getStatus())) {
                    leaveDAO.deleteLeave(id);
                    response.sendRedirect("studentLeave?msg=Leave+application+canceled");
                } else {
                    response.sendRedirect("studentLeave?error=Cannot+cancel+this+application");
                }
            } catch (Exception e) {
                response.sendRedirect("studentLeave?error=Invalid+ID");
            }
            return;
        }

        List<LeaveApplication> leaves = leaveDAO.getLeavesByStudent(student.getId());
        request.setAttribute("leaves", leaves);
        request.getRequestDispatcher("student_leave.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Student student = session != null ? (Student) session.getAttribute("user") : null;
        if (student == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Unauthorized+Access");
            return;
        }

        String reason    = ValidationUtil.sanitizeText(request.getParameter("reason"));
        String startDate = ValidationUtil.clean(request.getParameter("start_date"));
        String endDate   = ValidationUtil.clean(request.getParameter("end_date"));
        boolean declaration = request.getParameter("declaration") != null;

        // ── Validation ──────────────────────────────────────────────────────
        if (!ValidationUtil.isValidTextBlock(reason)) {
            response.sendRedirect("studentLeave?error=Invalid+or+too+short+reason+(min+5+chars)");
            return;
        }
        if (!ValidationUtil.isValidDate(startDate) || !ValidationUtil.isValidDate(endDate)) {
            response.sendRedirect("studentLeave?error=Invalid+date+format");
            return;
        }
        // End date must not be before start date
        if (LocalDate.parse(endDate).isBefore(LocalDate.parse(startDate))) {
            response.sendRedirect("studentLeave?error=End+date+cannot+be+before+start+date");
            return;
        }
        // Cannot apply for past leave (start date must be today or future)
        if (LocalDate.parse(startDate).isBefore(LocalDate.now())) {
            response.sendRedirect("studentLeave?error=Cannot+apply+for+past+dates");
            return;
        }
        if (!declaration) {
            response.sendRedirect("studentLeave?error=You+must+accept+the+declaration");
            return;
        }

        // ── File upload (optional, strict validation) ───────────────────────
        String proofPath = "";
        try {
            Part filePart = request.getPart("proof");
            if (filePart != null && filePart.getSize() > 0) {
                String originalName = filePart.getSubmittedFileName();
                if (!ValidationUtil.isValidFileExtension(originalName)) {
                    response.sendRedirect("studentLeave?error=Only+PDF,+JPG,+PNG+files+allowed");
                    return;
                }
                // Limit: 5 MB already enforced by @MultipartConfig maxFileSize
                String fileName   = UUID.randomUUID().toString() + "_" + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "leaves";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                filePart.write(uploadPath + File.separator + fileName);
                proofPath = "uploads/leaves/" + fileName;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        LeaveApplication leave = new LeaveApplication();
        leave.setStudentId(student.getId());
        leave.setReason(reason);
        leave.setStartDate(startDate);
        leave.setEndDate(endDate);
        leave.setDeclaration(declaration);
        leave.setProofPath(proofPath);

        boolean success = leaveDAO.submitLeave(leave);
        if (success) {
            com.college.attendance.dao.ActivityLogDAO.log("Student", student.getName(), "Submitted a leave application from " + startDate + " to " + endDate);
            response.sendRedirect("studentLeave?msg=Leave+application+submitted+successfully");
        } else {
            response.sendRedirect("studentLeave?error=Failed+to+submit+leave+application");
        }
    }
}
