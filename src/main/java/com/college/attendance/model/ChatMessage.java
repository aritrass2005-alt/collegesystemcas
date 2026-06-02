package com.college.attendance.model;

import java.sql.Timestamp;

public class ChatMessage {
    private int id;
    private int groupId;
    private String senderType;
    private int senderId;
    private String encryptedContent;
    private String iv;
    private Timestamp timestamp;
    private String messageType; // "text", "image", "file", "voice"
    private String fileUrl;     // relative URL for non-text messages
    private String fileName;    // original filename

    // For UI display
    private String senderName;
    private String senderDetails;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getGroupId() { return groupId; }
    public void setGroupId(int groupId) { this.groupId = groupId; }

    public String getSenderType() { return senderType; }
    public void setSenderType(String senderType) { this.senderType = senderType; }

    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }

    public String getEncryptedContent() { return encryptedContent; }
    public void setEncryptedContent(String encryptedContent) { this.encryptedContent = encryptedContent; }

    public String getIv() { return iv; }
    public void setIv(String iv) { this.iv = iv; }

    public Timestamp getTimestamp() { return timestamp; }
    public void setTimestamp(Timestamp timestamp) { this.timestamp = timestamp; }

    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderDetails() { return senderDetails; }
    public void setSenderDetails(String senderDetails) { this.senderDetails = senderDetails; }
}
