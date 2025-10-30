const imageSize = 64;

const setIcons = (cls, paaPath) => {
    A3API.RequestTexture(paaPath, imageSize).then(imageContent => {
        document.querySelectorAll(`.${cls}`).forEach(img => img.src = imageContent);
    });
};

setIcons('player-icon', 'a3\\modules_f_bootcamp\\data\\portraitbootcampstage.paa');
setIcons('kill-icon', 'a3\\ui_f\\data\\igui\\cfg\\weaponicons\\srifle_ca.paa');
setIcons('static-icon', 'a3\\static_f_sams\\radar_system_01\\data\\ui\\radar_system_01_picture_ca.paa');
setIcons('light-icon', 'a3\\soft_f\\mrap_01\\data\\ui\\mrap_01_gmg_ca.paa');
setIcons('heavy-icon', 'a3\\armor_f_tank\\mbt_04\\data\\ui\\mbt_04_command.paa');
setIcons('helo-icon', 'a3\\ui_f\\data\\gui\\rsc\\rscdisplaygarage\\helicopter_ca.paa');
setIcons('plane-icon', 'a3\\ui_f\\data\\gui\\rsc\\rscdisplaygarage\\plane_ca.paa');
setIcons('death-icon', 'a3\\ui_f_curator\\data\\cfgmarkers\\kia_ca.paa');
setIcons('point-icon', 'a3\\modules_f_curator\\data\\portraitcuratoraddpoints_ca.paa');

setIcons('nato-flag', 'a3\\ui_f\\data\\map\\markers\\flags\\nato_ca.paa');
setIcons('csat-flag', 'a3\\ui_f\\data\\map\\markers\\flags\\CSAT_ca.paa');

function formatScore(value) {
    if (isNaN(value)) return value;
    if (value < 1000) return String(value);
    if (value < 1_000_000) return (value / 1000).toFixed(1) + 'K';
    return (value / 1_000_000).toFixed(1) + 'M';
}

function renderScoreboard(players, firstRender) {
    const makeCell = (value, className) => {
        const div = document.createElement('div');
        if (className) div.className = className;
        div.textContent = value != null ? formatScore(value) : '';
        return div;
    };

    const clearNode = (node) => { while (node.firstChild) node.removeChild(node.firstChild); };

    const zeroTotals = () => ({
        kills: 0, staticKills: 0, lightKills: 0, heavyKills: 0,
        heloKills: 0, planeKills: 0, deaths: 0, points: 0
    });

    const addToTotals = (totals, src) => {
        totals.kills += src.kills;
        totals.staticKills += src.staticKills;
        totals.lightKills += src.lightKills;
        totals.heavyKills += src.heavyKills;
        totals.heloKills += src.heloKills;
        totals.planeKills += src.planeKills;
        totals.deaths += src.deaths;
        totals.points += src.points;
    };

    const renderFooter = (el, label, totals) => {
        el.appendChild(makeCell(''));
        el.appendChild(makeCell(label, 'player-name'));
        el.appendChild(makeCell(totals.kills));
        el.appendChild(makeCell(totals.staticKills));
        el.appendChild(makeCell(totals.lightKills));
        el.appendChild(makeCell(totals.heavyKills));
        el.appendChild(makeCell(totals.heloKills));
        el.appendChild(makeCell(totals.planeKills));
        el.appendChild(makeCell(totals.deaths));
        el.appendChild(makeCell(totals.points));
    };

    const allPlayers = JSON.parse(players || '[]');

    const bluPlayers = allPlayers.filter(p => p.side === 'BLUFOR');
    const opfPlayers = allPlayers.filter(p => p.side === 'OPFOR');

    const bluBody = document.getElementById('scoreboard-body-blufor');
    const opfBody = document.getElementById('scoreboard-body-opfor');
    clearNode(bluBody);
    clearNode(opfBody);

    const bluforTotals = zeroTotals();
    const opforTotals = zeroTotals();
    let scrollTarget = null;

    const buildRows = (list, body, side) => {
        const frag = document.createDocumentFragment();

        list.forEach((player, idx) => {
            const row = document.createElement('div');
            row.className = 'scoreboard-row';

            const stats = {
                kills: player.kills || 0,
                staticKills: player.staticKills || 0,
                lightKills: player.lightKills || 0,
                heavyKills: player.heavyKills || 0,
                heloKills: player.heloKills || 0,
                planeKills: player.planeKills || 0,
                deaths: player.deaths || 0,
                points: player.points || 0
            };

            row.appendChild(makeCell(idx + 1));
            const nameDiv = makeCell(player.name || '', 'player-name');
            row.appendChild(nameDiv);
            row.appendChild(makeCell(stats.kills));
            row.appendChild(makeCell(stats.staticKills));
            row.appendChild(makeCell(stats.lightKills));
            row.appendChild(makeCell(stats.heavyKills));
            row.appendChild(makeCell(stats.heloKills));
            row.appendChild(makeCell(stats.planeKills));
            row.appendChild(makeCell(stats.deaths));
            row.appendChild(makeCell(stats.points));

            if (side === 'BLUFOR') nameDiv.style.color = '#66ccff';
            if (side === 'OPFOR') nameDiv.style.color = '#ff8080';

            frag.appendChild(row);

            if (player.isPlayer) {
                if (firstRender) {
                    scrollTarget = row;
                }
                row.style.border = '2px solid yellow';
            };

            if (side === 'BLUFOR') addToTotals(bluforTotals, stats);
            else addToTotals(opforTotals, stats);
        });

        body.appendChild(frag);
    };

    buildRows(bluPlayers, bluBody, 'BLUFOR');
    buildRows(opfPlayers, opfBody, 'OPFOR');

    const bluFooterRow = document.querySelector('.blufor-row');
    const opfFooterRow = document.querySelector('.opfor-row');

    clearNode(bluFooterRow);
    clearNode(opfFooterRow);

    renderFooter(bluFooterRow, 'BLUFOR', bluforTotals);
    renderFooter(opfFooterRow, 'OPFOR', opforTotals);

    if (scrollTarget && firstRender) {
        const scroller = document.getElementById('scoreboard-scroll');
        scroller.scrollTop = scrollTarget.offsetTop - 51;
    }
}

const STEP = 50;
const scoreboard = document.getElementById('scoreboard-scroll');

function scrollDown() {
    scoreboard.scrollTop += STEP;
}

function scrollUp() {
    scoreboard.scrollTop -= STEP;
}