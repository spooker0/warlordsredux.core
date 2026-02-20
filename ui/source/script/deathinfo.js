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

function updateDeathInfoData(gameData) {
    gameData = JSON.parse(gameData || '[]');

    const [health, killer, killerIcon, ratioYou, ratioThem, killedBy, killerSide, badgeText, badgeLevel, badgeIcon, hitPoints, hitProjectiles] = gameData;

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

    updateHitpoints(hitPoints);
    updateHitProjectiles(hitProjectiles);
}

function updateHitProjectiles(hitProjectiles) {
    const container = document.querySelector('.hit-projectiles');
    if (!hitProjectiles || hitProjectiles.length === 0) {
        return;
    }

    const hitTimesEl = document.querySelector('.hit-times');
    const hitByEl = document.querySelector('.hit-by');

    hitTimesEl.innerHTML = '<div class="hit-header">TIME</div>';
    hitByEl.innerHTML = '<div class="hit-header">PROJECTILE</div>';

    hitProjectiles.forEach(proj => {
        hitTimesEl.innerHTML += `${proj[0]}<br/>`;
        hitByEl.innerHTML += `${proj[1]}<br/>`;
    });
}

function updateRespawnTimer(time) {
    const respawnTimer = document.querySelector('.respawn-timer');
    if (time) {
        respawnTimer.textContent = `BLEED OUT IN ${String(time).padStart(4, '0')}...`;
    } else {
        respawnTimer.textContent = "WAITING TO RESPAWN...";
    }
}

const HITPOINT_ORDER = ["hitface", "hitneck", "hithead", "hitpelvis", "hitabdomen", "hitdiaphragm", "hitchest", "hitbody", "hitarms", "hithands", "hitlegs"];
const LINE_WIDTH = 1;

function norm01(v) {
    v = Number.isFinite(v) ? v : 0;
    return Math.max(0, Math.min(1, v));
}

function damageColor(damage) {
    damage = Math.max(0, Math.min(1, damage));
    const t = Math.pow(damage, 1.5);
    let r, g, b;

    if (t < 0.5) {
        const k = t / 0.5;
        r = 255;
        g = 255 - k * (255 - 165);
        b = 255 - k * 255;
    } else {
        const k = (t - 0.5) / 0.5;
        r = 255;
        g = 165 - k * 165;
        b = 0;
    }
    return `rgb(${r}, ${g}, ${b})`;
}

function drawRect(ctx, x, y, w, h, damage) {
    ctx.save();
    ctx.beginPath();
    const rx = Math.round(x) + 0.5, ry = Math.round(y) + 0.5;
    const rw = Math.round(w), rh = Math.round(h);
    ctx.roundRect(rx, ry, rw, rh, 3);
    ctx.globalAlpha = 1.0;
    ctx.fillStyle = damageColor(damage);
    ctx.fill();
    ctx.restore();
}

