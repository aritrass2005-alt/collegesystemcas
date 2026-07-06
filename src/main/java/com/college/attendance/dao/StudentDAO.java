package com.college.attendance.dao;

import com.college.attendance.model.Student;
import com.college.attendance.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    public boolean addStudent(Student student, String dob, String address) {
        String sql = "INSERT INTO student (roll_no, name, email, phone, dob, password, address, department, year, section, parent_name, parent_email, parent_phone) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, student.getRollNo());
            stmt.setString(2, student.getName());
            stmt.setString(3, student.getEmail());
            stmt.setString(4, student.getPhone());
            stmt.setString(5, dob);
            
            // Hash the DOB as the default password
            String hashedPassword = BCrypt.hashpw(dob, BCrypt.gensalt(12));
            stmt.setString(6, hashedPassword);
            stmt.setString(7, address);
            stmt.setString(8, student.getDepartment());
            stmt.setInt(9, student.getYear());
            stmt.setString(10, student.getSection());
            stmt.setString(11, student.getParentName());
            stmt.setString(12, student.getParentEmail());
            stmt.setString(13, student.getParentPhone());
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateStudent(Student student, String address) {
        String sql = "UPDATE student SET roll_no=?, name=?, email=?, phone=?, dob=?, address=?, department=?, year=?, section=?, parent_name=?, parent_email=?, parent_phone=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, student.getRollNo());
            stmt.setString(2, student.getName());
            stmt.setString(3, student.getEmail());
            stmt.setString(4, student.getPhone());
            stmt.setString(5, student.getDob());
            stmt.setString(6, address);
            stmt.setString(7, student.getDepartment());
            stmt.setInt(8, student.getYear());
            stmt.setString(9, student.getSection());
            stmt.setString(10, student.getParentName());
            stmt.setString(11, student.getParentEmail());
            stmt.setString(12, student.getParentPhone());
            stmt.setInt(13, student.getId());
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteStudent(int id) {
        String sql = "DELETE FROM student WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean addStudentsBulk(List<Student> students, List<String> dobs) {
        String sql = "INSERT IGNORE INTO student (roll_no, name, email, phone, dob, password, department, year, section) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            conn.setAutoCommit(false); // Enable transaction
            
            for (int i = 0; i < students.size(); i++) {
                Student s = students.get(i);
                String dob = dobs.get(i);
                
                stmt.setString(1, s.getRollNo());
                stmt.setString(2, s.getName());
                stmt.setString(3, s.getEmail());
                stmt.setString(4, s.getPhone());
                stmt.setString(5, dob);
                stmt.setString(6, BCrypt.hashpw(dob, BCrypt.gensalt(12)));
                stmt.setString(7, s.getDepartment());
                stmt.setInt(8, s.getYear());
                stmt.setString(9, s.getSection());
                
                stmt.addBatch();
            }
            
            stmt.executeBatch();
            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean promoteStudents(String department, int year) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            String baseCondition = " WHERE status = 'Active'";
            if (department != null && !department.isEmpty()) {
                baseCondition += " AND department = ?";
            }
            
            // Step 1: Promote Year 4 (or the specified year if it's 4) to PassedOut
            if (year == 0 || year == 4) {
                String sql4 = "UPDATE student SET status = 'PassedOut' " + baseCondition + " AND year = 4";
                try (PreparedStatement stmt = conn.prepareStatement(sql4)) {
                    if (department != null && !department.isEmpty()) stmt.setString(1, department);
                    stmt.executeUpdate();
                }
            }
            
            // Step 2: Promote Year 3 to 4
            if (year == 0 || year == 3) {
                String sql3 = "UPDATE student SET year = 4 " + baseCondition + " AND year = 3";
                try (PreparedStatement stmt = conn.prepareStatement(sql3)) {
                    if (department != null && !department.isEmpty()) stmt.setString(1, department);
                    stmt.executeUpdate();
                }
            }
            
            // Step 3: Promote Year 2 to 3
            if (year == 0 || year == 2) {
                String sql2 = "UPDATE student SET year = 3 " + baseCondition + " AND year = 2";
                try (PreparedStatement stmt = conn.prepareStatement(sql2)) {
                    if (department != null && !department.isEmpty()) stmt.setString(1, department);
                    stmt.executeUpdate();
                }
            }
            
            // Step 4: Promote Year 1 to 2
            if (year == 0 || year == 1) {
                String sql1 = "UPDATE student SET year = 2 " + baseCondition + " AND year = 1";
                try (PreparedStatement stmt = conn.prepareStatement(sql1)) {
                    if (department != null && !department.isEmpty()) stmt.setString(1, department);
                    stmt.executeUpdate();
                }
            }
            
            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Student> getStudentsByFilter(String department, int year, String section, String subjectId) {
        List<Student> students = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT s.* FROM student s WHERE 1=1");
        
        if (department != null && !department.isEmpty()) sql.append(" AND s.department = ?");
        if (year > 0) sql.append(" AND s.year = ?");
        if (section != null && !section.isEmpty()) sql.append(" AND s.section = ?");
        if (subjectId != null && !subjectId.isEmpty()) {
            sql.append(" AND EXISTS (SELECT 1 FROM subject sub WHERE sub.id = ? AND sub.department = s.department AND sub.year = s.year AND sub.section = s.section)");
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
             
            int paramIndex = 1;
            if (department != null && !department.isEmpty()) stmt.setString(paramIndex++, department);
            if (year > 0) stmt.setInt(paramIndex++, year);
            if (section != null && !section.isEmpty()) stmt.setString(paramIndex++, section);
            if (subjectId != null && !subjectId.isEmpty()) stmt.setInt(paramIndex++, Integer.parseInt(subjectId));
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Student s = new Student();
                s.setId(rs.getInt("id"));
                s.setRollNo(rs.getString("roll_no"));
                s.setName(rs.getString("name"));
                s.setEmail(rs.getString("email"));
                s.setPhone(rs.getString("phone"));
                s.setDob(rs.getString("dob"));
                s.setStatus(rs.getString("status"));
                s.setDepartment(rs.getString("department"));
                s.setYear(rs.getInt("year"));
                s.setSection(rs.getString("section"));
                try { s.setEmail(rs.getString("email")); } catch(Exception ex) {} // Safety
                s.setBanned(rs.getBoolean("is_banned"));
                s.setParentName(rs.getString("parent_name"));
                s.setParentEmail(rs.getString("parent_email"));
                s.setParentPhone(rs.getString("parent_phone"));
                students.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return students;
    }

    public List<Student> getStudentsForSubject(String department, int year, String section) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM student WHERE department = ? AND year = ? AND section = ? AND status = 'Active'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, department);
            stmt.setInt(2, year);
            stmt.setString(3, section);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Student s = new Student();
                    s.setId(rs.getInt("id"));
                    s.setRollNo(rs.getString("roll_no"));
                    s.setName(rs.getString("name"));
                    s.setEmail(rs.getString("email"));
                    s.setPhone(rs.getString("phone"));
                    s.setDob(rs.getString("dob"));
                s.setStatus(rs.getString("status"));
                    s.setDepartment(rs.getString("department"));
                    s.setYear(rs.getInt("year"));
                    s.setSection(rs.getString("section"));
                    s.setParentName(rs.getString("parent_name"));
                    s.setParentEmail(rs.getString("parent_email"));
                    s.setParentPhone(rs.getString("parent_phone"));
                    students.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return students;
    }

    public List<String> getAvailableSections() {
        List<String> sections = new ArrayList<>();
        String sql = "SELECT DISTINCT section FROM student WHERE section IS NOT NULL AND section != '' ORDER BY section";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                sections.add(rs.getString("section"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sections;
    }

    public List<Student> getStudentsByTeacher(int teacherId) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT DISTINCT s.* FROM student s " +
                     "JOIN subject sub ON s.department = sub.department AND s.year = sub.year " +
                     "WHERE sub.teacher_id = ? AND (sub.section IS NULL OR sub.section = '' OR s.section = sub.section) AND s.status = 'Active' " +
                     "ORDER BY s.roll_no";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, teacherId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Student s = new Student();
                    s.setId(rs.getInt("id"));
                    s.setRollNo(rs.getString("roll_no"));
                    s.setName(rs.getString("name"));
                    s.setEmail(rs.getString("email"));
                    s.setPhone(rs.getString("phone"));
                    s.setDob(rs.getString("dob"));
                s.setStatus(rs.getString("status"));
                    s.setDepartment(rs.getString("department"));
                    s.setYear(rs.getInt("year"));
                    s.setSection(rs.getString("section"));
                    s.setParentName(rs.getString("parent_name"));
                    s.setParentEmail(rs.getString("parent_email"));
                    s.setParentPhone(rs.getString("parent_phone"));
                    students.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return students;
    }

    public Student getStudentById(int id) {
        String sql = "SELECT * FROM student WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Student s = new Student();
                    s.setId(rs.getInt("id"));
                    s.setRollNo(rs.getString("roll_no"));
                    s.setName(rs.getString("name"));
                    s.setEmail(rs.getString("email"));
                    s.setPhone(rs.getString("phone"));
                    s.setDob(rs.getString("dob"));
                    s.setStatus(rs.getString("status"));
                    s.setDepartment(rs.getString("department"));
                    s.setYear(rs.getInt("year"));
                    s.setSection(rs.getString("section"));
                    s.setParentName(rs.getString("parent_name"));
                    s.setParentEmail(rs.getString("parent_email"));
                    s.setParentPhone(rs.getString("parent_phone"));
                    s.setBanned(rs.getBoolean("is_banned"));
                    return s;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}

