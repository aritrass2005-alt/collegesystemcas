
import com.college.attendance.dao.UserDAO;
import com.college.attendance.model.Student;
public class TestLogin {
    public static void main(String[] args) {
        UserDAO dao = new UserDAO();
        Student s = dao.authenticateStudent("22642723052", "32012006");
        if (s != null) {
            System.out.println("Login Success! Roll: " + s.getRollNo() + ", Name: " + s.getName());
        } else {
            System.out.println("Login Failed!");
        }
    }
}

