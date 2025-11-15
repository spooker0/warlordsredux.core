function setTargetList(targetListEl, targets) {
    targets = JSON.parse(targets || '[]');
    targetListEl.innerHTML = "";
    targets.forEach((target, index) => {
        const listItem = document.createElement('li');
        let selectionState = " ";
        if (target[2]) {
            selectionState = ">";
        }
        listItem.textContent = `[${selectionState}] ${target[1]}`;
        listItem.dataset.targetId = target[0];

        targetListEl.dataset.targetIndex = index;
        targetListEl.appendChild(listItem);
    });
}

function setAATargetData(targets) {
    const targetListEl = document.querySelector('.mode-aa .target-list');
    setTargetList(targetListEl, targets);
}

function setRemoteTargetData(targets) {
    const targetListEl = document.querySelector('.mode-remote .target-list');
    setTargetList(targetListEl, targets);
}

function setSEADTargetData(targets) {
    const targetListEl = document.querySelector('.mode-sead .target-list');
    setTargetList(targetListEl, targets);
}

function setMunitionList(munitions) {
    munitions = JSON.parse(munitions || '[]');

    const munitionsEl = document.querySelector('.munition-display');
    munitionsEl.innerHTML = "";
    munitions.forEach((munition, index) => {
        const listItem = document.createElement('li');
        listItem.textContent = munition;
        munitionsEl.appendChild(listItem);
    });
}

function setGPSData(nextKeyName, selectionList, selectionIndex, gridCoord, targetRange, assetRange, inRange) {
    const controlsEl = document.querySelector('.mode-gps .gps-controls');
    controlsEl.innerHTML = "";

    selectionList.unshift("ENTER CORDS [0-9] OR CLICK MAP");
    selectionList.unshift(`PRESS ${nextKeyName} TO ENTER GRID`);
    selectionList.forEach((item, index) => {
        const listItem = document.createElement('li');
        let selectionState = " ";
        if (index === selectionIndex) {
            selectionState = ">";
        }

        if (index < 2) {
            listItem.textContent = `[${selectionState}] ${item}`;
        } else {
            listItem.textContent = `[${selectionState}] GRID ${item.slice(0, -3)} ${item.slice(-3)}`;
        }
        controlsEl.appendChild(listItem);
    });

    const gridCoordEl = document.querySelector('.mode-gps .grid-coord-display');
    if (gridCoord === "") {
        gridCoordEl.textContent = "GRID 000 000";
    } else {
        let lastThree = gridCoord.slice(-3);
        while (lastThree.length < 3) {
            lastThree = "0" + lastThree;
        }
        let firstThree = gridCoord.slice(-6, -3);
        while (firstThree.length < 3) {
            firstThree = "0" + firstThree;
        }
        gridCoordEl.textContent = `GRID ${firstThree} ${lastThree}`;
    }

    const targetRangeDisplayEl = document.querySelector('.mode-gps .target-range-display');
    targetRangeDisplayEl.textContent = `TARGET DISTANCE: ${targetRange} KM`;

    const assetRangeDisplayEl = document.querySelector('.mode-gps .asset-range-display');
    assetRangeDisplayEl.textContent = `EFFECTIVE RANGE: ${assetRange} KM`;

    const rangeWarningEl = document.querySelector('.mode-gps .range-warning');
    if (inRange) {
        targetRangeDisplayEl.style.color = "green";
        assetRangeDisplayEl.style.color = "green";
        rangeWarningEl.textContent = "FIRE NOW";
        rangeWarningEl.style.color = "green";
    } else {
        targetRangeDisplayEl.style.color = "red";
        assetRangeDisplayEl.style.color = "red";
        if (targetRange <= 0.5) {
            rangeWarningEl.textContent = "TOO CLOSE TO TARGET";
        } else {
            rangeWarningEl.textContent = "ALIGN HEADING AND GET CLOSER / HIGHER / FASTER";
        }
        rangeWarningEl.style.color = "red";
    }
}

function setMode(mode, title) {
    document.querySelectorAll('.mode').forEach(el => el.style.display = 'none');
    const modeEl = document.querySelectorAll(`.mode-${mode}`);
    if (modeEl) {
        modeEl.forEach(el => el.style.display = 'block');

        if (title && title !== "") {
            document.querySelectorAll('.mode-title').forEach(el => el.textContent = title);
        }
    }
}

