function updateData(gameData) {
    gameData = JSON.parse(gameData || '{}');

    const panel = document.querySelector('.panel');
    panel.innerHTML = '';

    if (!gameData || !gameData.length) {
        panel.innerHTML = '<div>No vehicles belonging to player found. Buy vehicles using the buy menu.</div>';
        return;
    }

    gameData.forEach(vehicle => {
        const vehicleDiv = document.createElement('div');
        vehicleDiv.className = 'vehicle';
        vehicleDiv.dataset.vehicleId = vehicle[0];
        vehicleDiv.innerHTML = `<span class="vehicle-name">${vehicle[1]}</span>`;

        const vehicleOptions = vehicle[2];
        vehicleOptions.forEach(optionId => {
            let optionClass = "";
            let optionText = "";
            if (optionId === 'remove') {
                optionClass = 'remove-button';
                optionText = 'REMOVE';
            } else if (optionId === 'lock') {
                optionClass = 'lock-button';
                optionText = 'LOCK';
            } else if (optionId === 'unlock') {
                optionClass = 'unlock-button';
                optionText = 'UNLOCK';
            } else if (optionId === 'kick') {
                optionClass = 'kick-button';
                optionText = 'KICK ALL';
            } else if (optionId === 'connect-driver') {
                optionClass = 'connect-button';
                optionText = 'CONTROL DRIVER';
            } else if (optionId === 'connect-gunner') {
                optionClass = 'connect-button';
                optionText = 'CONTROL GUNNER';
            } else if (optionId === 'set-auto') {
                optionClass = 'connect-button';
                optionText = 'TOGGLE AUTO';
            } else if (optionId === 'rearm') {
                optionClass = 'rearm-button';
                optionText = 'REARM';
            } else if (optionId === 'repair') {
                optionClass = 'repair-button';
                optionText = 'REPAIR';
            } else if (optionId === 'refuel') {
                optionClass = 'refuel-button';
                optionText = 'REFUEL';
            }

            const button = document.createElement('button');
            button.className = optionClass;
            button.textContent = optionText;

            button.addEventListener('mousedown', () => {
                A3API.SendAlert(`["${vehicle[0]}", "${optionId}"]`);
            });

            vehicleDiv.appendChild(button);
        });

        panel.appendChild(vehicleDiv);
    });
}