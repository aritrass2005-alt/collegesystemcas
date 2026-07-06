package com.college.attendance.model;

import java.sql.Timestamp;

public class ChatMessage {
    private long id;
    private int conversationId;
    private String senderRole;
    private int senderId;
    private String senderName;
    private String senderPhoto;
    private String encryptedContent;
    private String messageType; // TEXT, SYSTEM, FILE, PHOTO, AUDIO
    private String fileUrl;
    private String fileName;
    private Timestamp sentAt;
    
    // Status tracking for frontend (not stored in DB per message, computed dynamically based on participants' lastReadMessageId)
    private String status; // SENT, DELIVERED, READ
    
    private boolean isEdited;
    private boolean isDeleted;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }

    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }

    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderPhoto() { return senderPhoto; }
    public void setSenderPhoto(String senderPhoto) { this.senderPhoto = senderPhoto; }

    public String getEncryptedContent() { return encryptedContent; }
    public void setEncryptedContent(String encryptedContent) { this.encryptedContent = encryptedContent; }

    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isEdited() { return isEdited; }
    public void setEdited(boolean isEdited) { this.isEdited = isEdited; }

    public boolean isDeleted() { return isDeleted; }
    public void setDeleted(boolean isDeleted) { this.isDeleted = isDeleted; }
}
