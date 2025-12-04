function setButtons(buttonGroups, left, top) {
    const wrapper = document.querySelector('.buttons-wrapper');
    wrapper.style.left = left + 'vw';
    wrapper.style.top = top + 'vh';
    wrapper.style.maxHeight = (100 - top - 2) + 'vh';

    let buttonNumpad = 1;
    buttonGroups.forEach(group => {
        const [targetId, targetName, buttons] = group;
        const container = document.createElement('div');
        container.className = 'buttons-container';
        wrapper.appendChild(container);

        const header = document.createElement('div');
        header.className = 'buttons-header';
        header.innerHTML = targetName;
        container.appendChild(header);

        buttons.forEach(button => {
            const btn = document.createElement('div');
            btn.className = 'button';
            btn.dataset.targetId = targetId;

            const [id, label, cost, canAfford, enabled, iconUrl] = button;
            btn.dataset.buttonId = id;

            if (!enabled) {
                btn.classList.add('disabled');
            }

            if (iconUrl) {
                const iconElement = document.createElement('img');
                iconElement.className = 'button-icon';
                A3API.RequestTexture(iconUrl, 16).then(img => {
                    iconElement.src = img;
                });
                btn.appendChild(iconElement);
            }

            const labelElement = document.createElement('span');
            labelElement.className = 'button-label';
            labelElement.innerHTML = label;

            if (cost >= 0) {
                const costElement = document.createElement('span');
                costElement.className = 'button-cost';
                const costText = cost === 0 ? 'Free' : `Cost: ${cost}`;
                costElement.innerHTML = `(${costText})`;

                if (canAfford) {
                    costElement.style.color = 'lightgreen';
                } else {
                    costElement.style.color = 'red';
                }

                labelElement.appendChild(costElement);
            }

            btn.appendChild(labelElement);

            if (buttonNumpad <= 9) {
                const hotkeyElement = document.createElement('span');
                hotkeyElement.className = 'button-hotkey';
                hotkeyElement.textContent = `[${buttonNumpad !== 1 ? buttonNumpad : '1 or Space'}]`;
                btn.appendChild(hotkeyElement);
                buttonNumpad++;
            }

            btn.addEventListener('mousedown', function (event) {
                const leftClick = event.button === 0;
                A3API.SendAlert(`[${leftClick ? 0 : 1}, "${id}", ${targetId}]`);
            });

            container.appendChild(btn);
        });
    });
}

function changeButtonText(targetId, buttonId, newText) {
    const button = document.querySelector(`.button[data-target-id="${targetId}"][data-button-id="${buttonId}"]`);
    if (button) {
        button.querySelector('.button-label').innerHTML = newText;
    }
}

document.addEventListener('mousedown', function (event) {
    if (!(event.target.closest(".buttons-wrapper"))) {
        A3API.SendAlert("exit");
    }
});