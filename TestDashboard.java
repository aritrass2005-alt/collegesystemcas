
import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Student;
import com.college.attendance.dao.UserDAO;
public class TestDashboard {
    public static void main(String[] args) {
        try {
            UserDAO userDAO = new UserDAO();
            Student student = userDAO.authenticateStudent("22642723052", "32012006");
            
            AttendanceDAO dao = new AttendanceDAO();
            System.out.println("Getting subject summary...");
            dao.getStudentAttendanceSummary(student.getId());
            System.out.println("Getting month summary...");
            dao.getMonthWiseAttendance(student.getId());
            System.out.println("Getting history...");
            dao.getStudentAttendanceHistory(student.getId());
            System.out.println("Getting defaulters...");
            dao.getDefaultersForSection(student.getDepartment(), student.getYear(), student.getSection(), 75.0);
            System.out.println("All DAO calls succeeded!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

