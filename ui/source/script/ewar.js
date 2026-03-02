function hideLoadingOverlay() {
    const overlay = document.getElementById('loading-overlay');
    overlay.style.display = 'none';
    const ewarMenu = document.querySelector('.ewar-menu');
    ewarMenu.style.opacity = '1.0';
}

function place(number, index) {
    A3API.SendAlert(String(number) + ',' + String(index));
}

function wrong() {
    A3API.SendAlert('wrong');
}

let hintedCellIndices = new Set();

let selectedCellIndex = null;
let ewarPuzzleString = '';
let ewarSolutionString = '';
let ewarKeyString = '';
let keyCharactersByNumber = [];
let numberByKeyCharacter = new Map();

let forcedHighlightNumber = null;

let ewarCellElementsByIndex = [];
let ewarCellValueElementsByIndex = [];
let ewarCandidatePlaceElementsByCellIndex = [];
let candidatesByCellIndex = [];
let allowedCandidatesByCellIndex = [];

let friendlySignalBarFillElement = null;
let friendlySignalBarTextElement = null;
let hostileSignalBarFillElement = null;
let hostileSignalBarTextElement = null;
let friendlySignalInstructionsElement = null;
let hostileSignalInstructionsElement = null;

let ewarNumpadButtonsByNumber = [];
let disabledNumpadNumbers = new Set();

/*
    Multiplayer methods expected to be called by the host game.
    - reveal(candidateNumber, cellIndex): teammate reveals/places the number for the team.
    - hint(cellIndex): opponent indicates they have the answer; we only show a low-priority red tint.
*/
function reveal(candidateNumber, cellIndex) {
    const safeCellIndex = Number(cellIndex);
    const safeCandidateNumber = Number(candidateNumber);

    if (!Number.isFinite(safeCellIndex) || safeCellIndex < 0 || safeCellIndex > 80) {
        return;
    }

    if (!Number.isFinite(safeCandidateNumber) || safeCandidateNumber < 1 || safeCandidateNumber > 9) {
        return;
    }

    const cellElement = ewarCellElementsByIndex[safeCellIndex];
    const cellValueElement = ewarCellValueElementsByIndex[safeCellIndex];

    if (!cellElement || !cellValueElement) {
        return;
    }

    if (cellElement.classList.contains('given') || cellElement.classList.contains('filled')) {
        return;
    }

    cellValueElement.textContent = getDisplayCharacterForNumber(safeCandidateNumber);
    cellElement.classList.add('filled');

    candidatesByCellIndex[safeCellIndex].clear();
    renderCandidatesForCell(safeCellIndex);

    hintedCellIndices.delete(safeCellIndex);
    cellElement.classList.remove('hinted');

    updateAllowedCandidatesAndPruneAll(false);
    updateHighlightsForSelectedCell();
    updateSingleCandidateHighlights();
    updateNumpadDisabledStates();
}

function hint(cellIndex) {
    const safeCellIndex = Number(cellIndex);

    if (!Number.isFinite(safeCellIndex) || safeCellIndex < 0 || safeCellIndex > 80) {
        return;
    }

    const cellElement = ewarCellElementsByIndex[safeCellIndex];
    if (!cellElement) {
        return;
    }

    if (cellElement.classList.contains('given') || cellElement.classList.contains('filled')) {
        return;
    }

    hintedCellIndices.add(safeCellIndex);
    cellElement.classList.add('hinted');
}

function initScreen(puzzle, solution, key, friendlySignal, hostileSignal) {
    hideLoadingOverlay();

    ewarPuzzleString = String(puzzle || '');
    ewarSolutionString = String(solution || '');
    ewarKeyString = String(key || '');

    buildKeyMappingsFromKeyString(ewarKeyString);

    hintedCellIndices = new Set();
    selectedCellIndex = null;
    forcedHighlightNumber = null;

    disabledNumpadNumbers = new Set();
    ewarNumpadButtonsByNumber = [];

    const ewarMenu = document.querySelector('.ewar-menu');
    ewarMenu.innerHTML = '';

    const ewarContainer = document.createElement('div');
    ewarContainer.className = 'ewar-container';

    const ewarBoard = createEwarBoard(ewarPuzzleString);
    const ewarBoardInstructions = createEwarBoardInstructions();
    const ewarSidePanel = createEwarSidePanel();

    const ewarLeftPanel = document.createElement('div');
    ewarLeftPanel.className = 'ewar-left-panel';
    ewarLeftPanel.appendChild(ewarBoard);
    ewarLeftPanel.appendChild(ewarBoardInstructions);

    ewarContainer.appendChild(ewarLeftPanel);
    ewarContainer.appendChild(ewarSidePanel);
    ewarMenu.appendChild(ewarContainer);

    updateAllowedCandidatesAndPruneAll(true);
    updateSingleCandidateHighlights();
    updateSignals(friendlySignal, hostileSignal);

    updateNumpadDisabledStates();
    updateHighlightsForSelectedCell();
}

