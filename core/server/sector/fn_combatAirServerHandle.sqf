#include "includes.inc"
params ["_combatAirSide", "_target", "_senderName", "_uid"];

private _broadcastActionToSide = {
	params ["_side", "_message"];
	private _allPlayers = call BIS_fnc_listPlayers;
	private _sidePlayers = [];
	{
		if (side group _x == _side) then {
			_sidePlayers pushBack _x;
		};
	} forEach _allPlayers;
	[_message] remoteExec ["WL2_fnc_broadcastAction", _sidePlayers];
};

private _targetName = _target getVariable ["WL2_name", "Forward Airbase"];
private _sideName = [_combatAirSide] call WL2_fnc_sideToFaction;

private _friendlyMessage = format ["%1 has initiated combat air patrol over %2.", _senderName, _targetName];
[_combatAirSide, _friendlyMessage] call _broadcastActionToSide;

private _enemyMessage = format ["%1 (%2) has initiated combat air patrol over %3.", _sideName, _senderName, _targetName];
private _enemySide = switch (_combatAirSide) do {
    case west : { east };
    case east : { west };
    default { civilian };
};
[_enemySide, _enemyMessage] call _broadcastActionToSide;

[_targetName] remoteExec ["WL2_fnc_combatAirWarning", _enemySide];

_target setVariable ["WL2_combatAirActive", true, true];
_target setVariable ["WL2_combatAirStart", serverTime, true];
_target setVariable ["WL2_combatAirRequester", _uid, true];

private _cooldown = if (_target in [WL2_base1, WL2_base2]) then {
	WL_COOLDOWN_CAP / 5
} else {
	WL_COOLDOWN_CAP
};
_target setVariable ["WL2_nextCombatAir", serverTime + WL_DURATION_CAP + _cooldown, true];

[_target] spawn {
    params ["_target"];
    uiSleep WL_DURATION_CAP;
    _target setVariable ["WL2_combatAirActive", false, true];
};