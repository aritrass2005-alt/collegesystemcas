import org.mindrot.jbcrypt.BCrypt;

public class TestDOBHash {
    public static void main(String[] args) {
        String testPassword = "32012006";

        String[] hashes = {
            "$2a$12$gaqDSyZojUelkkemzmy/lOI8uBP4P20nKxrg7VneRCFGfGeYRErje", // Student 2
            "$2a$12$PMKgks9oNWOF8NxXfS1xreAv2W6Z8GCQtwi/z/huDEO5W3lRwt.Qm", // Student 3
            "$2a$12$l7TRYOrYH5zwdkJGKaUcc.iEn2NjyoU7d4tyVHVaI4Nhv9QkjsyU2", // Student 4
            "$2a$12$G759OT9fdjFk7qMeBVdpWeXtaAiMQMMj2Ezq6zRTQzsVvVIn3dr0S", // Student 5
            "$2a$12$zCkKke9/QmqhAHtV9hQ6lOpAMq8NJWeVIWZSEp6MjZDYW17dUeimi"  // Student 6
        };

        for (int i = 0; i < hashes.length; i++) {
            try {
                boolean match = BCrypt.checkpw(testPassword, hashes[i]);
                System.out.println("Hash #" + (i+2) + " match for '" + testPassword + "': " + match);
            } catch (Exception e) {
                System.out.println("Hash #" + (i+2) + " check exception: " + e.getMessage());
            }
        }
    }
}
