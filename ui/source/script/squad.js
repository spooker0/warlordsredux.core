document.querySelector('.create-squad-button').addEventListener('mousedown', function () {
    A3API.SendAlert('["create"]');
    document.querySelector('.create-squad-button-wrapper').classList.add('hide');
});

document.getElementById('cancel-rename-button').addEventListener('mousedown', () => {
    document.querySelector('.rename-modal').style.display = 'none';
});

function saveName() {
    document.querySelector('.rename-modal').style.display = 'none';
    const newName = document.getElementById('squad-name-input').value;
    const sanitizedName = newName.replace(/[^a-zA-Z0-9\s]/g, "").trim();
    if (!sanitizedName) {
        return;
    }
    A3API.SendAlert(`["renamed", ["${sanitizedName}"]]`);
}

document.getElementById('rename-squad-button').addEventListener('mousedown', () => {
    saveName();
});

function formatPoints(points) {
    if (points >= 1000000) {
        return (points / 1000000).toFixed(1) + "M pts";
    }
    if (points >= 1000) {
        return (points / 1000).toFixed(1) + "K pts";
    }
    return `Points: ${points}`;
}

function updateData(playerInfo, squadData) {
    playerInfo = JSON.parse(playerInfo || '{}');
    squadData = JSON.parse(squadData || '{}');

    const squadTemplate = document.querySelector('.squad.template');
    document.querySelector('.squads').innerHTML = '';

    const squaddedPlayers = [];
    let isInASquad = false;
    squadData.forEach(squad => {
        const squadMembers = squad[2];

        if (!squadMembers || squadMembers.length === 0) {
            return;
        }

        const squadEl = document.createElement('div');
        squadEl.classList.add('squad');

        const squadNameEl = document.createElement('h3');
        squadEl.appendChild(squadNameEl);
        document.querySelector('.squads').appendChild(squadEl);

        const isSquadLeader = squad[1] === playerInfo[0];
        const inCurrentSquad = squadMembers.some(member => member[0] === playerInfo[0]);

        let squadPoints = 0;
        squadMembers.forEach(member => {
            const memberEl = document.createElement('div');
            memberEl.classList.add('member');
            memberEl.dataset.playerId = member[0];
            memberEl.textContent = `${member[1]} (${formatPoints(member[2])})`;
            squadEl.appendChild(memberEl);

            squadPoints += member[2];

            squaddedPlayers.push(member[0]);

            const canFastTravel = member[3] === true;

            if (member[0] === playerInfo[0]) {
                isInASquad = true;

                const leaveButton = document.createElement('button');
                leaveButton.textContent = 'Leave';
                leaveButton.classList.add('leave-button');
                leaveButton.addEventListener('mousedown', function () {
                    A3API.SendAlert(`["leave"]`);
                });
                memberEl.appendChild(leaveButton);
            } else if (isSquadLeader) {
                const kickButton = document.createElement('button');
                kickButton.textContent = 'Kick';
                kickButton.classList.add('kick-button');
                kickButton.addEventListener('mousedown', function () {
                    A3API.SendAlert(`["kick", ["${member[0]}"]]`);
                });
                memberEl.appendChild(kickButton);

                const promoteButton = document.createElement('button');
                promoteButton.textContent = 'Promote';
                promoteButton.classList.add('promote-button');
                promoteButton.addEventListener('mousedown', function () {
                    A3API.SendAlert(`["promote", ["${member[0]}"]]`);
                });
                memberEl.appendChild(promoteButton);

                if (canFastTravel) {
                    const fastTravelButton = document.createElement('button');
                    fastTravelButton.textContent = 'Fast Travel';
                    fastTravelButton.classList.add('ft-button');
                    fastTravelButton.addEventListener('mousedown', function () {
                        A3API.SendAlert(`["ftSquad", ["${member[0]}"]]`);
                    });
                    memberEl.appendChild(fastTravelButton);
                }
            }

            if (squad[1] === member[0]) {
                memberEl.classList.add('squad-leader');
            } else {
                memberEl.classList.remove('squad-leader');
            }
        });

        squadNameEl.textContent = `${squad[0]} `;

        const squadMembersEl = document.createElement('span');
        squadMembersEl.classList.add('squad-members');
        squadMembersEl.textContent = `Members: ${squadMembers.length}`;
        squadNameEl.appendChild(squadMembersEl);

        const squadPointsEl = document.createElement('span');
        squadPointsEl.classList.add('squad-points');
        squadPointsEl.textContent = `${formatPoints(squadPoints)}`;
        squadNameEl.appendChild(squadPointsEl);

        if (isSquadLeader) {
            const editButton = document.createElement('button');
            editButton.textContent = 'Edit Squad Name';
            editButton.classList.add('edit-button');
            editButton.addEventListener('mousedown', function () {
                const renameModalEl = document.querySelector('.rename-modal');
                renameModalEl.style.display = 'flex';
                setTimeout(() => {
                    const input = document.getElementById('squad-name-input');
                    input.focus();

                    input.addEventListener('keydown', function handler(e) {
                        if (e.key === 'Enter') {
                            e.preventDefault();
                            saveName();
                            input.removeEventListener('keydown', handler);
                        }
                    });
                }, 50);
            });
            squadNameEl.appendChild(editButton);
        }
    });

    if (isInASquad) {
        document.querySelector('.create-squad-button-wrapper').classList.add('hide');
    } else {
        document.querySelector('.create-squad-button-wrapper').classList.remove('hide');
    }

    const unsquaddedPlayers = playerInfo[1].filter(player => !squaddedPlayers.includes(player[0]) && player[0] !== playerInfo[0]);
    const rightPanel = document.querySelector('.right-panel');
    rightPanel.innerHTML = '';
    unsquaddedPlayers.forEach(player => {
        const playerEl = document.createElement('div');
        playerEl.classList.add('unsquadded-player');
        playerEl.dataset.playerId = player[0];
        rightPanel.appendChild(playerEl);

        const playerName = player[1] || "";
        const playerNameSpan = document.createElement('span');
        playerNameSpan.textContent = `${playerName} (${formatPoints(player[2])})`;
        playerEl.appendChild(playerNameSpan);

        if (isInASquad) {
            const inviteButton = document.createElement('button');
            inviteButton.textContent = 'Invite';
            inviteButton.classList.add('invite-button');
            inviteButton.addEventListener('mousedown', function () {
                A3API.SendAlert(`["invite", ["${player[0]}"]]`);
            });
            playerEl.appendChild(inviteButton);
        }
    });
}