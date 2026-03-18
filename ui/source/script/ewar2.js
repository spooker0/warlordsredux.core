function hideLoadingOverlay() {
    const overlay = document.getElementById('loading-overlay');
    overlay.style.display = 'none';
    const ewarMenu = document.querySelector('.ewar-menu');
    ewarMenu.style.opacity = '1.0';
}

let friendlySignalBarFillElement = null;
let friendlySignalBarTextElement = null;
let hostileSignalBarFillElement = null;
let hostileSignalBarTextElement = null;
let friendlySignalInstructionsElement = null;
let hostileSignalInstructionsElement = null;

const EWAR_EMPTY_VALUE = 0;
const EWAR_DEFAULT_BOARD_SIZE = 5;
const EWAR_MIN_BOARD_SIZE = 2;
const EWAR_MAX_BOARD_SIZE = 10;
const EWAR_CELEBRATION_DURATION_MS = 3000;

let ewarBoardSize = EWAR_DEFAULT_BOARD_SIZE;
let ewarTiles = [];
let ewarBoardElement = null;
let ewarBoardWrapperElement = null;
let ewarBoardInstructionsElement = null;
let ewarCelebrationOverlayElement = null;
let ewarCompletionTextElement = null;
let ewarCompletionTimeElement = null;
let ewarInputEnabled = true;
let ewarCelebrationTimeoutId = null;

let ewarTimerElement = null;
let ewarStartTimeMs = null;
let ewarElapsedBeforeStartMs = 0;
let ewarTimerIntervalId = null;
let ewarHasStartedTimer = false;

function done() {
    A3API.SendAlert('done');
}

function clampBoardSize(size) {
    const safeSize = Number(size);

    if (!Number.isInteger(safeSize)) {
        return EWAR_DEFAULT_BOARD_SIZE;
    }

    return Math.max(EWAR_MIN_BOARD_SIZE, Math.min(EWAR_MAX_BOARD_SIZE, safeSize));
}

function initScreen(friendlySignal, hostileSignal, size) {
    hideLoadingOverlay();

    ewarBoardSize = clampBoardSize(size);

    const ewarMenu = document.querySelector('.ewar-menu');
    ewarMenu.innerHTML = '';

    const ewarContainer = document.createElement('div');
    ewarContainer.className = 'ewar-container';

    const ewarBoard = createEwarBoard();
    const ewarBoardInstructions = createEwarBoardInstructions();
    const ewarSidePanel = createEwarSidePanel();

    const ewarLeftPanel = document.createElement('div');
    ewarLeftPanel.className = 'ewar-left-panel';

    if (ewarTimerElement) {
        ewarLeftPanel.appendChild(ewarTimerElement);
    }

    ewarLeftPanel.appendChild(ewarBoard);
    ewarLeftPanel.appendChild(ewarBoardInstructions);

    ewarContainer.appendChild(ewarLeftPanel);
    ewarContainer.appendChild(ewarSidePanel);
    ewarMenu.appendChild(ewarContainer);

    updateSignals(friendlySignal, hostileSignal);
}

