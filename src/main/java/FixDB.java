import java.sql.Connection;
import java.sql.Statement;
import com.college.attendance.util.DBConnection;

public class FixDB {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Applying ON DELETE CASCADE constraints...");
            
            // Drop existing foreign keys
            try { stmt.execute("ALTER TABLE chat_participant DROP FOREIGN KEY chat_participant_ibfk_1"); } catch(Exception e) {}
            try { stmt.execute("ALTER TABLE chat_message DROP FOREIGN KEY chat_message_ibfk_1"); } catch(Exception e) {}
            try { stmt.execute("ALTER TABLE group_keys DROP FOREIGN KEY group_keys_ibfk_1"); } catch(Exception e) {}

            // Add foreign keys with CASCADE
            stmt.execute("ALTER TABLE chat_participant ADD CONSTRAINT chat_participant_ibfk_1 FOREIGN KEY (group_id) REFERENCES chat_group(id) ON DELETE CASCADE");
            stmt.execute("ALTER TABLE chat_message ADD CONSTRAINT chat_message_ibfk_1 FOREIGN KEY (group_id) REFERENCES chat_group(id) ON DELETE CASCADE");
            stmt.execute("ALTER TABLE group_keys ADD CONSTRAINT group_keys_ibfk_1 FOREIGN KEY (group_id) REFERENCES chat_group(id) ON DELETE CASCADE");

            System.out.println("Successfully added CASCADE constraints.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
