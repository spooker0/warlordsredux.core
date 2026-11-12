#include "includes.inc"
params ["_orderedClass", "_cost", "_offset"];

private _teamSectorsData = WL_SECTORS_DATA(BIS_WL_playerSide);
private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];

private _findCurrentOwnedSector = _linkedSectors select {
	player inArea (_x getVariable "objectAreaComplete")
} select {
	private _services = _x getVariable ["WL2_services", []];
	"A" in _services
};

if (count _findCurrentOwnedSector == 0) exitWith {
	playSoundUI ["AddItemFailed", 1];
	[localize "STR_WL_orderAircraftRunwayRequired"] call WL2_fnc_smoothText;
};

private _sector = _findCurrentOwnedSector # 0;
private _services = _sector getVariable ["WL2_services", []];
if ("NR" in _services) exitWith {
	[_orderedClass, _cost, _offset] spawn WL2_fnc_orderVehicle;
};

private _sectorMarker = _sector getVariable [format ["WL2_MapMarker_%1", BIS_WL_playerSide], "unknown"];
private _sectorIsCamped = _sectorMarker == "camped";

private _settingsMap = missionProfileNamespace getVariable ["WL2_settings", createHashMap];
private _camperWarning = _settingsMap getOrDefault ["camperWarning", true];
if (_sectorIsCamped && _camperWarning) exitWith {
	playSoundUI ["AddItemFailed", 1];
	[localize "STR_WL_orderAircraftCampedWarning"] call WL2_fnc_smoothText;
};

private _campResult = if (_sectorIsCamped) then {
	playSoundUI ["AddItemFailed", 1];
	[localize "STR_WL_campedAirbase", localize "STR_WL_campedAirbaseConfirm", localize "STR_WL_yes", localize "STR_WL_cancel"] call WL2_fnc_prompt;
} else {
	true;
};
if (!_campResult) exitWith {
	[localize "STR_A3_WL_deploy_canceled"] call WL2_fnc_smoothText;
};

if (_sectorIsCamped) then {
	uiSleep 1;
};

private _sectorName = _sector getVariable ["WL2_name", localize "STR_WL_sector"];
private _displayName = [objNull, _orderedClass] call WL2_fnc_getAssetTypeName;
private _result = [localize "STR_WL_purchaseAircraft", format [localize "STR_WL_purchaseAircraftConfirm", _displayName, WL_MONEY_SIGN, _cost, _sectorName], localize "STR_WL_yes", localize "STR_WL_cancel"] call WL2_fnc_prompt;

if (_result) then {
	playSoundUI ["AddItemOK", 1];
	player setPosATL (getPosATL player);
	player setVariable ["BIS_WL_isOrdering", true, [2, clientOwner]];
	[player, "orderAsset", "air", _sector, _orderedClass, false] remoteExec ["WL2_fnc_handleClientRequest", 2];
	player setVariable ["BIS_WL_isOrdering", false, [2, clientOwner]];
} else {
	playSoundUI ["AddItemFailed", 1];
	[localize "STR_A3_WL_deploy_canceled"] call WL2_fnc_smoothText;
};