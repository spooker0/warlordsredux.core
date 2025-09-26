#include "includes.inc"
params ["_asset"];

if (!alive _asset) exitWith {
	false;
};

private _pos = getPosASL _asset;

if (_pos # 0 > -WL_MAP_RESTRICTION_BUFFER &&
	_pos # 0 < worldSize + WL_MAP_RESTRICTION_BUFFER &&
	_pos # 1 > -WL_MAP_RESTRICTION_BUFFER &&
	_pos # 1 < worldSize + WL_MAP_RESTRICTION_BUFFER) exitWith {
	false;
};

// team must own airbase
private _servicesAvailable = BIS_WL_sectorsArray # 5;
if !("A" in _servicesAvailable) exitWith {
    false;
};

true;