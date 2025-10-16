function patchList(container, items, {
    key,
    create,
    update,
    itemSelector = ':scope > *',
    keepSelection = false,
    selectedClass = 'selected'
}) {
    if (!container) return;

    let selectedKey = null;
    if (keepSelection) {
        const selectedEl = container.querySelector(`.${selectedClass}`);
        if (selectedEl) selectedKey = selectedEl.dataset.uid || selectedEl.dataset.key || null;
    }

    const existing = new Map();
    container.querySelectorAll(itemSelector).forEach(el => {
        const k = el.dataset.uid || el.dataset.key;
        if (k) existing.set(k, el);
    });

    const frag = document.createDocumentFragment();

    for (const item of items) {
        const k = key(item);
        let el = existing.get(k);
        if (!el) {
            el = create(item);
            if (!el.dataset.uid && !el.dataset.key) el.dataset.uid = k;
        } else {
            update(el, item);
            existing.delete(k);
        }
        frag.appendChild(el);
    }

    for (const el of existing.values()) el.remove();

    container.replaceChildren(frag);

    if (keepSelection && selectedKey) {
        const el = container.querySelector(`[data-uid="${selectedKey}"], [data-key="${selectedKey}"]`);
        if (el) el.classList.add(selectedClass);
    }
}

function createTimedOutListItem(timeout, listEl) {
    const li = document.createElement('li');
    li.className = 'timeout-item';
    li.dataset.uid = timeout.uid;

    const row = document.createElement('div');
    row.className = 'timeout-row';

    const uidEl = document.createElement('span');
    uidEl.className = 'timeout-uid';
    uidEl.textContent = timeout.uid;

    const endEl = document.createElement('span');
    endEl.className = 'timeout-end';
    endEl.textContent = timeout.end;

    const clearBtn = document.createElement('button');
    clearBtn.className = 'timeout-clear';
    clearBtn.textContent = 'Clear';
    clearBtn.addEventListener('click', () => {
        A3API.SendAlert(`["clearTimeout", "${timeout.uid}"]`);
    });

    row.appendChild(uidEl);
    row.appendChild(endEl);
    row.appendChild(clearBtn);
    li.appendChild(row);

    return li;
}

function updateTimedOutListItem(li, timeout) {
    li.dataset.uid = timeout.uid;

    const uidEl = li.querySelector('.timeout-uid');
    if (uidEl && uidEl.textContent !== timeout.uid)
        uidEl.textContent = timeout.uid;

    const endEl = li.querySelector('.timeout-end');
    if (endEl && endEl.textContent !== timeout.end)
        endEl.textContent = timeout.end;
}

function updateTimeouts(timeoutData) {
    timeoutData = JSON.parse(timeoutData || '[]');

    const listEl = document.getElementById('timeout-records');
    if (!listEl) return;

    const items = timeoutData.map(([uid, end]) => ({ uid, end }));

    patchList(listEl, items, {
        key: i => i.uid, // one per player
        create: i => createTimedOutListItem(i, listEl),
        update: updateTimedOutListItem,
        itemSelector: '.timeout-item',
        keepSelection: true,
        selectedClass: 'selected'
    });
}

function createPlayerListItem(player, listEl) {
    const li = document.createElement('li');
    li.className = 'player-item';
    li.dataset.uid = player.uid;

    const row = document.createElement('div');
    row.className = 'player-row';

    const nameEl = document.createElement('span');
    nameEl.className = 'player-name';
    nameEl.textContent = player.name;

    const reportsEl = document.createElement('div');
    reportsEl.className = 'player-reports';
    reportsEl.textContent = player.reports ? `${player.reports}` : '';

    row.appendChild(nameEl);
    row.appendChild(reportsEl);

    const aliasesEl = document.createElement('div');
    aliasesEl.className = 'player-aliases';
    aliasesEl.textContent = player.aliases.length
        ? `AKA: ${player.aliases.join(', ')}`
        : '';

    li.appendChild(row);
    li.appendChild(aliasesEl);

    li.addEventListener('click', () => selectPlayer(player, listEl));
    return li;
}

function updatePlayerListItem(li, player) {
    li.dataset.id = String(player.id ?? '');
    li.querySelector('.player-name').textContent = player.name;
    li.querySelector('.player-reports').textContent = player.reports ? `${player.reports}` : '';
    li.querySelector('.player-aliases').textContent = player.aliases.length
        ? `AKA: ${player.aliases.join(', ')}`
        : '';
}

