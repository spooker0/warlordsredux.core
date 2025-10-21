function updatePlayerList(players) {
    const data = JSON.parse(players) || [];

    const root = document.querySelector('.spectate-content');
    if (!root) return;

    const listMap = new Map();
    Array.from(root.querySelectorAll('.data-list')).forEach(el => {
        const key =
            el.dataset.listType ||
            el.dataset.type ||
            el.getAttribute('data-list') ||
            'OTHER';
        listMap.set(String(key), el);
    });

    if (!listMap.has('OTHER')) {
    }

    const findEntry = (objectId) =>
        root.querySelector(`.player-entry[data-object-id="${CSS.escape(objectId)}"]`);

    const normalizeType = (t) => (listMap.has(String(t)) ? String(t) : 'OTHER');

    const orderBuckets = {};
    for (const key of listMap.keys()) orderBuckets[key] = [];
    if (!orderBuckets.OTHER) orderBuckets.OTHER = [];

    const seen = new Set();
    const nameById = new Map();

    data.forEach(player => {
        const name = String(player[0] ?? '').trim();
        const listTypeRaw = player[1];
        const objectId = String(player[2]);
        const vehicle = player.length >= 4 ? String(player[3]).trim() : '';

        const listType = normalizeType(listTypeRaw);
        const targetList = listMap.get(listType) || listMap.get('OTHER');
        if (!targetList) return;

        seen.add(objectId);
        nameById.set(objectId, name);
        orderBuckets[listType].push({ objectId, name, vehicle });

        const text = vehicle ? `${name}<br/>[${vehicle}]` : name;

        let el = findEntry(objectId);
        if (!el) {
            el = document.createElement('div');
            el.className = 'player-entry';
            el.dataset.objectId = objectId;
            el.innerHTML = text;

            el.addEventListener('click', () => {
                A3API.SendAlert(`${objectId}`);
            });

            targetList.appendChild(el);

            el.dataset.name = name;
        } else {
            if (!targetList.contains(el)) {
                targetList.appendChild(el);
            }
            if (el.innerHTML !== text) {
                el.innerHTML = text;
            }

            el.dataset.name = name;
        }
    });

    root.querySelectorAll('.player-entry').forEach(el => {
        if (!seen.has(el.dataset.objectId)) el.remove();
    });

    const collator = new Intl.Collator(undefined, { sensitivity: 'base', numeric: true });
    const toSortedIds = (arr) => arr.sort((a, b) => {
        const byName = collator.compare(a.name, b.name);
        return byName !== 0 ? byName : collator.compare(a.objectId, b.objectId);
    }).map(x => x.objectId);

    const reorder = (listEl, orderArray) => {
        let cursor = listEl.firstChild;
        orderArray.forEach(objectId => {
            const el = listEl.querySelector(`.player-entry[data-object-id="${CSS.escape(objectId)}"]`);
            if (!el) return;
            if (el !== cursor) listEl.insertBefore(el, cursor);
            cursor = el.nextSibling;
        });
    };

    for (const [key, listEl] of listMap.entries()) {
        reorder(listEl, toSortedIds(orderBuckets[key] || []));
    }

    applyNameFilter();
}

const spectateSearch = document.getElementById('spectate-search');
const applyNameFilter = () => {
    const q = (spectateSearch ? spectateSearch.value : '').trim().toLowerCase();
    document.querySelectorAll('.player-entry').forEach(el => {
        const n = (el.dataset.name || '').toLowerCase();
        const match = !q || n.startsWith(q) || n.indexOf(q) !== -1;
        el.style.display = match ? '' : 'none';
    });
};
spectateSearch.addEventListener('input', (e) => {
    applyNameFilter();
});