function buildKeyMappingsFromKeyString(keyString) {
    keyCharactersByNumber = [];
    numberByKeyCharacter = new Map();

    const safeKeyString = String(keyString || '');

    for (let number = 1; number <= 9; number++) {
        const characterIndex = number - 1;
        const keyCharacter = safeKeyString.charAt(characterIndex);

        keyCharactersByNumber[number] = keyCharacter;

        if (keyCharacter.length > 0) {
            numberByKeyCharacter.set(String(keyCharacter).toUpperCase(), number);
        }
    }
}

function getDisplayCharacterForNumber(number) {
    const safeNumber = Number(number);
    if (!Number.isFinite(safeNumber) || safeNumber < 1 || safeNumber > 9) {
        return '';
    }

    const mappedCharacter = keyCharactersByNumber[safeNumber];
    if (typeof mappedCharacter !== 'string' || mappedCharacter.length === 0) {
        return String(safeNumber);
    }

    return mappedCharacter;
}

function createEwarBoard(puzzleString) {
    const ewarBoard = document.createElement('div');
    ewarBoard.className = 'ewar-board';

    ewarCellElementsByIndex = [];
    ewarCellValueElementsByIndex = [];
    ewarCandidatePlaceElementsByCellIndex = [];
    candidatesByCellIndex = [];
    allowedCandidatesByCellIndex = [];

    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        candidatesByCellIndex[cellIndex] = new Set();
        ewarCandidatePlaceElementsByCellIndex[cellIndex] = [];
        allowedCandidatesByCellIndex[cellIndex] = createAllowedCandidateArrayAllTrue();

        const cellElement = document.createElement('div');
        cellElement.className = 'ewar-cell';
        cellElement.dataset.index = String(cellIndex);

        const rowIndex = Math.floor(cellIndex / 9);
        const columnIndex = cellIndex % 9;

        if (columnIndex === 2 || columnIndex === 5) {
            cellElement.classList.add('border-right-thick');
        }

        if (rowIndex === 2 || rowIndex === 5) {
            cellElement.classList.add('border-bottom-thick');
        }

        const cellValueElement = document.createElement('div');
        cellValueElement.className = 'ewar-cell-value';

        const candidateGridElement = document.createElement('div');
        candidateGridElement.className = 'ewar-cell-candidates';

        for (let candidateNumber = 1; candidateNumber <= 9; candidateNumber++) {
            const candidatePlaceElement = document.createElement('div');
            candidatePlaceElement.className = 'ewar-candidate-place not-candidate';
            candidatePlaceElement.textContent = getDisplayCharacterForNumber(candidateNumber);
            candidatePlaceElement.dataset.number = String(candidateNumber);
            candidatePlaceElement.dataset.index = String(cellIndex);

            candidatePlaceElement.addEventListener('mousedown', function (event) {
                event.stopPropagation();
                handleCandidatePlaceMouseDown(cellIndex, candidateNumber);
            });

            ewarCandidatePlaceElementsByCellIndex[cellIndex][candidateNumber] = candidatePlaceElement;
            candidateGridElement.appendChild(candidatePlaceElement);
        }

        cellElement.appendChild(cellValueElement);
        cellElement.appendChild(candidateGridElement);

        const puzzleCharacter = puzzleString[cellIndex] || '0';
        const isGiven = puzzleCharacter !== '0';

        if (isGiven) {
            const givenNumber = Number(puzzleCharacter);
            cellValueElement.textContent = getDisplayCharacterForNumber(givenNumber);
            cellElement.classList.add('given', 'filled');
        } else {
            cellValueElement.textContent = '';
        }

        cellElement.addEventListener('mousedown', function () {
            handleCellMouseDown(cellIndex);
        });

        ewarCellElementsByIndex[cellIndex] = cellElement;
        ewarCellValueElementsByIndex[cellIndex] = cellValueElement;
        ewarBoard.appendChild(cellElement);
    }

    return ewarBoard;
}

