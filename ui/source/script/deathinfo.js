function setHealth(percent) {
    const fill = document.getElementById('fillInner');
    const text = document.getElementById('healthText');
    const bounded = Math.max(0, Math.min(percent, 100));
    fill.style.height = bounded + '%';
    text.textContent = `HEALTH ${bounded}%`;
}

function updateData(gameData) {
    gameData = JSON.parse(gameData || '[]');

    const health = gameData[0] || 100;
    setHealth(health);

    const killer = gameData[1] || "Unknown";
    const killerText = document.querySelector('.killer-text');
    killerText.textContent = killer;

    const killerIcon = gameData[2] || "";
    const killerIconElement = document.querySelector('.killer-icon');
    if (killerIcon) {
        A3API.RequestTexture(killerIcon, 512).then(imageContent => killerIconElement.src = imageContent);
    }

    const distance = gameData[3] || "CQB";
    const distanceText = document.querySelector('.distance-text');
    distanceText.textContent = distance;

    const ratio = gameData[4] || "0 - 0";
    const ratioText = document.querySelector('.ratio-text');
    ratioText.textContent = ratio;

    const sensorDetected = gameData[5] || "";
    const sensorDisplayTitle = document.querySelector('.sensor-display-title');
    sensorDisplayTitle.textContent = sensorDetected;

    const killedBy = gameData[6] || "Enemy";
    const killedByName = document.querySelector('.killed-by-name');
    killedByName.textContent = killedBy;

    const killerColor = gameData[7] || "#ff2222";
    killedByName.style.color = killerColor;

    const badgeText = gameData[8] || "No Badge";
    const badge = document.querySelector('.badge-text');
    const badgeEl = document.querySelector('.badge');
    if (badgeText === "No Badge") {
        badgeEl.style.display = "none";
    } else {
        badgeEl.style.display = "block";
        badge.textContent = badgeText;
    }

    const badgeLevel = gameData[9] || 1;
    if (badgeLevel === 1) {
        badgeEl.className = "badge badge-level-1";
    } else if (badgeLevel === 2) {
        badgeEl.className = "badge badge-level-2";
    } else if (badgeLevel === 3) {
        badgeEl.className = "badge badge-level-3";
    }
}