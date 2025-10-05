document.playerLevel = 0;
document.playerScore = 0;
document.playerNextLevelScore = 0;
document.imageCache = {};

document.addEventListener('wheel', function (e) {
    const el = document.elementFromPoint(e.clientX, e.clientY);
    if (el && el.closest('.scroll-panel')) {
        el.closest('.scroll-panel').scrollTop += e.deltaY;
        e.preventDefault();
    }
}, { passive: false });

document.querySelector('.close-button').addEventListener('mousedown', function () {
    A3API.SendAlert('exit');
});

document.ammoFlash = false;
setInterval(() => {
    if (document.ammoAttentionNeeded) {
        const ammoSlot = document.querySelector('.slot.ammo');
        if (ammoSlot && document.ammoFlash) {
            ammoSlot.classList.add('ammo-flash');
        } else {
            ammoSlot.classList.remove('ammo-flash');
        }
    } else {
        const ammoSlot = document.querySelector('.slot.ammo');
        if (ammoSlot) {
            ammoSlot.classList.remove('ammo-flash');
        }
    }
    document.ammoFlash = !document.ammoFlash;
}, 200);

function scrollPanelIntoView(panel) {
    [
        '.selected-weapon',
        '.selected-optic',
        '.selected-muzzle',
        '.selected-bipod',
        '.selected-outfit',
        '.selected-backpack'
    ].forEach((selector) => {
        const selectedRow = panel.querySelector(selector);
        if (selectedRow) {
            const scrollPanel = selectedRow.closest('.scroll-panel');
            if (scrollPanel) {
                const containerRect = scrollPanel.getBoundingClientRect();
                const elementRect = selectedRow.getBoundingClientRect();

                const scrollOffset =
                    elementRect.top - containerRect.top + scrollPanel.scrollTop
                    - (containerRect.height / 2)
                    + (elementRect.height / 2);

                scrollPanel.scrollTo({
                    top: scrollOffset,
                    behavior: 'instant'
                });
            }
        }
    });

}

document.querySelectorAll('.slot').forEach(slot => {
    slot.addEventListener('mousedown', function () {
        document.querySelectorAll('.slot').forEach(slot => slot.classList.remove('selected-slot'));
        this.classList.add('selected-slot');

        document.querySelectorAll('.right-panel').forEach(panel => {
            panel.classList.add('hide');
        });
        const panelClass = this.classList[1];
        const activePanel = document.querySelector(`.panel-${panelClass}`);
        activePanel.classList.remove('hide');

        if (panelClass === "ammo") {
            document.ammoAttentionNeeded = false;
            const ammoList = document.querySelectorAll('.ammo-list li');
            ammoList.forEach(row => {
                const quantityDisplay = row.querySelector('.quantity-display');
                const quantity = parseInt(quantityDisplay.textContent, 10) || 0;
                if (quantity == 0) {
                    row.classList.remove('item-in-use');
                } else {
                    row.classList.add('item-in-use');
                }
            });
        }

        scrollPanelIntoView(activePanel);
    });
});

document.querySelectorAll('.loadout').forEach(loadout => {
    loadout.addEventListener('mousedown', function () {
        document.querySelectorAll('.loadout').forEach(loadout => loadout.classList.remove('selected-loadout'));
        this.classList.add('selected-loadout');

        const loadoutIndex = parseInt(loadout.textContent.trim(), 10) - 1;
        A3API.SendAlert('l' + loadoutIndex);
    });
});

document.querySelector('.reset-all').addEventListener('mousedown', function () {
    A3API.SendAlert('r');
});

document.querySelector('.copy-current').addEventListener('mousedown', function () {
    A3API.SendAlert('c');
});

function nextPowerOfTwo(x) {
    if (x < 1) return 1;
    return Math.pow(2, Math.ceil(Math.log2(x)));
}

const imageObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const img = entry.target;
            imageObserver.unobserve(img);

            const imageUrl = img.dataset.imageUrl;
            const imageHeight = Math.max(img.clientWidth, img.clientHeight);
            const resolution = nextPowerOfTwo(imageHeight);

            if (document.imageCache[imageUrl] && document.imageCache[imageUrl][resolution]) {
                img.src = document.imageCache[imageUrl][resolution];
                img.style.opacity = 1;
                return;
            }

            A3API.RequestTexture(imageUrl, resolution).then(imageContent => {
                // if (imageContent === "data:image/webp;base64,") {
                // console.log(element.parentElement);
                // }
                img.src = imageContent;
                img.style.opacity = 1;

                if (!document.imageCache[imageUrl]) {
                    document.imageCache[imageUrl] = {};
                }
                document.imageCache[imageUrl][resolution] = imageContent;
            });
        }
    });
}, {
    root: null,
    rootMargin: '0px',
    threshold: 0.1
});

function populateImage(element, imageUrl) {
    element.dataset.imageUrl = imageUrl;
    imageObserver.observe(element);
}

