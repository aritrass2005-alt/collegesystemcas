let ws;
let currentConversationId = null;
let activeConversations = [];
let unreadCounts = {};
let peers = {}; // Map of userKey -> RTCPeerConnection
let localStream = null;
let screenStream = null;
let isVideoCall = false;
const loadedMessages = {};

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initWebSocket();
    loadConversations();
    
    // Enter key to send
    document.getElementById('messageInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendMessage();
    });
});

// Encryption Wrappers
async function encryptMessage(text, salt) {
    // Currently using the global CASEncryption which has a fixed master key
    // The salt (conversationId) can be used in the future to derive unique keys
    return await CASEncryption.encrypt(text);
}

async function decryptMessage(ciphertext, salt) {
    return await CASEncryption.decrypt(ciphertext);
}

// WebSocket
function initWebSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const host = window.location.host;
    ws = new WebSocket(`${protocol}//${host}/webapp/ws/chat`);

    ws.onmessage = async (event) => {
        const data = JSON.parse(event.data);
        handleWebSocketMessage(data);
    };

    ws.onclose = () => {
        setTimeout(initWebSocket, 3000); // Reconnect
    };
}

async function handleWebSocketMessage(data) {
    switch (data.type) {
        case 'CHAT':
            if (data.conversationId === currentConversationId) {
                const msg = {
                    ...data,
                    encryptedContent: data.content,
                    content: await decryptMessage(data.content, data.conversationId.toString()),
                    fileUrl: data.fileUrl ? await decryptMessage(data.fileUrl, data.conversationId.toString()) : null,
                    encFileUrl: data.fileUrl // preserve encrypted file url for forwarding
                };
                appendMessage(msg);
                scrollToBottom();
                
                // Send read receipt if we are looking at it
                sendReadReceipt(data.messageId);
            } else {
                // Update unread count for other group
                const item = document.querySelector(`.conversation-item[data-id="${data.conversationId}"]`);
                if (item) {
                    let badge = item.querySelector('.unread-badge');
                    if (!badge) {
                        badge = document.createElement('span');
                        badge.className = 'badge unread-badge';
                        item.querySelector('.conv-last-msg').appendChild(badge);
                    }
                    badge.textContent = parseInt(badge.textContent || 0) + 1;
                    
                    // Show notification
                    showNotification(`New message in ${item.dataset.name}`);
                }
            }
            break;
        case 'EDIT':
            console.log("[WebSocket] Received EDIT event from server:", data);
            if (data.conversationId === currentConversationId) {
                const msg = loadedMessages[data.messageId];
                if (msg) {
                    msg.content = await decryptMessage(data.content, data.conversationId.toString());
                    msg.encryptedContent = data.content;
                    msg.isEdited = true;
                    
                    const row = document.getElementById(`msg-row-${data.messageId}`);
                    if (row) {
                        const contentDiv = row.querySelector('.msg-content');
                        if (contentDiv) {
                            contentDiv.innerHTML = escapeHtml(msg.content) + ` <span class="edited-tag" style="font-size: 0.75rem; opacity: 0.5; font-style: italic; margin-left: 5px;">(edited)</span>`;
                        }
                    }
                } else {
                    console.warn("[WebSocket] EDIT message key not found in loadedMessages map for messageId:", data.messageId);
                }
            }
            break;
        case 'DELETE_FOR_EVERYONE':
            if (data.conversationId === currentConversationId) {
                const msg = loadedMessages[data.messageId];
                if (msg) {
                    msg.isDeleted = true;
                    msg.content = "This message was deleted";
                    msg.messageType = "SYSTEM";
                    msg.fileUrl = null;
                    msg.fileName = null;
                }
                
                const row = document.getElementById(`msg-row-${data.messageId}`);
                if (row) {
                    const contentDiv = row.querySelector('.msg-content');
                    if (contentDiv) {
                        contentDiv.innerHTML = `<span style="font-style: italic; opacity: 0.6;"><i class="bi bi-ban" style="margin-right: 5px;"></i> This message was deleted</span>`;
                    }
                    const timeSpan = row.querySelector('.msg-time');
                    if (timeSpan) {
                        const buttons = timeSpan.querySelectorAll('button');
                        buttons.forEach(btn => btn.remove());
                    }
                }
            }
            break;
        case 'READ_RECEIPT':
            if (data.conversationId === currentConversationId) {
                // update ticks
                const tick = document.getElementById(`status-${data.messageId}`);
                if (tick) tick.innerHTML = '<i class="bi bi-check-all"></i>';
            }
            break;
        case 'GROUP_CALL_JOIN':
            if (data.conversationId === currentConversationId) {
                if (isVideoCall) {
                    initiateMeshConnection(data.senderKey);
                } else {
                    showJoinCallBanner(data.senderName, data.conversationId, data.callType || 'video');
                }
            } else {
                const typeStr = data.callType === 'audio' ? 'voice' : 'video';
                showNotification(`${data.senderName} started a group ${typeStr} call in another group.`);
            }
            break;
        case 'MESH_OFFER':
            if (isVideoCall) handleMeshOffer(data);
            break;
        case 'MESH_ANSWER':
            if (isVideoCall) handleMeshAnswer(data);
            break;
        case 'MESH_ICE_CANDIDATE':
            if (isVideoCall) handleMeshIceCandidate(data);
            break;
        case 'GROUP_CALL_LEAVE':
            if (isVideoCall) removePeer(data.senderKey);
            break;
        case 'POLL_CREATED':
        case 'POLL_UPDATED':
            if (data.conversationId === currentConversationId && data.pollId) {
                refreshPoll(data.pollId);
            }
            break;
        case 'PIN_UPDATE':
            if (data.conversationId === currentConversationId) {
                loadPinnedMessages();
            }
            break;
    }
}

