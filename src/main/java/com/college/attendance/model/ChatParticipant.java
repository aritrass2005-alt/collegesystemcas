package com.college.attendance.model;

import java.sql.Timestamp;

public class ChatParticipant {
    private int id;
    private int conversationId;
    private String userRole;
    private int userId;
    private String userName;
    private String profilePhoto;
    private long lastReadMessageId;
    private Timestamp joinedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getProfilePhoto() { return profilePhoto; }
    public void setProfilePhoto(String profilePhoto) { this.profilePhoto = profilePhoto; }

    public long getLastReadMessageId() { return lastReadMessageId; }
    public void setLastReadMessageId(long lastReadMessageId) { this.lastReadMessageId = lastReadMessageId; }

    public Timestamp getJoinedAt() { return joinedAt; }
    public void setJoinedAt(Timestamp joinedAt) { this.joinedAt = joinedAt; }
}
