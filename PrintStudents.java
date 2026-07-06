import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class PrintStudents {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/college_attendance";
        String user = "root";
        String password = "aritra04";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, password);
                 Statement stmt = conn.createStatement()) {
                
                System.out.println("Fetching all student records from database...");
                String sql = "SELECT id, roll_no, name, email, password, dob FROM student";
                try (ResultSet rs = stmt.executeQuery(sql)) {
                    int count = 0;
                    while (rs.next()) {
                        count++;
                        System.out.println("Student #" + count + ":");
                        System.out.println("  ID: " + rs.getInt("id"));
                        System.out.println("  Roll No: '" + rs.getString("roll_no") + "'");
                        System.out.println("  Name: " + rs.getString("name"));
                        System.out.println("  Email: " + rs.getString("email"));
                        System.out.println("  DOB / Password: '" + rs.getString("dob") + "'");
                        System.out.println("  Password Hash: " + rs.getString("password"));
                    }
                    if (count == 0) {
                        System.out.println("No students found in the database!");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