function createEwarBoardInstructions() {
    const instructionsElement = document.createElement('ul');
    instructionsElement.className = 'ewar-board-instructions';

    const instructionLines = [
        'Boost signals by revealing characters in this grid.',
        'Each character is present exactly once in each row, each column, and each box region.',
        'Unfilled cells show candidates, which indicate all possible characters in that cell.'
    ];

    for (let i = 0; i < instructionLines.length; i++) {
        const listItem = document.createElement('li');
        listItem.textContent = instructionLines[i];
        instructionsElement.appendChild(listItem);
    }

    return instructionsElement;
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

    const ewarNumpad = document.createElement('div');
    ewarNumpad.className = 'ewar-numpad';

    for (let number = 1; number <= 9; number++) {
        const numpadButton = document.createElement('div');
        numpadButton.className = 'ewar-numpad-button';
        numpadButton.textContent = getDisplayCharacterForNumber(number);
        numpadButton.dataset.number = String(number);

        ewarNumpadButtonsByNumber[number] = numpadButton;

        numpadButton.addEventListener('mousedown', function (event) {
            if (event.button === 2) {
                event.preventDefault();
                handleNumpadRightMouseDown(number);
                return;
            }

            if (event.button === 0) {
                handleNumpadMouseDown(number);
            }
        });

        ewarNumpad.appendChild(numpadButton);
    }

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

    ewarSidePanel.appendChild(ewarNumpad);
    ewarSidePanel.appendChild(signalPanel);

    return ewarSidePanel;
}

/* ---------------- NUMPAD DISABLE LOGIC ---------------- */

function isNumpadDisabled(number) {
    return disabledNumpadNumbers.has(Number(number));
}

function setNumpadButtonDisabled(number, disabled) {
    const safeNumber = Number(number);
    const button = ewarNumpadButtonsByNumber[safeNumber];
    if (!button) {
        return;
    }

    if (disabled) {
        button.classList.add('disabled');
        disabledNumpadNumbers.add(safeNumber);
    } else {
        button.classList.remove('disabled');
        disabledNumpadNumbers.delete(safeNumber);
    }
}

function updateNumpadDisabledStates() {
    const counts = [];
    for (let n = 0; n <= 9; n++) {
        counts[n] = 0;
    }

    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        const v = getCellValueNumber(cellIndex);
        if (v !== null && v >= 1 && v <= 9) {
            counts[v] += 1;
        }
    }

    for (let number = 1; number <= 9; number++) {
        const shouldDisable = counts[number] >= 9;
        setNumpadButtonDisabled(number, shouldDisable);
    }
}

/* ---------------- SIGNALS ---------------- */

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

/* ---------------- INPUT + GAMEPLAY ---------------- */

function handleCellMouseDown(cellIndex) {
    setSelectedCellIndex(cellIndex);
}

function handleCandidatePlaceMouseDown(cellIndex, candidateNumber) {
    const cellElement = ewarCellElementsByIndex[cellIndex];
    if (!cellElement) {
        return;
    }

    if (selectedCellIndex === null || selectedCellIndex !== cellIndex) {
        return;
    }

    if (cellElement.classList.contains('given')) {
        return;
    }

    if (cellElement.classList.contains('filled')) {
        return;
    }

    if (!isCandidateAllowed(cellIndex, candidateNumber)) {
        return;
    }

    toggleCandidate(cellIndex, candidateNumber);
}

function toggleCandidate(cellIndex, candidateNumber) {
    const candidateSet = candidatesByCellIndex[cellIndex];
    if (!candidateSet) {
        return;
    }

    if (!isCandidateAllowed(cellIndex, candidateNumber)) {
        return;
    }

    if (candidateSet.has(candidateNumber)) {
        candidateSet.delete(candidateNumber);
    } else {
        candidateSet.add(candidateNumber);
    }

    renderCandidatesForCell(cellIndex);
    updateHighlightsForSelectedCell();
    updateSingleCandidateHighlights();
}