function showNotification(text) {
    if ("Notification" in window && Notification.permission === "granted") {
        new Notification("Staff Chat", { body: text });
    } else if ("Notification" in window && Notification.permission !== "denied") {
        Notification.requestPermission().then(perm => {
            if (perm === "granted") new Notification("Staff Chat", { body: text });
        });
    }
}

// API Calls
async function loadConversations() {
    const res = await fetch('chat?action=conversations');
    activeConversations = await res.json();
    // Render list (already rendered by JSP, but we can refresh here if needed)
}

function selectConversation(el) {
    document.querySelectorAll('.conversation-item').forEach(i => i.classList.remove('active'));
    el.classList.add('active');
    
    currentConversationId = parseInt(el.dataset.id);
    document.getElementById('chatEmpty').style.display = 'none';
    document.getElementById('chatMain').style.display = 'flex';
    document.getElementById('activeName').textContent = el.dataset.name;
    
    // Clear badge
    const badge = el.querySelector('.unread-badge');
    if (badge) badge.remove();
    
    loadMessages();
}

async function loadMessages() {
    const msgRes = await fetch(`chat?action=messages&convId=${currentConversationId}&limit=50&offset=0`);
    const messages = await msgRes.json();

    const pollRes = await fetch(`chat?action=getPolls&convId=${currentConversationId}`);
    const polls = await pollRes.json();
    
    const container = document.getElementById('messagesContainer');
    container.innerHTML = '';
    
    let allItems = [];
    for (let msg of messages) {
        msg.content = await decryptMessage(msg.encryptedContent, currentConversationId.toString());
        if (msg.fileUrl) {
            msg.fileUrl = await decryptMessage(msg.fileUrl, currentConversationId.toString());
        }
        allItems.push({ type: 'msg', time: new Date(msg.sentAt).getTime(), data: msg });
    }
    for (let poll of polls) {
        allItems.push({ type: 'poll', time: new Date(poll.createdAt).getTime(), data: poll });
    }
    
    allItems.sort((a, b) => a.time - b.time);
    
    for (let item of allItems) {
        if (item.type === 'msg') {
            appendMessage(item.data);
        } else if (item.type === 'poll') {
            // Note: renderPollInChat needs to just append to the container chronologically
            // appendPollMessage calls renderPollInChat, which we can just use directly since we already have the poll object
            renderPollInChat(item.data);
        }
    }
    scrollToBottom();
}

// Messaging
let selectedFile = null;

function handleFileSelect(event) {
    selectedFile = event.target.files[0];
    if (selectedFile) {
        if (selectedFile.size > 5 * 1024 * 1024) {
            alert("File is too large! Maximum size is 5MB for encryption.");
            selectedFile = null;
            return;
        }
        document.getElementById('attachmentPreview').style.display = 'flex';
        document.getElementById('attachmentName').textContent = selectedFile.name;
    }
}

function clearAttachment() {
    selectedFile = null;
    document.getElementById('fileInput').value = '';
    document.getElementById('attachmentPreview').style.display = 'none';
}

