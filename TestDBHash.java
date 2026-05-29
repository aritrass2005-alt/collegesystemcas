
import org.mindrot.jbcrypt.BCrypt;
public class TestDBHash {
    public static void main(String[] args) {
        System.out.println("admin123: " + BCrypt.checkpw("admin123", "$2a$12$YxIwXcaaTkHZ3TUYRzuPQeccLGQaofxUOw35X32tXhdNccHHyWBKy"));
        System.out.println("admin: " + BCrypt.checkpw("admin", "$2a$12$YxIwXcaaTkHZ3TUYRzuPQeccLGQaofxUOw35X32tXhdNccHHyWBKy"));
        System.out.println("password: " + BCrypt.checkpw("password", "$2a$12$YxIwXcaaTkHZ3TUYRzuPQeccLGQaofxUOw35X32tXhdNccHHyWBKy"));
    }
}

