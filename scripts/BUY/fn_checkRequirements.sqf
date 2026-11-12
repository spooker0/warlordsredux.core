#include "includes.inc"
params ["_sector", "_requirements"];

if ("W" in _requirements) exitWith {
    [true, ""];
};

private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBases = _potentialBases select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
} select {
    player distance2D _x < WL_FOB_RANGE
};

if ("NF" in _requirements && count _forwardBases > 0) exitWith {
    [false, localize "STR_WL_requirementNoForwardBase"];
};

if ("F" in _requirements && count _forwardBases == 0) exitWith {
    [false, localize "STR_WL_requirementForwardBase"];
};

if (count _forwardBases > 0) then {
    _sector = _forwardBases # 0;
};

private _defenders = _sector getVariable ["WL2_defenders", 0];
private _sectorUnderAttack = _sector == WL_TARGET_ENEMY;

if (_sectorUnderAttack && _defenders <= 0) exitWith {
    [false, localize "STR_WL_sectorNoReinforcementsBuy"];
};

private _servicesInSector = _sector getVariable ["WL2_services", []];
if ("A" in _requirements && !("A" in _servicesInSector)) exitWith {
    [false, localize "STR_WL_requirementRunway"];
};

if ("H" in _requirements && !("H" in _servicesInSector)) exitWith {
    [false, localize "STR_WL_requirementHelipad"];
};

if ("FA" in _requirements && !("FA" in _servicesInSector)) exitWith {
    [false, localize "STR_WL_requirementForwardAirbase"];
};

if ("S" in _requirements && _sectorUnderAttack) exitWith {
    [false, localize "STR_WL_spawnUnderAttack"];
};

[true, ""];
