#include "includes.inc"
private _asset = cameraOn;
if !(_asset isKindOf "Plane") exitWith { "" };

private _pos = getPosASL _asset;
if (_pos # 0 > -WL_MAP_RESTRICTION_BUFFER &&
	_pos # 0 < worldSize + WL_MAP_RESTRICTION_BUFFER &&
	_pos # 1 > -WL_MAP_RESTRICTION_BUFFER &&
	_pos # 1 < worldSize + WL_MAP_RESTRICTION_BUFFER) exitWith {
	"Fly further away from the battlefield. You must fly 5km outside map boundaries to return to base.";
};

private _allUnits = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select {
	WL_ISUP(_x)
};

private _enemyAir = _allUnits select {
	_x isKindOf "Plane"
} select {
	WL_UNIT(_x, "cost", 0) > 10000;
} select {
	[_x] call WL2_fnc_getAssetSide != BIS_WL_playerSide
} select {
	private _alt = getPosASL _x # 2;
	_alt > 50 && speed _x > 50
};
if (count _enemyAir > 0) exitWith {
	"Enemy jets in the air. You can't return to base when enemy jets are in the air.";
};

private _lastDamageTime = _asset getEntityInfo 5;
if (damage _asset > 0.1 && _lastDamageTime > 0 && _lastDamageTime < WL_COOLDOWN_JETRTB_DMG) exitWith {
	"Damaged too recently to return to base.";
};

"ok";