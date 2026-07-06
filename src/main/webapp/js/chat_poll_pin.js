// ======================== POLL LOGIC ========================

function showPollModal() {
    if (!currentConversationId) { alert('Select a chat group first.'); return; }
    document.getElementById('pollQuestion').value = '';
    const container = document.getElementById('pollOptionsContainer');
    container.innerHTML = '';
    addPollOptionField('Option 1');
    addPollOptionField('Option 2');
    document.getElementById('pollModal').style.display = 'flex';
}

function addPollOption() {
    const container = document.getElementById('pollOptionsContainer');
    const count = container.querySelectorAll('.poll-option-input').length + 1;
    addPollOptionField('Option ' + count);
}

function addPollOptionField(placeholder) {
    const container = document.getElementById('pollOptionsContainer');
    const count = container.querySelectorAll('.poll-option-input').length + 1;
    const div = document.createElement('div');
    div.className = 'form-group poll-option-row';
    div.innerHTML = '<label>Option ' + count + '</label><input type="text" class="poll-option-input" placeholder="' + placeholder + '" maxlength="200">';
    container.appendChild(div);
}

async function submitPoll() {
    const question = document.getElementById('pollQuestion').value.trim();
    const optInputs = document.querySelectorAll('.poll-option-input');
    const opts = Array.from(optInputs).map(i => i.value.trim()).filter(v => v.length > 0);
    if (!question) { alert('Please enter a question.'); return; }
    if (opts.length < 2) { alert('Please provide at least 2 options.'); return; }

    const params = new URLSearchParams({ action: 'createPoll', convId: currentConversationId, question });
    opts.forEach(o => params.append('options[]', o));

    const res = await fetch('chat', { method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: params });
    const json = await res.json();
    if (json.success) {
        closeModal('pollModal');
        ws.send(JSON.stringify({ type: 'POLL_CREATED', conversationId: currentConversationId, pollId: json.pollId }));
        await appendPollMessage(json.pollId);
    } else {
        alert('Failed to create poll: ' + (json.error || 'Unknown error'));
    }
}

async function appendPollMessage(pollId) {
    const res = await fetch('chat?action=getPoll&pollId=' + pollId);
    const poll = await res.json();
    if (!poll || poll.error) return;
    renderPollInChat(poll);
}

function renderPollInChat(poll) {
    const container = document.getElementById('messagesContainer');
    const existing = document.getElementById('poll-card-' + poll.id);
    if (existing) {
        existing.outerHTML = buildPollCardHtml(poll);
        return;
    }
    const wrapper = document.createElement('div');
    wrapper.className = 'message-row received';
    wrapper.id = 'poll-msg-' + poll.id;
    wrapper.innerHTML = buildPollCardHtml(poll);
    container.appendChild(wrapper);
    scrollToBottom();
}

function buildPollCardHtml(poll) {
    const totalVotes = poll.options ? poll.options.reduce(function(s, o) { return s + o.voteCount; }, 0) : 0;
    const isClosed = poll.closed;
    const myVote = poll.myVotedOptionId;

    let optionsHtml = '';
    if (poll.options) {
        poll.options.forEach(function(opt) {
            const pct = totalVotes > 0 ? Math.round((opt.voteCount / totalVotes) * 100) : 0;
            const isVoted = myVote === opt.id;
            const checkIcon = isVoted ? '<i class="bi bi-check-circle-fill" style="color:#a78bfa;z-index:1;flex-shrink:0;"></i>' : '';
            const onclickAttr = isClosed ? '' : 'onclick="votePoll(' + poll.id + ', ' + opt.id + ')"';
            optionsHtml += '<button class="poll-option-btn ' + (isVoted ? 'voted' : '') + '" ' + onclickAttr +
                ' style="cursor:' + (isClosed ? 'default' : 'pointer') + ';" title="' + (isClosed ? 'Poll is closed' : 'Click to vote') + '">' +
                '<div class="vote-bar" style="width:' + pct + '%"></div>' +
                checkIcon +
                '<span>' + escapeHtml(opt.optionText) + '</span>' +
                '<span class="vote-pct">' + pct + '%</span>' +
                '</button>';
        });
    }

    const canClose = !isClosed && (MY_ROLE === 'SuperAdmin' || MY_ROLE === 'Admin' ||
        (poll.createdByRole === MY_ROLE && poll.createdById === MY_ID));
    const closeBtnHtml = canClose ? '<button class="poll-close-btn" onclick="closePoll(' + poll.id + ')">Close Poll</button>' : '';

    return '<div class="poll-card" id="poll-card-' + poll.id + '">' +
        '<div class="poll-question"><i class="bi bi-bar-chart-fill"></i>' + escapeHtml(poll.question) + '</div>' +
        optionsHtml +
        '<div class="poll-meta">' +
        '<span>' + totalVotes + ' vote' + (totalVotes !== 1 ? 's' : '') + '</span>' +
        (isClosed ? '<span class="poll-closed-badge"><i class="bi bi-lock-fill"></i> Closed</span>' : '') +
        closeBtnHtml +
        '</div></div>';
}

