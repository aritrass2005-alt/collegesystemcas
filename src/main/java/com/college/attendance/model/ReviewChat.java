package com.college.attendance.model;

import java.sql.Timestamp;

public class ReviewChat {
    private int id;
    private int reviewId;
    private String senderType; // Student, Coordinator
    private int senderId;
    private String message;
    private String proofPath;
    private Timestamp createdAt;
    
    // For UI display
    private String senderName;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }
    public String getSenderType() { return senderType; }
    public void setSenderType(String senderType) { this.senderType = senderType; }
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getProofPath() { return proofPath; }
    public void setProofPath(String proofPath) { this.proofPath = proofPath; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
}
