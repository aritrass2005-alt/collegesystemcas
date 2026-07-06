package com.college.attendance.model;

import java.sql.Timestamp;
import java.util.List;
import java.util.ArrayList;

public class ChatConversation {
    private int id;
    private String name;
    private String type; // DIRECT, GROUP, DEPARTMENT
    private String departmentName;
    private String createdByRole;
    private int createdById;
    private Timestamp createdAt;

    // Display helpers
    private List<ChatParticipant> participants = new ArrayList<>();
    private String lastMessage;
    private Timestamp lastMessageTime;
    private String lastSenderName;
    private int unreadCount;
    private String displayName;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getCreatedByRole() { return createdByRole; }
    public void setCreatedByRole(String createdByRole) { this.createdByRole = createdByRole; }

    public int getCreatedById() { return createdById; }
    public void setCreatedById(int createdById) { this.createdById = createdById; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<ChatParticipant> getParticipants() { return participants; }
    public void setParticipants(List<ChatParticipant> participants) { this.participants = participants; }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public Timestamp getLastMessageTime() { return lastMessageTime; }
    public void setLastMessageTime(Timestamp lastMessageTime) { this.lastMessageTime = lastMessageTime; }

    public String getLastSenderName() { return lastSenderName; }
    public void setLastSenderName(String lastSenderName) { this.lastSenderName = lastSenderName; }

    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
}
