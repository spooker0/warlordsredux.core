#include "..\warlords_constants.inc"

if (isDedicated) exitWith {};
private _uid = getPlayerUID player;
private _isAdmin = _uid in (getArray (missionConfigFile >> "adminIDs"));
if (_isAdmin) exitWith {};

private _addAction = {
    player addAction [
        "<t color='#ff0000'>NOT AFK</t>",
        {
            params ["_target", "_caller", "_actionId", "_argument"];
            missionNamespace setVariable ["WL2_afkTimer", serverTime + WL_AFK_TIMER];
            player setVariable ["WL2_afk", false, [clientOwner, 2]];
            hintSilent "";

            player removeAction _actionId;
            call _argument;
        },
        _addAction,
        round (random [0, 3, 6]),
        false,
        true,
        "",
        "_target == _this && player getVariable ['WL2_afk', false]",
        -1
    ];
};
call _addAction;

while { alive player } do {
	sleep 5;
	private _afkTimer = missionNamespace getVariable ["WL2_afkTimer", -1];
    private _isAfk = serverTime > _afkTimer;
	if (_isAfk) then {
		hintSilent "You are too inactive to earn passive income. Mark yourself as not afk in the scroll action menu.";
	};

    private _wasAfk = player getVariable ["WL2_afk", false];
    if (_wasAfk != _isAfk) then {
        player setVariable ["WL2_afk", _isAfk, [clientOwner, 2]];
    };
};
