import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;

public class AddMockStudents {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/college_attendance";
        String user = "root";
        String pass = "aritra04";

        String[] depts = {
            "BCA", "BBA", "MCA", "BHM", "Computer Science", "Electronics", "Information Technology"
        };

        String[] firstNames = {
            "Aarav", "Aditya", "Amit", "Anjali", "Arjun", "Deepak", "Divya", "Gaurav", "Isha", "Kabir",
            "Karan", "Kiran", "Manoj", "Neha", "Pooja", "Rahul", "Rohan", "Sanjay", "Shreya", "Siddharth",
            "Sneha", "Suresh", "Tanvi", "Vikram", "Yash", "Alex", "Emma", "Liam", "Olivia", "Noah",
            "Ava", "Ethan", "Sophia", "Mason", "Isabella", "William", "Mia", "James", "Charlotte", "Benjamin",
            "Amelia", "Lucas", "Harper", "Alexander"
        };

        String[] lastNames = {
            "Sharma", "Verma", "Gupta", "Mehra", "Singh", "Kumar", "Patel", "Shah", "Joshi", "Das",
            "Sen", "Roy", "Bose", "Sarkar", "Chatterjee", "Mukherjee", "Banerjee", "Dutta", "Mitra", "Ghosh",
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Garcia", "Rodriguez", "Wilson",
            "Martinez", "Anderson", "Taylor", "Thomas", "Hernandez", "Moore", "Martin", "Jackson", "Thompson", "White",
            "Lopez", "Lee", "Gonzalez", "Harris"
        };

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                System.out.println("Connecting to database...");

                // 1. Insert missing departments into configuration
                String checkDeptSql = "SELECT COUNT(*) FROM department WHERE name = ?";
                String insertDeptSql = "INSERT INTO department (name) VALUES (?)";
                
                try (PreparedStatement checkStmt = conn.prepareStatement(checkDeptSql);
                     PreparedStatement insertStmt = conn.prepareStatement(insertDeptSql)) {
                    for (String dept : depts) {
                        checkStmt.setString(1, dept);
                        try (ResultSet rs = checkStmt.executeQuery()) {
                            if (rs.next() && rs.getInt(1) == 0) {
                                insertStmt.setString(1, dept);
                                insertStmt.executeUpdate();
                                System.out.println("Registered configuration department: " + dept);
                            }
                        }
                    }
                }

                // Clear existing students to ensure a fresh clean seeding
                try (Statement truncateStmt = conn.createStatement()) {
                    truncateStmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 0");
                    truncateStmt.executeUpdate("TRUNCATE TABLE student");
                    truncateStmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 1");
                    System.out.println("Cleared existing student table to ensure fresh parent details seeding!");
                }

                // 2. Generate and insert 44 students
                String insertStudentSql = "INSERT INTO student (roll_no, name, email, phone, dob, password, address, department, year, section, status, parent_name, parent_email, parent_phone) " +
                                          "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Active', ?, ?, ?)";