function setSelectedCellIndex(cellIndex) {
    clearSelectedCell();

    selectedCellIndex = cellIndex;
    forcedHighlightNumber = null;

    const selectedCellElement = ewarCellElementsByIndex[selectedCellIndex];
    if (selectedCellElement) {
        selectedCellElement.classList.add('selected');
    }

    updateHighlightsForSelectedCell();
}

function clearSelectedCell() {
    if (selectedCellIndex === null) {
        clearHighlights();
        updateSingleCandidateHighlights();
        return;
    }

    const previouslySelectedCellElement = ewarCellElementsByIndex[selectedCellIndex];
    if (previouslySelectedCellElement) {
        previouslySelectedCellElement.classList.remove('selected');
    }

    selectedCellIndex = null;
    clearHighlights();
    updateSingleCandidateHighlights();
}

function clearSelectedCellVisualOnly() {
    if (selectedCellIndex === null) {
        return;
    }

    const selectedCellElement = ewarCellElementsByIndex[selectedCellIndex];
    if (selectedCellElement) {
        selectedCellElement.classList.remove('selected');
    }
}

function handleNumpadRightMouseDown(number) {
    const safeNumber = Number(number);
    if (!Number.isFinite(safeNumber) || safeNumber < 1 || safeNumber > 9) {
        return;
    }

    if (isNumpadDisabled(safeNumber)) {
        return;
    }

    if (selectedCellIndex !== null) {
        clearSelectedCellVisualOnly();
    }

    forcedHighlightNumber = safeNumber;
    updateHighlightsForSelectedCell();
}

function handleNumpadMouseDown(number) {
    const safeNumber = Number(number);
    if (!Number.isFinite(safeNumber) || safeNumber < 1 || safeNumber > 9) {
        return;
    }

    if (isNumpadDisabled(safeNumber)) {
        return;
    }

    if (selectedCellIndex === null) {
        return;
    }

    forcedHighlightNumber = null;

    const selectedCellElement = ewarCellElementsByIndex[selectedCellIndex];
    const selectedCellValueElement = ewarCellValueElementsByIndex[selectedCellIndex];

    if (!selectedCellElement || !selectedCellValueElement) {
        return;
    }

    if (selectedCellElement.classList.contains('given')) {
        return;
    }

    if (selectedCellElement.classList.contains('filled')) {
        return;
    }

    const isCorrect = isNumberCorrectForIndex(safeNumber, selectedCellIndex);

    if (!isCorrect) {
        wrong();
        return;
    }

    selectedCellValueElement.textContent = getDisplayCharacterForNumber(safeNumber);
    selectedCellElement.classList.add('filled');

    candidatesByCellIndex[selectedCellIndex].clear();
    renderCandidatesForCell(selectedCellIndex);

    hintedCellIndices.delete(selectedCellIndex);
    selectedCellElement.classList.remove('hinted');

    place(safeNumber, selectedCellIndex);

    updateAllowedCandidatesAndPruneAll(false);
    updateHighlightsForSelectedCell();
    updateSingleCandidateHighlights();
    updateNumpadDisabledStates();
}

function isNumberCorrectForIndex(number, cellIndex) {
    const expectedCharacter = ewarSolutionString[cellIndex];
    const expectedNumber = Number(expectedCharacter);

    return expectedNumber === Number(number);
}

function handleKeyDown(event) {
    if (!event) {
        return;
    }

    if (selectedCellIndex === null) {
        return;
    }

    const pressedKeyCharacter = String(event.key || '');
    if (pressedKeyCharacter.length === 0) {
        return;
    }

    const normalizedCharacter = pressedKeyCharacter.toUpperCase();

    const number = numberByKeyCharacter.get(normalizedCharacter);
    if (number === undefined) {
        return;
    }

    if (isNumpadDisabled(number)) {
        return;
    }

    event.preventDefault();
    handleNumpadMouseDown(number);
}

window.addEventListener('keydown', handleKeyDown);