function updatePlayers(playerData) {
    playerData = JSON.parse(playerData || '[]');
    const listEl = document.getElementById('player-list');
    const players = playerData.map(p => ({
        uid: p[0],
        name: p[1],
        aliases: p[2],
        reports: p[3]
    }));

    patchList(listEl, players, {
        key: p => p.uid,
        create: p => createPlayerListItem(p, listEl),
        update: updatePlayerListItem,
        itemSelector: '.player-item',
        keepSelection: true,
        selectedClass: 'selected',
        stickToBottom: false,
    });
}

function selectPlayer(player, listEl) {
    const prev = listEl.querySelector('.player-item.selected');
    if (prev) prev.classList.remove('selected');
    const el = listEl.querySelector(`.player-item[data-uid="${player.uid}"]`);
    if (el) el.classList.add('selected');
    A3API.SendAlert(`["select", "${player.uid}"]`);
}

function updatePlayerInfo(playerInfo) {
    playerInfo = JSON.parse(playerInfo || '[]');
    const playerUid = playerInfo[0] || '';
    document.selectedPlayer = playerUid;
    const playerName = playerInfo[1] || '';
    document.selectedPlayerName = playerName;
    const systemTime = playerInfo[2] || '';

    const nameEl = document.getElementById('selected-player-name');
    nameEl.textContent = playerName;

    const infoEl = document.getElementById('player-info');
    const beid = uidToBeGuid(playerUid);
    const displayString = `[NAME] ${playerName}\n[BEID] ${beid}\n[GUID] ${playerUid}\n[TIME] ${systemTime}`;
    infoEl.value = displayString;

    const reportList = document.getElementById('player-reports');
    reportList.innerHTML = '';
    for (const [from, reason] of playerInfo[3]) {
        const li = document.createElement('li');
        li.className = 'report-item';
        li.innerHTML = `<span class="report-from">By: ${from}</span> <span class="report-reason">${reason}</span>`;
        reportList.appendChild(li);
    }

    changeButtons();
    document.querySelector('.player-details-panel').style.display = 'flex';
}

function makeChatUid(timestamp, channel, player, text) {
    return `${timestamp}||${channel}||${player}||${text}`;
}

function createChatMsgItem(msg) {
    const { timestamp, channel, player, text, uid } = msg;

    const li = document.createElement('li');
    li.className = 'chat-msg';
    li.dataset.uid = uid;
    li.dataset.channel = channel;
    li.dataset.player = player;

    const timeEl = document.createElement('span');
    timeEl.className = 'chat-time';
    timeEl.textContent = timestamp;

    const channelEl = document.createElement('span');
    channelEl.className = 'chat-channel';
    channelEl.dataset.channel = channel;
    channelEl.textContent = channel;
    channelEl.addEventListener('click', () => filterChatByChannel(channel));

    const playerEl = document.createElement('span');
    playerEl.className = 'chat-player';
    playerEl.dataset.player = player;
    playerEl.textContent = player;
    playerEl.addEventListener('click', () => filterChatByPlayer(player));

    if (player) {
        playerEl.style.visibility = 'visible';
    } else {
        playerEl.style.visibility = 'hidden';
    }

    const textEl = document.createElement('span');
    textEl.className = 'chat-text';
    textEl.textContent = text;

    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.className = 'chat-select';

    checkbox.addEventListener('click', (e) => {
        const copyChatBtn = document.getElementById('btn-copy-chat');
        const selectedCount = document.querySelectorAll('.chat-select:checked').length;
        if (selectedCount > 0) {
            copyChatBtn.style.fontWeight = 'bold';
        } else {
            copyChatBtn.style.fontWeight = 'normal';
        }

        copyChatBtn.textContent = `Copy chat (${selectedCount})`;
    });

    li.append(timeEl, channelEl, playerEl, textEl, checkbox);
    li.addEventListener('click', (e) => {
        if (e.target !== checkbox) {
            checkbox.checked = !checkbox.checked;
        }
        checkbox.dispatchEvent(new Event('click'));
    });
    return li;
}

