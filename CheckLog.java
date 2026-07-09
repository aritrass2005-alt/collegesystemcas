import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class CheckLog {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/college_attendance", "root", "aritra04");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM activity_log LIMIT 10;");
            int count = 0;
            while(rs.next()) {
                count++;
                System.out.println("ID: " + rs.getInt("id") + ", User: " + rs.getString("user_name") + ", Action: " + rs.getString("action"));
            }
            if (count == 0) {
                System.out.println("No activity logs found.");
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
