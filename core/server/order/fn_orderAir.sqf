#include "includes.inc"
params ["_sender", "_pos", "_orderedClass", "_cost"];

if !(isServer) exitWith {};
private _class = WL_ASSET(_orderedClass, "spawn", _orderedClass);

private _owner = owner _sender;

private _sector = (_pos nearObjects ["Logic", 10]) select { _x in BIS_WL_allSectors } select 0;
private _spawnParams = [_sector] call WL2_fnc_getAirSectorSpawn;
_spawnParams params ["_spawnPos", "_dir"];

if (count _spawnPos == 0) exitWith {
	diag_log format ["Ordering aircraft failed. Spawn position not found in sector %1.", _sector getVariable "WL2_name"];
	["No suitable spawn position found. Clear the runways."] remoteExec ["WL2_fnc_smoothText", _owner];
	_sender setVariable ["BIS_WL_isOrdering", false, [2, _owner]];

	// refund if nothing spawned
	[_cost, getPlayerUID _sender] call WL2_fnc_fundsDatabaseWrite;
};

private _isUav = getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1;
private _asset = if (_isUav) then {
	[_spawnPos, _class, _orderedClass, [[0, 0, 1], [0, 1, 0]], false, _sender] call WL2_fnc_createUAVCrew;
} else {
	createVehicle [_class, _spawnPos, [], 0, "NONE"];
};

_asset setVehiclePosition [_spawnPos, [], 0, "CAN_COLLIDE"];
_asset setDir _dir;

[_asset, _sender, _orderedClass] call WL2_fnc_processOrder;

if (!_isUav) then {
	private _memoryPoint = getText (configFile >> "CfgVehicles" >> _class >> "memoryPointsGetInDriver");
	private _memoryPointPosition = _asset selectionPosition _memoryPoint;
	private _actualPosition = _asset modelToWorld _memoryPointPosition;
	_sender setVehiclePosition [_actualPosition, [], 0, "CAN_COLLIDE"];
};