async function sendMessage() {
    const input = document.getElementById('messageInput');
    const text = input.value.trim();
    
    if (!text && !selectedFile) return;
    
    if (editingMessageId !== null) {
        console.log("[WebSocket] Preparing to send message edit request. messageId:", editingMessageId, "conversationId:", currentConversationId, "new text:", text);
        try {
            let encryptedText = await encryptMessage(text, currentConversationId.toString());
            console.log("[WebSocket] Sending EDIT payload:", {
                type: 'EDIT',
                messageId: editingMessageId,
                conversationId: currentConversationId,
                content: encryptedText
            });
            ws.send(JSON.stringify({
                type: 'EDIT',
                messageId: editingMessageId,
                conversationId: currentConversationId,
                content: encryptedText
            }));
            cancelEditMessage();
        } catch (err) {
            console.error("[WebSocket] Error trying to encrypt/send edited message:", err);
        }
        return;
    }
    
    let encryptedText = await encryptMessage(text || "Sent an attachment", currentConversationId.toString());
    let msgType = "TEXT";
    let encryptedFileUrl = null;
    
    if (selectedFile) {
        const reader = new FileReader();
        reader.onload = async (e) => {
            const base64Url = e.target.result;
            encryptedFileUrl = await encryptMessage(base64Url, currentConversationId.toString());
            msgType = selectedFile.type.startsWith('image/') ? 'PHOTO' : 'FILE';
            
            sendWsMessage(encryptedText, msgType, encryptedFileUrl, selectedFile.name);
            clearAttachment();
        };
        reader.readAsDataURL(selectedFile);
    } else {
        sendWsMessage(encryptedText, msgType, null, null);
    }
    
    input.value = '';
}

function sendWsMessage(encText, type, encFile, fileName) {
    const msg = {
        type: 'CHAT',
        conversationId: currentConversationId,
        content: encText,
        messageType: type
    };
    if (encFile) {
        msg.fileUrl = encFile;
        msg.fileName = fileName;
    }
    ws.send(JSON.stringify(msg));
}

