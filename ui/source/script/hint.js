const hintWrapper = document.querySelector('.hint-wrapper');
const hintText = hintWrapper.querySelector('p');
const keysList = hintWrapper.querySelector('.keys-list');

const animationTimer = document.querySelector('.animation-timer');

function updateHint(hint, keysText) {
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
    const clampedProgress = Math.max(0, Math.min(1, progress));
    animationTimer.textContent = `${(clampedProgress * 100).toFixed(0)}%`;
    animationTimer.style.background = `linear-gradient(to right, #00ff00 ${clampedProgress * 100}%, rgba(0,0,0,0.5) ${clampedProgress * 100}%)`;
}