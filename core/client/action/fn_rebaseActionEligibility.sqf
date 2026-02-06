#include "includes.inc"
params ["_asset"];

if (!alive _asset) exitWith {
	[false, ""];
};

private _pos = getPosASL _asset;

if (_pos # 0 > -WL_MAP_RESTRICTION_BUFFER &&
	_pos # 0 < worldSize + WL_MAP_RESTRICTION_BUFFER &&
	_pos # 1 > -WL_MAP_RESTRICTION_BUFFER &&
	_pos # 1 < worldSize + WL_MAP_RESTRICTION_BUFFER) exitWith {
	[false, ""];
};

// Make sure false are returned first

private _allUnits = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select {
	WL_ISUP(_x)
};

private _enemyAir = _allUnits select {
	_x isKindOf "Plane" && !(_x isKindOf "Plane_Civil_01_base_F")
} select {
	[_x] call WL2_fnc_getAssetSide != BIS_WL_playerSide
} select {
	private _alt = getPosASL _x # 2;
	_alt > 50 && speed _x > 50
};
if (count _enemyAir > 0) exitWith {
	[true, "Enemy jet in air."];
};

private _lastDamageTime = _asset getEntityInfo 5;
if (damage _asset > 0.1 && _lastDamageTime > 0 && _lastDamageTime < WL_COOLDOWN_JETRTB_DMG) exitWith {
    [true, "Damaged too recently."];
};

private _playerFunds = (missionNamespace getVariable ["fundsDatabaseClients", createHashMap]) getOrDefault [getPlayerUID player, 0];
if (_playerFunds < WL_COST_JETRTB) exitWith {
	[true, "Insufficient funds."];
};

// team owns airbase
private _servicesAvailable = BIS_WL_sectorsArray # 5;
if ("A" in _servicesAvailable) exitWith {
    [true, ""];
};

private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _railUnits = _allUnits select {
	typeof _x == "Land_CraneRail_01_F"
};
private _forwardBasesWithRail = _forwardBases select {
	private _railsInBase = _railUnits inAreaArray [getPosASL _x, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
	count _railsInBase > 0
};

if (count _forwardBasesWithRail > 0) exitWith {
	[true, ""];
};

[true, "No friendly airfields available."];