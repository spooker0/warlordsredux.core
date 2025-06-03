params ["_asset"];

if (lifeState _x == "INCAPACITATED") exitWith {
    35;
};

private _cachedSize = _asset getVariable ["WL2_iconSize", 0];
if (_cachedSize != 0) exitWith {
    _cachedSize;
};

private _returnResult = {
    params ["_size"];
    _asset setVariable ["WL2_iconSize", _size];
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