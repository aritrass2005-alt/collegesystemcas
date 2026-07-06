import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class RunMigration {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/college_attendance";
        String user = "root";
        String pass = "aritra04";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 Statement stmt = conn.createStatement()) {
                System.out.println("Connected to the database. Running migration...");

                // Step 1: Add parent columns to student table
                try {
                    stmt.executeUpdate("ALTER TABLE student ADD COLUMN parent_name VARCHAR(100) DEFAULT NULL");
                    System.out.println("Added column parent_name successfully.");
                } catch (Exception e) {
                    System.out.println("Column parent_name might already exist: " + e.getMessage());
                }

                try {
                    stmt.executeUpdate("ALTER TABLE student ADD COLUMN parent_email VARCHAR(100) DEFAULT NULL");
                    System.out.println("Added column parent_email successfully.");
                } catch (Exception e) {
                    System.out.println("Column parent_email might already exist: " + e.getMessage());
                }

                try {
                    stmt.executeUpdate("ALTER TABLE student ADD COLUMN parent_phone VARCHAR(20) DEFAULT NULL");
                    System.out.println("Added column parent_phone successfully.");
                } catch (Exception e) {
                    System.out.println("Column parent_phone might already exist: " + e.getMessage());
                }

                // Step 2: Create parent_alert_log table
                String createTableSql = "CREATE TABLE IF NOT EXISTS parent_alert_log (" +
                        "    id INT AUTO_INCREMENT PRIMARY KEY," +
                        "    student_id INT NOT NULL," +
                        "    parent_name VARCHAR(100) NOT NULL," +
                        "    parent_email VARCHAR(100)," +
                        "    parent_phone VARCHAR(20)," +
                        "    alert_type VARCHAR(10) NOT NULL," +
                        "    subject VARCHAR(255)," +
                        "    message TEXT NOT NULL," +
                        "    status VARCHAR(15) DEFAULT 'SENT'," +
                        "    sender_name VARCHAR(100) NOT NULL," +
                        "    sender_role VARCHAR(50) NOT NULL," +
                        "    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                        "    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE" +
                        ")";
                stmt.executeUpdate(createTableSql);
                System.out.println("Created table parent_alert_log (if not exists) successfully.");
                System.out.println("Database migration completed successfully!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
