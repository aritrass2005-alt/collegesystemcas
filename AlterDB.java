import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class AlterDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/college_attendance", "root", "aritra04");
            Statement stmt = conn.createStatement();
            
            try {
                stmt.execute("ALTER TABLE attendance ADD COLUMN appeal_status VARCHAR(20) DEFAULT NULL;");
                System.out.println("Added appeal_status.");
            } catch(Exception e) {
                System.out.println("appeal_status already exists or error: " + e.getMessage());
            }
            
            try {
                stmt.execute("ALTER TABLE attendance ADD COLUMN admin_edited BOOLEAN DEFAULT FALSE;");
                System.out.println("Added admin_edited.");
            } catch(Exception e) {
                System.out.println("admin_edited already exists or error: " + e.getMessage());
            }

        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