function updateChatMsgItem(li, msg) {
    const { timestamp, channel, player, text } = msg;

    li.dataset.channel = channel;
    li.dataset.player = player;

    const timeEl = li.querySelector('.chat-time');
    if (timeEl && timeEl.textContent !== String(timestamp)) timeEl.textContent = String(timestamp);

    const channelEl = li.querySelector('.chat-channel');
    if (channelEl) {
        if (channelEl.dataset.channel !== channel) channelEl.dataset.channel = channel;
        if (channelEl.textContent !== channel) channelEl.textContent = channel;
    }

    const playerEl = li.querySelector('.chat-player');
    if (playerEl) {
        if (playerEl.dataset.player !== player) playerEl.dataset.player = player;
        if (playerEl.textContent !== player) playerEl.textContent = player;
    }

    const textEl = li.querySelector('.chat-text');
    if (textEl && textEl.textContent !== text) textEl.textContent = text;
}

function updateChat(chatData) {
    chatData = JSON.parse(chatData || '[]');

    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;

    const messages = chatData.map(m => {
        const timestamp = m[0];
        const channel = m[1];
        const player = m[2];
        const text = m[3];
        const uid = makeChatUid(timestamp, channel, player, text);
        return { timestamp, channel, player, text, uid };
    });

    patchList(chatEl, messages, {
        key: m => m.uid,
        create: createChatMsgItem,
        update: updateChatMsgItem,
        itemSelector: '.chat-msg',
        keepSelection: false
    });
}

function resetChatFilter() {
    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;
    chatEl.querySelectorAll('.chat-msg').forEach(li => { li.style.display = ''; });
}

function filterChatByChannel(channel) {
    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;
    chatEl.querySelectorAll('.chat-msg').forEach(li => {
        li.style.display = li.dataset.channel === channel ? '' : 'none';
    });
    const currentFilterEl = document.getElementById('chat-current-filter');
    currentFilterEl.textContent = `Clear filter: Channel ${channel}`;
}

function filterChatByPlayer(player) {
    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;
    chatEl.querySelectorAll('.chat-msg').forEach(li => {
        li.style.display = li.dataset.player === player ? '' : 'none';
    });
    const currentFilterEl = document.getElementById('chat-current-filter');
    currentFilterEl.textContent = `Clear filter: Player ${player}`;
}

function updateModReceipts(modReceipts) {
    document.modReceipts = modReceipts;
    const receiptCount = (modReceipts.match(/\[NAME\]/g) || []).length;
    const modReceiptsBtn = document.getElementById('btn-mod-receipts');
    modReceiptsBtn.textContent = `Copy mod receipts (${receiptCount})`;

    if (receiptCount > 0) {
        modReceiptsBtn.style.fontWeight = 'bold';
    } else {
        modReceiptsBtn.style.fontWeight = 'normal';
    }
}

const currentFilterEl = document.getElementById('chat-current-filter');
currentFilterEl.addEventListener('click', () => {
    currentFilterEl.textContent = 'Showing all messages';
    resetChatFilter();
});

const clearReportBtn = document.getElementById('btn-clear-reports');
clearReportBtn.addEventListener('click', () => {
    const player = document.selectedPlayer;
    A3API.SendAlert(`["clearReports", "${player}"]`);
});

const timeoutButton = document.getElementById('btn-timeout');
const timeoutSliderEl = document.getElementById('timeout-minutes-slider');
timeoutSliderEl.addEventListener('input', () => {
    timeoutDurationEl.value = timeoutSliderEl.value;
    timeoutDurationEl.dispatchEvent(new Event('change'));
});

const timeoutDurationEl = document.getElementById('timeout-minutes');
timeoutDurationEl.addEventListener('change', () => {
    let duration = timeoutDurationEl.value || 15;
    if (duration > 120 && !document.isAdmin) {
        timeoutDurationEl.value = 120;
        duration = 120;
    }
    timeoutButton.textContent = `Timeout ${document.selectedPlayerName} for ${duration} minutes`;
    timeoutSliderEl.value = duration;
});

timeoutButton.addEventListener('click', () => {
    const player = document.selectedPlayer;
    const duration = timeoutDurationEl.value || 15;
    const reason = document.getElementById('timeout-reason').value || 'unsportsmanlike conduct';
    const infoEl = document.getElementById('player-info');
    const timeoutString = `${infoEl.value}\n[TIMEOUT] ${duration} minutes\n[REASON] ${reason}\n\n`;
    A3API.SendAlert(`["timeout", "${player}", ${duration}, "${btoa(reason)}", "${btoa(timeoutString)}"]`);
});

