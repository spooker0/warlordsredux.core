const hintWrapper = document.querySelector('.hint-wrapper');
const hintText = hintWrapper.querySelector('p');
const keysList = hintWrapper.querySelector('.keys-list');

const animationTimer = document.querySelector('.animation-timer');

const sectorWrapperDiv = document.querySelector('.sector-wrapper');
const sectorCaptureDiv = sectorWrapperDiv.querySelector('.sector-capture-display');
const sectorVoteDiv = sectorWrapperDiv.querySelector('.sector-vote-display');

document.hintId = "";

function clearHint(hintId) {
    animationTimer.style.visibility = 'hidden';
    if (document.hintId !== hintId) {
        return;
    }
    document.hintId = "";
    hintWrapper.style.visibility = 'hidden';
}

function playHintAnimation() {
    hintWrapper.classList.remove('is-animating');
    void hintWrapper.offsetWidth;   // trigger reflow to restart animation
    hintWrapper.classList.add('is-animating');
}

function updateHint(hintId, hint, keysText) {
    if (document.hintId === hintId) {
        return;
    }
    document.hintId = hintId;
    hintWrapper.style.visibility = 'visible';
    playHintAnimation();

    const keys = JSON.parse(keysText || '[]');
    hintText.textContent = hint;
    keysList.innerHTML = '';
    keys.forEach(key => {
        const li = document.createElement('li');

        const leftSpan = document.createElement('span');
        leftSpan.textContent = `${key[0]}`;
        leftSpan.style.marginRight = '30px';
        li.appendChild(leftSpan);

        const rightSpan = document.createElement('span');
        rightSpan.textContent = `[${key[1]}]`;
        rightSpan.style.float = 'right';
        rightSpan.style.clear = 'both';
        rightSpan.style.color = '#00ff00';
        li.appendChild(rightSpan);

        keysList.appendChild(li);
    });
}

function updateAnimationTimer(progress) {
    animationTimer.style.visibility = 'visible';
    const clampedProgress = Math.max(0, Math.min(1, progress));
    animationTimer.textContent = `${(clampedProgress * 100).toFixed(0)}%`;
    animationTimer.style.background = `linear-gradient(to right, #00ff00 ${clampedProgress * 100}%, rgba(0,0,0,0.5) ${clampedProgress * 100}%)`;
}

function playSectorAnimation() {
    if (!sectorVoteHiding || !sectorCaptureHiding) {
        return;
    }

    sectorWrapperDiv.style.visibility = 'visible';
    sectorWrapperDiv.classList.remove('is-animating');
    void sectorWrapperDiv.offsetWidth;   // trigger reflow to restart animation
    sectorWrapperDiv.classList.add('is-animating');
}

function formatNumber(num) {
    if (num >= 1e6) {
        return (num / 1e6).toFixed(1) + 'M';
    } else if (num >= 1e3) {
        return (num / 1e3).toFixed(1) + 'K';
    } else {
        return num.toString();
    }
}

function sideToColor(side) {
    switch (side) {
        case "BLUFOR":
            return "#9dbcdb";
        case "OPFOR":
            return "#d87c79";
        case "INDEP":
            return "#78c07a";
        case "UNKNOWN":
            return "#bbbb7c";
        default:
            return "#aaaaaa";
    }
}

let sectorCaptureHiding = true;
let sectorVoteHiding = true;

function hideSectorWrapper() {
    if (!sectorCaptureHiding || !sectorVoteHiding) {
        return;
    }
    sectorWrapperDiv.style.visibility = 'hidden';
}

function hideSectorCapture() {
    sectorCaptureDiv.style.display = 'none';
    sectorCaptureHiding = true;
    hideSectorWrapper();
}

