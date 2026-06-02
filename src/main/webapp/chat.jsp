<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    Boolean isCoordinator = (Boolean) session.getAttribute("isCoordinator");
    if ("Teacher".equals(role) && isCoordinator != null && isCoordinator) {
        role = "Coordinator";
    }
    Object userObj = session.getAttribute("user");
    if (userObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = -1;
    if (userObj instanceof com.college.attendance.model.Admin) {
        userId = ((com.college.attendance.model.Admin) userObj).getId();
    } else if (userObj instanceof com.college.attendance.model.Teacher) {
        userId = ((com.college.attendance.model.Teacher) userObj).getId();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Departmental Chat</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="css/theme.css?v=2" rel="stylesheet">
    <style>
        /* Modern Chat Variables */
        :root {
            --chat-primary: #4f9cf9;
            --chat-primary-dark: #3b82f6;
            --chat-primary-xdark: #1e3a5f;
            --chat-bg: #f3f6fa;
            --chat-sidebar-inner-bg: #ffffff;
            --border-color: #e5e7eb;
            --msg-sent-bg: linear-gradient(135deg, #4f9cf9, #3b82f6);
            --msg-sent-text: #ffffff;
            --msg-recv-bg: #ffffff;
            --msg-recv-text: #1f2937;
            --chat-radius: 12px;
            --shadow-subtle: 0 2px 10px rgba(0,0,0,0.03);
            --shadow-hover: 0 8px 24px rgba(0,0,0,0.08);
        }
        
        body, html { overflow: hidden; height: 100%; }
        
        #content-wrapper {
            height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 20px 24px !important;
            overflow: hidden;
        }
        
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            padding: 0 !important;
            overflow: hidden;
        }
        
        .chat-container { display: flex; flex: 1; overflow: hidden; position: relative; width: 100%; border-radius: var(--radius-xl); box-shadow: var(--shadow-card); background: #fff; margin: 0 auto; max-width: 1400px; border: 1px solid var(--border-color); }
        
        /* Sidebar */
        .sidebar-chat { width: 340px; background: var(--chat-sidebar-inner-bg); border-right: 1px solid var(--border-color); display: flex; flex-direction: column; z-index: 5; transition: transform 0.3s ease; }
        .sidebar-header { padding: 22px 24px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center; background: #fff; }
        .sidebar-header h5 { margin: 0; font-weight: 700; color: var(--text-heading); font-size: 1.15rem; letter-spacing: -0.2px; }
        
        .group-list-container { padding: 12px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 6px; }
        .group-item { padding: 14px 16px; border-radius: var(--chat-radius); cursor: pointer; transition: all 0.2s ease; display: flex; align-items: center; gap: 14px; border: 1px solid transparent; }
        .group-item:hover { background: #f9fafb; border-color: #f3f4f6; transform: translateY(-1px); }
        .group-item.active { background: #eff6ff; border-color: #bfdbfe; box-shadow: var(--shadow-subtle); }
        
        .group-icon { width: 48px; height: 48px; border-radius: 50%; background: linear-gradient(135deg, #1e3a5f, #0f2240); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; font-weight: 600; flex-shrink: 0; box-shadow: 0 4px 12px rgba(30,58,95,0.2); }
        .group-item.active .group-icon { background: linear-gradient(135deg, #4f9cf9, #3b82f6); box-shadow: 0 4px 12px rgba(79,156,249,0.3); }
        
        .group-details { overflow: hidden; }
        .group-details h6 { margin: 0 0 3px 0; font-weight: 600; color: var(--text-heading); font-size: 0.98rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .group-details small { color: var(--text-muted); font-size: 0.8rem; display: flex; align-items: center; gap: 4px; }
        .group-details small i { font-size: 0.75rem; color: #10b981; }

        /* Chat Area */
        .chat-area { flex: 1; display: flex; flex-direction: column; background: var(--chat-bg); position: relative; }
        /* Subtle background pattern */
        .chat-area::before { content: ""; position: absolute; inset: 0; background-image: radial-gradient(#cbd5e1 1px, transparent 1px); background-size: 24px 24px; opacity: 0.4; pointer-events: none; z-index: 1; }
        
        .chat-header { padding: 18px 26px; background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(12px); border-bottom: 1px solid var(--border-color); display: flex; align-items: center; justify-content: space-between; z-index: 10; box-shadow: 0 2px 12px rgba(0,0,0,0.02); }
        .chat-title-group { display: flex; align-items: center; gap: 14px; }
        .mobile-back-btn { display: none; background: #f1f5f9; border: none; color: #475569; width: 36px; height: 36px; border-radius: 50%; padding: 0; cursor: pointer; transition: all 0.2s; align-items: center; justify-content: center; }
        .mobile-back-btn:hover { background: #e2e8f0; color: #1e293b; }
        .chat-header h5 { margin: 0 0 3px 0; font-weight: 700; color: var(--text-heading); font-size: 1.15rem; letter-spacing: -0.2px; }
        .chat-status { font-size: 0.75rem; font-weight: 500; color: #10b981; display: flex; align-items: center; gap: 4px; }
        
        .chat-messages { flex: 1; padding: 24px 32px; overflow-y: auto; display: flex; flex-direction: column; gap: 20px; scroll-behavior: smooth; z-index: 2; position: relative; }
        
        .message { max-width: 65%; padding: 14px 18px; position: relative; word-wrap: break-word; font-size: 0.95rem; line-height: 1.5; box-shadow: var(--shadow-subtle); animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1); }
        .message.sent { background: var(--msg-sent-bg); color: var(--msg-sent-text); align-self: flex-end; border-radius: 18px 18px 4px 18px; box-shadow: 0 4px 14px rgba(79,156,249,0.25); }
        .message.received { background: var(--msg-recv-bg); color: var(--msg-recv-text); align-self: flex-start; border-radius: 18px 18px 18px 4px; border: 1px solid rgba(0,0,0,0.03); }
        
        .message-sender { font-size: 0.75rem; font-weight: 600; margin-bottom: 6px; color: var(--chat-primary-xdark); cursor: pointer; opacity: 0.9; }
        .message.sent .message-sender { display: none; }
        .message-time { font-size: 0.65rem; opacity: 0.8; text-align: right; margin-top: 8px; font-weight: 500; }
        .message.received .message-time { color: #6b7280; }
        
        .chat-input-wrapper { padding: 20px 32px; background: #fff; border-top: 1px solid var(--border-color); z-index: 10; display: flex; align-items: center; }
        .chat-input { display: flex; gap: 12px; background: #f8fafc; padding: 8px; border-radius: 40px; border: 1.5px solid #e2e8f0; transition: all 0.25s ease; flex: 1; align-items: center; box-shadow: inset 0 2px 4px rgba(0,0,0,0.01); }
        .chat-input:focus-within { border-color: var(--chat-primary); background: #fff; box-shadow: 0 0 0 4px rgba(79,156,249,0.1); }
        .chat-input input { border: none; background: transparent; padding: 10px 20px; width: 100%; outline: none; font-size: 0.98rem; color: var(--text-body); font-family: 'Inter', sans-serif; }
        .chat-input input::placeholder { color: #94a3b8; }
        .chat-input button { background: linear-gradient(135deg, #4f9cf9, #3b82f6); color: white; border: none; width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; transition: all 0.2s; flex-shrink: 0; box-shadow: 0 4px 10px rgba(59,130,246,0.3); cursor: pointer; }
        .chat-input button:hover { transform: scale(1.05); box-shadow: 0 6px 14px rgba(59,130,246,0.4); }
        .chat-input button:active { transform: scale(0.95); }
        
        .empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: #64748b; text-align: center; }
        .empty-state i { font-size: 4.5rem; color: #cbd5e1; margin-bottom: 20px; }
        .empty-state h5 { font-weight: 700; color: #334155; margin-bottom: 8px; }
        
        .delete-msg-btn { color: #f87171; cursor: pointer; font-size: 0.85rem; position: absolute; top: 12px; right: 12px; opacity: 0; transition: all 0.2s; background: rgba(255,255,255,0.9); width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .message:hover .delete-msg-btn { opacity: 1; transform: scale(1); }
        .message.sent { padding-right: 36px; }
        .message.received { padding-right: 36px; }
        
        @keyframes slideUp { from { opacity: 0; transform: translateY(15px) scale(0.98); } to { opacity: 1; transform: translateY(0) scale(1); } }

        /* Media toolbar */
        .media-toolbar { display: flex; gap: 4px; align-items: center; padding: 0 4px; }
        .media-btn { background: none; border: none; width: 34px; height: 34px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #64748b; cursor: pointer; transition: all 0.2s; font-size: 1rem; flex-shrink: 0; }
        .media-btn:hover { background: #f1f5f9; color: var(--chat-primary); transform: scale(1.1); }
        .media-btn.recording { color: #ef4444; animation: pulse-rec 1s infinite; }
        @keyframes pulse-rec { 0%,100%{opacity:1} 50%{opacity:0.4} }

        /* Image preview inside chat */
        .msg-image { max-width: 260px; border-radius: 12px; cursor: pointer; display: block; transition: transform 0.2s; }
        .msg-image:hover { transform: scale(1.02); }
        .msg-file-card { display: flex; align-items: center; gap: 10px; background: rgba(255,255,255,0.15); padding: 10px 14px; border-radius: 12px; text-decoration: none; color: inherit; }
        .msg-file-card i { font-size: 1.6rem; }
        .msg-voice { width: 220px; border-radius: 20px; height: 36px; }

        /* Image lightbox */
        .lightbox { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.85); z-index: 9999; align-items: center; justify-content: center; }
        .lightbox.open { display: flex; }
        .lightbox img { max-width: 90vw; max-height: 90vh; border-radius: 12px; }
        .lightbox-close { position: absolute; top: 20px; right: 28px; color: #fff; font-size: 2rem; cursor: pointer; }

        /* Video call overlay */
        .call-overlay { display: none; position: fixed; inset: 0; background: #0a0a1a; z-index: 9998; flex-direction: column; }
        .call-overlay.active { display: flex; }
        .call-videos { flex: 1; display: flex; align-items: center; justify-content: center; gap: 16px; padding: 24px; flex-wrap: wrap; }
        .call-videos video { width: 380px; height: 280px; border-radius: 16px; background: #1e1e2e; object-fit: cover; border: 2px solid rgba(255,255,255,0.1); }
        .call-videos video#localVideo { border-color: #4f9cf9; }
        .call-label { position: absolute; bottom: 10px; left: 14px; color: #fff; font-size: 0.8rem; font-weight: 600; background: rgba(0,0,0,0.5); padding: 3px 10px; border-radius: 20px; }
        .call-controls { display: flex; justify-content: center; gap: 16px; padding: 20px; background: rgba(255,255,255,0.04); border-top: 1px solid rgba(255,255,255,0.08); }
        .call-btn { width: 56px; height: 56px; border-radius: 50%; border: none; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; cursor: pointer; transition: all 0.2s; color: #fff; }
        .call-btn.end { background: #ef4444; } .call-btn.end:hover { background: #dc2626; }
        .call-btn.mute { background: #374151; } .call-btn.mute.active { background: #ef4444; }
        .call-btn.cam { background: #374151; } .call-btn.cam.active { background: #ef4444; }
        .call-btn.share { background: #7c3aed; } .call-btn.share.active { background: #6d28d9; }
        .call-info { text-align: center; padding: 16px; color: rgba(255,255,255,0.7); font-size: 0.9rem; }


        /* Call Banner */
        .call-banner { display: none; background: linear-gradient(135deg, #10b981, #059669); color: #fff; padding: 12px 24px; align-items: center; gap: 14px; z-index: 12; border-bottom: 1px solid rgba(255,255,255,0.2); animation: slideDown 0.3s ease; }
        .call-banner.active { display: flex; }
        .call-banner i { font-size: 1.4rem; animation: pulse-rec 1.2s infinite; }
        .call-banner .banner-text { flex: 1; font-weight: 600; font-size: 0.95rem; }
        .call-banner .banner-text small { display: block; font-weight: 400; opacity: 0.85; font-size: 0.8rem; }
        .join-btn { background: #fff; color: #059669; border: none; border-radius: 20px; padding: 7px 20px; font-weight: 700; cursor: pointer; font-size: 0.88rem; transition: all 0.2s; }
        .join-btn:hover { background: #ecfdf5; transform: scale(1.03); }
        .dismiss-btn { background: rgba(255,255,255,0.2); border: none; color: #fff; border-radius: 50%; width: 28px; height: 28px; cursor: pointer; font-size: 0.9rem; display: flex; align-items: center; justify-content: center; }
        @keyframes slideDown { from { transform: translateY(-100%); opacity:0; } to { transform: translateY(0); opacity:1; } }

        @media (max-width: 768px) {
            .chat-container { border-radius: 0; height: calc(100vh - 60px); border: none; }
            .sidebar-chat { position: absolute; left: 0; top: 0; bottom: 0; width: 100%; transform: translateX(0); z-index: 20; }
            .sidebar-chat.hidden { transform: translateX(-100%); }
            .mobile-back-btn { display: flex; }
            .message { max-width: 85%; }
            .chat-messages { padding: 16px; }
            .chat-input-wrapper { padding: 16px; }
            .chat-header { padding: 14px 16px; }
        }
    </style>
</head>
<body>

<!-- Loading Overlay for Crypto Ops -->
<div id="loadingOverlay" class="loading-overlay">
    <div class="spinner-border text-primary" role="status"></div>
    <h5 class="mt-3" id="loadingText">Initializing Secure Environment...</h5>
</div>

<% if (role.equals("Admin") || role.equals("SuperAdmin")) { %>
    <jsp:include page="includes/admin_sidebar.jsp" />
<% } else { %>
    <jsp:include page="includes/teacher_sidebar.jsp" />
<% } %>

<div id="content-wrapper">
    <% if (role.equals("Admin") || role.equals("SuperAdmin")) { %>
        <jsp:include page="includes/admin_header.jsp" />
    <% } else { %>
        <jsp:include page="includes/teacher_header.jsp" />
    <% } %>

    <div class="main-content" style="padding: 20px;">
        <div class="chat-container">
    <!-- Sidebar -->
    <div class="sidebar-chat" id="sidebarChat">
        <div class="sidebar-header">
            <h5>Groups</h5>
            <% if(role.equals("Admin") || role.equals("SuperAdmin")) { %>
                <button class="btn btn-sm btn-primary rounded-circle" style="width:32px;height:32px;display:flex;align-items:center;justify-content:center;" data-bs-toggle="modal" data-bs-target="#createGroupModal" title="Create Group"><i class="bi bi-plus-lg"></i></button>
            <% } %>
        </div>
        <div id="groupList" class="group-list-container">
            <!-- Groups injected here -->
        </div>
    </div>

    <!-- Chat Area -->
    <div class="chat-area">
        <div class="chat-header">
            <div class="chat-title-group">
                <button class="mobile-back-btn" id="mobileBackBtn">
                    <i class="bi bi-arrow-left"></i>
                </button>
                <div>
                    <h5 id="chatTitle">Select a Group</h5>
                    <span class="chat-status" id="chatStatus"><i class="bi bi-shield-lock-fill"></i> End-to-End Encrypted</span>
                </div>
            </div>
            <div>
                <% if(role.equals("Admin") || role.equals("SuperAdmin")) { %>
                    <button class="btn btn-sm btn-outline-danger px-3 me-2" id="deleteGroupBtn" style="display:none;" onclick="deleteActiveGroup()">
                        <i class="bi bi-trash me-1"></i> Delete
                    </button>
                <% } %>
                <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" id="viewParticipantsBtn" style="display:none;" data-bs-toggle="modal" data-bs-target="#participantsModal">
                    <i class="bi bi-people me-1"></i> Participants
                </button>
                <button class="btn btn-sm btn-success rounded-pill px-3 ms-2" id="startCallBtn" style="display:none;" onclick="startCall()">
                    <i class="bi bi-camera-video-fill me-1"></i> Call
                </button>
            </div>
        </div>
        <!-- Call Banner (shown to non-callers when a call is active) -->
        <div class="call-banner" id="callBanner">
            <i class="bi bi-camera-video-fill"></i>
            <div class="banner-text">
                <span id="bannerCallerName">Someone</span> started a video call
                <small>Click Join to enter the call</small>
            </div>
            <button class="join-btn" onclick="joinCall()">Join Now</button>
            <button class="dismiss-btn" onclick="hideCallBanner()" title="Dismiss"><i class="bi bi-x"></i></button>
        </div>
        <div class="chat-messages" id="chatMessages">
            <div class="empty-state">
                <i class="bi bi-chat-dots"></i>
                <h5>Your secure space</h5>
                <p>Select a department group from the sidebar to start chatting.</p>
            </div>
        </div>
        <div class="chat-input-wrapper" id="chatInputArea" style="opacity: 0.5; pointer-events: none;">
            <div class="media-toolbar">
                <button class="media-btn" id="imgUploadBtn" title="Send Image" onclick="document.getElementById('imgFileInput').click()">
                    <i class="bi bi-image"></i>
                </button>
                <button class="media-btn" id="fileUploadBtn" title="Send File" onclick="document.getElementById('fileInput').click()">
                    <i class="bi bi-paperclip"></i>
                </button>
                <button class="media-btn" id="voiceBtn" title="Record Voice">
                    <i class="bi bi-mic"></i>
                </button>
                <input type="file" id="imgFileInput" accept="image/*" style="display:none">
                <input type="file" id="fileInput" style="display:none">
            </div>
            <div class="chat-input">
                <input type="text" id="messageInput" placeholder="Type a message..." autocomplete="off">
                <button id="sendBtn"><i class="bi bi-send-fill"></i></button>
            </div>
        </div>
    </div>
</div>
</div>

<!-- Image Lightbox -->
<div class="lightbox" id="lightbox" onclick="closeLightbox()">
    <span class="lightbox-close"><i class="bi bi-x-lg"></i></span>
    <img id="lightboxImg" src="" alt="Preview">
</div>

<!-- Video Call Overlay -->
<div class="call-overlay" id="callOverlay">
    <div class="call-info" id="callInfo">🔒 Encrypted Video Call — <span id="callGroupName"></span></div>
    <div class="call-videos" id="callVideos">
        <div style="position:relative;">
            <video id="localVideo" autoplay muted playsinline></video>
            <span class="call-label">You</span>
        </div>
        <div id="remoteVideosContainer"></div>
    </div>
    <div class="call-controls">
        <button class="call-btn mute" id="muteBtn" onclick="toggleMute()" title="Mute">
            <i class="bi bi-mic-fill" id="muteIcon"></i>
        </button>
        <button class="call-btn cam" id="camBtn" onclick="toggleCam()" title="Camera">
            <i class="bi bi-camera-video-fill" id="camIcon"></i>
        </button>
        <button class="call-btn share" id="shareBtn" onclick="toggleScreenShare()" title="Share Screen">
            <i class="bi bi-display" id="shareIcon"></i>
        </button>
        <button class="call-btn end" onclick="endCall()" title="End Call">
            <i class="bi bi-telephone-x-fill"></i>
        </button>
    </div>
</div>

<!-- Create Group Modal -->
<div class="modal fade" id="createGroupModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Create Group</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small mb-4">Creates an End-to-End Encrypted room. Only authorized faculty in this department will be able to decrypt the messages.</p>
                <div class="mb-3">
                    <label class="form-label fw-bold">Department Name</label>
                    <input type="text" id="newGroupDept" class="form-control form-control-lg bg-light" placeholder="e.g. Computer Science">
                </div>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary px-4" id="createGroupBtn">Create & Setup Encryption</button>
            </div>
        </div>
    </div>
</div>

<!-- Participants Modal -->
<div class="modal fade" id="participantsModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Participants</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <ul class="list-group list-group-flush" id="participantsList">
                </ul>
            </div>
        </div>
    </div>
</div>

<!-- Script Includes -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/crypto_utils.js?v=2"></script>
<script>
    const USER_ROLE = '<%= role %>';
    const USER_ID = <%= userId %>;
    
    let rsaKeyPair = null;
    let activeGroupId = null;
    let activeGroupAESKey = null;
    let ws = null;

    // UI Elements
    const loadingOverlay = document.getElementById('loadingOverlay');
    const loadingText = document.getElementById('loadingText');
    const groupList = document.getElementById('groupList');
    const chatMessages = document.getElementById('chatMessages');
    const chatTitle = document.getElementById('chatTitle');
    const messageInput = document.getElementById('messageInput');
    const sendBtn = document.getElementById('sendBtn');
    const chatInputArea = document.getElementById('chatInputArea');

    async function init() {
        try {
            // 1. Check if user has RSA keys in IndexedDB
            loadingText.innerText = "Checking device keys...";
            const privKey = await CryptoUtils.getKeyFromDB("rsa_private");
            const pubKey = await CryptoUtils.getKeyFromDB("rsa_public");

            if (!privKey || !pubKey) {
                loadingText.innerText = "Generating new End-to-End Encryption Keys... (This only happens once)";
                rsaKeyPair = await CryptoUtils.generateRSAKeyPair();
                
                await CryptoUtils.saveKeyToDB("rsa_private", rsaKeyPair.privateKey);
                await CryptoUtils.saveKeyToDB("rsa_public", rsaKeyPair.publicKey);
            } else {
                rsaKeyPair = { privateKey: privKey, publicKey: pubKey };
            }

            // Always upload/sync the current public key to the server on every login.
            // This keeps the server's record fresh even if the DB was restored.
            loadingText.innerText = "Syncing encryption keys with server...";
            const pubKeyBase64 = await CryptoUtils.exportPublicKey(rsaKeyPair.publicKey);
            await fetch('chatApi?action=storePublicKey', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `publicKey=\${encodeURIComponent(pubKeyBase64)}`
            });

            // 2. Load Groups
            await loadGroups();
            loadingOverlay.style.display = 'none';

        } catch (e) {
            console.error(e);
            loadingText.innerText = "Error initializing encryption. " + e.message;
        }
    }

    // Re-register device keys: regenerate RSA pair, upload new public key,
    // clear stale group_keys so admins can auto-re-share.
    async function reRegisterDeviceKeys() {
        const btn = document.getElementById('reRegisterBtn');
        if (btn) { btn.disabled = true; btn.innerText = 'Regenerating...'; }
        try {
            // Generate fresh RSA key pair
            rsaKeyPair = await CryptoUtils.generateRSAKeyPair();
            await CryptoUtils.saveKeyToDB("rsa_private", rsaKeyPair.privateKey);
            await CryptoUtils.saveKeyToDB("rsa_public", rsaKeyPair.publicKey);
            const pubKeyBase64 = await CryptoUtils.exportPublicKey(rsaKeyPair.publicKey);

            // Upload new public key AND clear all stale group_keys in one call
            const res = await fetch('chatApi?action=clearMyKeys', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `publicKey=\${encodeURIComponent(pubKeyBase64)}`
            });
            const data = await res.json();
            if (data.success) {
                chatMessages.innerHTML = `
                    <div class="empty-state">
                        <i class="bi bi-shield-check" style="color:#10b981;font-size:3.5rem;"></i>
                        <h6 class="mt-3" style="color:#10b981;">New Keys Registered!</h6>
                        <p class="text-muted" style="max-width:340px;">
                            Your new device keys have been saved and your old stale keys have been cleared.
                            The encryption keys will be <strong>automatically re-shared</strong> the next time
                            an admin or another group member opens this chat.
                        </p>
                        <p class="text-muted small">Ask an admin to open the group to trigger automatic re-sharing, then refresh this page.</p>
                        <button class="btn btn-primary mt-2" onclick="location.reload()"><i class="bi bi-arrow-clockwise me-2"></i>Refresh Page</button>
                    </div>`;
            } else {
                chatMessages.innerHTML = `<div class="empty-state text-danger"><i class="bi bi-x-circle"></i><h6>Re-registration Failed</h6><p>${data.message}</p></div>`;
            }
        } catch (e) {
            console.error(e);
            chatMessages.innerHTML = `<div class="empty-state text-danger"><i class="bi bi-x-circle"></i><h6>Error</h6><p>${e.message}</p></div>`;
        }
    }

    async function loadGroups() {
        const res = await fetch('chatApi?action=getGroups');
        const groups = await res.json();
        groupList.innerHTML = '';
        groups.forEach(g => {
            const div = document.createElement('div');
            div.className = 'group-item';
            const initial = g.department.charAt(0).toUpperCase();
            div.dataset.id = g.id;
            div.innerHTML = `
                <div class="group-icon">\${initial}</div>
                <div class="group-details">
                    <h6>\${g.department}</h6>
                    <small>Encrypted Channel</small>
                </div>
            `;
            div.onclick = () => selectGroup(g.id, g.department, div);
            groupList.appendChild(div);
        });
    }

    async function selectGroup(groupId, deptName, element) {
        document.querySelectorAll('.group-item').forEach(el => el.classList.remove('active'));
        if (element) {
            element.classList.add('active');
        } else {
            const el = Array.from(document.querySelectorAll('.group-item')).find(e => e.dataset.id == groupId);
            if (el) el.classList.add('active');
        }
        
        // Mobile handling
        if(window.innerWidth <= 768) {
            document.getElementById('sidebarChat').classList.add('hidden');
        }
        
        chatTitle.innerText = deptName;
        activeGroupId = groupId;
        chatInputArea.style.opacity = 0.5;
        chatInputArea.style.pointerEvents = 'none';
        document.getElementById('viewParticipantsBtn').style.display = 'inline-block';
        document.getElementById('startCallBtn').style.display = 'inline-block';
        document.getElementById('callGroupName').innerText = deptName;
        if (document.getElementById('deleteGroupBtn')) {
            document.getElementById('deleteGroupBtn').style.display = 'inline-block';
        }
        chatMessages.innerHTML = '<div class="empty-state"><div class="spinner-border text-primary"></div><h6 class="mt-3">Decrypting secure channel...</h6></div>';

        // Connect WebSocket early
        if (ws) ws.close();
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const contextPath = '<%= request.getContextPath() %>';
        ws = new WebSocket(`\${protocol}//\${window.location.host}\${contextPath}/chat/\${groupId}/\${USER_ROLE}/\${USER_ID}`);
        
        ws.onmessage = async (event) => {
            const msgObj = JSON.parse(event.data);
            
            // Handle call notifications
            if (msgObj.type === 'call-started') {
                showCallBanner(msgObj.callerName, msgObj.groupId);
                return;
            }
            if (msgObj.type === 'call-ended') {
                hideCallBanner();
                return;
            }
            if (msgObj.type === 'key-request') {
                if (activeGroupAESKey) {
                    console.log("Received key request. Checking and sharing keys...");
                    loadParticipants(activeGroupId).then(participants => {
                        autoShareKey(activeGroupId, participants, activeGroupAESKey);
                    });
                }
                return;
            }
            if (msgObj.type === 'key-shared') {
                if (!activeGroupAESKey && activeGroupId == msgObj.groupId) {
                    console.log("A key was just shared! Reloading group...");
                    selectGroup(activeGroupId, chatTitle.innerText);
                }
                return;
            }
            
            await renderMessage(msgObj);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        };


        try {
            // Fetch Encrypted AES Key for this group
            const res = await fetch(`chatApi?action=getGroupKey&groupId=\${groupId}`);
            const data = await res.json();
            
            if (!data.encryptedGroupKey) {
                let actionHtml = '';
                if (USER_ROLE === 'Admin' || USER_ROLE === 'SuperAdmin') {
                    actionHtml = `
                        <button class="btn btn-warning mt-3 px-4" onclick="resetGroupEncryption(\${groupId})">
                            <i class="bi bi-arrow-clockwise me-2"></i>Reset Group Encryption
                        </button>
                        <small class="d-block mt-2 text-muted" style="max-width:350px;">
                            This will generate a new encryption key for the group and share it with all current members. 
                            <strong>Note:</strong> Old messages will become permanently unreadable.
                        </small>
                    `;
                } else {
                    actionHtml = `
                        <p class="text-muted small mt-2">Please wait for an admin or a group member who has the key to open this chat and automatically share it with you.</p>
                        <button id="requestKeyBtn" class="btn btn-primary mt-2" onclick="requestEncryptionKey(\${groupId})">
                            <i class="bi bi-bell-fill me-2"></i>Request Key Access
                        </button>
                    `;
                }
                
                chatMessages.innerHTML = `
                    <div class="empty-state">
                        <i class="bi bi-shield-lock" style="color:#ef4444;font-size:3.5rem;"></i>
                        <h6 class="mt-3" style="color:#ef4444;">Access Denied</h6>
                        <p class="text-muted">You do not have the encryption key for this group.</p>
                        ${actionHtml}
                    </div>`;
                return;
            }

            // Decrypt AES Key using our Private RSA Key
            const aesKeyBase64 = await CryptoUtils.decryptAESKeyWithRSA(data.encryptedGroupKey, rsaKeyPair.privateKey);
            activeGroupAESKey = await CryptoUtils.importAESKey(aesKeyBase64);

            // Fetch and decrypt message history
            const historyRes = await fetch(`chatApi?action=getMessages&groupId=\${groupId}`);
            const history = await historyRes.json();
            
            chatMessages.innerHTML = '';
            for (const msg of history) {
                await renderMessage(msg);
            }
            if (history.length === 0) {
                chatMessages.innerHTML = '<div class="empty-state"><i class="bi bi-chat-dots"></i><p>No messages yet. Send the first encrypted message!</p></div>';
            }
            
            chatMessages.scrollTop = chatMessages.scrollHeight;
            chatInputArea.style.opacity = 1;
            chatInputArea.style.pointerEvents = 'auto';

            // Load participants list
            const participants = await loadParticipants(groupId);

            // Auto-share key to users who missed it
            await autoShareKey(groupId, participants, activeGroupAESKey);

        } catch (e) {
            console.error("Failed to decrypt group", e);
            chatMessages.innerHTML = `
                <div class="empty-state">
                    <i class="bi bi-shield-x" style="color:#ef4444;font-size:3.5rem;"></i>
                    <h6 class="mt-3" style="color:#ef4444;">Decryption Failed</h6>
                    <p class="text-muted" style="max-width:380px;">
                        The encryption key stored for this group doesn't match your current device key.
                        This can happen if you cleared browser data or signed in from a new device.
                    </p>
                    <div class="mt-3 d-flex flex-column align-items-center gap-2">
                        <button id="reRegisterBtn" class="btn btn-warning px-4" onclick="reRegisterDeviceKeys()">
                            <i class="bi bi-key-fill me-2"></i>Re-register Device Keys
                        </button>
                        <small class="text-muted">This will generate new keys and notify admins to re-share access.</small>
                    </div>
                </div>`;
        }
    }

    document.getElementById('mobileBackBtn').addEventListener('click', () => {
        document.getElementById('sidebarChat').classList.remove('hidden');
    });

    async function renderMessage(msgObj) {
        const isMe = (msgObj.senderType === USER_ROLE && msgObj.senderId === USER_ID);
        const isAdmin = USER_ROLE === 'Admin' || USER_ROLE === 'SuperAdmin';
        const div = document.createElement('div');
        div.className = `message \${isMe ? 'sent' : 'received'}`;
        div.id = `msg-\${msgObj.id}`;
        let senderHtml = !isMe ? `<div class="message-sender">\${msgObj.senderName} (\${msgObj.senderType})</div>` : '';
        let deleteBtn = (isMe || isAdmin) ? `<span class="delete-msg-btn" onclick="deleteMessage(\${msgObj.id}, this)"><i class="bi bi-trash"></i></span>` : '';
        let dt = new Date(msgObj.timestamp);
        if (isNaN(dt.getTime()) && typeof msgObj.timestamp === 'string') {
            dt = new Date(msgObj.timestamp.replace(' ', 'T'));
        }
        const timeStr = !isNaN(dt.getTime()) ? dt.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}) : '';
        let contentHtml = '';
        const mtype = msgObj.messageType || 'text';
        if (mtype === 'image') {
            contentHtml = `<img src="\${msgObj.fileUrl}" class="msg-image" alt="\${msgObj.fileName}" onclick="openLightbox('\${msgObj.fileUrl}')"><br><small style="opacity:0.7;font-size:0.7rem">\${msgObj.fileName}</small>`;
        } else if (mtype === 'voice') {
            contentHtml = `<audio controls class="msg-voice"><source src="\${msgObj.fileUrl}"></audio>`;
        } else if (mtype === 'file') {
            const ext = (msgObj.fileName||'').split('.').pop().toLowerCase();
            const icon = ['pdf'].includes(ext)?'bi-file-pdf':['doc','docx'].includes(ext)?'bi-file-word':['xls','xlsx'].includes(ext)?'bi-file-excel':'bi-file-earmark';
            contentHtml = `<a href="\${msgObj.fileUrl}" download="\${msgObj.fileName}" class="msg-file-card"><i class="bi \${icon}"></i><div><div style="font-weight:600">\${msgObj.fileName}</div><small>Download</small></div></a>`;
        } else {
            let plaintext = '[Encrypted]';
            try { plaintext = await CryptoUtils.decryptMessage(msgObj.encryptedContent, msgObj.iv, activeGroupAESKey); } catch(e) { console.error('Decrypt failed', e); }
            contentHtml = `<div>\${plaintext}</div>`;
        }
        div.innerHTML = `\${senderHtml}\${contentHtml}\${deleteBtn}<div class="message-time">\${timeStr}</div>`;
        chatMessages.appendChild(div);
    }


    sendBtn.onclick = async () => {

        const text = messageInput.value.trim();
        if (!text || !activeGroupAESKey || !ws) return;
        
        const encrypted = await CryptoUtils.encryptMessage(text, activeGroupAESKey);
        ws.send(JSON.stringify(encrypted));
        messageInput.value = '';
    };

    messageInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendBtn.click();
    });

    // Admin: Create Group
    document.getElementById('createGroupBtn')?.addEventListener('click', async () => {
        const dept = document.getElementById('newGroupDept').value.trim();
        if(!dept) return;

        const btn = document.getElementById('createGroupBtn');
        btn.disabled = true;
        btn.innerText = "Creating...";

        try {
            // 1. Create group on server
            const res = await fetch('chatApi?action=createGroup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `department=\${encodeURIComponent(dept)}`
            });
            const data = await res.json();
            if(!data.success) {
                alert(data.message);
                btn.disabled = false; btn.innerText = "Create & Setup Encryption";
                return;
            }

            const groupId = data.group.id;

            // 2. Generate AES Key for group
            const aesKey = await CryptoUtils.generateAESKey();
            const aesKeyBase64 = await CryptoUtils.exportAESKey(aesKey);

            // 3. Fetch participants
            const pRes = await fetch(`chatApi?action=getParticipants&groupId=\${groupId}`);
            const participants = await pRes.json();

            // 4. Encrypt AES Key for EVERY participant
            for (const p of participants) {
                const pkRes = await fetch(`chatApi?action=getPublicKey&userType=\${p.userType}&userId=\${p.userId}`);
                const pkData = await pkRes.json();
                
                if (pkData.publicKey) {
                    const pubKey = await CryptoUtils.importPublicKey(pkData.publicKey);
                    const encryptedKey = await CryptoUtils.encryptAESKeyWithRSA(aesKeyBase64, pubKey);
                    
                    await fetch('chatApi?action=storeGroupKey', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: `groupId=\${groupId}&userType=\${p.userType}&userId=\${p.userId}&encryptedKey=\${encodeURIComponent(encryptedKey)}`
                    });
                } else {
                    console.warn(`User \${p.userType} \${p.userId} has no public key uploaded. They won't be able to decrypt the group until they login and generate one.`);
                    // We can't encrypt for them yet. 
                }
            }

            // Close modal and cleanup backdrop
            const modalEl = document.getElementById('createGroupModal');
            const modalInstance = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
            modalInstance.hide();
            
            // Fallback cleanup in case Bootstrap leaves the backdrop hanging
            setTimeout(() => {
                document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';
                document.body.style.paddingRight = '';
            }, 300);

            await loadGroups();
            selectGroup(groupId, dept);

        } catch (e) {
            console.error(e);
            alert("Failed to create group.");
        } finally {
            btn.disabled = false; btn.innerText = "Create & Setup Encryption";
        }
    });

    async function loadParticipants(groupId) {
        const res = await fetch(`chatApi?action=getParticipants&groupId=\${groupId}`);
        const list = await res.json();
        const ul = document.getElementById('participantsList');
        ul.innerHTML = '';
        list.forEach(p => {
            const li = document.createElement('li');
            li.className = 'list-group-item d-flex justify-content-between align-items-center';
            li.innerHTML = `
                <div>
                    <div class="fw-bold">\${p.name} <span class="badge bg-secondary ms-2">\${p.userType}</span></div>
                    <small class="text-muted">\${p.details}</small>
                </div>
                \${p.hasKey ? '<i class="bi bi-shield-check text-success" title="Encrypted"></i>' : '<i class="bi bi-shield-exclamation text-warning" title="Waiting for key..."></i>'}
            `;
            ul.appendChild(li);
        });
        return list;
    }

    async function autoShareKey(groupId, participants, aesKey) {
        const aesKeyBase64 = await CryptoUtils.exportAESKey(aesKey);
        let updatedAny = false;
        for (const p of participants) {
            if (!p.hasKey) {
                const pkRes = await fetch(`chatApi?action=getPublicKey&userType=\${p.userType}&userId=\${p.userId}`);
                const pkData = await pkRes.json();
                if (pkData.publicKey) {
                    console.log(`Auto-sharing key to \${p.name}`);
                    const pubKey = await CryptoUtils.importPublicKey(pkData.publicKey);
                    const encryptedKey = await CryptoUtils.encryptAESKeyWithRSA(aesKeyBase64, pubKey);
                    await fetch('chatApi?action=storeGroupKey', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: `groupId=\${groupId}&userType=\${p.userType}&userId=\${p.userId}&encryptedKey=\${encodeURIComponent(encryptedKey)}`
                    });
                    updatedAny = true;
                }
            }
        }
        if (updatedAny) {
            await loadParticipants(groupId);
            if (ws && ws.readyState === WebSocket.OPEN) {
                ws.send(JSON.stringify({ type: 'key-shared', groupId: groupId }));
            }
        }
    }

    function requestEncryptionKey(groupId) {
        if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: 'key-request', groupId: groupId }));
            const btn = document.getElementById('requestKeyBtn');
            if(btn) { btn.disabled = true; btn.innerText = "Request Sent"; }
            alert("Key request sent to active group members.");
        } else {
            alert("Connection not established yet. Please try again in a few seconds.");
        }
    }

    // Delete Group (Admin only)
    async function deleteActiveGroup() {
        if (!activeGroupId) return;
        if (!confirm("Are you sure you want to delete this group? All messages and encryption keys will be permanently deleted. This action cannot be undone.")) return;
        
        try {
            const res = await fetch('chatApi?action=deleteGroup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `groupId=\${activeGroupId}`
            });
            const data = await res.json();
            if (data.success) {
                activeGroupId = null;
                chatTitle.innerText = 'Select a Group';
                chatMessages.innerHTML = '<div class="empty-state"><i class="bi bi-chat-dots"></i><h5>Group Deleted</h5><p>Select a different group to continue.</p></div>';
                chatInputArea.style.opacity = 0.5;
                chatInputArea.style.pointerEvents = 'none';
                document.getElementById('viewParticipantsBtn').style.display = 'none';
                if (document.getElementById('deleteGroupBtn')) document.getElementById('deleteGroupBtn').style.display = 'none';
                if (ws) { ws.close(); ws = null; }
                await loadGroups();
            } else {
                alert(data.message || "Failed to delete group.");
            }
        } catch (e) {
            console.error(e);
            alert("An error occurred while deleting the group.");
        }
    }

    // Delete Message
    async function deleteMessage(messageId, btnElement) {
        if (!confirm("Delete this message?")) return;
        try {
            const res = await fetch('chatApi?action=deleteMessage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `messageId=\${messageId}`
            });
            const data = await res.json();
            if (data.success) {
                const msgDiv = document.getElementById(`msg-\${messageId}`);
                if (msgDiv) {
                    msgDiv.style.opacity = 0.5;
                    msgDiv.innerHTML = '<em><small>Message deleted</small></em>';
                }
            } else {
                alert("Failed to delete message. You may not have permission.");
            }
        } catch (e) {
            console.error(e);
            alert("Error deleting message.");
        }
    }

    // Reset Group Encryption (Admin only)
    async function resetGroupEncryption(groupId) {
        if (!confirm("Are you sure you want to reset the encryption key? All previous messages will become permanently unreadable for everyone.")) return;
        
        try {
            chatMessages.innerHTML = '<div class="empty-state"><div class="spinner-border text-primary"></div><h6 class="mt-3">Resetting encryption...</h6></div>';
            
            // 1. Generate new AES key
            const aesKey = await CryptoUtils.generateAESKey();
            const aesKeyBase64 = await CryptoUtils.exportAESKey(aesKey);
            
            // 2. Fetch all participants for this group
            const pRes = await fetch(`chatApi?action=getParticipants&groupId=\${groupId}`);
            const participants = await pRes.json();
            
            // 3. Encrypt and store the new key for everyone who has a public key
            let successCount = 0;
            for (const p of participants) {
                const pkRes = await fetch(`chatApi?action=getPublicKey&userType=\${p.userType}&userId=\${p.userId}`);
                const pkData = await pkRes.json();
                
                if (pkData.publicKey) {
                    const pubKey = await CryptoUtils.importPublicKey(pkData.publicKey);
                    const encryptedKey = await CryptoUtils.encryptAESKeyWithRSA(aesKeyBase64, pubKey);
                    
                    await fetch('chatApi?action=storeGroupKey', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: `groupId=\${groupId}&userType=\${p.userType}&userId=\${p.userId}&encryptedKey=\${encodeURIComponent(encryptedKey)}`
                    });
                    successCount++;
                }
            }
            
            alert(`Encryption reset successfully. Shared new key with \${successCount} participants.`);
            // Reload the group
            selectGroup(groupId, chatTitle.innerText);
            
        } catch(e) {
            console.error(e);
            alert("Failed to reset encryption.");
            chatMessages.innerHTML = `<div class="empty-state text-danger"><i class="bi bi-x-circle"></i><h6>Reset Failed</h6><p>\${e.message}</p></div>`;
        }
    }

    // Start
    init();

    // ── LIGHTBOX ──────────────────────────────────────────
    function openLightbox(src) {
        document.getElementById('lightboxImg').src = src;
        document.getElementById('lightbox').classList.add('open');
    }
    function closeLightbox() {
        document.getElementById('lightbox').classList.remove('open');
    }

    // ── FILE / IMAGE UPLOAD ───────────────────────────────
    async function uploadMedia(file, messageType) {
        if (!activeGroupId) return;
        const fd = new FormData();
        fd.append('file', file);
        fd.append('groupId', activeGroupId);
        fd.append('messageType', messageType);
        try {
            const res = await fetch('chatUpload', { method: 'POST', body: fd });
            const data = await res.json();
            if (data.success && data.message) {
                // Broadcast file message via WebSocket signal
                const signal = { type: 'file-message', message: data.message };
                if (ws && ws.readyState === WebSocket.OPEN) ws.send(JSON.stringify(signal));
                await renderMessage(data.message);
                chatMessages.scrollTop = chatMessages.scrollHeight;
            } else {
                alert('Upload failed: ' + (data.message || 'Unknown error'));
            }
        } catch(e) { console.error(e); alert('Upload error'); }
    }

    document.getElementById('imgFileInput').addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (file) { await uploadMedia(file, 'image'); e.target.value = ''; }
    });
    document.getElementById('fileInput').addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (file) { await uploadMedia(file, 'file'); e.target.value = ''; }
    });

    // ── VOICE RECORDING ──────────────────────────────────
    let mediaRecorder = null, audioChunks = [];
    const voiceBtn = document.getElementById('voiceBtn');
    voiceBtn.addEventListener('click', async () => {
        if (mediaRecorder && mediaRecorder.state === 'recording') {
            mediaRecorder.stop();
            voiceBtn.classList.remove('recording');
            voiceBtn.querySelector('i').className = 'bi bi-mic';
            voiceBtn.title = 'Record Voice';
        } else {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                mediaRecorder = new MediaRecorder(stream);
                audioChunks = [];
                mediaRecorder.ondataavailable = e => audioChunks.push(e.data);
                mediaRecorder.onstop = async () => {
                    stream.getTracks().forEach(t => t.stop());
                    const blob = new Blob(audioChunks, { type: 'audio/webm' });
                    const file = new File([blob], `voice_${Date.now()}.webm`, { type: 'audio/webm' });
                    await uploadMedia(file, 'voice');
                };
                mediaRecorder.start();
                voiceBtn.classList.add('recording');
                voiceBtn.querySelector('i').className = 'bi bi-stop-circle-fill';
                voiceBtn.title = 'Stop Recording';
            } catch(e) { alert('Microphone access denied.'); }
        }
    });

    // ── WEBRTC VIDEO CALL ────────────────────────────────
    let localStream = null, callWs = null, peerConnections = {};
    const iceServers = [{ urls: 'stun:stun.l.google.com:19302' }];

    function showCallBanner(callerName, gid) {
        document.getElementById('bannerCallerName').innerText = callerName || 'A participant';
        document.getElementById('callBanner').classList.add('active');
        // Store which group the active call is in
        document.getElementById('callBanner').dataset.gid = gid;
    }
    function hideCallBanner() {
        document.getElementById('callBanner').classList.remove('active');
    }

    // Join an ongoing call (triggered from banner)
    async function joinCall() {
        hideCallBanner();
        await startCall(true); // joinOnly = true, skip broadcasting
    }

    async function startCall(joinOnly) {
        try {
            localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
            document.getElementById('localVideo').srcObject = localStream;
            document.getElementById('callOverlay').classList.add('active');

            const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
            const ctxPath = '<%= request.getContextPath() %>';
            callWs = new WebSocket(`\${protocol}//\${location.host}\${ctxPath}/callSignal/\${activeGroupId}/\${USER_ID}`);

            callWs.onmessage = async (event) => {
                const msg = JSON.parse(event.data);
                const from = msg.fromUserId;
                if (msg.type === 'offer') {
                    const pc = createPeerConnection(from);
                    await pc.setRemoteDescription(new RTCSessionDescription(msg.offer));
                    const answer = await pc.createAnswer();
                    await pc.setLocalDescription(answer);
                    callWs.send(JSON.stringify({ type: 'answer', answer, targetUserId: from }));
                } else if (msg.type === 'answer' && peerConnections[from]) {
                    await peerConnections[from].setRemoteDescription(new RTCSessionDescription(msg.answer));
                } else if (msg.type === 'ice' && peerConnections[from]) {
                    await peerConnections[from].addIceCandidate(new RTCIceCandidate(msg.candidate));
                } else if (msg.type === 'user-joined') {
                    const pc = createPeerConnection(from);
                    const offer = await pc.createOffer();
                    await pc.setLocalDescription(offer);
                    callWs.send(JSON.stringify({ type: 'offer', offer, targetUserId: from }));
                } else if (msg.type === 'user-left') {
                    if (peerConnections[from]) { peerConnections[from].close(); delete peerConnections[from]; }
                    const vid = document.getElementById(`remVid-\${from}`);
                    if (vid) vid.parentElement.remove();
                }
            };

            callWs.onopen = () => {
                callWs.send(JSON.stringify({ type: 'user-joined' }));
                // Notify group via chat WebSocket (so others see the Join banner)
                if (!joinOnly && ws && ws.readyState === WebSocket.OPEN) {
                    ws.send(JSON.stringify({
                        type: 'call-started',
                        callerName: '<%= ((com.college.attendance.model.Admin) (session.getAttribute("user") instanceof com.college.attendance.model.Admin ? session.getAttribute("user") : null)) != null ? ((com.college.attendance.model.Admin)session.getAttribute("user")).getName() : (session.getAttribute("user") instanceof com.college.attendance.model.Teacher ? ((com.college.attendance.model.Teacher)session.getAttribute("user")).getName() : "Someone") %>',
                        groupId: activeGroupId
                    }));
                }
            };

        } catch(e) { alert('Camera/mic access denied: ' + e.message); }
    }

    function createPeerConnection(remoteUserId) {
        const pc = new RTCPeerConnection({ iceServers });
        peerConnections[remoteUserId] = pc;
        localStream.getTracks().forEach(track => pc.addTrack(track, localStream));
        pc.onicecandidate = e => {
            if (e.candidate) callWs.send(JSON.stringify({ type: 'ice', candidate: e.candidate, targetUserId: remoteUserId }));
        };
        pc.ontrack = e => {
            let wrapper = document.getElementById(`vidWrap-\${remoteUserId}`);
            if (!wrapper) {
                wrapper = document.createElement('div');
                wrapper.id = `vidWrap-\${remoteUserId}`;
                wrapper.style.position = 'relative';
                const vid = document.createElement('video');
                vid.id = `remVid-\${remoteUserId}`;
                vid.autoplay = true; vid.playsinline = true;
                const label = document.createElement('span');
                label.className = 'call-label'; label.innerText = 'Participant';
                wrapper.appendChild(vid); wrapper.appendChild(label);
                document.getElementById('remoteVideosContainer').appendChild(wrapper);
            }
            document.getElementById(`remVid-\${remoteUserId}`).srcObject = e.streams[0];
        };
        return pc;
    }

    function toggleMute() {
        if (!localStream) return;
        const enabled = localStream.getAudioTracks()[0].enabled;
        localStream.getAudioTracks()[0].enabled = !enabled;
        document.getElementById('muteBtn').classList.toggle('active', enabled);
        document.getElementById('muteIcon').className = enabled ? 'bi bi-mic-mute-fill' : 'bi bi-mic-fill';
    }

    function toggleCam() {
        if (!localStream) return;
        const enabled = localStream.getVideoTracks()[0]?.enabled;
        if (localStream.getVideoTracks()[0]) localStream.getVideoTracks()[0].enabled = !enabled;
        document.getElementById('camBtn').classList.toggle('active', enabled);
        document.getElementById('camIcon').className = enabled ? 'bi bi-camera-video-off-fill' : 'bi bi-camera-video-fill';
    }

    let screenStream = null;
    async function toggleScreenShare() {
        const btn = document.getElementById('shareBtn');
        if (screenStream) {
            screenStream.getTracks().forEach(t => t.stop());
            screenStream = null;
            // Restore camera track
            const camTrack = localStream.getVideoTracks()[0];
            Object.values(peerConnections).forEach(pc => {
                const sender = pc.getSenders().find(s => s.track?.kind === 'video');
                if (sender && camTrack) sender.replaceTrack(camTrack);
            });
            document.getElementById('localVideo').srcObject = localStream;
            btn.classList.remove('active');
            document.getElementById('shareIcon').className = 'bi bi-display';
        } else {
            try {
                screenStream = await navigator.mediaDevices.getDisplayMedia({ video: true });
                const screenTrack = screenStream.getVideoTracks()[0];
                Object.values(peerConnections).forEach(pc => {
                    const sender = pc.getSenders().find(s => s.track?.kind === 'video');
                    if (sender) sender.replaceTrack(screenTrack);
                });
                document.getElementById('localVideo').srcObject = screenStream;
                btn.classList.add('active');
                document.getElementById('shareIcon').className = 'bi bi-display-fill';
                screenTrack.onended = () => toggleScreenShare();
            } catch(e) { alert('Screen share cancelled or denied.'); }
        }
    }

    function endCall() {
        // Notify group the call ended
        if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: 'call-ended' }));
        }
        if (localStream) { localStream.getTracks().forEach(t => t.stop()); localStream = null; }
        if (screenStream) { screenStream.getTracks().forEach(t => t.stop()); screenStream = null; }
        Object.values(peerConnections).forEach(pc => pc.close());
        peerConnections = {};
        if (callWs) { callWs.close(); callWs = null; }
        document.getElementById('remoteVideosContainer').innerHTML = '';
        document.getElementById('localVideo').srcObject = null;
        document.getElementById('callOverlay').classList.remove('active');
    }


</script>
</body>
</html>