function ammoChanged() {
    const ammoList = document.querySelectorAll('.ammo-list li');
    const ammoSumList = [];
    ammoList.forEach(ammoRow => {
        const ammoId = ammoRow.dataset.ammoId;
        const ammoMass = parseFloat(ammoRow.dataset.ammoMass) || 0;
        const quantityDisplay = ammoRow.querySelector('.quantity-display');
        const quantity = parseInt(quantityDisplay.textContent, 10) || 0;

        if (quantity == 0) {
            ammoRow.classList.remove('item-in-use');
            return;
        }

        ammoRow.classList.add('item-in-use');
        ammoSumList.push([ammoId, quantity, ammoMass]);
    });

    const itemList = document.querySelectorAll('.item-list li');
    itemList.forEach(itemRow => {
        const itemId = itemRow.dataset.itemId;
        const itemMass = parseFloat(itemRow.dataset.itemMass) || 0;
        const quantityDisplay = itemRow.querySelector('.quantity-display');
        const quantity = parseInt(quantityDisplay.textContent, 10) || 0;

        if (quantity == 0) {
            itemRow.classList.remove('item-in-use');
            return;
        }

        itemRow.classList.add('item-in-use');
        ammoSumList.push([itemId, quantity, itemMass]);
    });

    const weaponData = document.weaponData || [];
    const magazineData = document.magazineData || [];

    document.playerLoadout[0][4] = [];
    document.playerLoadout[0][5] = [];
    document.playerLoadout[1][4] = [];
    document.playerLoadout[2][4] = [];

    const primaryWeapon = document.playerLoadout[0][0];
    const primaryWeaponData = weaponData.find(weapon => weapon[0] === primaryWeapon);
    const primaryCompatibleMags1 = primaryWeaponData ? primaryWeaponData[8] : [];
    for (let i = 0; i < ammoSumList.length; i++) {
        const ammoSum = ammoSumList[i];
        const [ammoId] = ammoSum;
        const magData = magazineData.find(mag => mag[0] === ammoId);
        if (ammoId && magData && primaryCompatibleMags1.includes(ammoId)) {
            document.playerLoadout[0][4] = [ammoId, magData[4]];
            ammoSumList[i][1]--;
            break;
        }
    }
    const primaryCompatibleMags2 = primaryWeaponData ? primaryWeaponData[9] : [];
    for (let i = 0; i < ammoSumList.length; i++) {
        const ammoSum = ammoSumList[i];
        const [ammoId] = ammoSum;
        const magData = magazineData.find(mag => mag[0] === ammoId);
        if (ammoId && magData && primaryCompatibleMags2.includes(ammoId)) {
            document.playerLoadout[0][5] = [ammoId, magData[4]];
            ammoSumList[i][1]--;
            break;
        }
    }

    const launcherWeapon = document.playerLoadout[1][0];
    const launcherWeaponData = weaponData.find(weapon => weapon[0] === launcherWeapon);
    const launcherCompatibleMags = launcherWeaponData ? launcherWeaponData[8] : [];
    for (let i = 0; i < ammoSumList.length; i++) {
        const ammoSum = ammoSumList[i];
        const [ammoId] = ammoSum;
        const magData = magazineData.find(mag => mag[0] === ammoId);
        if (ammoId && magData && launcherCompatibleMags.includes(ammoId)) {
            document.playerLoadout[1][4] = [ammoId, magData[4]];
            ammoSumList[i][1]--;
            break;
        }
    }

    const secondaryWeapon = document.playerLoadout[2][0];
    const secondaryWeaponData = weaponData.find(weapon => weapon[0] === secondaryWeapon);
    const secondaryCompatibleMags = secondaryWeaponData ? secondaryWeaponData[8] : [];
    for (let i = 0; i < ammoSumList.length; i++) {
        const ammoSum = ammoSumList[i];
        const [ammoId] = ammoSum;
        const magData = magazineData.find(mag => mag[0] === ammoId);
        if (ammoId && magData && secondaryCompatibleMags.includes(ammoId)) {
            document.playerLoadout[2][4] = [ammoId, magData[4]];
            ammoSumList[i][1]--;
            break;
        }
    }

    const currentUniform = document.playerLoadout[3][0];
    const uniformData = weaponData.find(weapon => weapon[0] === currentUniform);
    let uniformCapacity = uniformData ? uniformData[5] : 0;

    const currentVest = document.playerLoadout[4][0];
    const vestData = weaponData.find(weapon => weapon[0] === currentVest);
    let vestCapacity = vestData ? vestData[5] : 0;

    const currentBackpack = document.playerLoadout[5][0];
    const backpackData = weaponData.find(weapon => weapon[0] === currentBackpack);
    let backpackCapacity = backpackData ? backpackData[5] : 0;

    const uniformAmmos = {};
    const vestAmmos = {};
    const backpackAmmos = {};

    while (ammoSumList.length > 0) {
        let [ammoId, quantity, ammoMass] = ammoSumList.shift();

        while (quantity > 0) {
            if (uniformCapacity >= ammoMass) {
                uniformCapacity -= ammoMass;
                uniformAmmos[ammoId] = (uniformAmmos[ammoId] || 0) + 1;
            } else if (vestCapacity >= ammoMass) {
                vestCapacity -= ammoMass;
                vestAmmos[ammoId] = (vestAmmos[ammoId] || 0) + 1;
            } else if (backpackCapacity >= ammoMass && currentBackpack) {
                backpackCapacity -= ammoMass;
                backpackAmmos[ammoId] = (backpackAmmos[ammoId] || 0) + 1;
            }
            quantity--;
        }
    }

    const uniformAmmosList = [];
    for (const key in uniformAmmos) {
        const magData = magazineData.find(mag => mag[0] === key);
        if (document.itemList[key] === 1) {
            uniformAmmosList.push([key, uniformAmmos[key], 1]);
        } else if (magData) {
            const magCount = magData[4];
            uniformAmmosList.push([key, uniformAmmos[key], magCount]);
        } else {
            uniformAmmosList.push([key, uniformAmmos[key]]);
        }
    }

    const vestAmmosList = [];
    for (const key in vestAmmos) {
        const magData = magazineData.find(mag => mag[0] === key);
        if (document.itemList[key] === 1) {
            vestAmmosList.push([key, vestAmmos[key], 1]);
        } else if (magData) {
            const magCount = magData[4];
            vestAmmosList.push([key, vestAmmos[key], magCount]);
        } else {
            vestAmmosList.push([key, vestAmmos[key]]);
        }
    }

    const backpackAmmosList = [];
    for (const key in backpackAmmos) {
        const magData = magazineData.find(mag => mag[0] === key);
        if (document.itemList[key] === 1) {
            backpackAmmosList.push([key, backpackAmmos[key], 1]);
        } else if (magData) {
            const magCount = magData[4];
            backpackAmmosList.push([key, backpackAmmos[key], magCount]);
        } else {
            backpackAmmosList.push([key, backpackAmmos[key]]);
        }
    }

    document.playerLoadout[3][1] = uniformAmmosList;
    document.playerLoadout[4][1] = vestAmmosList;
    if (document.playerLoadout[5][0]) {
        document.playerLoadout[5][1] = backpackAmmosList;
    }

    selectionChanged();
}

