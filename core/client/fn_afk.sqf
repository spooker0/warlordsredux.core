#include "..\warlords_constants.inc"

if (isDedicated) exitWith {};
private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));
if (_isAdmin || _isSpectator) exitWith {};

call WL2_fnc_afkAction;

while { alive player } do {
	sleep 5;
	private _afkTimer = missionNamespace getVariable ["WL2_afkTimer", -1];
    private _isAfk = serverTime > _afkTimer;
	if (_isAfk) then {
		hintSilent "You are too inactive to earn passive income. Mark yourself not afk in the scroll action menu.";
	};

    private _wasAfk = player getVariable ["WL2_afk", false];
    if (_wasAfk != _isAfk) then {
        player setVariable ["WL2_afk", _isAfk, [clientOwner, 2]];
    };
};