function appendMessage(msg) {
    const isMe = msg.senderId === MY_ID && msg.senderRole === MY_ROLE;
    const time = new Date(msg.sentAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    
    let contentHtml = escapeHtml(msg.content);
    const deletedForEveryone = msg.isDeleted || msg.deleted;
    if (deletedForEveryone) {
        contentHtml = `<span style="font-style: italic; opacity: 0.6;"><i class="bi bi-ban" style="margin-right: 5px;"></i> This message was deleted</span>`;
    } else {
        if (msg.isEdited) {
            contentHtml += ` <span class="edited-tag" style="font-size: 0.75rem; opacity: 0.5; font-style: italic; margin-left: 5px;">(edited)</span>`;
        }

        if (msg.messageType === 'PHOTO' && msg.fileUrl) {
            contentHtml = `<img src="${msg.fileUrl}" class="msg-photo"><br>` + contentHtml;
        } else if (msg.messageType === 'AUDIO' && msg.fileUrl) {
            contentHtml = `<audio src="${msg.fileUrl}" controls class="msg-audio"></audio><br>` + contentHtml;
        } else if (msg.messageType === 'FILE' && msg.fileUrl) {
            contentHtml = `<a href="${msg.fileUrl}" download="${msg.fileName}" class="msg-attachment"><i class="bi bi-file-earmark"></i> ${msg.fileName}</a><br>` + contentHtml;
        }
    }

    let statusHtml = '';
    if (isMe) {
        statusHtml = `<span class="msg-status" id="status-${msg.messageId || msg.id}">`;
        if (msg.status === 'READ') statusHtml += '<i class="bi bi-check-all"></i>';
        else if (msg.status === 'DELIVERED') statusHtml += '<i class="bi bi-check"></i>';
        else statusHtml += '<i class="bi bi-check"></i>';
        statusHtml += `</span>`;
    }

    const forwardHtml = deletedForEveryone ? '' : `<button class="icon-btn" style="font-size:0.8rem; padding:0; margin-left:10px;" onclick="showForwardModal(${msg.messageId || msg.id})"><i class="bi bi-reply-fill" style="transform: scaleX(-1); display:inline-block;"></i></button>`;
    
    let editHtml = '';
    if (!deletedForEveryone && isMe && msg.messageType === 'TEXT') {
        editHtml = `<button class="icon-btn" style="font-size:0.8rem; padding:0; margin-left:10px;" onclick="startEditMessage(${msg.messageId || msg.id})" title="Edit Message"><i class="bi bi-pencil-fill"></i></button>`;
    }

    let deleteHtml = '';
    if (!deletedForEveryone) {
        const canDeleteForEveryone = isMe || (MY_ROLE === "SuperAdmin");
        deleteHtml = `<button class="icon-btn" style="font-size:0.8rem; padding:0; margin-left:10px; color: var(--text-muted);" onclick="showDeleteModal(${msg.messageId || msg.id}, ${canDeleteForEveryone})" title="Delete Message"><i class="bi bi-trash"></i></button>`;
    }

    let pinHtml = '';
    if (!deletedForEveryone) {
        pinHtml = `<button class="icon-btn pin-action-btn" style="font-size:0.7rem; padding:0; margin-left:8px; color:#f59e0b;" onclick="pinMessage(${msg.messageId || msg.id})" title="Pin Message"><i class="bi bi-pin-angle"></i></button>`;
    }

    // Store in map for forwarding, editing and deletions
    loadedMessages[msg.messageId || msg.id] = msg;

    const html = `
        <div class="message-row ${isMe ? 'sent' : 'received'}" id="msg-row-${msg.messageId || msg.id}">
            <div class="message-bubble">
                <span class="msg-sender">${msg.senderName}</span>
                <div class="msg-content">${contentHtml}</div>
                <span class="msg-time">${time} ${statusHtml} ${forwardHtml} ${editHtml} ${deleteHtml} ${pinHtml}</span>
            </div>
        </div>
    `;
    
    document.getElementById('messagesContainer').insertAdjacentHTML('beforeend', html);
}

function scrollToBottom() {
    const c = document.getElementById('messagesContainer');
    c.scrollTop = c.scrollHeight;
}

function sendReadReceipt(messageId) {
    ws.send(JSON.stringify({
        type: 'READ_RECEIPT',
        conversationId: currentConversationId,
        messageId: messageId
    }));
}

function escapeHtml(text) {
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// Group Admin Functions
function showNewDeptGroupModal() { document.getElementById('newDeptGroupModal').style.display = 'flex'; }
function showAddMemberModal() { document.getElementById('addMemberModal').style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

async function createDepartmentGroup() {
    const dept = document.getElementById('newDeptSelect').value;
    if (!dept) {
        alert("Please select a valid department.");
        return;
    }
    const res = await fetch('chat', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({action: 'createDepartment', department: dept})
    });
    const json = await res.json();
    if (json.success) {
        location.reload();
    } else {
        alert("Failed to create group: " + (json.error || "Unknown error"));
    }
}

async function addMember() {
    const role = document.getElementById('addMemberRole').value;
    const email = document.getElementById('addMemberEmail').value;
    if (!email) { alert("Please enter an email address"); return; }
    
    const res = await fetch('chat', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({action: 'addMember', convId: currentConversationId, memberRole: role, memberEmail: email})
    });
    const json = await res.json();
    if (json.success) {
        alert("Member added!");
        closeModal('addMemberModal');
        // Refresh the page or reload group info to show the new member
        window.location.reload();
    } else {
        alert("Failed to add member: " + (json.error || "Unknown error"));
    }
}

async function deleteCurrentGroup() {
    if (!confirm("Are you sure you want to delete this group?")) return;
    const res = await fetch('chat', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({action: 'deleteGroup', convId: currentConversationId})
    });
    const json = await res.json();
    if (json.success) location.reload();
}

// WebRTC Group Mesh Networking
const rtcConfig = { iceServers: [{ urls: 'stun:stun.l.google.com:19302' }] };

function showJoinCallBanner(callerName, convId, callType) {
    let banner = document.getElementById('joinCallBanner');
    if (!banner) {
        banner = document.createElement('div');
        banner.id = 'joinCallBanner';
        banner.style.cssText = 'background: var(--primary); color: white; padding: 10px 20px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border);';
        
        const text = document.createElement('span');
        text.id = 'joinCallText';
        
        const joinBtn = document.createElement('button');
        joinBtn.id = 'joinCallBtn';
        joinBtn.className = 'btn-primary';
        joinBtn.style.background = 'white';
        joinBtn.style.color = 'var(--primary)';
        
        banner.appendChild(text);
        banner.appendChild(joinBtn);
        
        const header = document.querySelector('.chat-header');
        header.parentNode.insertBefore(banner, header.nextSibling);
    }
    
    const isAudio = callType === 'audio';
    const typeStr = isAudio ? 'voice' : 'video';
    const icon = isAudio ? '<i class="bi bi-telephone-fill"></i>' : '<i class="bi bi-camera-video-fill"></i>';
    
    document.getElementById('joinCallText').textContent = `${callerName} has started a group ${typeStr} call.`;
    
    const joinBtn = document.getElementById('joinCallBtn');
    joinBtn.innerHTML = `${icon} Join Call`;
    joinBtn.onclick = () => {
        banner.style.display = 'none';
        startGroupCall(callType);
    };
    
    banner.style.display = 'flex';
}

