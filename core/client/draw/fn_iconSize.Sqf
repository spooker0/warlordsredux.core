#include "includes.inc"
params ["_asset", "_mapSizeCache"];

if (lifeState _x == "INCAPACITATED") exitWith {
    35;
};

private _sizeFromCache = _mapSizeCache getOrDefault [hashValue _asset, -1];
if (_sizeFromCache != -1) exitWith {
    _sizeFromCache;
};

private _returnResult = {
    params ["_size"];
    _mapSizeCache set [hashValue _asset, _size];
    _size;
};

if (_asset isKindOf "Man") exitWith {
    [19] call _returnResult;
};

if (_asset isKindOf "StaticWeapon") exitWith {
    [19] call _returnResult;
};

if (_asset isKindOf "LandVehicle") exitWith {
    [21] call _returnResult;
};

if (_asset isKindOf "Ship") exitWith {
    [19] call _returnResult;
};

if (_asset isKindOf "Air") exitWith {
    [23] call _returnResult;
};

[19] call _returnResult;