
import org.mindrot.jbcrypt.BCrypt;
public class TestBCrypt {
    public static void main(String[] args) {
        try {
            System.out.println("Teacher Hash: " + BCrypt.checkpw("teacher123", "`$2a`$12`$dE7f5f.X8N2P8JvA9J.2Ue3O.7L7y.X8Y9L8V9W9V.X8Y9L8V9W9V"));
        } catch (Exception e) {
            System.out.println("Teacher exception: " + e.getMessage());
        }
        try {
            System.out.println("Student Hash: " + BCrypt.checkpw("15082002", "`$2a`$12`$z2P.X8N2P8JvA9J.2Ue3O.7L7y.X8Y9L8V9W9V.X8Y9L8V9W9V.X8Y"));
        } catch (Exception e) {
            System.out.println("Student exception: " + e.getMessage());
        }
        try {
            System.out.println("Admin Hash: " + BCrypt.checkpw("admin123", "`$2a`$12`$r/vnu8AObAl42J.sZdDzZO9xKjdm2p81xR24heAL7ZrWAxkdaf7zC"));
        } catch (Exception e) {
            System.out.println("Admin exception: " + e.getMessage());
        }
    }
}