async function startGroupCall(type) {
    isVideoCall = true;
    document.getElementById('videoCallContainer').style.display = 'flex';
    document.getElementById('toggleVideoBtn').style.display = type === 'video' ? 'inline-block' : 'none';
    document.getElementById('shareScreenBtn').style.display = 'inline-block';
    document.getElementById('callStatus').textContent = 'Connected';
    
    const banner = document.getElementById('joinCallBanner');
    if (banner) banner.style.display = 'none';
    
    try {
        localStream = await navigator.mediaDevices.getUserMedia({ 
            audio: true, 
            video: type === 'video' 
        });
        document.getElementById('localVideo').srcObject = localStream;
    } catch (e) {
        console.warn("Could not access camera/microphone. Proceeding as receive-only.", e);
        // We proceed without localStream so the user can still watch/listen to others
    }
    
    ws.send(JSON.stringify({
        type: 'GROUP_CALL_JOIN',
        conversationId: currentConversationId,
        callType: type
    }));
}

function createPeerConnection(targetKey) {
    const pc = new RTCPeerConnection(rtcConfig);
    peers[targetKey] = pc;
    
    // Add local tracks
    if (localStream) {
        localStream.getTracks().forEach(t => pc.addTrack(t, localStream));
    }
    
    pc.onicecandidate = (e) => {
        if (e.candidate) {
            ws.send(JSON.stringify({
                type: 'MESH_ICE_CANDIDATE',
                targetKey: targetKey,
                candidate: e.candidate
            }));
        }
    };
    
    pc.ontrack = (e) => {
        let wrapper = document.getElementById(`video-wrapper-${targetKey}`);
        if (!wrapper) {
            wrapper = document.createElement('div');
            wrapper.className = 'video-wrapper';
            wrapper.id = `video-wrapper-${targetKey}`;
            
            const vid = document.createElement('video');
            vid.autoplay = true;
            vid.playsinline = true;
            vid.id = `video-${targetKey}`;
            vid.srcObject = e.streams[0];
            
            const label = document.createElement('span');
            label.className = 'video-label';
            label.textContent = "Peer"; // would need sender name lookup ideally
            
            wrapper.appendChild(vid);
            wrapper.appendChild(label);
            document.getElementById('videoGrid').appendChild(wrapper);
        }
    };
    
    return pc;
}

async function initiateMeshConnection(targetKey) {
    const pc = createPeerConnection(targetKey);
    const offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    
    ws.send(JSON.stringify({
        type: 'MESH_OFFER',
        targetKey: targetKey,
        offer: offer
    }));
}

async function handleMeshOffer(data) {
    const pc = createPeerConnection(data.senderKey);
    await pc.setRemoteDescription(new RTCSessionDescription(data.offer));
    
    const answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    
    ws.send(JSON.stringify({
        type: 'MESH_ANSWER',
        targetKey: data.senderKey,
        answer: answer
    }));
}

async function handleMeshAnswer(data) {
    const pc = peers[data.senderKey];
    if (pc) {
        await pc.setRemoteDescription(new RTCSessionDescription(data.answer));
    }
}

async function handleMeshIceCandidate(data) {
    const pc = peers[data.senderKey];
    if (pc) {
        await pc.addIceCandidate(new RTCIceCandidate(data.candidate));
    }
}

function removePeer(targetKey) {
    if (peers[targetKey]) {
        peers[targetKey].close();
        delete peers[targetKey];
    }
    const wrapper = document.getElementById(`video-wrapper-${targetKey}`);
    if (wrapper) wrapper.remove();
}

