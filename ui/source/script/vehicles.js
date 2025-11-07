document.imageCache = document.imageCache || {};

function hideLoadingOverlay() {
    const overlay = document.getElementById('loading-overlay');
    overlay.style.display = 'none';
    const emptyState = document.querySelector('.empty-state');
    emptyState.style.opacity = '1.0';
    const vehicleMenu = document.querySelector('.vehicle-menu');
    vehicleMenu.style.opacity = '1.0';
}

function getTexture(paaPath, size = 256) {
    if (!paaPath) return Promise.resolve(null);
    if (document.imageCache[paaPath]) {
        return Promise.resolve(document.imageCache[paaPath]);
    }
    return A3API.RequestTexture(paaPath, size)
        .then(img => (document.imageCache[paaPath] = img))
        .catch(() => null);
}

const OPTION_META = {
    "remove": { text: "REMOVE", cls: "remove-button" },
    "lock": { text: "LOCK", cls: "lock-button" },
    "unlock": { text: "UNLOCK", cls: "unlock-button" },
    "kick": { text: "KICK ALL", cls: "kick-button" },
    "connect-driver": { text: "CONTROL DRIVER", cls: "connect-button" },
    "connect-gunner": { text: "CONTROL GUNNER", cls: "connect-button" },
    "set-auto": { text: "TOGGLE AUTO", cls: "connect-button" },
    "rearm": { text: "REARM", cls: "rearm-button" },
    "repair": { text: "REPAIR", cls: "repair-button" },
    "refuel": { text: "REFUEL", cls: "refuel-button" },
};

function makeButtonBar(vehicleId, optionIds = []) {
    const bar = document.createElement('div');
    bar.className = 'vehicle-bar';

    // Fixed layout: [row][col]
    const LAYOUT = [
        ['remove', 'lock', 'unlock'],
        ['rearm', 'repair', 'refuel'],
        ['set-auto', 'connect-driver', 'connect-gunner'],
        ['kick', null, null],
    ];

    const has = new Set(optionIds);

    LAYOUT.forEach(row => {
        row.forEach((opt, index) => {
            if (opt && OPTION_META[opt] && has.has(opt)) {
                const meta = OPTION_META[opt];
                const btn = document.createElement('button');
                btn.className = meta.cls;
                btn.textContent = meta.text;
                btn.addEventListener('mousedown', () => {
                    A3API.SendAlert(`["${vehicleId}", "${opt}"]`);
                });
                if (index === 0) {
                    btn.style.borderLeft = 'none';
                } else if (index === row.length - 1) {
                    btn.style.borderRight = 'none';
                }
                bar.appendChild(btn);
            } else {
                const spacer = document.createElement('div');
                spacer.className = 'button-spacer';
                bar.appendChild(spacer);
            }
        });
    });

    return bar;
}

function updateData(gameData) {
    let data = [];
    try { data = JSON.parse(gameData || '[]'); } catch { data = []; }

    const panel = document.querySelector('.vehicle-menu');
    if (!panel) return;

    if (!data || !data.length) {
        panel.querySelectorAll('.vehicle-wrap').forEach(w => w.remove());
        const empty = document.querySelector('.empty-state');
        empty.style.display = 'block';
        hideLoadingOverlay();
        return;
    } else {
        const empty = document.querySelector('.empty-state');
        if (empty) {
            empty.style.display = 'none';
        }
    }

    const incomingIds = new Set();

    data.forEach(vehicle => {
        // [id, [name, location, apsAmmo, lockLabel], options[], iconPath]
        const [vehicleId, vehicleData, optionIds = [], iconPath] = vehicle;
        const [vehicleName, vehicleLocation, vehicleApsAmmo, vehicleLockLabel] = vehicleData;
        const idStr = String(vehicleId);
        incomingIds.add(idStr);

        let wrap = panel.querySelector(`.vehicle-wrap[data-vehicle-id="${idStr}"]`);
        let tile, title, bar;

        if (!wrap) {
            wrap = document.createElement('div');
            wrap.className = 'vehicle-wrap';
            wrap.dataset.vehicleId = idStr;

            tile = document.createElement('div');
            tile.className = 'vehicle';
            tile.dataset.vehicleId = idStr;

            title = document.createElement('div');
            title.className = 'vehicle-name';
            tile.appendChild(title);

            bar = makeButtonBar(vehicleId, optionIds);

            wrap.appendChild(tile);
            wrap.appendChild(bar);
            panel.appendChild(wrap);
        } else {
            tile = wrap.querySelector('.vehicle');
            title = tile.querySelector('.vehicle-name');
            bar = wrap.querySelector('.vehicle-bar');
        }

        const newHTML = `${vehicleName}<br/>${vehicleLocation}<br/>${vehicleApsAmmo}<br/>${vehicleLockLabel}`;
        if (title.innerHTML !== newHTML) {
            title.innerHTML = newHTML;
        }

        const prevIcon = wrap.dataset.iconPath || '';
        const nextIcon = iconPath || '';
        if (prevIcon !== nextIcon) {
            wrap.dataset.iconPath = nextIcon;
            if (nextIcon) {
                getTexture(nextIcon, 128).then(dataUrl => {
                    if (dataUrl && tile.isConnected) {
                        tile.style.setProperty('--bg', `url("${dataUrl}")`);
                    }
                });
            } else {
                tile.style.removeProperty('--bg');
            }
        }

        const optsSig = optionIds.join('|');
        if (bar.dataset.sig !== optsSig) {
            const newBar = makeButtonBar(vehicleId, optionIds);
            newBar.dataset.sig = optsSig;
            bar.replaceWith(newBar);
        }
    });

    panel.querySelectorAll('.vehicle-wrap').forEach(wrap => {
        const idStr = wrap.dataset.vehicleId;
        if (!incomingIds.has(idStr)) wrap.remove();
    });

    hideLoadingOverlay();
}

const closeButton = document.querySelector('.close-button');
closeButton.addEventListener('mousedown', function () {
    A3API.SendAlert('exit');
});