function updateSectorCapture(captureData, fontSize) {
    if (captureData.length === 0) {
        hideSectorCapture();
        return;
    }
    sectorCaptureDiv.style.display = 'block';

    const sectorList = sectorCaptureDiv.querySelector('.sector-capture-list');
    sectorList.innerHTML = '';

    fontSize = fontSize ? `${fontSize}pt` : '10pt';

    captureData.forEach((sector) => {
        const listItem = document.createElement('li');

        const leftValue = sector[1];
        const rightValue = sector[2];

        const progressLeftSpan = document.createElement('span');
        progressLeftSpan.className = 'sector-progress-left';
        progressLeftSpan.textContent = `${Math.floor(leftValue)}`;
        progressLeftSpan.style.fontSize = fontSize;
        listItem.appendChild(progressLeftSpan);

        const leftPercent = sector[3];

        const nameSpan = document.createElement('span');
        nameSpan.className = 'sector-progress-name';
        nameSpan.textContent = `${sector[0]} (${Math.round(leftPercent)}%)`;
        nameSpan.style.fontSize = fontSize;
        listItem.appendChild(nameSpan);

        const progressRightSpan = document.createElement('span');
        progressRightSpan.className = 'sector-progress-right';
        progressRightSpan.textContent = `${Math.floor(rightValue)}`;
        progressRightSpan.style.fontSize = fontSize;
        listItem.appendChild(progressRightSpan);

        const attackingColor = sideToColor(sector[4]);
        const defendingColor = sideToColor(sector[5]);

        listItem.style.setProperty('--bar-left-color', attackingColor);
        listItem.style.setProperty('--bar-right-color', defendingColor);

        listItem.style.setProperty('--bar-width', `${leftPercent}%`);

        listItem.style.setProperty('--sector-text-color', defendingColor);
        listItem.style.setProperty('--sector-left-text-color', attackingColor);
        listItem.style.setProperty('--sector-right-text-color', defendingColor);

        const speedRatio = leftValue / (leftValue + rightValue + 0.01);
        const direction = leftValue >= rightValue ? 'right' : 'left';
        const diff = Math.abs(speedRatio - 0.5);

        const arrowSpan = document.createElement('span');
        arrowSpan.classList.add('capture-arrow', direction);
        arrowSpan.style.setProperty('--bar-width', `${leftPercent}%`);
        listItem.appendChild(arrowSpan);

        const isFastCapture = diff > 0.2;
        if (isFastCapture) {
            const arrowFastSpan = document.createElement('span');
            arrowFastSpan.classList.add('capture-arrow', 'capture-arrow-fast', direction);
            arrowFastSpan.style.setProperty('--bar-width', `${leftPercent}%`);
            listItem.appendChild(arrowFastSpan);
        }

        const isVeryFastCapture = diff > 0.4;
        if (isVeryFastCapture) {
            const arrowVeryFastSpan = document.createElement('span');
            arrowVeryFastSpan.classList.add('capture-arrow', 'capture-arrow-very-fast', direction);
            arrowVeryFastSpan.style.setProperty('--bar-width', `${leftPercent}%`);
            listItem.appendChild(arrowVeryFastSpan);
        }

        sectorList.appendChild(listItem);
    });

    playSectorAnimation();
    sectorCaptureHiding = false;

    if (sectorVoteHiding) {
        sectorCaptureDiv.style.marginBottom = '0';
    } else {
        sectorCaptureDiv.style.marginBottom = '50px';
    }
}

function hideSectorVote() {
    sectorVoteDiv.style.display = 'none';
    sectorVoteHiding = true;
    hideSectorWrapper();
}

function updateSectorVote(etaDisplay, sectorData) {
    sectorVoteDiv.style.display = 'block';

    sectorVoteDiv.querySelector('.eta-display').textContent = etaDisplay;

    const sectorList = sectorVoteDiv.querySelector('.sector-vote-list');
    sectorList.innerHTML = '';

    let maxVotes = 0;
    sectorData.forEach((sector) => {
        maxVotes = Math.max(maxVotes, sector[1]);
    });

    sectorData.forEach((sector) => {
        const listItem = document.createElement('li');

        const nameSpan = document.createElement('span');
        nameSpan.className = 'sector-name';
        nameSpan.textContent = sector[0];
        listItem.appendChild(nameSpan);

        const votesSpan = document.createElement('span');
        votesSpan.className = 'sector-votes';
        votesSpan.textContent = formatNumber(sector[1]);
        listItem.appendChild(votesSpan);

        listItem.style.setProperty('--bar-width', ((sector[1] / maxVotes) * 100).toFixed(2) + '%');
        listItem.style.setProperty('--sector-text-color', sideToColor(sector[2]));
        sectorList.appendChild(listItem);
    });

    playSectorAnimation();
    sectorVoteHiding = false;
}

hideSectorCapture();
hideSectorVote();