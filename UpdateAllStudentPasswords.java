import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import org.mindrot.jbcrypt.BCrypt;

public class UpdateAllStudentPasswords {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/college_attendance";
        String user = "root";
        String pass = "aritra04";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                System.out.println("Updating all student credentials to DOB/Password: 32012006...");

                // 1. Generate BCrypt hash for "32012006"
                String passwordToHash = "32012006";
                String hashed = BCrypt.hashpw(passwordToHash, BCrypt.gensalt(12));

                // 2. Update all student rows in the database
                String sql = "UPDATE student SET dob = ?, password = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, passwordToHash);
                    stmt.setString(2, hashed);
                    
                    int rowsUpdated = stmt.executeUpdate();
                    System.out.println("Successfully updated " + rowsUpdated + " student accounts to DOB/Password: " + passwordToHash);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
