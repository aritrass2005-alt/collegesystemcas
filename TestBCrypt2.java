
import org.mindrot.jbcrypt.BCrypt;
public class TestBCrypt2 {
    public static void main(String[] args) {
        String hash = BCrypt.hashpw("admin123", BCrypt.gensalt(12));
        System.out.println("Generated Hash: " + hash);
        System.out.println("Checks out? " + BCrypt.checkpw("admin123", hash));
    }
}

