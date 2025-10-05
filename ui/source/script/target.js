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

function setGPSData(selectionIndex, gridCoord, targetRange, assetRange, inRange) {
    const controlsEl = document.querySelector('.mode-gps .gps-controls');
    if (selectionIndex === 1) {
        controlsEl.innerHTML = `<li>[ ] READY</li><li>[&gt;] ENTER NEW COORDS</li>`;
    } else {
        controlsEl.innerHTML = `<li>[&gt;] READY</li><li>[ ] ENTER NEW COORDS</li>`;
    }

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
    targetRangeDisplayEl.textContent = `TGT: ${targetRange}`;

    const assetRangeDisplayEl = document.querySelector('.mode-gps .asset-range-display');
    assetRangeDisplayEl.textContent = `RNG: ${assetRange}`;

    if (inRange) {
        targetRangeDisplayEl.style.color = "green";
        assetRangeDisplayEl.style.color = "green";
    } else {
        targetRangeDisplayEl.style.color = "red";
        assetRangeDisplayEl.style.color = "red";
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

function setSettings(targetLeft, targetTop, incomingLeft, incomingTop, fontSize) {
    const wrapper = document.querySelector('.target-wrapper');
    wrapper.style.marginLeft = `${targetLeft}vw`;
    wrapper.style.marginTop = `${targetTop}vh`;

    const incomingWrapper = document.querySelector('.missile-wrapper');
    incomingWrapper.style.marginLeft = `${incomingLeft}vw`;
    incomingWrapper.style.marginTop = `${incomingTop}vh`;

    document.documentElement.style.setProperty('--base-font-size', `${fontSize}px`);
}