function getAllMagazinesInLoadout() {
    const allMagazinesInLoadout = {};
    const uniformMags = document.playerLoadout[3][1];
    if (uniformMags) {
        uniformMags.forEach(mag => {
            const magName = mag[0];
            allMagazinesInLoadout[magName] = (allMagazinesInLoadout[magName] || 0) + mag[1];
        });
    }
    const vestMags = document.playerLoadout[4][1];
    if (vestMags) {
        vestMags.forEach(mag => {
            const magName = mag[0];
            allMagazinesInLoadout[magName] = (allMagazinesInLoadout[magName] || 0) + mag[1];
        });
    }
    const backpackMags = document.playerLoadout[5][1];
    if (backpackMags) {
        backpackMags.forEach(mag => {
            const magName = mag[0];
            allMagazinesInLoadout[magName] = (allMagazinesInLoadout[magName] || 0) + mag[1];
        });
    }

    const primaryMag1 = document.playerLoadout[0][4];
    if (primaryMag1) {
        const primaryMagName = primaryMag1[0];
        allMagazinesInLoadout[primaryMagName] = (allMagazinesInLoadout[primaryMagName] || 0) + 1;
    }

    const primaryMag2 = document.playerLoadout[0][5];
    if (primaryMag2) {
        const primaryMagName = primaryMag2[0];
        allMagazinesInLoadout[primaryMagName] = (allMagazinesInLoadout[primaryMagName] || 0) + 1;
    }

    const launcherMag = document.playerLoadout[1][4];
    if (launcherMag) {
        const launcherMagName = launcherMag[0];
        allMagazinesInLoadout[launcherMagName] = (allMagazinesInLoadout[launcherMagName] || 0) + 1;
    }

    const secondaryMag = document.playerLoadout[2][4];
    if (secondaryMag) {
        const secondaryMagName = secondaryMag[0];
        allMagazinesInLoadout[secondaryMagName] = (allMagazinesInLoadout[secondaryMagName] || 0) + 1;
    }

    return allMagazinesInLoadout;
}

function weaponChanged() {
    if (!document.playerLoadout) {
        return;
    }

    const weaponData = document.weaponData || [];
    const magazineData = document.magazineData || [];

    const compatibleMags = [];
    const primaryWeapon = document.playerLoadout[0][0];
    const launcherWeapon = document.playerLoadout[1][0];
    const secondaryWeapon = document.playerLoadout[2][0];
    weaponData.forEach(weapon => {
        if ([primaryWeapon, launcherWeapon, secondaryWeapon].includes(weapon[0])) {
            compatibleMags.push(...weapon[8]);
            compatibleMags.push(...weapon[9]);
        }
    });

    const primaryWeaponData = weaponData.find(weapon => weapon[0] === primaryWeapon);
    if (primaryWeaponData) {
        if (!primaryWeaponData[8].includes(document.playerLoadout[0][4][0])) {
            document.playerLoadout[0][4] = [];
        }
        if (!primaryWeaponData[9].includes(document.playerLoadout[0][5][0])) {
            document.playerLoadout[0][5] = [];
        }
    }

    const launcherWeaponData = weaponData.find(weapon => weapon[0] === launcherWeapon);
    if (launcherWeaponData) {
        if (!launcherWeaponData[8].includes(document.playerLoadout[1][4][0])) {
            document.playerLoadout[1][4] = [];
        }
    }

    const secondaryWeaponData = weaponData.find(weapon => weapon[0] === secondaryWeapon);
    if (secondaryWeaponData) {
        if (!secondaryWeaponData[8].includes(document.playerLoadout[2][4][0])) {
            document.playerLoadout[2][4] = [];
        }
    }

    selectionChanged();

    const previousCompatibleMags = new Set();
    document.querySelectorAll('.ammo-list li').forEach(li => {
        previousCompatibleMags.add(li.dataset.ammoId);
    });
    const newCompatibleMags = new Set(compatibleMags);

    if (previousCompatibleMags.size === newCompatibleMags.size && [...previousCompatibleMags].every(mag => newCompatibleMags.has(mag))) {
        return;
    }

    document.ammoAttentionNeeded = true;

    const ammoList = document.querySelector('.ammo-list');
    ammoList.innerHTML = '';

    const allMagazinesInLoadout = getAllMagazinesInLoadout();

    compatibleMags.forEach(mag => {
        const magData = magazineData.find(magazine => magazine[0] === mag);

        const ammoRow = document.createElement('li');
        ammoRow.className = 'ammo-row';
        ammoRow.dataset.ammoId = mag;
        ammoRow.dataset.ammoMass = magData[3];

        const ammoIconImg = document.createElement('img');
        ammoIconImg.className = 'ammo-icon';
        ammoRow.appendChild(ammoIconImg);

        const ammoText = document.createElement('span');
        ammoText.textContent = magData[1];
        ammoRow.appendChild(ammoText);

        const quantityContainer = document.createElement('div');
        quantityContainer.className = 'quantity-container';

        const minusButton = document.createElement('button');
        minusButton.textContent = '-';
        minusButton.className = 'quantity-minus';
        minusButton.addEventListener('mousedown', () => {
            const currentQuantity = parseInt(quantityDisplay.textContent, 10);
            if (currentQuantity > 0) {
                quantityDisplay.textContent = currentQuantity - 1;
                ammoChanged();
            }
        });

        const quantityDisplay = document.createElement('span');
        quantityDisplay.textContent = (allMagazinesInLoadout[mag] || 0) + "";
        quantityDisplay.className = 'quantity-display';

        const plusButton = document.createElement('button');
        plusButton.textContent = '+';
        plusButton.className = 'quantity-plus';
        plusButton.addEventListener('mousedown', () => {
            const currentQuantity = parseInt(quantityDisplay.textContent, 10);
            quantityDisplay.textContent = currentQuantity + 1;
            ammoChanged();
        });

        quantityContainer.appendChild(minusButton);
        quantityContainer.appendChild(quantityDisplay);
        quantityContainer.appendChild(plusButton);

        ammoRow.appendChild(quantityContainer);
        ammoList.appendChild(ammoRow);

        populateImage(ammoIconImg, magData[2]);
    });
}

