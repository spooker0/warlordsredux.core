#include "includes.inc"
params ["_sender", "_pos", "_orderedClass", "_direction", "_exactPosition", "_spawnInAir"];

if !(isServer) exitWith {};

private _class = WL_ASSET(_orderedClass, "spawn", _orderedClass);

private _isUav = getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1;
private _asset = if (_isUav) then {
	[_pos, _class, _orderedClass, _direction, _exactPosition, _sender] call WL2_fnc_createUAVCrew;
} else {
	[_class, _orderedClass, _pos, _direction, _exactPosition, _spawnInAir] call WL2_fnc_createVehicleCorrectly;
};

waitUntil {
	uiSleep 0.1;
	!isNull _asset
};

[_asset, _sender, _orderedClass] call WL2_fnc_processOrder;