document.addEventListener('contextmenu', function (event) {
    const targetElement = event && event.target ? event.target : null;
    if (!targetElement) {
        return;
    }

    if (targetElement.closest && targetElement.closest('.ewar-numpad')) {
        event.preventDefault();
    }
});

/* ---------------- CANDIDATES RENDERING ---------------- */

function renderCandidatesForCell(cellIndex) {
    const candidateSet = candidatesByCellIndex[cellIndex];
    const candidatePlaceElements = ewarCandidatePlaceElementsByCellIndex[cellIndex];
    const allowedArray = allowedCandidatesByCellIndex[cellIndex];

    if (!candidateSet || !candidatePlaceElements || !allowedArray) {
        return;
    }

    for (let candidateNumber = 1; candidateNumber <= 9; candidateNumber++) {
        const candidatePlaceElement = candidatePlaceElements[candidateNumber];
        if (!candidatePlaceElement) {
            continue;
        }

        const allowed = Boolean(allowedArray[candidateNumber]);

        if (allowed) {
            candidatePlaceElement.classList.remove('candidate-not-allowed');
        } else {
            candidatePlaceElement.classList.add('candidate-not-allowed');
        }

        if (candidateSet.has(candidateNumber)) {
            candidatePlaceElement.classList.add('candidate');
            candidatePlaceElement.classList.remove('not-candidate');
        } else {
            candidatePlaceElement.classList.remove('candidate');
            candidatePlaceElement.classList.add('not-candidate');
        }
    }
}

/* ---------------- HIGHLIGHTS ---------------- */

function clearHighlights() {
    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        const cellElement = ewarCellElementsByIndex[cellIndex];
        if (!cellElement) {
            continue;
        }

        cellElement.classList.remove('highlight-same-number');
        cellElement.classList.remove('highlight-candidate-available');
    }
}

function getCellValueNumber(cellIndex) {
    const cellValueElement = ewarCellValueElementsByIndex[cellIndex];
    if (!cellValueElement) {
        return null;
    }

    const valueText = String(cellValueElement.textContent || '').trim();
    if (valueText.length === 0) {
        return null;
    }

    const resolvedNumber = numberByKeyCharacter.get(String(valueText).toUpperCase());
    if (resolvedNumber !== undefined) {
        return resolvedNumber;
    }

    const valueNumber = Number(valueText);
    if (!Number.isFinite(valueNumber) || valueNumber < 1 || valueNumber > 9) {
        return null;
    }

    return valueNumber;
}

function updateHighlightsForSelectedCell() {
    clearHighlights();

    const focusNumber = forcedHighlightNumber !== null
        ? forcedHighlightNumber
        : (selectedCellIndex !== null ? getCellValueNumber(selectedCellIndex) : null);

    if (focusNumber === null) {
        updateSingleCandidateHighlights();
        return;
    }

    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        const cellElement = ewarCellElementsByIndex[cellIndex];
        if (!cellElement) {
            continue;
        }

        const cellValueNumber = getCellValueNumber(cellIndex);

        if (cellValueNumber === focusNumber) {
            cellElement.classList.add('highlight-same-number');
            continue;
        }

        const isCellEmpty = cellValueNumber === null;
        const candidateSet = candidatesByCellIndex[cellIndex];
        const isCandidateSelected = candidateSet && candidateSet.has(focusNumber);

        if (isCellEmpty && isCandidateSelected) {
            cellElement.classList.add('highlight-candidate-available');
        }
    }

    updateSingleCandidateHighlights();
}

function updateSingleCandidateHighlights() {
    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        const cellElement = ewarCellElementsByIndex[cellIndex];
        if (!cellElement) {
            continue;
        }

        cellElement.classList.remove('highlight-single-candidate');

        if (cellElement.classList.contains('given') || cellElement.classList.contains('filled')) {
            continue;
        }

        const candidateSet = candidatesByCellIndex[cellIndex];
        if (candidateSet && candidateSet.size === 1) {
            cellElement.classList.add('highlight-single-candidate');
        }
    }
}

/* ---------------- CANDIDATE LEGALITY ---------------- */