function selectionChanged() {
    if (!document.readyToSend) {
        return;
    }
    if (!document.playerLoadout) {
        return;
    }
    // console.log(JSON.stringify(document.playerLoadout));
    const playerLoadoutJSON = JSON.stringify(document.playerLoadout);
    A3API.SendAlert(playerLoadoutJSON);
}

function handleAttachmentSelection() {
    if (!document.playerLoadout) {
        return;
    }

    const primaryPanel = document.querySelector('.panel-primary');
    const secondaryPanel = document.querySelector('.panel-secondary');

    const primaryOptic = primaryPanel.querySelector('.selected-optic');
    const primaryOpticId = primaryOptic ? primaryOptic.dataset.opticId : "";
    const primaryMuzzle = primaryPanel.querySelector('.selected-muzzle');
    const primaryMuzzleId = primaryMuzzle ? primaryMuzzle.dataset.muzzleId : "";
    const primaryBipod = primaryPanel.querySelector('.selected-bipod');
    const primaryBipodId = primaryBipod ? primaryBipod.dataset.bipodId : "";

    document.playerLoadout[0][3] = primaryOpticId;
    document.playerLoadout[0][1] = primaryMuzzleId;
    document.playerLoadout[0][2] = primaryBipodId;

    const secondaryOptic = secondaryPanel.querySelector('.selected-optic');
    const secondaryOpticId = secondaryOptic ? secondaryOptic.dataset.opticId : "";
    const secondaryMuzzle = secondaryPanel.querySelector('.selected-muzzle');
    const secondaryMuzzleId = secondaryMuzzle ? secondaryMuzzle.dataset.muzzleId : "";
    const secondaryBipod = secondaryPanel.querySelector('.selected-bipod');
    const secondaryBipodId = secondaryBipod ? secondaryBipod.dataset.bipodId : "";

    document.playerLoadout[2][3] = secondaryOpticId;
    document.playerLoadout[2][1] = secondaryMuzzleId;
    document.playerLoadout[2][2] = secondaryBipodId;
}

function createOpticRow(optic, parentPanel) {
    const opticRow = document.createElement('li');
    opticRow.className = 'optic-row';
    opticRow.dataset.opticId = optic[0];
    opticRow.dataset.opticName = optic[1];
    opticRow.innerHTML = `<img class="optic-icon" />${optic[1]}`;
    parentPanel.querySelector('.optic-list').appendChild(opticRow);
    populateImage(opticRow.querySelector('.optic-icon'), optic[2]);

    opticRow.addEventListener('mousedown', function () {
        document.querySelectorAll('.optic-row').forEach(row => row.classList.remove('selected-optic'));
        this.classList.add('selected-optic');

        handleAttachmentSelection();

        selectionChanged();
    });
}

function createMuzzleRow(muzzle, parentPanel) {
    const muzzleRow = document.createElement('li');
    muzzleRow.className = 'muzzle-row';
    muzzleRow.dataset.muzzleId = muzzle[0];
    muzzleRow.dataset.muzzleName = muzzle[1];
    muzzleRow.innerHTML = `<img class="muzzle-icon" />${muzzle[1]}`;
    parentPanel.querySelector('.muzzle-list').appendChild(muzzleRow);
    populateImage(muzzleRow.querySelector('.muzzle-icon'), muzzle[2]);

    muzzleRow.addEventListener('mousedown', function () {
        document.querySelectorAll('.muzzle-row').forEach(row => row.classList.remove('selected-muzzle'));
        this.classList.add('selected-muzzle');

        if (parentPanel.classList.contains('panel-primary')) {
            document.playerLoadout[0][1] = muzzle[0];
        } else if (parentPanel.classList.contains('panel-secondary')) {
            document.playerLoadout[2][1] = muzzle[0];
        } else if (parentPanel.classList.contains('panel-launcher')) {
            document.playerLoadout[1][1] = muzzle[0];
        }

        selectionChanged();
    });
}

function createBipodRow(bipod, parentPanel) {
    const bipodRow = document.createElement('li');
    bipodRow.className = 'bipod-row';
    bipodRow.dataset.bipodId = bipod[0];
    bipodRow.dataset.bipodName = bipod[1];
    bipodRow.innerHTML = `<img class="bipod-icon" />${bipod[1]}`;
    parentPanel.querySelector('.bipod-list').appendChild(bipodRow);
    populateImage(bipodRow.querySelector('.bipod-icon'), bipod[2]);

    bipodRow.addEventListener('mousedown', function () {
        document.querySelectorAll('.bipod-row').forEach(row => row.classList.remove('selected-bipod'));
        this.classList.add('selected-bipod');

        if (parentPanel.classList.contains('panel-primary')) {
            document.playerLoadout[0][6] = bipod[0];
        } else if (parentPanel.classList.contains('panel-secondary')) {
            document.playerLoadout[2][6] = bipod[0];
        } else if (parentPanel.classList.contains('panel-launcher')) {
            document.playerLoadout[1][6] = bipod[0];
        }

        selectionChanged();
    });
}

