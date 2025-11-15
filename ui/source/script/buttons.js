function setButtons(title, buttons, left, top) {
    const wrapper = document.querySelector('.buttons-wrapper');
    wrapper.style.left = left + 'vw';
    wrapper.style.top = top + 'vh';

    const header = document.querySelector('.buttons-header');
    const container = document.querySelector('.buttons-container');

    header.textContent = title;
    container.innerHTML = '';

    buttons.forEach(button => {
        const btn = document.createElement('div');
        btn.className = 'button';

        const [id, label, enabled, iconUrl] = button;
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
        btn.appendChild(labelElement);

        btn.addEventListener('mousedown', function (event) {
            const leftClick = event.button === 0;
            A3API.SendAlert(`[${leftClick ? 0 : 1}, "${id}"]`);
        });

        container.appendChild(btn);
    });
}

function changeButtonText(buttonId, newText) {
    const button = document.querySelector(`.button[data-button-id="${buttonId}"]`);
    if (button) {
        button.querySelector('.button-label').innerHTML = newText;
    }
}

document.addEventListener('mousedown', function (event) {
    if (!(event.target.closest(".buttons-wrapper"))) {
        A3API.SendAlert("exit");
    }
});