function endGroupCall() {
    isVideoCall = false;
    document.getElementById('videoCallContainer').style.display = 'none';
    
    if (localStream) {
        localStream.getTracks().forEach(t => t.stop());
        localStream = null;
    }
    if (screenStream) {
        screenStream.getTracks().forEach(t => t.stop());
        screenStream = null;
    }
    
    for (let key in peers) {
        peers[key].close();
    }
    peers = {};
    
    // Remove all remote videos
    document.querySelectorAll('.video-wrapper:not(.local)').forEach(el => el.remove());
    
    ws.send(JSON.stringify({
        type: 'GROUP_CALL_LEAVE',
        conversationId: currentConversationId
    }));
}

function toggleMute() {
    if (localStream) {
        const audioTrack = localStream.getAudioTracks()[0];
        if (audioTrack) {
            audioTrack.enabled = !audioTrack.enabled;
            document.getElementById('toggleMuteBtn').style.background = audioTrack.enabled ? 'rgba(255,255,255,0.2)' : 'var(--danger)';
        }
    }
}

function toggleVideo() {
    if (localStream) {
        const videoTrack = localStream.getVideoTracks()[0];
        if (videoTrack) {
            videoTrack.enabled = !videoTrack.enabled;
            document.getElementById('toggleVideoBtn').style.background = videoTrack.enabled ? 'rgba(255,255,255,0.2)' : 'var(--danger)';
        }
    }
}

async function toggleScreenShare() {
    if (!screenStream) {
        try {
            screenStream = await navigator.mediaDevices.getDisplayMedia({ video: true });
            const screenTrack = screenStream.getVideoTracks()[0];
            
            // Replace track in all peers
            for (let key in peers) {
                const pc = peers[key];
                const sender = pc.getSenders().find(s => s.track.kind === 'video');
                if (sender) sender.replaceTrack(screenTrack);
            }
            
            document.getElementById('localVideo').srcObject = screenStream;
            
            screenTrack.onended = () => {
                stopScreenShare();
            };
        } catch (e) {
            console.error("Screen share failed", e);
        }
    } else {
        stopScreenShare();
    }
}

function stopScreenShare() {
    if (screenStream) {
        screenStream.getTracks().forEach(t => t.stop());
        screenStream = null;
    }
    if (localStream) {
        const videoTrack = localStream.getVideoTracks()[0];
        for (let key in peers) {
            const pc = peers[key];
            const sender = pc.getSenders().find(s => s.track.kind === 'video');
            if (sender && videoTrack) sender.replaceTrack(videoTrack);
        }
        document.getElementById('localVideo').srcObject = localStream;
    }
}

// Forwarding Logic
let messageToForwardId = null;

function showForwardModal(messageId) {
    messageToForwardId = messageId;
    document.getElementById('forwardModal').style.display = 'flex';
}

function executeForward() {
    const targetConvId = document.getElementById('forwardSelect').value;
    const msgObj = loadedMessages[messageToForwardId];
    if (!targetConvId || !msgObj) return;
    
    (async () => {
        try {
            // Re-encrypt content for the target conversation ID
            const rawContent = await decryptMessage(msgObj.encryptedContent, currentConversationId.toString());
            const reEncryptedContent = await encryptMessage(rawContent, targetConvId);
            
            let reEncryptedFile = null;
            if (msgObj.encFileUrl) {
                const rawFile = await decryptMessage(msgObj.encFileUrl, currentConversationId.toString());
                reEncryptedFile = await encryptMessage(rawFile, targetConvId);
            }
            
            const msg = {
                type: 'CHAT',
                conversationId: parseInt(targetConvId),
                content: reEncryptedContent,
                messageType: msgObj.messageType
            };
            if (reEncryptedFile) {
                msg.fileUrl = reEncryptedFile;
                msg.fileName = msgObj.fileName;
            }
            ws.send(JSON.stringify(msg));
            
            closeModal('forwardModal');
            alert("Message forwarded!");
        } catch(e) {
            alert("Failed to forward: " + e.message);
        }
    })();
}

// Voice Note Recording Logic
let mediaRecorder = null;
let audioChunks = [];
let recordingInterval = null;
let recordingSeconds = 0;
let isRecording = false;