function handleWeaponRowClick(weaponRow, weapon, panel) {
    panel.querySelectorAll('.weapon-row').forEach(row => row.classList.remove('selected-weapon'));
    weaponRow.classList.add('selected-weapon');

    if (panel.classList.contains('panel-primary')) {
        const leftPanelWeaponIcon = document.querySelector('.primary-icon');
        if (!weapon || weapon[3] === "") {
            leftPanelWeaponIcon.style.display = 'none';
        } else {
            leftPanelWeaponIcon.style.display = 'block';
            populateImage(leftPanelWeaponIcon, weapon[3]);
        }
    } else if (panel.classList.contains('panel-secondary')) {
        const leftPanelWeaponIcon = document.querySelector('.secondary-icon');
        if (!weapon || weapon[3] === "") {
            leftPanelWeaponIcon.style.display = 'none';
        } else {
            leftPanelWeaponIcon.style.display = 'block';
            populateImage(leftPanelWeaponIcon, weapon[3]);
        }
    } else if (panel.classList.contains('panel-launcher')) {
        const leftPanelWeaponIcon = document.querySelector('.launcher-icon');
        if (!weapon || weapon[3] === "") {
            leftPanelWeaponIcon.style.display = 'none';
        } else {
            leftPanelWeaponIcon.style.display = 'block';
            populateImage(leftPanelWeaponIcon, weapon[3]);
        }
    }

    if (weapon && !panel.classList.contains('panel-launcher')) {
        const optics = weapon[5] || [];
        const muzzles = weapon[6] || [];
        const bipods = weapon[7] || [];

        const opticsListEl = panel.querySelector('.optic-list');
        opticsListEl.innerHTML = '';
        const muzzlesListEl = panel.querySelector('.muzzle-list');
        muzzlesListEl.innerHTML = '';
        const bipodsListEl = panel.querySelector('.bipod-list');
        bipodsListEl.innerHTML = '';

        optics.forEach(optic => createOpticRow(optic, panel));
        muzzles.forEach(muzzle => createMuzzleRow(muzzle, panel));
        bipods.forEach(bipod => createBipodRow(bipod, panel));

        // sort
        const opticRows = Array.from(opticsListEl.querySelectorAll('.optic-row'));
        opticRows.sort((a, b) => {
            const aName = a.dataset.opticName.trim() || "ZZZ";
            const bName = b.dataset.opticName.trim() || "ZZZ";
            if (aName === "None") return -1;
            if (bName === "None") return 1;
            return aName.localeCompare(bName);
        });
        opticRows.forEach(row => opticsListEl.appendChild(row));

        const muzzleRows = Array.from(muzzlesListEl.querySelectorAll('.muzzle-row'));
        muzzleRows.sort((a, b) => {
            const aName = a.dataset.muzzleName.trim() || "ZZZ";
            const bName = b.dataset.muzzleName.trim() || "ZZZ";
            if (aName === "None") return -1;
            if (bName === "None") return 1;
            return aName.localeCompare(bName);
        });
        muzzleRows.forEach(row => muzzlesListEl.appendChild(row));

        const bipodRows = Array.from(bipodsListEl.querySelectorAll('.bipod-row'));
        bipodRows.sort((a, b) => {
            const aName = a.dataset.bipodName.trim() || "ZZZ";
            const bName = b.dataset.bipodName.trim() || "ZZZ";
            if (aName === "None") return -1;
            if (bName === "None") return 1;
            return aName.localeCompare(bName);
        });
        bipodRows.forEach(row => bipodsListEl.appendChild(row));
    }

    if (document.playerLoadout) {
        if (panel.classList.contains('panel-primary')) {
            changeAttachments(document.playerLoadout[0], weapon, panel);
        } else if (panel.classList.contains('panel-secondary')) {
            changeAttachments(document.playerLoadout[2], weapon, panel);
        } else if (panel.classList.contains('panel-launcher')) {
            changeAttachments(document.playerLoadout[1], weapon, panel);
        }
    }

    weaponChanged();
}

function changeAttachments(loadout, weapon, panel) {
    let weaponId = "";
    let optics = [];
    let muzzles = [];
    let bipods = [];
    if (weapon && weapon.length > 0) {
        weaponId = weapon[0];
        optics = (weapon[5] || []).map(optic => optic[0]);
        muzzles = (weapon[6] || []).map(muzzle => muzzle[0]);
        bipods = (weapon[7] || []).map(bipod => bipod[0]);
    }
    loadout[0] = weaponId || "";
    if (weaponId === "") {
        loadout[1] = "";
        loadout[3] = "";
        loadout[6] = "";
    } else {
        if (!muzzles.includes(loadout[1])) {
            loadout[1] = "";
            console.log(loadout);
        }
        if (!optics.includes(loadout[3])) {
            loadout[3] = "";
        }
        if (!bipods.includes(loadout[6])) {
            loadout[6] = "";
        }
    }

    selectAttachmentRows(loadout, panel);
}

function createWeaponRow(weapon, panel) {
    const weaponId = weapon[0];
    let weaponReadableName = weapon[2];
    const weaponIcon = weapon[3];
    const weaponRow = document.createElement('li');
    weaponRow.className = 'weapon-row';
    weaponRow.dataset.weaponId = weaponId;
    weaponRow.dataset.weaponName = weaponReadableName;

    const weaponLevel = weapon[4];
    if (weaponLevel > document.playerLevel) {
        weaponRow.classList.add('locked');
        weaponReadableName += `&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [Requires: Level ${weaponLevel}]`;
    } else {
        weaponRow.classList.remove('locked');
    }

    if (weaponIcon === "") {
        weaponRow.innerHTML = weaponReadableName;
    } else {
        weaponRow.innerHTML = `<img class="weapon-icon" />${weaponReadableName}`;
        populateImage(weaponRow.querySelector('.weapon-icon'), weaponIcon);
    }

    panel.querySelector('.weapon-list').appendChild(weaponRow);

    weaponRow.addEventListener('mousedown', function () {
        if (this.classList.contains('locked')) {
            return;
        }
        handleWeaponRowClick(weaponRow, weapon, panel);
    });
}

function handleOutfitRowClick(outfitRow, outfit, panel) {
    panel.querySelectorAll('.outfit-row').forEach(row => row.classList.remove('selected-outfit'));
    outfitRow.classList.add('selected-outfit');

    if (panel.classList.contains('panel-vest')) {
        const leftPanelVestIcon = document.querySelector('.vest-icon');
        populateImage(leftPanelVestIcon, outfit[3]);
    } else if (panel.classList.contains('panel-uniform')) {
        const leftPanelUniformIcon = document.querySelector('.uniform-icon');
        populateImage(leftPanelUniformIcon, outfit[3]);
    } else if (panel.classList.contains('panel-helmet')) {
        const leftPanelHelmetIcon = document.querySelector('.helmet-icon');
        populateImage(leftPanelHelmetIcon, outfit[3]);
    }

    if (!document.playerLoadout) {
        return;
    }

    if (panel.classList.contains('panel-vest')) {
        document.playerLoadout[4][0] = outfit[0];
    } else if (panel.classList.contains('panel-uniform')) {
        document.playerLoadout[3][0] = outfit[0];
    } else if (panel.classList.contains('panel-helmet')) {
        document.playerLoadout[6] = outfit[0];
    }

    weaponChanged();
    ammoChanged();
    selectionChanged();
}