const balanceButton = document.getElementById('btn-rebalance');
balanceButton.addEventListener('click', () => {
    A3API.SendAlert(`["rebalance", "${document.selectedPlayer}"]`);
});

const vehiclesButton = document.getElementById('btn-vehicles');
vehiclesButton.addEventListener('click', () => {
    A3API.SendAlert(`["accessVehicles", "${document.selectedPlayer}"]`);
});

const gotoButton = document.getElementById('btn-goto');
gotoButton.addEventListener('click', () => {
    A3API.SendAlert(`["gotoPlayer", "${document.selectedPlayer}"]`);
});

const muteButton = document.getElementById('btn-mute');
muteButton.addEventListener('click', () => {
    A3API.SendAlert(`["mutePlayer", "${document.selectedPlayer}"]`);
});

const seeTransfersButton = document.getElementById('btn-see-transfers');
seeTransfersButton.addEventListener('click', () => {
    A3API.SendAlert(`["seeTransfers", "${document.selectedPlayer}"]`);
});

const seeAFKLogButton = document.getElementById('btn-see-afk-log');
seeAFKLogButton.addEventListener('click', () => {
    A3API.SendAlert(`["seeAFKLog", "${document.selectedPlayer}"]`);
});

function changeButtons() {
    const player = document.selectedPlayer;
    const playerName = document.selectedPlayerName;
    timeoutButton.textContent = `Timeout ${playerName} for ${timeoutDurationEl.value || 15} minutes`;
    balanceButton.textContent = `Rebalance ${playerName}`;
}
changeButtons();

const selectAllBtn = document.getElementById('btn-select-all');
selectAllBtn.addEventListener('click', () => {
    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;
    chatEl.querySelectorAll('.chat-select').forEach(cb => {
        if (cb.offsetParent !== null) {
            cb.checked = true;
            cb.dispatchEvent(new Event('click'));
        }
    });
});

const deselectAllBtn = document.getElementById('btn-select-none');
deselectAllBtn.addEventListener('click', () => {
    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;
    chatEl.querySelectorAll('.chat-select').forEach(cb => {
        cb.checked = false;
        cb.dispatchEvent(new Event('click'));
    });
});

const copyChatBtn = document.getElementById('btn-copy-chat');
copyChatBtn.addEventListener('click', () => {
    const chatEl = document.getElementById('chat-messages');
    if (!chatEl) return;
    let messages = "";
    const chatMessagesEl = chatEl.querySelectorAll('.chat-msg');
    chatMessagesEl.forEach(li => {
        const cb = li.querySelector('.chat-select');
        if (cb && cb.checked) {
            const player = li.querySelector('.chat-player')?.textContent || '';
            const text = li.querySelector('.chat-text')?.textContent || '';
            messages += (messages ? '\n' : '') + (player ? `${player}: ${text}` : text);
        }
    });
    document.copyData = messages;
    document.execCommand('copy');

    chatMessagesEl.forEach(li => {
        const cb = li.querySelector('.chat-select');
        if (cb && cb.checked) cb.checked = false;
    });
    copyChatBtn.style.fontWeight = 'normal';
    copyChatBtn.textContent = 'Copy chat (0)';
});

const modReceiptsBtn = document.getElementById('btn-mod-receipts');
modReceiptsBtn.addEventListener('click', () => {
    document.copyData = document.modReceipts || '';
    document.execCommand('copy');
    A3API.SendAlert('["modReceipts"]');
});

document.addEventListener('copy', (e) => {
    if (!document.copyData) return;
    e.clipboardData.setData('text/plain', document.copyData);
    document.copyData = '';
    e.preventDefault();
});

const copyInfoBtn = document.getElementById('btn-copy');
copyInfoBtn.addEventListener('click', () => {
    const infoEl = document.getElementById('player-info');
    document.copyData = infoEl.value;
    document.execCommand('copy');
});

function uidToBeGuid(uid) {
    if (!uid) return "";
    let id = BigInt(uid);
    let payload = "BE";

    for (let i = 0; i < 8; i++) {
        const byte = Number(id & 0xFFn);
        id >>= 8n;
        payload += String.fromCharCode(byte);
    }
    return CryptoJS.MD5(CryptoJS.enc.Latin1.parse(payload)).toString();
}