function formatElapsedTime(totalMilliseconds) {
    const totalSeconds = Math.floor(totalMilliseconds / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;

    return String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
}

function getCurrentElapsedTimeMs() {
    if (!ewarHasStartedTimer || ewarStartTimeMs === null) {
        return ewarElapsedBeforeStartMs;
    }

    return ewarElapsedBeforeStartMs + (Date.now() - ewarStartTimeMs);
}

function updateTimerDisplay() {
    if (!ewarTimerElement) {
        return;
    }

    ewarTimerElement.textContent = formatElapsedTime(getCurrentElapsedTimeMs());
}

function resetTimer() {
    ewarStartTimeMs = null;
    ewarElapsedBeforeStartMs = 0;
    ewarHasStartedTimer = false;

    if (ewarTimerIntervalId !== null) {
        clearInterval(ewarTimerIntervalId);
        ewarTimerIntervalId = null;
    }

    updateTimerDisplay();
}

function startTimerIfNeeded() {
    if (ewarHasStartedTimer) {
        return;
    }

    ewarHasStartedTimer = true;
    ewarStartTimeMs = Date.now();

    if (ewarTimerIntervalId !== null) {
        clearInterval(ewarTimerIntervalId);
    }

    ewarTimerIntervalId = setInterval(function () {
        updateTimerDisplay();
    }, 250);

    updateTimerDisplay();
}

function stopTimer() {
    if (ewarHasStartedTimer && ewarStartTimeMs !== null) {
        ewarElapsedBeforeStartMs += Date.now() - ewarStartTimeMs;
        ewarStartTimeMs = null;
    }

    if (ewarTimerIntervalId !== null) {
        clearInterval(ewarTimerIntervalId);
        ewarTimerIntervalId = null;
    }

    updateTimerDisplay();
}

function createEwarBoard() {
    ewarBoardWrapperElement = document.createElement('div');
    ewarBoardWrapperElement.className = 'ewar-board-wrapper';

    ewarBoardElement = document.createElement('div');
    ewarBoardElement.className = 'ewar-board';

    ewarCelebrationOverlayElement = document.createElement('div');
    ewarCelebrationOverlayElement.className = 'ewar-board-celebration-overlay';

    ewarCompletionTextElement = document.createElement('div');
    ewarCompletionTextElement.className = 'ewar-board-celebration-text';
    ewarCompletionTextElement.textContent = 'BOOSTED';

    ewarCompletionTimeElement = document.createElement('div');
    ewarCompletionTimeElement.className = 'ewar-board-celebration-time';
    ewarCompletionTimeElement.textContent = '00:00';

    ewarCelebrationOverlayElement.appendChild(ewarCompletionTextElement);
    ewarCelebrationOverlayElement.appendChild(ewarCompletionTimeElement);

    ewarBoardWrapperElement.appendChild(ewarBoardElement);
    ewarBoardWrapperElement.appendChild(ewarCelebrationOverlayElement);

    setupEwarBoard();

    return ewarBoardWrapperElement;
}

function createSolvedEwarTiles() {
    const tileCount = ewarBoardSize * ewarBoardSize;
    const tiles = [];

    for (let i = 1; i < tileCount; i++) {
        tiles.push(i);
    }

    tiles.push(EWAR_EMPTY_VALUE);

    return tiles;
}

function setupEwarBoard() {
    hideCelebrationOverlay();
    ewarInputEnabled = true;
    resetTimer();
    ewarTiles = createShuffledSolvableTiles();
    renderEwarBoard();
}

function renderEwarBoard() {
    if (!ewarBoardElement) {
        return;
    }

    ewarBoardElement.innerHTML = '';
    ewarBoardElement.style.display = 'grid';
    ewarBoardElement.style.gridTemplateColumns = 'repeat(' + String(ewarBoardSize) + ', 1fr)';
    ewarBoardElement.style.gridTemplateRows = 'repeat(' + String(ewarBoardSize) + ', 1fr)';

    if (ewarBoardWrapperElement) {
        if (ewarInputEnabled) {
            ewarBoardWrapperElement.classList.remove('ewar-board-disabled');
        } else {
            ewarBoardWrapperElement.classList.add('ewar-board-disabled');
        }
    }

    for (let i = 0; i < ewarTiles.length; i++) {
        const tileValue = ewarTiles[i];
        const tileElement = document.createElement('div');
        tileElement.className = 'ewar-tile';
        tileElement.dataset.index = String(i);

        if (tileValue === EWAR_EMPTY_VALUE) {
            tileElement.classList.add('ewar-tile-empty');
            tileElement.textContent = '';
        } else {
            tileElement.textContent = String(tileValue);

            if (isTileInCorrectPosition(i)) {
                tileElement.classList.add('ewar-tile-correct');
            }

            tileElement.addEventListener('click', function () {
                A3API.SendAlert('click');
                moveTileAtIndex(i);
            });
        }

        ewarBoardElement.appendChild(tileElement);
    }

    updateBoardInstructions();
}

function moveTileAtIndex(tileIndex) {
    if (!ewarInputEnabled) {
        return;
    }

    const movePath = getMovableTilePath(tileIndex);

    if (movePath.length === 0) {
        return;
    }

    startTimerIfNeeded();
    moveTilesAlongPath(movePath);
    renderEwarBoard();

    if (isEwarSolved()) {
        handleSolvedBoard();
    }
}

function getMovableTilePath(tileIndex) {
    const emptyIndex = ewarTiles.indexOf(EWAR_EMPTY_VALUE);

    if (tileIndex < 0 || emptyIndex < 0 || tileIndex === emptyIndex) {
        return [];
    }

    const tileRow = Math.floor(tileIndex / ewarBoardSize);
    const tileCol = tileIndex % ewarBoardSize;
    const emptyRow = Math.floor(emptyIndex / ewarBoardSize);
    const emptyCol = emptyIndex % ewarBoardSize;

    const path = [];

    if (tileRow === emptyRow) {
        const step = tileIndex > emptyIndex ? 1 : -1;

        for (let index = emptyIndex + step; index !== tileIndex + step; index += step) {
            path.push(index);
        }

        return path;
    }

    if (tileCol === emptyCol) {
        const step = tileIndex > emptyIndex ? ewarBoardSize : -ewarBoardSize;

        for (let index = emptyIndex + step; index !== tileIndex + step; index += step) {
            path.push(index);
        }

        return path;
    }

    return [];
}

function moveTilesAlongPath(path) {
    if (path.length === 0) {
        return;
    }

    let emptyIndex = ewarTiles.indexOf(EWAR_EMPTY_VALUE);

    for (let i = 0; i < path.length; i++) {
        const sourceIndex = path[i];
        ewarTiles[emptyIndex] = ewarTiles[sourceIndex];
        ewarTiles[sourceIndex] = EWAR_EMPTY_VALUE;
        emptyIndex = sourceIndex;
    }
}

function canMoveTile(tileIndex) {
    return getMovableTilePath(tileIndex).length > 0;
}

function isTileInCorrectPosition(index) {
    const tileValue = ewarTiles[index];

    if (tileValue === EWAR_EMPTY_VALUE) {
        return false;
    }

    return tileValue === index + 1;
}

function handleSolvedBoard() {
    stopTimer();
    ewarInputEnabled = false;

    if (ewarCompletionTimeElement) {
        ewarCompletionTimeElement.textContent = formatElapsedTime(getCurrentElapsedTimeMs());
    }

    renderEwarBoard();
    showCelebrationOverlay();
    done();

    if (ewarCelebrationTimeoutId !== null) {
        clearTimeout(ewarCelebrationTimeoutId);
    }

    ewarCelebrationTimeoutId = setTimeout(function () {
        ewarCelebrationTimeoutId = null;
        A3API.SendAlert('exit');
    }, EWAR_CELEBRATION_DURATION_MS);
}

function showCelebrationOverlay() {
    if (ewarCelebrationOverlayElement) {
        ewarCelebrationOverlayElement.classList.add('visible');
    }
}

function hideCelebrationOverlay() {
    if (ewarCelebrationOverlayElement) {
        ewarCelebrationOverlayElement.classList.remove('visible');
    }
}

function isEwarSolved() {
    const lastIndex = ewarTiles.length - 1;

    for (let i = 0; i < lastIndex; i++) {
        if (ewarTiles[i] !== i + 1) {
            return false;
        }
    }

    return ewarTiles[lastIndex] === EWAR_EMPTY_VALUE;
}

function createShuffledSolvableTiles() {
    let tiles = createSolvedEwarTiles();

    do {
        tiles = shuffleArray(createSolvedEwarTiles());
    } while (!isSolvableEwarState(tiles) || isSolvedEwarState(tiles));

    return tiles;
}

function shuffleArray(values) {
    const shuffled = values.slice();

    for (let i = shuffled.length - 1; i > 0; i--) {
        const randomIndex = Math.floor(Math.random() * (i + 1));
        const temp = shuffled[i];
        shuffled[i] = shuffled[randomIndex];
        shuffled[randomIndex] = temp;
    }

    return shuffled;
}

function isSolvedEwarState(tiles) {
    const lastIndex = tiles.length - 1;

    for (let i = 0; i < lastIndex; i++) {
        if (tiles[i] !== i + 1) {
            return false;
        }
    }

    return tiles[lastIndex] === EWAR_EMPTY_VALUE;
}

function isSolvableEwarState(tiles) {
    const inversionCount = countInversions(tiles);
    const emptyIndex = tiles.indexOf(EWAR_EMPTY_VALUE);
    const emptyRowFromTop = Math.floor(emptyIndex / ewarBoardSize);
    const emptyRowFromBottom = ewarBoardSize - emptyRowFromTop;

    if (ewarBoardSize % 2 === 0) {
        if (emptyRowFromBottom % 2 === 0) {
            return inversionCount % 2 === 1;
        }

        return inversionCount % 2 === 0;
    }

    return inversionCount % 2 === 0;
}

function countInversions(tiles) {
    let inversions = 0;

    for (let i = 0; i < tiles.length; i++) {
        for (let j = i + 1; j < tiles.length; j++) {
            if (
                tiles[i] !== EWAR_EMPTY_VALUE &&
                tiles[j] !== EWAR_EMPTY_VALUE &&
                tiles[i] > tiles[j]
            ) {
                inversions++;
            }
        }
    }

    return inversions;
}

function createEwarBoardInstructions() {
    const instructionsWrapper = document.createElement('div');
    instructionsWrapper.className = 'ewar-board-info';

    ewarBoardInstructionsElement = document.createElement('ul');
    ewarBoardInstructionsElement.className = 'ewar-board-instructions';

    ewarTimerElement = document.createElement('div');
    ewarTimerElement.className = 'ewar-board-timer';
    ewarTimerElement.textContent = '00:00';

    instructionsWrapper.appendChild(ewarBoardInstructionsElement);

    updateBoardInstructions();
    updateTimerDisplay();

    return instructionsWrapper;
}

function updateBoardInstructions() {
    if (!ewarBoardInstructionsElement) {
        return;
    }

    ewarBoardInstructionsElement.innerHTML = '';

    const tileCount = (ewarBoardSize * ewarBoardSize) - 1;

    const instructionLines = [
        'Click numbers in the same row or column as the gap to slide them.',
        'Arrange the tiles from 1 to ' + String(tileCount) + '.'
    ];

    for (let i = 0; i < instructionLines.length; i++) {
        const listItem = document.createElement('li');
        listItem.textContent = instructionLines[i];
        ewarBoardInstructionsElement.appendChild(listItem);
    }
}

function getInstructionsForSignal(signalValue, isFriendly) {
    const instructions = [];

    if (signalValue <= 350) {
        instructions.push('Signal strength degraded');
        instructions.push('Drone sensors impaired');
        instructions.push('Drones visible to enemy datalink');
        instructions.push('Spectrum jammer non-functional');
    } else if (signalValue >= 650) {
        instructions.push('Signal strength boosted');
        instructions.push('Spectrum jammer max range: 5000');
        instructions.push('10% drone rebate');
    } else {
        instructions.push('Signal strength nominal');
        instructions.push('Spectrum jammer max range: 300');
    }

    return instructions;
}

function createEwarSidePanel() {
    const ewarSidePanel = document.createElement('div');
    ewarSidePanel.className = 'ewar-side-panel';

    const signalPanel = document.createElement('div');
    signalPanel.className = 'signal-panel';

    const friendlySignalRow = createSignalRow('Friendly');
    friendlySignalBarFillElement = friendlySignalRow.barFillElement;
    friendlySignalBarTextElement = friendlySignalRow.barTextElement;

    friendlySignalInstructionsElement = document.createElement('ul');
    friendlySignalInstructionsElement.className = 'signal-instructions';

    const hostileSignalRow = createSignalRow('Hostile');
    hostileSignalBarFillElement = hostileSignalRow.barFillElement;
    hostileSignalBarTextElement = hostileSignalRow.barTextElement;

    hostileSignalInstructionsElement = document.createElement('ul');
    hostileSignalInstructionsElement.className = 'signal-instructions';

    signalPanel.appendChild(friendlySignalRow.rowElement);
    signalPanel.appendChild(friendlySignalInstructionsElement);

    signalPanel.appendChild(hostileSignalRow.rowElement);
    signalPanel.appendChild(hostileSignalInstructionsElement);

    ewarSidePanel.appendChild(signalPanel);

    return ewarSidePanel;
}

function clampSignalValue(signalValue) {
    const safeValue = Number(signalValue);
    if (!Number.isFinite(safeValue)) {
        return 0;
    }
    return Math.max(0, Math.min(1000, safeValue));
}

function getSignalStatus(signalValue) {
    if (signalValue <= 350) {
        return { label: 'Degraded', className: 'signal-degraded' };
    }

    if (signalValue >= 650) {
        return { label: 'Boosted', className: 'signal-boosted' };
    }

    return { label: 'Normal', className: 'signal-normal' };
}

function createSignalRow(labelText) {
    const rowElement = document.createElement('div');
    rowElement.className = 'signal-row';

    const labelElement = document.createElement('div');
    labelElement.className = 'signal-label';
    labelElement.textContent = String(labelText || '');

    const barElement = document.createElement('div');
    barElement.className = 'signal-bar';

    const barFillElement = document.createElement('div');
    barFillElement.className = 'signal-bar-fill signal-normal';

    const barTextElement = document.createElement('div');
    barTextElement.className = 'signal-bar-text';
    barTextElement.textContent = 'Normal (500)';

    barElement.appendChild(barFillElement);
    barElement.appendChild(barTextElement);

    rowElement.appendChild(labelElement);
    rowElement.appendChild(barElement);

    return {
        rowElement: rowElement,
        barFillElement: barFillElement,
        barTextElement: barTextElement
    };
}

function applySignalToBar(signalValue, barFillElement, barTextElement, instructionsElement, isFriendly) {
    if (!barFillElement || !barTextElement) {
        return;
    }

    const clampedSignalValue = clampSignalValue(signalValue);
    const percentage = (clampedSignalValue / 1000) * 100;

    const status = getSignalStatus(clampedSignalValue);

    barFillElement.classList.remove('signal-degraded', 'signal-boosted', 'signal-normal');
    barFillElement.classList.add(status.className);

    barFillElement.style.width = String(percentage) + '%';
    barTextElement.textContent = status.label + ' (' + String(Math.round(clampedSignalValue)) + ')';

    if (instructionsElement) {
        instructionsElement.innerHTML = '';

        const instructions = getInstructionsForSignal(clampedSignalValue, isFriendly);

        for (let i = 0; i < instructions.length; i++) {
            const listItem = document.createElement('li');
            listItem.textContent = instructions[i];
            instructionsElement.appendChild(listItem);
        }
    }
}

function updateSignals(friendlySignal, hostileSignal) {
    applySignalToBar(
        friendlySignal,
        friendlySignalBarFillElement,
        friendlySignalBarTextElement,
        friendlySignalInstructionsElement,
        true
    );

    applySignalToBar(
        hostileSignal,
        hostileSignalBarFillElement,
        hostileSignalBarTextElement,
        hostileSignalInstructionsElement,
        false
    );
}

// document.addEventListener('keydown', function (event) {
//     if (event.key !== 'c' && event.key !== 'C') {
//         return;
//     }

//     const tileCount = ewarBoardSize * ewarBoardSize;
//     ewarTiles = [];

//     for (let i = 1; i <= tileCount - 2; i++) {
//         ewarTiles.push(i);
//     }

//     ewarTiles.push(EWAR_EMPTY_VALUE);
//     ewarTiles.push(tileCount - 1);

//     renderEwarBoard();
// });

const closeButton = document.querySelector('.close-button');
closeButton.addEventListener('mousedown', function () {
    A3API.SendAlert('exit');
});