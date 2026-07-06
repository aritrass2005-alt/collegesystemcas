package com.college.attendance.model;

import java.sql.Timestamp;
import java.util.List;

public class ChatPoll {
    private int id;
    private int conversationId;
    private String question;
    private String createdByRole;
    private int createdById;
    private Timestamp createdAt;
    private boolean closed;
    private List<ChatPollOption> options;
    private int myVotedOptionId; // 0 = not voted

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getConversationId() { return conversationId; }
    public void setConversationId(int conversationId) { this.conversationId = conversationId; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getCreatedByRole() { return createdByRole; }
    public void setCreatedByRole(String createdByRole) { this.createdByRole = createdByRole; }

    public int getCreatedById() { return createdById; }
    public void setCreatedById(int createdById) { this.createdById = createdById; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isClosed() { return closed; }
    public void setClosed(boolean closed) { this.closed = closed; }

    public List<ChatPollOption> getOptions() { return options; }
    public void setOptions(List<ChatPollOption> options) { this.options = options; }

    public int getMyVotedOptionId() { return myVotedOptionId; }
    public void setMyVotedOptionId(int myVotedOptionId) { this.myVotedOptionId = myVotedOptionId; }
}
