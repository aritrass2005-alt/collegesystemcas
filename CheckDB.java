import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class CheckDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/college_attendance", "root", "aritra04");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SHOW COLUMNS FROM attendance;");
            while(rs.next()) {
                System.out.println("Column: " + rs.getString("Field"));
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