function updateHitpoints(hitArray) {
    const canvas = document.getElementById('hitviz');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    const v = {};
    for (let i = 0; i < HITPOINT_ORDER.length; i++) {
        v[HITPOINT_ORDER[i]] = norm01(hitArray?.[i] ?? 0);
    }

    const W = canvas.width, H = canvas.height;
    const CX = W / 2;

    const TOP_MARGIN = 15;
    const BOTTOM_MARGIN = 8;
    const GAP_V_SMALL = 6;
    const GAP_H_ARMS = 8;
    const LEGS_FRACTION = 0.65;

    const BODY_W = 90;
    const BODY_H = 150;

    const NECK_W = 24;
    const NECK_H = 10;

    const HEAD_W = 56;
    const HEAD_H = 40;

    const PELVIS_W = BODY_W;
    const PELVIS_H = 26;

    const ARM_W = 32;
    const HAND_S = ARM_W;
    const ARM_HAND_GAP = GAP_V_SMALL;
    const ARM_H = BODY_H - ARM_HAND_GAP - HAND_S;

    const headX = CX - HEAD_W / 2;
    const headY = TOP_MARGIN;

    const neckX = CX - NECK_W / 2;
    const neckY = headY + HEAD_H + GAP_V_SMALL;

    const bodyX = CX - BODY_W / 2;
    const bodyY = neckY + NECK_H + GAP_V_SMALL;

    const pelvisX = bodyX;
    const pelvisY = bodyY + BODY_H + GAP_V_SMALL;

    const armY = bodyY;
    const armL_X = bodyX - GAP_H_ARMS - ARM_W;
    const armR_X = bodyX + BODY_W + GAP_H_ARMS;
    const handY = armY + ARM_H + ARM_HAND_GAP;
    const handL_X = armL_X;
    const handR_X = armR_X;

    const BODY_MARGIN = 8;
    const BAND_GAP_DI = 6;

    const innerX = bodyX + BODY_MARGIN;
    const innerW = BODY_W - 2 * BODY_MARGIN;
    const innerH = BODY_H - 2 * BODY_MARGIN;

    const rChest = 0.26, rDiaph = 0.40, rAbd = 1 - rChest - rDiaph;
    const chestH = Math.round((innerH - 2 * BAND_GAP_DI) * rChest);
    const abdH = Math.round((innerH - 2 * BAND_GAP_DI) * rAbd);
    const diaphH = innerH - chestH - abdH - 2 * BAND_GAP_DI;

    const chestY = bodyY + BODY_MARGIN;
    const diaphY = chestY + chestH + BAND_GAP_DI;
    const abdY = diaphY + diaphH + BAND_GAP_DI;

    const FACE_W = Math.round(HEAD_W * 0.68);
    const FACE_H = Math.round(HEAD_H * 0.7);
    const faceX = CX - FACE_W / 2;
    const faceY = headY + Math.round((HEAD_H - FACE_H) / 2) + 2;

    const LEG_GAP = 8;
    const LEG_W = Math.floor((BODY_W - LEG_GAP) / 2);
    const legsY = pelvisY + PELVIS_H + GAP_V_SMALL;

    const availableH = Math.max(0, H - legsY - BOTTOM_MARGIN - (LINE_WIDTH * 0.5));
    const legsH = Math.floor(availableH * LEGS_FRACTION);
    const legL_X = bodyX;
    const legR_X = bodyX + LEG_W + LEG_GAP;

    const LUNG_GAP = 12;
    const lungW = Math.floor((innerW - LUNG_GAP) / 2);
    const lungL_X = innerX;
    const lungR_X = innerX + lungW + LUNG_GAP;

    ctx.setTransform(1, 0, 0, 1, 0, 0);
    ctx.clearRect(0, 0, W, H);

    drawRect(ctx, bodyX, bodyY, BODY_W, BODY_H, 0);
    drawRect(ctx, innerX, chestY, innerW, chestH, v.hitchest);
    drawRect(ctx, lungL_X, diaphY, lungW, diaphH, v.hitdiaphragm);
    drawRect(ctx, lungR_X, diaphY, lungW, diaphH, v.hitdiaphragm);
    drawRect(ctx, innerX, abdY, innerW, abdH, v.hitabdomen);
    drawRect(ctx, armL_X, armY, ARM_W, ARM_H, v.hitarms);
    drawRect(ctx, armR_X, armY, ARM_W, ARM_H, v.hitarms);
    drawRect(ctx, handL_X, handY, HAND_S, HAND_S, v.hithands);
    drawRect(ctx, handR_X, handY, HAND_S, HAND_S, v.hithands);
    drawRect(ctx, neckX, neckY, NECK_W, NECK_H, v.hitneck);
    drawRect(ctx, headX, headY, HEAD_W, HEAD_H, v.hithead);
    drawRect(ctx, faceX, faceY, FACE_W, FACE_H, v.hitface);
    drawRect(ctx, pelvisX, pelvisY, PELVIS_W, PELVIS_H, v.hitpelvis);
    drawRect(ctx, legL_X, legsY, LEG_W, legsH, v.hitlegs);
    drawRect(ctx, legR_X, legsY, LEG_W, legsH, v.hitlegs);
}

const track = document.getElementById('actionsTrack');
const actions = Array.from(track.querySelectorAll('.action'));
const HOLD_TIME_MS = 1000;

let selectedIndex = 0;
let holdRaf = null;
let holdStartTs = 0;
let holdProgress = 0;
let isHolding = false;

function applySelection() {
    actions.forEach((el, i) => {
        el.classList.toggle('is-selected', i === selectedIndex);
        if (i !== selectedIndex) el.style.removeProperty('--hold-progress');
    });
}

function stepHold(ts) {
    if (!holdStartTs) holdStartTs = ts;
    const dt = ts - holdStartTs;
    holdProgress = Math.min(1, dt / HOLD_TIME_MS);

    const el = actions[selectedIndex];
    if (el) el.style.setProperty('--hold-progress', holdProgress.toFixed(4));

    if (isHolding && holdProgress < 1) {
        holdRaf = requestAnimationFrame(stepHold);
    } else {
        holdRaf = null;
        isHolding = false;
        A3API.SendAlert(`${el.textContent}`);
    }
}

function startHold() {
    if (isHolding) return;
    isHolding = true;
    holdStartTs = 0;
    holdProgress = 0;

    const el = actions[selectedIndex];
    if (el) el.style.setProperty('--hold-progress', '0');

    holdRaf = requestAnimationFrame(stepHold);
}

function cancelHold() {
    if (!isHolding && holdRaf == null) return;
    isHolding = false;

    if (holdRaf != null) {
        cancelAnimationFrame(holdRaf);
        holdRaf = null;
    }
    holdStartTs = 0;
    holdProgress = 0;

    const el = actions[selectedIndex];
    if (el) el.style.removeProperty('--hold-progress');
}

function disableButton(actionId) {
    const el = actions[actionId];
    if (el) el.classList.add('is-disabled');
}

function updateSelectedItem(actionId) {
    const clamped = Math.max(0, Math.min(actions.length - 1, (actionId | 0)));
    if (clamped === selectedIndex) return;
    cancelHold();
    selectedIndex = clamped;
    applySelection();
}

applySelection();
actions.forEach(el => {
    el.dataset.label = el.textContent.trim();
});