function createAllowedCandidateArrayAllTrue() {
    const allowedArray = [];
    for (let candidateNumber = 0; candidateNumber <= 9; candidateNumber++) {
        allowedArray[candidateNumber] = true;
    }
    return allowedArray;
}

function isCandidateAllowed(cellIndex, candidateNumber) {
    const allowedArray = allowedCandidatesByCellIndex[cellIndex];
    if (!allowedArray) {
        return false;
    }
    return Boolean(allowedArray[candidateNumber]);
}

function updateAllowedCandidatesAndPruneAll(shouldFillAllAllowedCandidates) {
    const boardValues = getCurrentBoardValues();

    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        const cellValue = boardValues[cellIndex];

        const cellElement = ewarCellElementsByIndex[cellIndex];
        if (cellValue !== 0 && cellElement) {
            hintedCellIndices.delete(cellIndex);
            cellElement.classList.remove('hinted');
        }

        if (cellValue !== 0) {
            allowedCandidatesByCellIndex[cellIndex] = createAllowedCandidateArrayAllTrue();
            candidatesByCellIndex[cellIndex].clear();
            renderCandidatesForCell(cellIndex);
            continue;
        }

        const allowedArray = computeAllowedCandidatesForCell(cellIndex, boardValues);
        allowedCandidatesByCellIndex[cellIndex] = allowedArray;

        const candidateSet = candidatesByCellIndex[cellIndex];

        if (shouldFillAllAllowedCandidates) {
            candidateSet.clear();
            for (let candidateNumber = 1; candidateNumber <= 9; candidateNumber++) {
                if (allowedArray[candidateNumber]) {
                    candidateSet.add(candidateNumber);
                }
            }
        } else {
            for (let candidateNumber = 1; candidateNumber <= 9; candidateNumber++) {
                if (!allowedArray[candidateNumber] && candidateSet.has(candidateNumber)) {
                    candidateSet.delete(candidateNumber);
                }
            }
        }

        renderCandidatesForCell(cellIndex);
    }
}

function getCurrentBoardValues() {
    const values = [];

    for (let cellIndex = 0; cellIndex < 81; cellIndex++) {
        const valueNumber = getCellValueNumber(cellIndex);
        values[cellIndex] = valueNumber === null ? 0 : valueNumber;
    }

    return values;
}

function computeAllowedCandidatesForCell(cellIndex, boardValues) {
    const allowedArray = [];
    for (let candidateNumber = 0; candidateNumber <= 9; candidateNumber++) {
        allowedArray[candidateNumber] = true;
    }

    const rowIndex = Math.floor(cellIndex / 9);
    const columnIndex = cellIndex % 9;

    const usedNumbers = new Set();

    for (let scanColumnIndex = 0; scanColumnIndex < 9; scanColumnIndex++) {
        const scanIndex = rowIndex * 9 + scanColumnIndex;
        const value = boardValues[scanIndex];
        if (value !== 0) {
            usedNumbers.add(value);
        }
    }

    for (let scanRowIndex = 0; scanRowIndex < 9; scanRowIndex++) {
        const scanIndex = scanRowIndex * 9 + columnIndex;
        const value = boardValues[scanIndex];
        if (value !== 0) {
            usedNumbers.add(value);
        }
    }

    const boxRowStart = Math.floor(rowIndex / 3) * 3;
    const boxColumnStart = Math.floor(columnIndex / 3) * 3;

    for (let boxRowOffset = 0; boxRowOffset < 3; boxRowOffset++) {
        for (let boxColumnOffset = 0; boxColumnOffset < 3; boxColumnOffset++) {
            const scanRowIndex = boxRowStart + boxRowOffset;
            const scanColumnIndex = boxColumnStart + boxColumnOffset;
            const scanIndex = scanRowIndex * 9 + scanColumnIndex;

            const value = boardValues[scanIndex];
            if (value !== 0) {
                usedNumbers.add(value);
            }
        }
    }

    for (let candidateNumber = 1; candidateNumber <= 9; candidateNumber++) {
        if (usedNumbers.has(candidateNumber)) {
            allowedArray[candidateNumber] = false;
        }
    }

    return allowedArray;
}

const closeButton = document.querySelector('.close-button');
closeButton.addEventListener('mousedown', function () {
    A3API.SendAlert('exit');
});