function setIncomingMissiles(missiles) {
    missiles = JSON.parse(missiles || '[]');
    missiles.sort((a, b) => {
        const approachA = a[2] ? 0 : 100000;
        const approachB = b[2] ? 0 : 100000;
        return (approachA + a[1]) - (approachB + b[1]);
    });

    const missileTableEl = document.querySelector('.missile-table');
    missileTableEl.innerHTML = "";

    missiles.forEach((missile) => {
        const [missileState, missileDistance, missileApproaching, missileType] = missile;

        const rowEl = document.createElement('li');
        rowEl.classList.add('missile-row');

        const typeEl = document.createElement('span');
        typeEl.classList.add('col', 'type');
        typeEl.textContent = missileType;
        rowEl.appendChild(typeEl);

        const statusEl = document.createElement('span');
        statusEl.classList.add('col', 'status');
        statusEl.textContent = missileState;
        rowEl.appendChild(statusEl);

        const angleEl = document.createElement('span');
        angleEl.classList.add('col', 'angle');
        angleEl.textContent = `${(missileDistance / 1000.0).toFixed(1)} KM`;
        rowEl.appendChild(angleEl);

        let rowColor = "#ff0000";
        if (!missileApproaching) {
            rowColor = "#000000";
        } else if (missileDistance > 5000) {
            rowColor = "#ffffff";
        } else if (missileDistance > 2500) {
            rowColor = "#ffff00";
        }

        rowEl.style.color = rowColor;
        missileTableEl.appendChild(rowEl);
    });
}

function setReconOptics(state, ready) {
    const reconEl = document.querySelector('.recon-indicator');
    if (state) {
        reconEl.textContent = ready ? "RECON OPTICS READY" : "RECON OPTICS WAIT";
        reconEl.style.color = ready ? "lime" : "black";
    } else {
        reconEl.textContent = "";
    }
}

function setEcmCharges(active, count, nextChargeTime) {
    const ecmIndicatorEl = document.querySelector('.ecm-indicator');
    const rechargeEl = document.querySelector('.recharge-indicator');
    if (active) {
        ecmIndicatorEl.textContent = `ECM CHARGES: ${count}`;
        rechargeEl.textContent = `RECHARGE: ${nextChargeTime}`;
        ecmIndicatorEl.style.color = count > 0 ? "lime" : "black";
    } else {
        ecmIndicatorEl.textContent = "";
        rechargeEl.textContent = "";
    }
}

function setWeaponName(name) {
    const weaponWrapperEl = document.querySelector('.weapon-wrapper');
    const weaponNameEl = document.querySelector('.weapon-name');
    if (name === "") {
        weaponWrapperEl.style.display = "none";
    } else {
        weaponWrapperEl.style.display = "block";
        weaponNameEl.textContent = name;
    }
}

function setSettings(targetLeft, targetTop, incomingLeft, incomingTop, fontSize, weaponPosition) {
    const wrapper = document.querySelector('.target-wrapper');
    wrapper.style.marginLeft = `${targetLeft}vw`;
    wrapper.style.marginTop = `${targetTop}vh`;

    const incomingWrapper = document.querySelector('.missile-wrapper');
    incomingWrapper.style.marginLeft = `${incomingLeft}vw`;
    incomingWrapper.style.marginTop = `${incomingTop}vh`;

    document.documentElement.style.setProperty('--base-font-size', `${fontSize}px`);

    if (weaponPosition[2] !== 0 || weaponPosition[3] !== 0) {
        const weaponWrapperEl = document.querySelector('.weapon-wrapper');
        weaponWrapperEl.style.left = `${weaponPosition[0]}vw`;
        weaponWrapperEl.style.top = `${weaponPosition[1]}vh`;
        weaponWrapperEl.style.width = `${weaponPosition[2]}vw`;
        weaponWrapperEl.style.height = `${weaponPosition[3]}vh`;

        const weaponNameEl = document.querySelector('.weapon-name');
        weaponNameEl.style.lineHeight = `${weaponPosition[3]}vh`;
    }
}

setReconOptics(false, false);
setEcmCharges(false, 0, 0);