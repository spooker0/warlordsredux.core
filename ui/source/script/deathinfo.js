function sideToColorHex(side) {
    switch (side) {
        case 'WEST': {
            return "#1087ff";
        }
        case 'EAST': {
            return "#fe0000";
        }
        case 'GUER': {
            return "#00fe00";
        }
        default: {
            return "#FFFFFF";
        }
    }
}

function sideToColorRGB(side, opacity = 1) {
    switch (side) {
        case 'WEST': {
            return `rgba(16, 135, 255, ${opacity})`;
        }
        case 'EAST': {
            return `rgba(254, 0, 0, ${opacity})`;
        }
        case 'GUER': {
            return `rgba(0, 254, 0, ${opacity})`;
        }
        default: {
            return `rgba(255, 255, 255, ${opacity})`;
        }
    }
}

function updateData(gameData) {
    gameData = JSON.parse(gameData || '[]');

    const [health, killer, killerIcon, ratioYou, ratioThem, killedBy, killerSide, badgeText, badgeLevel, badgeIcon] = gameData;

    document.querySelector(".health-text").textContent = `HEALTH ${health}%`;

    document.querySelector(".ratio-you").textContent = `YOU ${ratioYou}`;
    document.querySelector(".ratio-them").textContent = `${ratioThem} THEM`;

    const killedByName = document.querySelector('.killed-by-name');
    killedByName.textContent = `${killedBy}`;

    const killerHex = sideToColorHex(killerSide);

    const deathStrip = document.querySelector('.death-strip');
    deathStrip.style.backgroundColor = sideToColorRGB(killerSide, 0.8);

    const killerText = document.querySelector('.killer-text');
    killerText.textContent = killer;

    const killerIconElement = document.querySelector('.killer-icon-mask');
    if (killerIcon) {
        killerIconElement.style.display = "";
        A3API.RequestTexture(killerIcon, 512).then(imageContent => {
            killerIconElement.style.setProperty('--icon', `url(${imageContent})`);
            // killerIconElement.style.setProperty('--icon-color', killerHex);
        });
    } else {
        killerIconElement.style.display = "none";
    }

    const badge = document.querySelector('.badge-text');
    const badgeEl = document.querySelector('.badge');
    badge.textContent = badgeText;

    let badgeColor = "#ffffff";
    if (badgeLevel === 1) {
        badgeEl.className = "badge badge-level-1";
        badgeColor = "#779ECB";
    } else if (badgeLevel === 2) {
        badgeEl.className = "badge badge-level-2";
        badgeColor = "#cc7573";
    } else if (badgeLevel === 3) {
        badgeEl.className = "badge badge-level-3";
        badgeColor = "#FFD700";
    }

    const badgeIconMask = document.querySelector('.badge-icon-mask');
    if (badgeIcon) {
        A3API.RequestTexture(badgeIcon.replace(/\\\\/g, "\\"), 256).then(imageContent => {
            badgeIconMask.style.setProperty('--icon', `url(${imageContent})`);
            badgeIconMask.style.setProperty('--badge-color', badgeColor);
        });
    } else {
        A3API.RequestTexture("a3\\missions_f_epa\\data\\img\\orbat\\i_aaf_ca.paa", 256).then(imageContent => {
            badgeIconMask.style.setProperty('--icon', `url(${imageContent})`);
            badgeIconMask.style.setProperty('--badge-color', badgeColor);
        });
    }
}

function updateRespawnTimer(time) {
    const respawnTimer = document.querySelector('.respawn-timer');
    if (time) {
        respawnTimer.textContent = `BLEED OUT IN ${String(time).padStart(4, '0')}...`;
    } else {
        respawnTimer.textContent = "WAITING TO RESPAWN...";
    }
}
