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

function createPlayerListItem(player, listEl) {
    const li = document.createElement('li');
    li.className = 'player-item';
    li.dataset.uid = player.uid;

    const row = document.createElement('div');
    row.className = 'player-row';

    const nameEl = document.createElement('span');
    nameEl.className = 'player-name';
    nameEl.textContent = player.name;

    row.appendChild(nameEl);
    li.appendChild(row);

    li.addEventListener('click', () => selectPlayer(player, listEl));
    return li;
}

function updatePlayerListItem(li, player) {
    li.dataset.id = String(player.id ?? '');
    li.querySelector('.player-name').textContent = player.name;
}

function updatePlayers(playerData) {
    playerData = JSON.parse(playerData || '[]');
    const listEl = document.getElementById('player-list');
    const players = playerData.map(p => ({
        uid: p[0],
        name: p[1]
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

    changeButtons();
    document.querySelector('.player-details-panel').style.display = 'flex';
}

const reportButton = document.getElementById('btn-report');
const reasonEl = document.getElementById('report-reason');
reasonEl.addEventListener('input', changeButtons);
reportButton.addEventListener('click', () => {
    const player = document.selectedPlayer;
    const reason = reasonEl.value || 'unsportsmanlike conduct';
    A3API.SendAlert(`["report", "${player}", "${btoa(reason)}"]`);
});

function changeButtons() {
    const playerName = document.selectedPlayerName;
    reportButton.textContent = `Report ${playerName} for ${reasonEl.value || 'unsportsmanlike conduct'}`;
    reasonEl.focus();
}
changeButtons();

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