                try (PreparedStatement stmt = conn.prepareStatement(insertStudentSql)) {
                    int count = 0;

                    // 1.5 Seed Custom/Developer Students
                    String[] customRolls = { "22642723052", "22642723053", "22642723149", "22642723022", "22642723023" };
                    String[] customNames = { "Aritra Paul", "Aritra Sengupta", "Rishika Das", "Anika Zahin", "Ankan Shamanta" };
                    String[] customEmails = { "paulboll@student.edu", "aritrass2005@gmail.com", "rishika.das@student.edu", "anika.zahin@student.edu", "ankan.shamanta@student.edu" };
                    String[] customPhones = { "6969108108", "08207212620", "9876543210", "9876543211", "9876543212" };
                    String[] customDobs = { "32012006", "32012006", "32012006", "32012006", "32012006" };
                    String[] customDepts = { "BCA", "Computer Science", "BCA", "BCA", "BCA" };
                    int[] customYears = { 3, 3, 3, 3, 3 };
                    String[] customSections = { "K1", "K1", "K1", "K1", "K1" };

                    for (int cs = 0; cs < customRolls.length; cs++) {
                        String hashedPassword = BCrypt.hashpw(customDobs[cs], BCrypt.gensalt(12));
                        stmt.setString(1, customRolls[cs]);
                        stmt.setString(2, customNames[cs]);
                        stmt.setString(3, customEmails[cs]);
                        stmt.setString(4, customPhones[cs]);
                        stmt.setString(5, customDobs[cs]);
                        stmt.setString(6, hashedPassword);
                        stmt.setString(7, "Developer Flat, Kolkata");
                        stmt.setString(8, customDepts[cs]);
                        stmt.setInt(9, customYears[cs]);
                        stmt.setString(10, customSections[cs]);
                        stmt.setString(11, "Mr. Parent " + customNames[cs].split(" ")[1]);
                        stmt.setString(12, customNames[cs].split(" ")[0].toLowerCase() + ".parent@gmail.com");
                        stmt.setString(13, "9830111111");

                        try {
                            int affected = stmt.executeUpdate();
                            if (affected > 0) {
                                System.out.println(String.format("Added Custom Student: Roll=%s, Name=%s, Dept=%s, DOB=%s", customRolls[cs], customNames[cs], customDepts[cs], customDobs[cs]));
                                count++;
                            }
                        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                            System.out.println("Custom student already exists: " + customNames[cs]);
                        }
                    }

                    for (int i = 0; i < 44; i++) {
                        String fName = firstNames[i % firstNames.length];
                        String lName = lastNames[(i + 7) % lastNames.length];
                        String name = fName + " " + lName;
                        
                        String dept = depts[i % depts.length];
                        String deptCode = dept.replaceAll(" ", "").toUpperCase();
                        if (deptCode.length() > 3) deptCode = deptCode.substring(0, 3);
                        
                        String roll = String.format("%s2026%03d", deptCode, (i + 1));
                        String email = String.format("%s.%s%d@student.edu", fName.toLowerCase(), lName.toLowerCase(), (i + 1));
                        String phone = String.format("98765%05d", (i + 1));
                        
                        // Set DOB/Password to the universal '32012006' to match developer credentials for easy testing
                        String dob = "32012006";
                        
                        // Hash the DOB as password
                        String hashedPassword = BCrypt.hashpw(dob, BCrypt.gensalt(12));
                        String address = "Hostel Block " + (1 + (i % 4)) + ", Room " + (101 + (i % 20));
                        int academicYear = 1 + (i % 4);
                        String section = (i % 2 == 0) ? "A" : "B";

                        // Parent details
                        String parentName = "Mr. " + fName.charAt(0) + ". " + lName;
                        String parentEmail = String.format("%s.parent%d@gmail.com", fName.toLowerCase(), (i + 1));
                        String parentPhone = String.format("98301%05d", (i + 1));

                        stmt.setString(1, roll);
                        stmt.setString(2, name);
                        stmt.setString(3, email);
                        stmt.setString(4, phone);
                        stmt.setString(5, dob);
                        stmt.setString(6, hashedPassword);
                        stmt.setString(7, address);
                        stmt.setString(8, dept);
                        stmt.setInt(9, academicYear);
                        stmt.setString(10, section);
                        stmt.setString(11, parentName);
                        stmt.setString(12, parentEmail);
                        stmt.setString(13, parentPhone);

                        try {
                            int affected = stmt.executeUpdate();
                            if (affected > 0) {
                                System.out.println(String.format("Added Student #%d: Roll=%s, Name=%s, Dept=%s, DOB=%s", (i + 1), roll, name, dept, dob));
                                count++;
                            }
                        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                            // Roll or email duplicate, modify and retry
                            String retryRoll = roll + "X";
                            stmt.setString(1, retryRoll);
                            stmt.executeUpdate();
                            System.out.println(String.format("Added Student #%d (with suffix): Roll=%s, Name=%s, Dept=%s, DOB=%s", (i + 1), retryRoll, name, dept, dob));
                            count++;
                        }
                    }
                    System.out.println("\nSuccessfully added " + count + " diverse mock students across departments!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
