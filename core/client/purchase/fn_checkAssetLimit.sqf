#include "includes.inc"
params ["_class"];
if (_class isKindOf "Man") exitWith {
    [true, ""];
};
if (WL_ASSET(_class, "obstacle", 0) > 0) exitWith {
    [true, ""];
};

private _ownedVehiclesVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
private _ownedVehicles = missionNamespace getVariable [_ownedVehiclesVar, []];
_ownedVehicles = _ownedVehicles select { alive _x } select {
    WL_UNIT(_x, "obstacle", 0) == 0
} select {
    !(_x isKindOf "Man")
} select {
    WL_UNIT(_x, "category", "Other") != "Special"
};

private _limitedVehicles = [];
private _typeLimit = 0;

private _isBuildable = {
    params ["_class"];
    _class isKindOf "Building" || _class isKindOf "ReammoBox_F"
};

if ([_class] call _isBuildable) then {
    _limitedVehicles = _ownedVehicles select { [_x] call _isBuildable } select { WL_ASSET(_class, "obstacle", 0) == 0 };
    _typeLimit = WL_MAX_BUILDINGS;
} else {
    _limitedVehicles = _ownedVehicles select { !([_x] call _isBuildable) } select { WL_ASSET(_class, "obstacle", 0) == 0 };
    _typeLimit = WL_MAX_ASSETS;
};

if (count _limitedVehicles >= _typeLimit) exitWith {
    [false, localize "STR_WL_assetLimitReached"];
};

private _teamLimit = WL_ASSET(_class, "teamLimit", 0);
if (_teamLimit == 0) exitWith {
    [true, ""];
};

private _teamUnits = switch (BIS_WL_playerSide) do {
    case west: { BIS_WL_westOwnedVehicles };
    case east: { BIS_WL_eastOwnedVehicles };
    case independent: { BIS_WL_guerOwnedVehicles };
    default { [] };
};

private _teamSameAsset = _teamUnits select {
    WL_ASSET_TYPE(_x) == _class
};
if (count _teamSameAsset >= _teamLimit) exitWith {
    [false, format ["Team asset limit reached. Limit: %1", _teamLimit]];
};

[true, ""];