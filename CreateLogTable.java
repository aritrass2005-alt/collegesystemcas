import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class CreateLogTable {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/college_attendance", "root", "aritra04");
            Statement stmt = conn.createStatement();
            
            String sql = "CREATE TABLE IF NOT EXISTS activity_log (" +
                         "id INT AUTO_INCREMENT PRIMARY KEY, " +
                         "user_type VARCHAR(50) NOT NULL, " +
                         "user_name VARCHAR(100) NOT NULL, " +
                         "action TEXT NOT NULL, " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                         ")";
            stmt.execute(sql);
            System.out.println("activity_log table created successfully.");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
