package com.college.attendance.model;

public class ChatPollOption {
    private int id;
    private int pollId;
    private String optionText;
    private int voteCount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPollId() { return pollId; }
    public void setPollId(int pollId) { this.pollId = pollId; }

    public String getOptionText() { return optionText; }
    public void setOptionText(String optionText) { this.optionText = optionText; }

    public int getVoteCount() { return voteCount; }
    public void setVoteCount(int voteCount) { this.voteCount = voteCount; }
}
