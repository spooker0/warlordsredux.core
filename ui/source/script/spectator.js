const speedLevel = document.querySelector('.speed-slider');
const zoomLevel = document.querySelector('.zoom-slider');
const controlsInfoEl = document.querySelector('.controls-info');
const targetInfoEl = document.querySelector('.target-info');
const targetNameEl = document.querySelector('.target-name');
const targetModeEl = document.querySelector('.target-mode');

let hideSpeedTimeout;
let hideZoomTimeout;
let hideTargetNameTimeout;
let hideTargetModeTimeout;

zoomLevel.style.opacity = 0;
speedLevel.style.opacity = 0;
targetNameEl.style.opacity = 0;
targetModeEl.style.opacity = 0;

function setControlsInfo(info) {
    const controlNamesEl = controlsInfoEl.querySelector('.control-names');
    const controlKeysEl = controlsInfoEl.querySelector('.control-keys');
    controlNamesEl.innerHTML = info[0];
    controlKeysEl.innerHTML = info[1];
}

function setTargetInfo(info) {
    targetInfoEl.innerHTML = info;
}

function updateSpeedLevel(value) {
    speedLevel.value = value;
    speedLevel.style.opacity = 1;

    clearTimeout(hideSpeedTimeout);
    hideSpeedTimeout = setTimeout(() => {
        speedLevel.style.opacity = 0;
    }, 5000);
}

function updateZoomLevel(value) {
    zoomLevel.value = value;
    zoomLevel.style.opacity = 1;

    clearTimeout(hideZoomTimeout);
    hideZoomTimeout = setTimeout(() => {
        zoomLevel.style.opacity = 0;
    }, 5000);
}

function updateTargetName(name) {
    targetNameEl.textContent = `Spectating: ${name}`;
    targetNameEl.style.opacity = 1;

    clearTimeout(hideTargetNameTimeout);
    hideTargetNameTimeout = setTimeout(() => {
        targetNameEl.style.opacity = 0;
    }, 5000);
}

function updateTargetMode(mode) {
    const modes = ["Bird Eye", "First Person", "Third Person", "Gunner"];

    targetModeEl.textContent = `Mode: ${modes[mode]}`;
    targetModeEl.style.opacity = 1;

    clearTimeout(hideTargetModeTimeout);
    hideTargetModeTimeout = setTimeout(() => {
        targetModeEl.style.opacity = 0;
    }, 5000);
}