function createOutfitRow(outfit, panel) {
    const outfitId = outfit[0];
    let outfitReadableName = outfit[2];
    const outfitIcon = outfit[3];
    const outfitRow = document.createElement('li');
    outfitRow.className = 'outfit-row';
    outfitRow.dataset.outfitId = outfitId;
    outfitRow.dataset.outfitName = outfitReadableName;

    const outfitLevel = outfit[4];
    if (outfitLevel > document.playerLevel) {
        outfitRow.classList.add('locked');
        outfitReadableName += `&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [Requires: Level ${outfitLevel}]`;
    } else {
        outfitRow.classList.remove('locked');
    }

    outfitRow.innerHTML = `<img class="outfit-icon" />${outfitReadableName}`;

    panel.querySelector('.outfit-list').appendChild(outfitRow);
    populateImage(outfitRow.querySelector('.outfit-icon'), outfitIcon);

    outfitRow.addEventListener('mousedown', function () {
        if (this.classList.contains('locked')) {
            return;
        }
        handleOutfitRowClick(outfitRow, outfit, panel);
    });
}

function handleBackpackRowClick(backpackRow, backpack, panel) {
    panel.querySelectorAll('.backpack-row').forEach(row => row.classList.remove('selected-backpack'));
    backpackRow.classList.add('selected-backpack');

    const backpackIcon = document.querySelector('.backpack-icon');
    if (backpack && backpack.length > 3 && backpack[0] !== "") {
        populateImage(backpackIcon, backpack[3]);
    } else {
        populateImage(backpackIcon, "A3\\Weapons_F\\Ammoboxes\\Bags\\data\\ui\\backpack_CA.paa");
    }

    if (!document.playerLoadout) {
        return;
    }

    if (!backpack || backpack[0] === "") {
        document.playerLoadout[5] = [];
        selectionChanged();
        return;
    }

    document.playerLoadout[5][0] = backpack[0];
    document.playerLoadout[5][1] = [];
    selectionChanged();
}

function createBackpackRow(backpack, panel) {
    const backpackId = backpack[0];
    let backpackReadableName = backpack[2];
    const backpackIcon = backpack[3];
    const backpackRow = document.createElement('li');
    backpackRow.className = 'backpack-row';
    backpackRow.dataset.backpackId = backpackId;

    const backpackLevel = backpack[4];
    if (backpackLevel > document.playerLevel) {
        backpackRow.classList.add('locked');
        backpackReadableName += `&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [Requires: Level ${backpackLevel}]`;
    } else {
        backpackRow.classList.remove('locked');
    }

    if (backpackIcon === "") {
        backpackRow.innerHTML = backpackReadableName;
    } else {
        backpackRow.innerHTML = `<img class="backpack-icon" />${backpackReadableName}`;
        populateImage(backpackRow.querySelector('.backpack-icon'), backpackIcon);
    }

    panel.querySelector('.backpack-list').appendChild(backpackRow);

    backpackRow.addEventListener('mousedown', function () {
        if (this.classList.contains('locked')) {
            return;
        }
        handleBackpackRowClick(backpackRow, backpack, panel);
    });
}

function createItemRow(item, itemList) {
    const allMagazinesInLoadout = getAllMagazinesInLoadout();
    if (item[4]) {
        document.itemList[item[0]] = 1;
    }

    const itemRow = document.createElement('li');
    itemRow.className = 'item-row';
    itemRow.dataset.itemId = item[0];
    itemRow.dataset.itemMass = item[3];

    const itemIconImg = document.createElement('img');
    itemIconImg.className = 'item-icon';
    itemRow.appendChild(itemIconImg);

    const itemText = document.createElement('span');
    itemText.textContent = item[1];
    itemRow.appendChild(itemText);

    const quantityContainer = document.createElement('div');
    quantityContainer.className = 'quantity-container';

    const minusButton = document.createElement('button');
    minusButton.textContent = '-';
    minusButton.className = 'quantity-minus';
    minusButton.addEventListener('mousedown', () => {
        const currentQuantity = parseInt(quantityDisplay.textContent, 10);
        if (currentQuantity > 0) {
            quantityDisplay.textContent = currentQuantity - 1;
            ammoChanged();
        }
    });

    const quantityDisplay = document.createElement('span');
    quantityDisplay.textContent = (allMagazinesInLoadout[item[0]] || 0) + "";
    quantityDisplay.className = 'quantity-display';

    const plusButton = document.createElement('button');
    plusButton.textContent = '+';
    plusButton.className = 'quantity-plus';
    plusButton.addEventListener('mousedown', () => {
        const currentQuantity = parseInt(quantityDisplay.textContent, 10);
        quantityDisplay.textContent = currentQuantity + 1;
        ammoChanged();
    });

    quantityContainer.appendChild(minusButton);
    quantityContainer.appendChild(quantityDisplay);
    quantityContainer.appendChild(plusButton);

    itemRow.appendChild(quantityContainer);
    itemList.appendChild(itemRow);

    populateImage(itemIconImg, item[2]);
}

function selectAttachmentRows(selectedWeaponData, panel) {
    const selectMuzzle = selectedWeaponData[1] || "";
    const selectMuzzleRow = panel.querySelector(`.muzzle-row[data-muzzle-id="${selectMuzzle}"]`);
    if (selectMuzzleRow) {
        selectMuzzleRow.classList.add('selected-muzzle');
    }

    const selectOptic = selectedWeaponData[3] || "";
    const selectOpticRow = panel.querySelector(`.optic-row[data-optic-id="${selectOptic}"]`);
    if (selectOpticRow) {
        selectOpticRow.classList.add('selected-optic');
    }

    const selectBipod = selectedWeaponData[6] || "";
    const selectBipodRow = panel.querySelector(`.bipod-row[data-bipod-id="${selectBipod}"]`);
    if (selectBipodRow) {
        selectBipodRow.classList.add('selected-bipod');
    }
}

