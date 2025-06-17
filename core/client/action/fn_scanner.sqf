#include "includes.inc"
params ["_asset", "_actionId", "_awacs", "_iteration", ["_radiusOverride", -1]];

private _scannerOn = _asset getVariable ["WL_scannerOn", false];

private _actionColor = if (_scannerOn) then {
    "#4bff58";
} else {
    "#ff4b4b";
};

private _scannerTypeText = if (_awacs) then {
    "AESA RADAR";
} else {
    "SCANNER";
};

private _actionText = if (_scannerOn) then {
    format ["%1: ON", _scannerTypeText];
} else {
    format ["%1: OFF", _scannerTypeText];
};

_asset setUserActionText [_actionId, format ["<t color = '%1'>%2 [%3]</t>", _actionColor, _actionText, actionKeysNames "ActiveSensorsToggle"]];

if (!_scannerOn) exitWith {
    _asset setVariable ["WL_scannedObjects", []];
};

private _assetSide = [_asset] call WL2_fnc_getAssetSide;

if (_assetSide != side group player) exitWith {};

private _assetPos = _asset modelToWorldVisual [0, 0, 0];
private _assetHeight = (_assetPos # 2) min (getPosASL _asset # 2);
if (!_awacs && _assetHeight > 2000) exitWith {
    _asset setVariable ["WL_scannedObjects", []];
    _asset setVariable ["WL_scanRadius", 0];
};
if (_awacs && _assetHeight < 50) exitWith {
    _asset setVariable ["WL_scannedObjects", []];
    _asset setVariable ["WL_scanRadius", 0];
};

private _scanRadius = if (_awacs) then {
    WL_AWACS_RANGE;
} else {
    ((_assetHeight * 2) min 1000) max 350;
};
if (_radiusOverride > 0) then {
    _scanRadius = _radiusOverride;
};
_asset setVariable ["WL_scanRadius", _scanRadius];

private _relevantVehicles = if (_awacs) then {
    private _munitions = (8 allObjects 2) select {
        [_x] call WL2_fnc_isScannerMunition &&
    	[_assetPos, getDir _asset, 120, getPosATL _x] call WL2_fnc_inAngleCheck;
    };
    private _airVehicles = vehicles select {
        private _vehiclePos = _x modelToWorldVisual [0, 0, 0];
        _x isKindOf "Air" &&
        _vehiclePos # 2 > 50 &&
        [_assetPos, getDir _asset, 120, _vehiclePos] call WL2_fnc_inAngleCheck;
    };
    _munitions + _airVehicles
} else {
    (vehicles + allUnits) select {
        private _vehiclePos = _x modelToWorldVisual [0, 0, 0];
        (_x getVariable ["WL_spawnedAsset", false] || isPlayer _x)
    };
};

private _vehiclesInRadius = _relevantVehicles select {
    private _vehiclePos = _x modelToWorldVisual [0, 0, 0];
    _vehiclePos distance2D _assetPos < _scanRadius &&
    alive _x &&
    vehicle _x == _x;
};
private _scannedObjects = _vehiclesInRadius select {
    private _vehicleSide = [_x] call WL2_fnc_getAssetSide;
    _vehicleSide != _assetSide || ([_x] call WL2_fnc_isScannerMunition);
};

{
    _assetSide reportRemoteTarget [_x, 10];
} forEach _scannedObjects;

{
    if (_x getVariable ["WL_lastSpotted", objNull] != player) then {
        _x setVariable ["WL_lastSpotted", player, [2, clientOwner]];
    };
} forEach (_scannedObjects select {
    _x getVariable ["BIS_WL_ownerAsset", "123"] != "123"
});

if (getConnectedUAV player == _asset || vehicle player == _asset) then {
    if (_awacs) then {
        if (_iteration % 8 == 0) then {
            playSoundUI ["radarTargetLost", 2, 1, true];
        };
    } else {
        if (_iteration % 2 == 0) then {
            playSoundUI ["radarTargetLost", 2, 1, true];
        };
    };
};

_asset setVariable ["WL_scannedObjects", _scannedObjects];