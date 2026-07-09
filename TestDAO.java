import com.college.attendance.dao.AttendanceDAO;
import com.college.attendance.model.Attendance;
import java.util.List;

public class TestDAO {
    public static void main(String[] args) {
        AttendanceDAO dao = new AttendanceDAO();
        List<Attendance> records = dao.getAttendanceBySubjectAndDate(161, "2026-07-09");
        System.out.println("Records found: " + records.size());
        for (Attendance a : records) {
            System.out.println(a.getStudentName() + " - " + a.getStatus());
        }
        
        List<Attendance> records2 = dao.getAttendanceBySubjectAndDate(170, "2026-07-09");
        System.out.println("Records found for 170: " + records2.size());
    }
}
