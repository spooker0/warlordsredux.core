#include "includes.inc"
params ["_orderedClass", "_cost"];

private _findCurrentOwnedSector = (BIS_WL_sectorsArray # 0) select {
	player inArea (_x getVariable "objectAreaComplete")
} select {
	private _services = _x getVariable ["WL2_services", []];
	"A" in _services
};

if (count _findCurrentOwnedSector == 0) exitWith {
	playSoundUI ["AddItemFailed", 1];
	["Must be in a sector with a runway."] call WL2_fnc_smoothText;
};

player setVariable ["BIS_WL_isOrdering", true, [2, clientOwner]];

private _sector = _findCurrentOwnedSector # 0;
private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", BIS_WL_playerSide], "unknown"];

private _result = if (_sectorMarker == "camped") then {
	["Camped airbase", "Your team has marked this airbase as camped! Are you sure you would like to spawn your aircraft here?", "Yes", "Cancel"] call WL2_fnc_prompt;
} else {
	private _sectorName = _sector getVariable ["WL2_name", "Sector"];
	private _displayName = [objNull, _orderedClass] call WL2_fnc_getAssetTypeName;
	["Purchase Aircraft", format ["You are about to purchase a %1 for %2%3 at %4.", _displayName, WL_MONEY_SIGN, _cost, _sectorName], "Yes", "Cancel"] call WL2_fnc_prompt;
};

if (_result) then {
	playSoundUI ["AddItemOK", 1];
	player setPosATL (getPosATL player);
	[player, "orderAsset", "air", _sector, _orderedClass, false] remoteExec ["WL2_fnc_handleClientRequest", 2];
} else {
	playSoundUI ["AddItemFailed", 1];
	[localize "STR_A3_WL_deploy_canceled"] call WL2_fnc_smoothText;
};

player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];