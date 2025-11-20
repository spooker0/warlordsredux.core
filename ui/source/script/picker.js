const imageSize = 512;

const setIcons = (cls, paaPath) => {
    A3API.RequestTexture(paaPath, imageSize).then(imageContent => {
        document.querySelectorAll(`.${cls}`).forEach(img => img.src = imageContent);
    });
};

setIcons('blufor-icon', "A3\\Data_F\\Flags\\flag_NATO_CO.paa");
setIcons('opfor-icon', "A3\\Data_F\\Flags\\flag_CSAT_CO.paa");

const bluforEl = document.querySelector('.blufor-side');
const opforEl = document.querySelector('.opfor-side');

function setPlayers(blufor, opfor, lockSides, playersArray) {
    const bluforPlayerEl = bluforEl.querySelector('.side-players');
    const opforPlayerEl = opforEl.querySelector('.side-players');

    if (blufor - opfor > 2 && lockSides) {
        bluforEl.classList.add('disabled');
        bluforPlayerEl.textContent = `${blufor} players (Locked)`;
    } else {
        bluforEl.classList.remove('disabled');
        bluforPlayerEl.textContent = `${blufor} players`;
    }

    if (opfor - blufor > 2 && lockSides) {
        opforEl.classList.add('disabled');
        opforPlayerEl.textContent = `${opfor} players (Locked)`;
    } else {
        opforEl.classList.remove('disabled');
        opforPlayerEl.textContent = `${opfor} players`;
    }

    const bluforNamesEl = bluforEl.querySelector('.side-player-names');
    const opforNamesEl = opforEl.querySelector('.side-player-names');

    const playerNames = JSON.parse(playersArray || "[]");
    const bluforNames = playerNames[0] || [];
    const opforNames = playerNames[1] || [];

    bluforNamesEl.textContent = bluforNames.join(', ');
    opforNamesEl.textContent = opforNames.join(', ');
}

bluforEl.addEventListener('click', () => {
    if (bluforEl.classList.contains('disabled')) return;
    A3API.SendAlert('blufor');
});

opforEl.addEventListener('click', () => {
    if (opforEl.classList.contains('disabled')) return;
    A3API.SendAlert('opfor');
});