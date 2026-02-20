// ===== Simplified version =====

const DISTANCE_STEPS = [
    0, 250, 500, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000,
    10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000, 19000, 20000
];

function clampToRange(v, min, max) {
    return Math.max(min, Math.min(max, v));
}

function getWrapper() {
    return document.querySelector('.hmd-wrapper');
}

function getRows() {
    return Array.from(getWrapper().querySelectorAll('.hmd-setting'));
}

function getRowByIndex(i) {
    return getRows()[i];
}

function getCurrentRow() {
    return getRowByIndex(document.currentSettingIndex);
}

function getNum(row, key) {
    return Number(row.dataset[key]);
}

function isDistance(row) {
    return row.dataset.isDistance === '1';
}

function getSteps(min, max) {
    return DISTANCE_STEPS.filter(s => s >= min && s <= max);
}

function snapToNearest(value, min, max) {
    const steps = getSteps(min, max);
    let nearest = steps[0];
    let diff = Math.abs(value - nearest);
    for (let i = 1; i < steps.length; i++) {
        const d = Math.abs(value - steps[i]);
        if (d < diff) {
            nearest = steps[i];
            diff = d;
        }
    }
    return nearest;
}

function isProfile(row) {
    return (row.dataset.name || '').toUpperCase() === 'PROFILE';
}

function getNextDistanceValue(current, dir, min, max) {
    const steps = getSteps(min, max);
    const index = steps.indexOf(current);
    if (index !== -1) {
        return steps[clampToRange(index + dir, 0, steps.length - 1)];
    }
    return steps[0];
}

function updateLabel(row, value) {
    const offset = Number(row.dataset.offset || '0');
    row.querySelector('.hmd-slider').value = value;
    row.querySelector('.hmd-setting-name').textContent =
        `${row.dataset.name}: ${value + offset}`;
}

function setRowValue(row, value) {
    const min = getNum(row, 'min');
    const max = getNum(row, 'max');
    value = isDistance(row) ? snapToNearest(value, min, max) : clampToRange(value, min, max);
    row.dataset.value = value;
    updateLabel(row, value);

    A3API.SendAlert(`["${row.dataset.name}", ${value}]`);
}

function bumpRow(row, dir) {
    const min = getNum(row, 'min');
    const max = getNum(row, 'max');
    const val = getNum(row, 'value');
    const next = isDistance(row)
        ? getNextDistanceValue(val, dir, min, max)
        : clampToRange(val + dir, min, max);
    setRowValue(row, next);
}

function settingPlus() {
    bumpRow(getCurrentRow(), +1);
}

function settingMinus() {
    bumpRow(getCurrentRow(), -1);
}

function setCurrentSetting(i) {
    const rows = getRows();
    document.currentSettingIndex = clampToRange(i, 0, rows.length - 1);
    rows.forEach((row, index) => {
        row.querySelector('.hmd-selector').textContent = index === document.currentSettingIndex ? '[>]' : '[ ]';
        row.classList.toggle('selected', index === document.currentSettingIndex);
    });
}

function currentSettingNext() {
    const rows = getRows();
    setCurrentSetting((document.currentSettingIndex + 1) % rows.length);

    const name = getCurrentRow().dataset.name;
    A3API.SendAlert(`["${name}"]`);
}

function currentSettingPrev() {
    const rows = getRows();
    setCurrentSetting((document.currentSettingIndex - 1 + rows.length) % rows.length);

    const name = getCurrentRow().dataset.name;
    A3API.SendAlert(`["${name}"]`);
}

function updateHmdData(settingsData, currentIndex) {
    settingsData = JSON.parse(settingsData) || [];

    const wrapper = getWrapper();
    wrapper.innerHTML = '<p class="hmd-settings-title">HMD SETTINGS</p>';

    settingsData.forEach(([name, min, max, value, dist]) => {
        let nMin = Number(min);
        let nMax = Number(max);
        let nVal = Number(value);
        let offset = 0;

        if ((name || '').toUpperCase() === 'PROFILE') {
            nMin = 0;
            nMax = 4;
            nVal = clampToRange(Number.isFinite(nVal) ? nVal : 0, nMin, nMax);
            offset = 1;
        } else {
            nVal = clampToRange(Number.isFinite(nVal) ? nVal : nMin, nMin, nMax);
        }

        const row = document.createElement('div');
        row.className = 'hmd-setting';
        row.dataset.name = name;
        row.dataset.min = nMin;
        row.dataset.max = nMax;
        row.dataset.isDistance = dist ? '1' : '0';
        row.dataset.value = nVal;
        row.dataset.offset = offset;

        const controls = document.createElement('div');
        controls.innerHTML = `
      <span class="hmd-setting-minus">&lt;</span>
      <input type="range" min="${nMin}" max="${nMax}" value="${nVal}" class="hmd-slider">
      <span class="hmd-setting-plus">&gt;</span>`;

        const selector = document.createElement('span');
        selector.className = 'hmd-selector';
        selector.textContent = '[ ]';

        const label = document.createElement('span');
        label.className = 'hmd-setting-name';
        label.textContent = `${name}: ${nVal + offset}`;

        row.append(controls, selector, label);
        wrapper.appendChild(row);
    });

    setCurrentSetting(currentIndex);
}
