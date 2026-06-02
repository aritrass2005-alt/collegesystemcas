package com.college.attendance.dao;

import com.college.attendance.model.AttendanceReview;
import com.college.attendance.model.ReviewChat;
import com.college.attendance.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AttendanceReviewDAO {

    public boolean createReview(AttendanceReview review) {
        String query = "INSERT INTO attendance_review (student_id, subject_id, review_date, reason) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, review.getStudentId());
            if (review.getSubjectId() > 0) {
                ps.setInt(2, review.getSubjectId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setDate(3, new java.sql.Date(review.getReviewDate().getTime()));
            ps.setString(4, review.getReason());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasExistingReview(int studentId, int subjectId, java.util.Date reviewDate) {
        String query = "SELECT COUNT(*) FROM attendance_review WHERE student_id = ? AND review_date = ? AND (subject_id = ? OR subject_id IS NULL)";
        if (subjectId <= 0) {
            query = "SELECT COUNT(*) FROM attendance_review WHERE student_id = ? AND review_date = ?";
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, studentId);
            ps.setDate(2, new java.sql.Date(reviewDate.getTime()));
            if (subjectId > 0) {
                ps.setInt(3, subjectId);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteReview(int reviewId, int studentId) {
        String query = "DELETE FROM attendance_review WHERE id = ? AND student_id = ? AND status IN ('Pending', 'In Review')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, reviewId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<AttendanceReview> getReviewsByStudent(int studentId) {
        List<AttendanceReview> list = new ArrayList<>();
        String query = "SELECT r.*, s.name as subject_name FROM attendance_review r LEFT JOIN subject s ON r.subject_id = s.id WHERE r.student_id = ? ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, studentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractReview(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<AttendanceReview> getReviewsForCoordinator(int coordinatorId, String dept, int year, String section) {
        List<AttendanceReview> list = new ArrayList<>();
        String query = "SELECT r.*, st.name as student_name, st.roll_no, su.name as subject_name " +
                       "FROM attendance_review r " +
                       "JOIN student st ON r.student_id = st.id " +
                       "LEFT JOIN subject su ON r.subject_id = su.id " +
                       "WHERE st.department = ? AND st.year = ? AND st.section = ? " +
                       "ORDER BY r.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, dept);
            ps.setInt(2, year);
            ps.setString(3, section);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractReviewWithDetails(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public AttendanceReview getReviewById(int id) {
        String query = "SELECT r.*, st.name as student_name, st.roll_no, su.name as subject_name " +
                       "FROM attendance_review r " +
                       "JOIN student st ON r.student_id = st.id " +
                       "LEFT JOIN subject su ON r.subject_id = su.id " +
                       "WHERE r.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return extractReviewWithDetails(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateReviewStatus(int id, String status, int coordinatorId) {
        String query = "UPDATE attendance_review SET status = ?, coordinator_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, status);
            ps.setInt(2, coordinatorId);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addChatMessage(ReviewChat chat) {
        String query = "INSERT INTO review_chat (review_id, sender_type, sender_id, message, proof_path) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, chat.getReviewId());
            ps.setString(2, chat.getSenderType());
            ps.setInt(3, chat.getSenderId());
            ps.setString(4, chat.getMessage());
            ps.setString(5, chat.getProofPath());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ReviewChat> getChatByReviewId(int reviewId) {
        List<ReviewChat> list = new ArrayList<>();
        String query = "SELECT c.*, " +
                       "CASE WHEN c.sender_type = 'Student' THEN (SELECT name FROM student WHERE id = c.sender_id) " +
                       "     WHEN c.sender_type = 'Coordinator' THEN (SELECT name FROM teacher WHERE id = c.sender_id) " +
                       "END as sender_name " +
                       "FROM review_chat c WHERE c.review_id = ? ORDER BY c.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, reviewId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ReviewChat chat = new ReviewChat();
                chat.setId(rs.getInt("id"));
                chat.setReviewId(rs.getInt("review_id"));
                chat.setSenderType(rs.getString("sender_type"));
                chat.setSenderId(rs.getInt("sender_id"));
                chat.setMessage(rs.getString("message"));
                chat.setProofPath(rs.getString("proof_path"));
                chat.setCreatedAt(rs.getTimestamp("created_at"));
                chat.setSenderName(rs.getString("sender_name"));
                list.add(chat);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private AttendanceReview extractReview(ResultSet rs) throws SQLException {
        AttendanceReview review = new AttendanceReview();
        review.setId(rs.getInt("id"));
        review.setStudentId(rs.getInt("student_id"));
        review.setSubjectId(rs.getInt("subject_id"));
        review.setReviewDate(rs.getDate("review_date"));
        review.setReason(rs.getString("reason"));
        review.setStatus(rs.getString("status"));
        review.setCoordinatorId(rs.getInt("coordinator_id"));
        review.setCreatedAt(rs.getTimestamp("created_at"));
        review.setUpdatedAt(rs.getTimestamp("updated_at"));
        try { review.setSubjectName(rs.getString("subject_name")); } catch (Exception e) {}
        return review;
    }
    
    private AttendanceReview extractReviewWithDetails(ResultSet rs) throws SQLException {
        AttendanceReview review = extractReview(rs);
        try { review.setStudentName(rs.getString("student_name")); } catch (Exception e) {}
        try { review.setStudentRollNo(rs.getString("roll_no")); } catch (Exception e) {}
        return review;
    }
}
