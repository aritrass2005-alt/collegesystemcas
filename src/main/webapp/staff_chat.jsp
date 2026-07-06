<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.college.attendance.model.ChatConversation" %>
<%
    String currentRole = (String) request.getAttribute("currentRole");
    Integer currentUserId = (Integer) request.getAttribute("currentUserId");
    String currentUserName = (String) request.getAttribute("currentUserName");
    List<ChatConversation> conversations = (List<ChatConversation>) request.getAttribute("conversations");
    
    boolean isAdmin = "Admin".equals(currentRole) || "SuperAdmin".equals(currentRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Chat</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="css/chat.css?v=5">
</head>
<body>

<div class="chat-layout">
    <!-- Sidebar -->
    <div class="chat-sidebar">
        <div class="sidebar-header">
            <h2>Chats</h2>
            <div class="sidebar-actions">
                <% if(isAdmin) { %>
                <button class="icon-btn primary-action" onclick="showNewDeptGroupModal()" title="New Department Group">
                    <i class="bi bi-buildings"></i>
                </button>
                <% } %>
            </div>
        </div>
        <div class="conversation-list" id="conversationList">
            <% if (conversations != null) { for (ChatConversation c : conversations) { %>
            <div class="conversation-item" 
                 data-id="<%= c.getId() %>" 
                 data-type="<%= c.getType() %>" 
                 data-name="<%= c.getDisplayName() %>"
                 onclick="selectConversation(this)">
                <div class="avatar group-avatar">
                    <i class="bi <%= "DEPARTMENT".equals(c.getType()) ? "bi-building" : "bi-people" %>"></i>
                </div>
                <div class="conv-info">
                    <div class="conv-header">
                        <span class="conv-name"><%= c.getDisplayName() %></span>
                        <% if (c.getLastMessageTime() != null) { %>
                            <span class="conv-time"><%= new java.text.SimpleDateFormat("HH:mm").format(c.getLastMessageTime()) %></span>
                        <% } %>
                    </div>
                    <div class="conv-last-msg">
                        <span class="msg-preview"><%= c.getLastMessage() != null ? c.getLastMessage() : "No messages yet" %></span>
                        <% if (c.getUnreadCount() > 0) { %>
                            <span class="badge unread-badge"><%= c.getUnreadCount() %></span>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } } %>
        </div>
    </div>

    <!-- Main Chat Area -->
    <div class="chat-main" id="chatMain" style="display: none;">
        <div class="chat-header">
            <div class="header-info">
                <div class="avatar group-avatar" id="activeAvatar"><i class="bi bi-people"></i></div>
                <div class="header-details">
                    <h3 id="activeName">Group Name</h3>
                    <span class="header-status" id="activeStatus">Members</span>
                </div>
            </div>
            <div class="header-actions">
                <button class="icon-btn" id="pinnedBtn" onclick="togglePinnedPanel()" title="Pinned Messages" style="position:relative;">
                    <i class="bi bi-pin-angle-fill" style="color:#f59e0b;"></i>
                    <span id="pinnedCount" class="pinned-count-badge" style="display:none;"></span>
                </button>
                <button class="icon-btn" onclick="startGroupCall('audio')" title="Voice Call"><i class="bi bi-telephone-fill"></i></button>
                <button class="icon-btn" onclick="startGroupCall('video')" title="Video Call"><i class="bi bi-camera-video-fill"></i></button>
                <% if(isAdmin) { %>
                <button class="icon-btn" onclick="showAddMemberModal()" title="Add Member"><i class="bi bi-person-plus-fill"></i></button>
                <button class="icon-btn text-danger" onclick="deleteCurrentGroup()" title="Delete Group"><i class="bi bi-trash"></i></button>
                <% } %>
            </div>
        </div>

        <!-- Pinned Messages Panel -->
        <div id="pinnedPanel" class="pinned-panel" style="display:none;">
            <div class="pinned-panel-header">
                <span><i class="bi bi-pin-angle-fill" style="color:#f59e0b; margin-right:6px;"></i>Pinned Messages</span>
                <button onclick="togglePinnedPanel()" style="background:none;border:none;color:var(--text-muted);cursor:pointer;font-size:1.1rem;"><i class="bi bi-x-lg"></i></button>
            </div>
            <div id="pinnedList" class="pinned-list">
                <p class="pinned-empty" style="color:var(--text-muted);padding:15px;text-align:center;">No pinned messages yet.</p>
            </div>
        </div>

        <!-- Video Call Container -->
        <div id="videoCallContainer" class="video-container" style="display: none;">
            <div class="video-header">
                <span>Group Call</span>
                <span id="callStatus">Connecting...</span>
            </div>
            <div id="videoGrid" class="video-grid">
                <div class="video-wrapper local">
                    <video id="localVideo" autoplay muted playsinline></video>
                    <span class="video-label">You</span>
                </div>
            </div>
            <div class="video-controls">
                <button class="control-btn" id="toggleMuteBtn" onclick="toggleMute()"><i class="bi bi-mic-fill"></i></button>
                <button class="control-btn" id="toggleVideoBtn" onclick="toggleVideo()"><i class="bi bi-camera-video-fill"></i></button>
                <button class="control-btn" id="shareScreenBtn" onclick="toggleScreenShare()"><i class="bi bi-display"></i></button>
                <button class="control-btn danger" id="endCallBtn" onclick="endGroupCall()"><i class="bi bi-telephone-x-fill"></i></button>
            </div>
        </div>

        <div class="messages-container" id="messagesContainer"></div>

        <div class="chat-input-area">
            <div id="attachmentPreview" style="display: none;">
                <span id="attachmentName"></span>
                <button onclick="clearAttachment()"><i class="bi bi-x"></i></button>
            </div>
            <div id="editMessageBanner" style="display: none; align-items: center; justify-content: space-between; padding: 10px 15px; background: rgba(79,156,249,0.1); border-radius: 8px; margin-bottom: 10px; font-size: 0.9rem;">
                <span style="color: var(--primary); font-weight: 500;"><i class="bi bi-pencil-fill" style="margin-right: 5px;"></i> Editing message...</span>
                <button onclick="cancelEditMessage()" style="background: none; border: none; color: var(--text-muted); cursor: pointer; padding: 0 5px;"><i class="bi bi-x-lg"></i></button>
            </div>
            <div class="input-wrapper">
                <label for="fileInput" class="icon-btn" title="Attach file/photo (Max 5MB)">
                    <i class="bi bi-paperclip"></i>
                </label>
                <input type="file" id="fileInput" style="display: none;" onchange="handleFileSelect(event)">

                <!-- Poll button - available to ALL roles -->
                <button class="icon-btn" onclick="showPollModal()" title="Create Poll" id="pollBtn">
                    <i class="bi bi-bar-chart-fill" style="color:#a78bfa;"></i>
                </button>
                
                <input type="text" id="messageInput" placeholder="Type a message..." autocomplete="off">
                
                <div id="recordingUI" style="display: none; align-items: center; flex: 1; color: var(--danger); font-weight: 600; gap: 10px; padding: 0 10px;">
                    <i class="bi bi-record-circle-fill red-blink"></i>
                    <span id="recordingTimer">0:00</span>
                    <button class="icon-btn" onclick="cancelRecording()" title="Cancel Recording" style="color: var(--text-muted);"><i class="bi bi-x-circle-fill"></i></button>
                </div>
                
                <button class="icon-btn" id="micBtn" onclick="toggleVoiceRecording()" title="Record Voice Message">
                    <i class="bi bi-mic-fill"></i>
                </button>
                <button class="send-btn" onclick="sendMessage()"><i class="bi bi-send-fill"></i></button>
            </div>
        </div>
    </div>
    
    <!-- Empty State -->
    <div class="chat-empty" id="chatEmpty">
        <div class="empty-content">
            <i class="bi bi-chat-dots"></i>
            <h3>Welcome to Staff Chat</h3>
            <p>Select a department group from the left to start messaging.</p>
        </div>
    </div>
</div>

<!-- ===== MODALS ===== -->

<% if(isAdmin) { %>
<!-- New Dept Group Modal -->
<div class="modal-overlay" id="newDeptGroupModal">
    <div class="modal">
        <h3>Create Department Group</h3>
        <p>This will auto-add all active teachers and coordinators from the selected department.</p>
        <div class="form-group">
            <label>Select Department</label>
            <select id="newDeptSelect">
                <% 
                    List<String> depts = (List<String>) request.getAttribute("departments");
                    if (depts != null && !depts.isEmpty()) { for (String d : depts) { %>
                <option value="<%= d %>"><%= d %></option>
                <% } } else { %>
                <option value="">No departments found</option>
                <% } %>
            </select>
        </div>
        <div class="modal-actions">
            <button class="btn-secondary" onclick="closeModal('newDeptGroupModal')">Cancel</button>
            <button class="btn-primary" onclick="createDepartmentGroup()">Create Group</button>
        </div>
    </div>
</div>

<!-- Add Member Modal -->
<div class="modal-overlay" id="addMemberModal">
    <div class="modal">
        <h3>Add Member Manually</h3>
        <div class="form-group">
            <label>Role</label>
            <select id="addMemberRole">
                <option value="Teacher">Teacher</option>
                <option value="Admin">Admin</option>
                <option value="Coordinator">Coordinator</option>
            </select>
        </div>
        <div class="form-group">
            <label>User ID</label>
            <input type="number" id="addMemberId" placeholder="Enter ID">
        </div>
        <div class="modal-actions">
            <button class="btn-secondary" onclick="closeModal('addMemberModal')">Cancel</button>
            <button class="btn-primary" onclick="addMember()">Add</button>
        </div>
    </div>
</div>
<% } %>

<!-- Poll Modal — available to ALL roles -->
<div class="modal-overlay" id="pollModal">
    <div class="modal" style="width:460px; max-width:95vw;">
        <h3><i class="bi bi-bar-chart-fill" style="color:#a78bfa; margin-right:8px;"></i>Create a Poll</h3>
        <div class="form-group">
            <label>Question</label>
            <input type="text" id="pollQuestion" placeholder="Ask a question..." maxlength="400">
        </div>
        <div id="pollOptionsContainer">
            <div class="form-group poll-option-row">
                <label>Option 1</label>
                <input type="text" class="poll-option-input" placeholder="Option 1" maxlength="200">
            </div>
            <div class="form-group poll-option-row">
                <label>Option 2</label>
                <input type="text" class="poll-option-input" placeholder="Option 2" maxlength="200">
            </div>
        </div>
        <button class="btn-secondary" onclick="addPollOption()" style="margin-bottom:15px; width:100%; justify-content:center;">
            <i class="bi bi-plus-circle"></i> Add Option
        </button>
        <div class="modal-actions">
            <button class="btn-secondary" onclick="closeModal('pollModal')">Cancel</button>
            <button class="btn-primary" onclick="submitPoll()">Create Poll</button>
        </div>
    </div>
</div>

<!-- Forward Modal -->
<div class="modal-overlay" id="forwardModal">
    <div class="modal">
        <h3>Forward Message</h3>
        <div class="form-group">
            <label>Select Destination Group</label>
            <select id="forwardSelect">
                <% if (conversations != null) { for (ChatConversation c : conversations) { %>
                <option value="<%= c.getId() %>"><%= c.getDisplayName() %></option>
                <% } } %>
            </select>
        </div>
        <div class="modal-actions">
            <button class="btn-secondary" onclick="closeModal('forwardModal')">Cancel</button>
            <button class="btn-primary" onclick="executeForward()">Forward</button>
        </div>
    </div>
</div>

<!-- Delete Message Modal -->
<div class="modal-overlay" id="deleteMessageModal">
    <div class="modal" style="width: 350px;">
        <h3>Delete message?</h3>
        <div class="modal-actions" style="flex-direction: column; gap: 10px; align-items: stretch; margin-top: 15px; width: 100%;">
            <button class="btn-primary" id="deleteForEveryoneBtn" onclick="executeDeleteForEveryone()" style="background: var(--danger); color: white; width: 100%; text-align: center; padding: 12px 0;">Delete for Everyone</button>
            <button class="btn-secondary" onclick="executeDeleteForMe()" style="text-align: center; border: 1px solid var(--border); width: 100%; padding: 12px 0;">Delete for Me</button>
            <button class="btn-secondary" onclick="closeModal('deleteMessageModal')" style="text-align: center; border: none; width: 100%; padding: 10px 0;">Cancel</button>
        </div>
    </div>
</div>

<script>
    const MY_ROLE = "<%= currentRole %>";
    const MY_ID = <%= currentUserId %>;
    const MY_NAME = "<%= currentUserName %>";
</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/forge/1.3.1/forge.min.js"></script>
<script src="js/encryption.js?v=4"></script>
<script src="js/chat.js?v=5"></script>
<script src="js/chat_poll_pin.js?v=1"></script>
</body>
</html>
