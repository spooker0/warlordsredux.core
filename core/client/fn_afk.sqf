#include "includes.inc"
if (isDedicated) exitWith {};

#if WL_AFK_ADMIN_TEST == 0
private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
private _isModerator = _uid in (getArray (missionConfigFile >> "moderatorIDs"));
private _isSpectator = _uid in (getArray (missionConfigFile >> "spectatorIDs"));
if (_isAdmin || _isModerator || _isSpectator) exitWith {};
#endif

while { !BIS_WL_missionEnd } do {
	uiSleep 5;
	private _afkTimer = missionNamespace getVariable ["WL2_afkTimer", -1];
    private _isAfk = serverTime > _afkTimer;
    if (speed cameraOn > 40) then {
        missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_DURATION_AFKTIME];
        _isAfk = false;
    };
	if (_isAfk) then {
		hintSilent "You are too inactive to earn passive income. Mark yourself not afk in the scroll action menu.";
	};

    private _wasAfk = player getVariable ["WL2_afk", false];
    if (_wasAfk != _isAfk) then {
        player setVariable ["WL2_afk", _isAfk, [clientOwner, 2]];
    };

    if (serverTime - _afkTimer > 900) then {
        ["One of Us", true] call RWD_fnc_addBadge;
    };
};