async function toggleVoiceRecording() {
    if (!isRecording) {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            audioChunks = [];
            mediaRecorder = new MediaRecorder(stream);
            
            mediaRecorder.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    audioChunks.push(event.data);
                }
            };
            
            mediaRecorder.onstop = async () => {
                if (audioChunks.length > 0) {
                    const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
                    const reader = new FileReader();
                    reader.onloadend = async () => {
                        const base64Url = reader.result;
                        const encryptedAudio = await encryptMessage(base64Url, currentConversationId.toString());
                        const encryptedText = await encryptMessage("Voice Message", currentConversationId.toString());
                        
                        sendWsMessage(encryptedText, 'AUDIO', encryptedAudio, "voice_message.webm");
                    };
                    reader.readAsDataURL(audioBlob);
                }
                stream.getTracks().forEach(t => t.stop());
            };
            
            mediaRecorder.start();
            isRecording = true;
            
            document.getElementById('messageInput').style.display = 'none';
            document.getElementById('recordingUI').style.display = 'flex';
            document.getElementById('micBtn').innerHTML = '<i class="bi bi-stop-circle-fill" style="color: var(--danger);"></i>';
            document.getElementById('micBtn').title = "Stop and Send Voice Message";
            
            recordingSeconds = 0;
            document.getElementById('recordingTimer').textContent = "0:00";
            recordingInterval = setInterval(() => {
                recordingSeconds++;
                const mins = Math.floor(recordingSeconds / 60);
                const secs = recordingSeconds % 60;
                document.getElementById('recordingTimer').textContent = `${mins}:${secs < 10 ? '0' : ''}${secs}`;
            }, 1000);
            
        } catch (err) {
            console.error("Failed to access microphone", err);
            alert("Could not access microphone. Please check permissions.");
        }
    } else {
        stopRecording(false);
    }
}

function stopRecording(cancelled) {
    if (isRecording) {
        clearInterval(recordingInterval);
        isRecording = false;
        
        if (cancelled) {
            audioChunks = [];
        }
        
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
            mediaRecorder.stop();
        }
        
        document.getElementById('messageInput').style.display = 'block';
        document.getElementById('recordingUI').style.display = 'none';
        document.getElementById('micBtn').innerHTML = '<i class="bi bi-mic-fill"></i>';
        document.getElementById('micBtn').title = "Record Voice Message";
    }
}

function cancelRecording() {
    stopRecording(true);
}

// Edit Message Logic
let editingMessageId = null;

function startEditMessage(messageId) {
    const msg = loadedMessages[messageId];
    if (!msg) return;
    
    editingMessageId = messageId;
    
    // Populate text input
    const input = document.getElementById('messageInput');
    input.value = msg.content;
    input.focus();
    
    // Show edit banner
    document.getElementById('editMessageBanner').style.display = 'flex';
    
    // Hide attachment option (can't attach files to edited messages)
    const fileLabel = document.querySelector('label[for="fileInput"]');
    if (fileLabel) {
        fileLabel.style.opacity = '0.3';
        fileLabel.style.pointerEvents = 'none';
    }
}

function cancelEditMessage() {
    editingMessageId = null;
    
    const input = document.getElementById('messageInput');
    input.value = '';
    
    // Hide edit banner
    document.getElementById('editMessageBanner').style.display = 'none';
    
    // Restore attachment option
    const fileLabel = document.querySelector('label[for="fileInput"]');
    if (fileLabel) {
        fileLabel.style.opacity = '1';
        fileLabel.style.pointerEvents = 'auto';
    }
}

// Delete Message Logic
let messageToDeleteId = null;

function showDeleteModal(messageId, canDeleteForEveryone) {
    messageToDeleteId = messageId;
    const deleteForEveryoneBtn = document.getElementById('deleteForEveryoneBtn');
    if (deleteForEveryoneBtn) {
        deleteForEveryoneBtn.style.display = canDeleteForEveryone ? 'block' : 'none';
    }
    document.getElementById('deleteMessageModal').style.display = 'flex';
}

function executeDeleteForMe() {
    if (!messageToDeleteId) return;
    ws.send(JSON.stringify({
        type: 'DELETE_FOR_ME',
        messageId: messageToDeleteId
    }));
    
    // Remove the message row from the DOM locally
    const row = document.getElementById(`msg-row-${messageToDeleteId}`);
    if (row) row.remove();
    
    closeModal('deleteMessageModal');
    messageToDeleteId = null;
}

function executeDeleteForEveryone() {
    if (!messageToDeleteId) return;
    ws.send(JSON.stringify({
        type: 'DELETE_FOR_EVERYONE',
        messageId: messageToDeleteId,
        conversationId: currentConversationId
    }));
    
    closeModal('deleteMessageModal');
    messageToDeleteId = null;
}

