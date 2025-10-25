#include "includes.inc"
params ["_unit"];

if (_unit isKindOf "Man") exitWith {
    side group _unit;
};

private _variableSide = _unit getVariable ["BIS_WL_ownerAssetSide", sideUnknown];
if (_variableSide != sideUnknown) exitWith {
    _variableSide;
};

private _strongholdSector = _unit getVariable ["WL_strongholdSector", objNull];
if !(isNull _strongholdSector) exitWith {
    _strongholdSector getVariable ["BIS_WL_owner", independent];
};

private _groupSide = side group _unit;
if (_groupSide != sideUnknown || _groupSide != civilian) exitWith {
    _groupSide;
};

private _vehicleConfig = configFile >> "CfgVehicles" >> typeOf _unit;
if (!isNull _vehicleConfig) exitWith {
    switch (getNumber (_vehicleConfig >> "side")) do {
        case 0: { east };
        case 1: { west };
        case 2: { independent };
        default { independent };
    };
};

sideUnknown;