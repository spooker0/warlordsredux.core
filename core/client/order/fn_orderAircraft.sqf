#include "includes.inc"
params ["_orderedClass"];

private _conditions = {
	params ["_sector"];

	private _linkOwner = _sector getVariable ["WL2_linkedOwner", sideUnknown];
	if (_linkOwner != BIS_WL_playerSide) exitWith {
		false
	};

	private _services = _sector getVariable ["WL2_services", []];
	if !("A" in _services) exitWith {
		false
	};

	true
};

private _successCallback = {
	params ["_sector", "_arguments"];
	private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", BIS_WL_playerSide], "unknown"];

	private _result = if (_sectorMarker == "camped") then {
		["Camped airbase", "Your team has marked this airbase as camped! Are you sure you would like to spawn your aircraft here?", "Yes", "Cancel"] call WL2_fnc_prompt;
	} else {
		true;
	};

	if (_result) then {
		[localize "STR_WL_assetDispatched"] call WL2_fnc_smoothText;
		player setPosATL (getPosATL player);

		[player, "orderAsset", "air", _sector, _arguments # 0, false] remoteExec ["WL2_fnc_handleClientRequest", 2];
	} else {
		[localize "STR_A3_WL_deploy_canceled"] call WL2_fnc_smoothText;
		player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
	};

	openMap [false, false];
};

private _cancelCallback = {
	[localize "STR_A3_WL_deploy_canceled"] call WL2_fnc_smoothText;
	player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
};

[
	"orderAircraft",
	_conditions,
	{},
	_successCallback,
	_cancelCallback,
	[_orderedClass],
	false
] spawn WL2_fnc_orderMapSelection;