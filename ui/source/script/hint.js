const hintWrapper = document.querySelector('.hint-wrapper');
const hintText = hintWrapper.querySelector('p');
const keysList = hintWrapper.querySelector('.keys-list');

// Function to update the hint text and keys
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
        rightSpan.style.color = '#00ff00';
        li.appendChild(rightSpan);

        keysList.appendChild(li);
    });
}