function selectDefaultForWeapon(weaponData, defaultWeaponData, panel) {
    const selectWeaponRow = panel.querySelector(`.weapon-row[data-weapon-id="${defaultWeaponData[0]}"]`);
    const selectWeaponData = weaponData.find(weapon => weapon[0] === defaultWeaponData[0]);
    if (selectWeaponRow) {
        handleWeaponRowClick(selectWeaponRow, selectWeaponData, panel);
        selectAttachmentRows(defaultWeaponData, panel);
    } else {
        const noneWeaponRow = panel.querySelector(".weapon-row");
        handleWeaponRowClick(noneWeaponRow, null, panel);
    }
}

function selectDefaultForOutfit(weaponData, outfitId, panel) {
    const selectOutfitRow = panel.querySelector(`.outfit-row[data-outfit-id="${outfitId}"]`);
    const selectOutfitData = weaponData.find(outfit => outfit[0] === outfitId);
    if (selectOutfitRow) {
        handleOutfitRowClick(selectOutfitRow, selectOutfitData, panel);
    }
}

function selectDefaultForBackpack(weaponData, backpackId, panel) {
    const selectBackpackRow = panel.querySelector(`.backpack-row[data-backpack-id="${backpackId}"]`);
    const selectBackpackData = weaponData.find(backpack => backpack[0] === backpackId);
    if (selectBackpackRow) {
        handleBackpackRowClick(selectBackpackRow, selectBackpackData, panel);
    } else {
        const noneBackpackRow = panel.querySelector(".backpack-row");
        handleBackpackRowClick(noneBackpackRow, null, panel);
    }
}

function updateTheme(themeIndex) {
    const themes = [
        {
            backgroundColor: "#344E41",
            panelColor: "#3A5A40",
            borderColor: "#588157",
            lighterColor: "#A3B18A",
            textColor: "#DAD7CD"
        },
        {
            backgroundColor: "#355482",
            panelColor: "#35719e",
            borderColor: "#348dba",
            lighterColor: "#34a8d5",
            textColor: "#34c4f0"
        },
        {
            backgroundColor: "#051923",
            panelColor: "#003554",
            borderColor: "#006494",
            lighterColor: "#0582ca",
            textColor: "#00a6fb"
        },
        {
            backgroundColor: "#880d1e",
            panelColor: "#dd2d4a",
            borderColor: "#f26a8d",
            lighterColor: "#f49cbb",
            textColor: "#cbeef3"
        },
        {
            backgroundColor: "#1a1a1a",
            panelColor: "#424242",
            borderColor: "#686868",
            lighterColor: "#8f8f8f",
            textColor: "#b5b5b5"
        }
    ];

    const theme = themes[themeIndex - 1] || themes[0];

    const themeRoot = document.querySelector(':root');
    themeRoot.style.setProperty('--main-bg-color', theme.backgroundColor);
    themeRoot.style.setProperty('--panel-color', theme.panelColor);
    themeRoot.style.setProperty('--border-color', theme.borderColor);
    themeRoot.style.setProperty('--lighter-color', theme.lighterColor);
    themeRoot.style.setProperty('--text-color', theme.textColor);
}

function selectLoadout(loadoutIndex) {
    document.querySelectorAll('.loadout').forEach(loadout => {
        loadout.classList.remove('selected-loadout');
    });
    const loadoutEl = document.querySelector(`.loadout-${loadoutIndex + 1}`);
    loadoutEl.classList.add('selected-loadout');
}

function formatNumber(num) {
    return num.toLocaleString();
}

