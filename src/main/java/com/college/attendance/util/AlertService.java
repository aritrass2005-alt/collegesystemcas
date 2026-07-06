package com.college.attendance.util;

import com.college.attendance.dao.ParentAlertLogDAO;
import com.college.attendance.model.ParentAlertLog;
import com.college.attendance.model.Student;

public class AlertService {
    private static final ParentAlertLogDAO logDAO = new ParentAlertLogDAO();

    public static boolean sendParentAlert(Student student, double attendancePct, double threshold, String period, String senderName, String senderRole) {
        String pName = student.getParentName();
        String pEmail = student.getParentEmail();
        String pPhone = student.getParentPhone();

        // If no parent details are provided, we cannot send the alert.
        if ((pName == null || pName.trim().isEmpty()) && 
            (pEmail == null || pEmail.trim().isEmpty()) && 
            (pPhone == null || pPhone.trim().isEmpty())) {
            System.out.println("[ALERT SERVICE WARNING] Unable to alert parent for " + student.getName() + 
                               " (" + student.getRollNo() + "): No parent contact details registered.");
            return false;
        }

        // Standardize default parent name if it's empty but other details exist
        if (pName == null || pName.trim().isEmpty()) {
            pName = "Parent/Guardian of " + student.getName();
        }

        String alertType = "BOTH";
        if ((pEmail == null || pEmail.trim().isEmpty()) && (pPhone != null && !pPhone.trim().isEmpty())) {
            alertType = "SMS";
        } else if ((pPhone == null || pPhone.trim().isEmpty()) && (pEmail != null && !pEmail.trim().isEmpty())) {
            alertType = "EMAIL";
        }

        String subject = "Urgent: Low Attendance Alert - " + student.getName();
        
        StringBuilder emailBody = new StringBuilder();
        emailBody.append("Dear ").append(pName).append(",\n\n");
        emailBody.append("This is an official communication from College Attendance System regarding the attendance of your ward:\n");
        emailBody.append("  Student Name: ").append(student.getName()).append("\n");
        emailBody.append("  Roll Number: ").append(student.getRollNo()).append("\n");
        emailBody.append("  Academic Year: Year ").append(student.getYear()).append(" - Section ").append(student.getSection()).append("\n");
        emailBody.append("  Department: ").append(student.getDepartment()).append("\n\n");
        
        emailBody.append(String.format("We regret to inform you that your ward's attendance is currently at %.2f%%, which falls below our minimum mandatory requirement of %.1f%%", attendancePct, threshold));
        if (period != null && !period.isEmpty()) {
            emailBody.append(" for the period from ").append(period);
        }
        emailBody.append(".\n\n");
        
        emailBody.append("Please ensure that your ward attends classes regularly. Inadequate attendance may lead to academic restrictions, including exclusion from end-semester examinations.\n\n");
        emailBody.append("If you have any questions or require clarification, please feel free to contact the department office.\n\n");
        emailBody.append("Sincerely,\n");
        emailBody.append(senderName).append(" (").append(senderRole).append(")\n");
        emailBody.append("College Attendance Management System (CAS)\n");

        String smsText = String.format("Dear %s, your ward %s's attendance is very low: %.2f%% (Min %.0f%%). Please ensure they attend classes regularly. - CAS %s",
                                       pName, student.getName(), attendancePct, threshold, senderRole);

        // Print beautiful console simulation
        System.out.println("=================================================================================");
        System.out.println("                     [SIMULATED PARENT NOTIFICATION GATEWAY]                    ");
        System.out.println("=================================================================================");
        System.out.println("Sender: " + senderName + " (" + senderRole + ")");
        System.out.println("Student: " + student.getName() + " [Roll: " + student.getRollNo() + "]");
        System.out.println("Parent Name: " + pName);
        System.out.println("Alert Type determined: " + alertType);
        
        if ("EMAIL".equals(alertType) || "BOTH".equals(alertType)) {
            System.out.println("---------------------------------------------------------------------------------");
            System.out.println("[SMTP SIMULATOR] Dispatching Email to parent: " + pEmail);
            System.out.println("Subject: " + subject);
            System.out.println("Content:\n" + emailBody.toString());
        }
        
        if ("SMS".equals(alertType) || "BOTH".equals(alertType)) {
            System.out.println("---------------------------------------------------------------------------------");
            System.out.println("[SMS GATEWAY SIMULATOR] Dispatching SMS to parent: " + pPhone);
            System.out.println("Message text: " + smsText);
        }
        System.out.println("=================================================================================\n");

        // Write the log to the database
        ParentAlertLog log = new ParentAlertLog();
        log.setStudentId(student.getId());
        log.setParentName(pName);
        log.setParentEmail(pEmail);
        log.setParentPhone(pPhone);
        log.setAlertType(alertType);
        log.setSubject(subject);
        // We will store the combined message details
        StringBuilder combinedMessage = new StringBuilder();
        if ("EMAIL".equals(alertType) || "BOTH".equals(alertType)) {
            combinedMessage.append("[EMAIL BODY]\n").append(emailBody.toString());
        }
        if ("BOTH".equals(alertType)) {
            combinedMessage.append("\n\n-------------------------\n\n");
        }
        if ("SMS".equals(alertType) || "BOTH".equals(alertType)) {
            combinedMessage.append("[SMS TEXT]\n").append(smsText);
        }
        log.setMessage(combinedMessage.toString());
        log.setStatus("SENT"); // simulated successfully sent
        log.setSenderName(senderName);
        log.setSenderRole(senderRole);

        return logDAO.logAlert(log);
    }
}
