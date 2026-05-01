#include "includes.inc"

private _conditions = {
	params ["_sector"];

	private _linkOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
	if (_linkOwner != BIS_WL_playerSide) exitWith {
		false
	};

	private _services = _sector getVariable ["WL2_services", []];
	if !("H" in _services) exitWith {
		false
	};

	private _nextCombatAir = _sector getVariable ["WL2_nextCombatAir", -9999];
	if (_nextCombatAir > serverTime) exitWith {
		false
	};

	private _combatAirActive = _sector getVariable ["WL2_combatAirActive", false];
	if (_combatAirActive) exitWith {
		false
	};

	true
};

private _successCallback = {
	params ["_sector"];
	[player, "combatAir", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
};

private _cancelCallback = {
	[localize "STR_A3_WL_deploy_canceled"] call WL2_fnc_smoothText;
};

[
	"combatAir",
	_conditions,
	{},
	_successCallback,
	_cancelCallback,
	[],
	false
] spawn WL2_fnc_orderMapSelection;