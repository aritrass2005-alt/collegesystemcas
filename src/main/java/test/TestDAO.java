package test;
import com.college.attendance.dao.TimetableDAO;
import com.college.attendance.model.Timetable;
import java.sql.Time;
public class TestDAO {
    public static void main(String[] args) {
        TimetableDAO dao = new TimetableDAO();
        Timetable t1 = new Timetable();
        t1.setSubjectId(1);
        t1.setDayOfWeek("Monday");
        t1.setStartTime(Time.valueOf("09:00:00"));
        t1.setEndTime(Time.valueOf("10:00:00"));
        
        Timetable t2 = new Timetable();
        t2.setSubjectId(2);
        t2.setDayOfWeek("Monday");
        t2.setStartTime(Time.valueOf("11:00:00"));
        t2.setEndTime(Time.valueOf("12:00:00"));
        
        System.out.println("Add 1: " + dao.addTimetable(t1));
        System.out.println("Add 2: " + dao.addTimetable(t2));
    }
}
