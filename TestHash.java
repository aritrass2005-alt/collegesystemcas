
import org.mindrot.jbcrypt.BCrypt;
public class TestHash {
    public static void main(String[] args) {
        String hash = "$2a$12$As4sVD7mWE7h8Uf1BQJEyeX3UpzAF8yukndVpC4QTLyhZqGBIU6Wq";
        System.out.println("32012006: " + BCrypt.checkpw("32012006", hash));
        System.out.println("Aritra2006: " + BCrypt.checkpw("Aritra2006", hash));
    }
}

