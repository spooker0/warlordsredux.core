function createMenu(settingsData) {
    settingsData = JSON.parse(settingsData || '[]');
    const container = document.getElementById("settingsContainer");

    function createCategory(title) {
        const h3 = document.createElement("div");
        h3.className = "category";
        h3.textContent = title;
        return h3;
    }

    function createSlider(labelText, [min, max, step, value, id]) {
        const row = document.createElement("div");
        row.className = "control-row";

        const label = document.createElement("label");
        label.htmlFor = id;
        label.textContent = labelText;

        const slider = document.createElement("input");
        slider.type = "range";
        slider.id = id;
        slider.min = min;
        slider.max = max;
        slider.step = step;
        slider.value = value;

        const valueInput = document.createElement("input");
        valueInput.className = "value-input";
        valueInput.type = "number";
        valueInput.min = min;
        valueInput.max = max;
        valueInput.step = step;
        valueInput.value = value;

        // Update input when slider moves
        slider.addEventListener("input", () => {
            valueInput.value = slider.value;
            A3API.SendAlert(`["slider", "${id}", ${slider.value}]`);
        });

        // Update slider when input changes
        valueInput.addEventListener("change", () => {
            let newValue = parseFloat(valueInput.value);
            if (isNaN(newValue)) newValue = value;
            newValue = Math.max(min, Math.min(max, newValue));
            valueInput.value = newValue;
            slider.value = newValue;
            A3API.SendAlert(`["slider", "${id}", ${newValue}]`);
        });

        row.appendChild(label);
        row.appendChild(slider);
        row.appendChild(valueInput);
        return row;
    }

    function createCheckbox(labelText, [id, defaultVal]) {
        const row = document.createElement("div");
        row.className = "control-row";

        const checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        checkbox.id = id;
        checkbox.checked = !!defaultVal;

        const label = document.createElement("label");
        label.htmlFor = id;
        label.textContent = labelText;

        checkbox.addEventListener("change", () => {
            A3API.SendAlert(`["checkbox", "${id}", ${checkbox.checked}]`);
        });

        row.appendChild(checkbox);
        row.appendChild(label);
        return row;
    }

    function createButton(labelText, image) {
        const button = document.createElement("button");

        if (image) {
            const eWeaponImage = document.createElement('img');
            A3API.RequestTexture(image, 64).then(imageContent => eWeaponImage.src = imageContent);
            button.appendChild(eWeaponImage);
        }

        const buttonText = document.createElement('div');
        buttonText.textContent = labelText;
        button.appendChild(buttonText);

        button.addEventListener("click", () => {
            A3API.SendAlert(`["button", "${labelText}"]`);
        });
        return button;
    }

    settingsData.forEach((item) => {
        const [type, label, params] = item;
        let element;
        switch (type) {
            case "category":
                element = createCategory(label);
                break;
            case "slider":
                element = createSlider(label, params);
                break;
            case "checkbox":
                element = createCheckbox(label, params);
                break;
            case "button":
                element = createButton(label, params);
                break;
            default:
                console.warn("Unknown control type:", type);
                return;
        }
        container.appendChild(element);
    });

    addSearchBar(container);
}

function addSearchBar(container) {
    const searchWrap = document.createElement('div');
    searchWrap.className = 'search-wrap';

    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'search-input';
    input.placeholder = 'Search settings...';
    searchWrap.appendChild(input);

    const children = Array.from(container.children);
    const buttons = children.filter(el => el.tagName === 'BUTTON');
    if (buttons.length) {
        buttons[buttons.length - 1].insertAdjacentElement('afterend', searchWrap);
    } else {
        container.insertBefore(searchWrap, container.firstChild);
    }

    const entries = () => Array.from(container.children).filter(el =>
        el.classList?.contains('control-row')
    );

    const entryText = (el) => {
        if (el.classList.contains('control-row')) {
            const label = el.querySelector('label');
            return (label ? label.textContent : el.textContent).trim();
        }
        if (el.tagName === 'BUTTON') return el.textContent.trim();
        return '';
    };

    function applyFilter(q) {
        const query = q.trim().toLowerCase();

        entries().forEach(el => {
            const text = entryText(el).toLowerCase();
            const match = !query || text.startsWith(query) || text.indexOf(query) >= 0;
            el.style.display = match ? '' : 'none';
        });
    }

    document.addEventListener('click', function (e) {
        if (e.target === input) {
            input.placeholder = '';
            input.style.border = '1px solid #e5f31f';
        } else {
            input.placeholder = 'Search settings...';
            input.style.border = '1px solid #555';
        }
    });

    input.addEventListener('input', e => applyFilter(e.target.value));
}