async function votePoll(pollId, optionId) {
    const res = await fetch('chat', {
        method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({ action: 'votePoll', pollId: pollId, optionId: optionId })
    });
    const json = await res.json();
    if (json.success && json.poll) {
        renderPollInChat(json.poll);
        ws.send(JSON.stringify({ type: 'POLL_UPDATED', conversationId: currentConversationId, pollId: pollId }));
    }
}

async function closePoll(pollId) {
    if (!confirm('Close this poll? No more votes will be accepted.')) return;
    const res = await fetch('chat', {
        method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({ action: 'closePoll', pollId: pollId })
    });
    const json = await res.json();
    if (json.success) {
        ws.send(JSON.stringify({ type: 'POLL_UPDATED', conversationId: currentConversationId, pollId: pollId }));
        await refreshPoll(pollId);
    }
}

async function refreshPoll(pollId) {
    const res = await fetch('chat?action=getPoll&pollId=' + pollId);
    const poll = await res.json();
    if (poll && !poll.error) renderPollInChat(poll);
}

// ======================== PIN LOGIC ========================

var pinnedPanelOpen = false;

async function togglePinnedPanel() {
    pinnedPanelOpen = !pinnedPanelOpen;
    const panel = document.getElementById('pinnedPanel');
    panel.style.display = pinnedPanelOpen ? 'block' : 'none';
    if (pinnedPanelOpen) await loadPinnedMessages();
}

async function loadPinnedMessages() {
    if (!currentConversationId) return;
    const res = await fetch('chat?action=getPinnedMessages&convId=' + currentConversationId);
    const pinned = await res.json();
    const list = document.getElementById('pinnedList');
    const badge = document.getElementById('pinnedCount');
    if (pinned && pinned.length > 0) {
        badge.textContent = pinned.length;
        badge.style.display = 'inline-block';
    } else {
        badge.style.display = 'none';
    }
    if (!pinned || !pinned.length) {
        list.innerHTML = '<p style="color:var(--text-muted);padding:15px;text-align:center;">No pinned messages yet.</p>';
        return;
    }
    let html = '';
    for (const msg of pinned) {
        let content = '(attachment)';
        if (msg.encryptedContent) {
            try { content = await decryptMessage(msg.encryptedContent, currentConversationId.toString()); } catch(e) {}
        }
        const senderName = msg.senderName || 'Unknown';
        html += '<div class="pinned-item" id="pinned-item-' + msg.id + '">' +
            '<i class="bi bi-pin-fill" style="color:#f59e0b;flex-shrink:0;margin-top:3px;"></i>' +
            '<div class="pinned-item-content">' +
            '<div class="pinned-item-sender">' + escapeHtml(senderName) + '</div>' +
            '<div class="pinned-item-text">' + escapeHtml(content.substring(0, 120)) + (content.length > 120 ? '…' : '') + '</div>' +
            '</div>' +
            '<div class="pinned-item-actions">' +
            '<button onclick="unpinMessage(' + msg.id + ')" title="Unpin"><i class="bi bi-x-lg"></i></button>' +
            '</div></div>';
    }
    list.innerHTML = html;
}

async function pinMessage(messageId) {
    const res = await fetch('chat', {
        method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({ action: 'pinMessage', convId: currentConversationId, messageId: messageId })
    });
    const json = await res.json();
    if (json.success) {
        ws.send(JSON.stringify({ type: 'PIN_UPDATE', conversationId: currentConversationId }));
        await loadPinnedMessages();
    } else { alert('Could not pin message.'); }
}

async function unpinMessage(messageId) {
    const res = await fetch('chat', {
        method: 'POST', headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({ action: 'unpinMessage', convId: currentConversationId, messageId: messageId })
    });
    const json = await res.json();
    if (json.success) {
        const item = document.getElementById('pinned-item-' + messageId);
        if (item) item.remove();
        ws.send(JSON.stringify({ type: 'PIN_UPDATE', conversationId: currentConversationId }));
        await loadPinnedMessages();
    }
}
