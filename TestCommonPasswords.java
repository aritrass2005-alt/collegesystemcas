import org.mindrot.jbcrypt.BCrypt;

public class TestCommonPasswords {
    public static void main(String[] args) {
        String[] testPasswords = {
            "32012006",
            "123456",
            "student123",
            "15082002",
            "aritra04",
            "CS202001",
            "22642723052",
            "22642723053",
            "22642723149",
            "22642723022"
        };

        String[] hashes = {
            "$2a$12$gaqDSyZojUelkkemzmy/lOI8uBP4P20nKxrg7VneRCFGfGeYRErje", // Student 2 (Aritra Paul)
            "$2a$12$PMKgks9oNWOF8NxXfS1xreAv2W6Z8GCQtwi/z/huDEO5W3lRwt.Qm", // Student 3 (Aritra Sengupta)
            "$2a$12$l7TRYOrYH5zwdkJGKaUcc.iEn2NjyoU7d4tyVHVaI4Nhv9QkjsyU2", // Student 4 (Rishika Das)
            "$2a$12$G759OT9fdjFk7qMeBVdpWeXtaAiMQMMj2Ezq6zRTQzsVvVIn3dr0S", // Student 5 (Anika Zahin)
            "$2a$12$zCkKke9/QmqhAHtV9hQ6lOpAMq8NJWeVIWZSEp6MjZDYW17dUeimi"  // Student 6 (John Doe)
        };

        String[] studentNames = {
            "Aritra Paul",
            "Aritra Sengupta",
            "Rishika Das",
            "Anika Zahin",
            "John Doe"
        };

        for (int i = 0; i < hashes.length; i++) {
            System.out.println("Testing hashes for " + studentNames[i] + "...");
            for (String pw : testPasswords) {
                try {
                    if (BCrypt.checkpw(pw, hashes[i])) {
                        System.out.println("  ==> MATCH FOUND! Password is: '" + pw + "'");
                    }
                } catch (Exception ignored) {}
            }
        }
    }
}