function updateLoadout(loadout, loadoutIndex, weaponData, magazineData, playerLevel, playerScore, playerNextLevelScore, themeIndex) {
    document.playerLoadout = undefined;
    document.readyToSend = false;

    weaponData = JSON.parse(weaponData) || [];
    loadout = JSON.parse(loadout) || [];
    magazineData = JSON.parse(magazineData) || [];
    document.weaponData = weaponData;
    document.magazineData = magazineData;
    document.itemList = {};
    document.playerLevel = playerLevel;
    document.playerScore = playerScore;
    document.playerNextLevelScore = playerNextLevelScore;

    const menuTitle = document.querySelector('.menu-title');
    menuTitle.textContent = `Loadout (Level ${playerLevel} - Score: ${formatNumber(playerScore)}/${formatNumber(playerNextLevelScore)})`;

    selectLoadout(loadoutIndex);
    updateTheme(themeIndex);

    const primaryPanel = document.querySelector('.panel-primary');
    const secondaryPanel = document.querySelector('.panel-secondary');
    const launcherPanel = document.querySelector('.panel-launcher');
    const vestPanel = document.querySelector('.panel-vest');
    const uniformPanel = document.querySelector('.panel-uniform');
    const helmetPanel = document.querySelector('.panel-helmet');
    const ammoPanel = document.querySelector('.panel-ammo');

    primaryPanel.querySelector('.weapon-list').innerHTML = '';
    secondaryPanel.querySelector('.weapon-list').innerHTML = '';
    launcherPanel.querySelector('.weapon-list').innerHTML = '';
    vestPanel.querySelector('.outfit-list').innerHTML = '';
    uniformPanel.querySelector('.outfit-list').innerHTML = '';
    helmetPanel.querySelector('.outfit-list').innerHTML = '';

    createWeaponRow(["", "primary", "None", "", 0, 0, [], [], [], [], []], primaryPanel);
    createWeaponRow(["", "secondary", "None", "", 0, 0, [], [], [], [], []], secondaryPanel);
    createWeaponRow(["", "launcher", "None", "", 0, 0, [], [], [], [], []], launcherPanel);
    createBackpackRow(["", "backpack", "None", ""], ammoPanel);

    weaponData.forEach((weapon, index) => {
        if (weapon[1] === "primary") {
            createWeaponRow(weapon, primaryPanel);
        } else if (weapon[1] === "secondary") {
            createWeaponRow(weapon, secondaryPanel);
        } else if (weapon[1] === "launcher") {
            createWeaponRow(weapon, launcherPanel);
        } else if (weapon[1] === "vest") {
            createOutfitRow(weapon, vestPanel);
        } else if (weapon[1] === "uniform") {
            createOutfitRow(weapon, uniformPanel);
        } else if (weapon[1] === "helmet") {
            createOutfitRow(weapon, helmetPanel);
        } else if (weapon[1] === "backpack") {
            createBackpackRow(weapon, ammoPanel);
        }
    });

    selectDefaultForWeapon(weaponData, loadout[0], primaryPanel);
    selectDefaultForWeapon(weaponData, loadout[1], launcherPanel);
    selectDefaultForWeapon(weaponData, loadout[2], secondaryPanel);

    selectDefaultForOutfit(weaponData, loadout[4][0], vestPanel);
    selectDefaultForOutfit(weaponData, loadout[3][0], uniformPanel);
    selectDefaultForOutfit(weaponData, loadout[6], helmetPanel);

    selectDefaultForBackpack(weaponData, loadout[5][0], ammoPanel);

    document.querySelectorAll(".weapon-list").forEach(list => {
        const rows = Array.from(list.querySelectorAll('.weapon-row'));
        rows.sort((a, b) => {
            const aName = a.dataset.weaponName.trim() || "ZZZ";
            const bName = b.dataset.weaponName.trim() || "ZZZ";
            if (aName === "None") return -1;
            if (bName === "None") return 1;
            return aName.localeCompare(bName);
        });
        rows.forEach(row => list.appendChild(row));
    });

    document.querySelectorAll(".outfit-list").forEach(list => {
        const rows = Array.from(list.querySelectorAll('.outfit-row'));
        rows.sort((a, b) => {
            const aName = a.dataset.outfitName.trim() || "ZZZ";
            const bName = b.dataset.outfitName.trim() || "ZZZ";
            if (aName === "None") return -1;
            if (bName === "None") return 1;
            return aName.localeCompare(bName);
        });
        rows.forEach(row => list.appendChild(row));
    });

    scrollPanelIntoView(primaryPanel);

    document.playerLoadout = loadout;
    const itemList = ammoPanel.querySelector('.item-list');
    itemList.innerHTML = '';
    createItemRow(["FirstAidKit", "First Aid Kit", "A3\\Weapons_F\\Items\\data\\UI\\gear_FirstAidKit_CA.paa", 8, false], itemList);
    createItemRow(["HandGrenade", "RGO Grenade", "A3\\Weapons_F\\Data\\UI\\gear_M67_CA.paa", 10, true], itemList);
    createItemRow(["MiniGrenade", "RGN Grenade", "A3\\Weapons_F\\Data\\UI\\gear_M67_CA.paa", 6, true], itemList);
    createItemRow(["SmokeShell", "Smoke Grenade (White)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_white_ca.paa", 4, true], itemList);
    createItemRow(["SmokeShellRed", "Smoke Grenade (Red)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_red_ca.paa", 4, true], itemList);
    createItemRow(["SmokeShellGreen", "Smoke Grenade (Green)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_green_ca.paa", 4, true], itemList);
    createItemRow(["SmokeShellBlue", "Smoke Grenade (Blue)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_blue_ca.paa", 4, true], itemList);
    createItemRow(["SmokeShellYellow", "Smoke Grenade (Yellow)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_yellow_ca.paa", 4, true], itemList);
    createItemRow(["SmokeShellOrange", "Smoke Grenade (Orange)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_orange_ca.paa", 4, true], itemList);
    createItemRow(["SmokeShellPurple", "Smoke Grenade (Purple)", "A3\\Weapons_f\\data\\ui\\gear_smokegrenade_purple_ca.paa", 4, true], itemList);

    createItemRow(["Chemlight_blue", "Chemlight (Blue)", "A3\\Weapons_f\\Data\\UI\\M_chemlight_blue_CA.paa", 2, true], itemList);
    createItemRow(["Chemlight_green", "Chemlight (Green)", "A3\\Weapons_f\\Data\\UI\\M_chemlight_green_CA.paa", 2, true], itemList);
    createItemRow(["Chemlight_red", "Chemlight (Red)", "A3\\Weapons_f\\Data\\UI\\M_chemlight_red_CA.paa", 2, true], itemList);
    createItemRow(["Chemlight_yellow", "Chemlight (Yellow)", "A3\\Weapons_f\\Data\\UI\\M_chemlight_yellow_CA.paa", 2, true], itemList);

    const ammoIconContainer = document.querySelector('.ammo-icon-container');

    const bulletsImage = ammoIconContainer.querySelector('.bullets-icon');
    populateImage(bulletsImage, "a3\\Weapons_F\\MagazineProxies\\data\\UI\\icon_100Rnd_65x39_caseless_khaki_mag_tracer_CA.paa");

    const grenadesImage = ammoIconContainer.querySelector('.grenades-icon');
    populateImage(grenadesImage, "A3\\Weapons_f\\data\\ui\\gear_M67_CA.paa");

    const firstAidKitImage = ammoIconContainer.querySelector('.fak-icon');
    populateImage(firstAidKitImage, "A3\\Weapons_f\\Items\\data\\UI\\gear_FirstAidKit_CA.paa");

    handleAttachmentSelection();
    weaponChanged();
    ammoChanged();
    document.readyToSend = true;
    selectionChanged();
    document.ammoAttentionNeeded = false;
}

let frameTime = 0, frameCount = 0;
let lastLoop = performance.now();
const fpsLoop = () => {
    const thisLoop = performance.now();
    frameTime += (thisLoop - lastLoop - frameTime) / 20;
    lastLoop = thisLoop;
    frameCount++;
    requestAnimationFrame(fpsLoop);
};
const fpsOut = document.querySelector('.fps-display');
setInterval(() => {
    if (frameCount > 60) {
        fpsOut.textContent = `MENU FPS: ${(1000 / frameTime).toFixed(2)}`;
    } else {
        fpsOut.textContent = `MENU FPS: -`;
    }
}, 100);
fpsLoop();