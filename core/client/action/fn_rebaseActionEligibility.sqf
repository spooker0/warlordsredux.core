#include "includes.inc"
params ["_asset"];

if (!alive _asset) exitWith {
	false;
};

private _lastDamageTime = _asset getEntityInfo 5;
if (_lastDamageTime > 0 && _lastDamageTime < WL_COOLDOWN_JETRTB_DMG) exitWith {
    false;
};

private _playerFunds = (missionNamespace getVariable ["fundsDatabaseClients", createHashMap]) getOrDefault [getPlayerUID player, 0];
if (_playerFunds < WL_COST_JETRTB) exitWith {
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