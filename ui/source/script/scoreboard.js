const imageSize = 64;
A3API.RequestTexture("a3\\modules_f_bootcamp\\data\\portraitbootcampstage.paa", imageSize).then(imageContent => {
    document.querySelector('.player-icon').src = imageContent;
});
A3API.RequestTexture("a3\\ui_f\\data\\igui\\cfg\\weaponicons\\srifle_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.kill-icon').src = imageContent;
});
A3API.RequestTexture("a3\\static_f_sams\\radar_system_01\\data\\ui\\radar_system_01_picture_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.static-icon').src = imageContent;
});
A3API.RequestTexture("a3\\soft_f\\mrap_01\\data\\ui\\mrap_01_gmg_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.light-icon').src = imageContent;
});
A3API.RequestTexture("a3\\armor_f_tank\\mbt_04\\data\\ui\\mbt_04_command.paa", imageSize).then(imageContent => {
    document.querySelector('.heavy-icon').src = imageContent;
});
A3API.RequestTexture("a3\\ui_f\\data\\gui\\rsc\\rscdisplaygarage\\helicopter_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.helo-icon').src = imageContent;
});
A3API.RequestTexture("a3\\ui_f\\data\\gui\\rsc\\rscdisplaygarage\\plane_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.plane-icon').src = imageContent;
});
A3API.RequestTexture("a3\\ui_f_curator\\data\\cfgmarkers\\kia_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.death-icon').src = imageContent;
});
A3API.RequestTexture("a3\\modules_f_curator\\data\\portraitcuratoraddpoints_ca.paa", imageSize).then(imageContent => {
    document.querySelector('.point-icon').src = imageContent;
});

function renderScoreboard(players, firstRender) {
    const makeCell = (value, className) => {
        const div = document.createElement('div');
        if (className) div.className = className;
        div.textContent = value != null ? String(value) : '';
        return div;
    };

    const clearNode = (node) => {
        while (node.firstChild) node.removeChild(node.firstChild);
    };

    const zeroTotals = () => ({
        kills: 0,
        staticKills: 0,
        lightKills: 0,
        heavyKills: 0,
        heloKills: 0,
        planeKills: 0,
        deaths: 0,
        points: 0
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
        clearNode(el);
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

    players = JSON.parse(players || '[]');

    const body = document.getElementById('scoreboard-body');
    clearNode(body);

    const blufor = zeroTotals();
    const opfor = zeroTotals();

    const frag = document.createDocumentFragment();
    let scrollTarget = null;

    players.forEach((player, index) => {
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

        row.appendChild(makeCell(index + 1));
        const nameDiv = makeCell(player.name, 'player-name');
        row.appendChild(nameDiv);
        row.appendChild(makeCell(stats.kills));
        row.appendChild(makeCell(stats.staticKills));
        row.appendChild(makeCell(stats.lightKills));
        row.appendChild(makeCell(stats.heavyKills));
        row.appendChild(makeCell(stats.heloKills));
        row.appendChild(makeCell(stats.planeKills));
        row.appendChild(makeCell(stats.deaths));
        row.appendChild(makeCell(stats.points));

        if (player.side === 'BLUFOR') {
            nameDiv.style.color = '#004d99';
            addToTotals(blufor, stats);
        } else if (player.side === 'OPFOR') {
            nameDiv.style.color = '#ff4b4b';
            addToTotals(opfor, stats);
        } else {
            nameDiv.style.color = '#ffffff';
        }

        if (player.isPlayer) {
            row.style.border = '2px solid #66ccff';
            if (firstRender) scrollTarget = row;
        }

        frag.appendChild(row);
    });

    body.appendChild(frag);

    if (scrollTarget && firstRender) {
        body.scrollTop = scrollTarget.offsetTop;
    }

    const bluforRow = document.getElementById('blufor-footer');
    const opforRow = document.getElementById('opfor-footer');
    if (bluforRow) renderFooter(bluforRow, 'BLUFOR', blufor);
    if (opforRow) renderFooter(opforRow, 'OPFOR', opfor);
}