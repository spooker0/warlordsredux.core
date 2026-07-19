#include "includes.inc"
params [["_cost", 0], ["_requirements", []]];

private _teamSectorsData = WL_SECTORS_DATA(BIS_WL_playerSide);
private _ownedSectors = _teamSectorsData getOrDefault ["owned", []];

private _findCurrentSector = _ownedSectors select {
    player inArea (_x getVariable "objectAreaComplete")
};

private _potentialBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBases = _potentialBases select {
    player distance2D _x < WL_FOB_RANGE
} select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
};

private _forwardBase = if (count _forwardBases > 0) then {
    _forwardBases # 0
} else {
    objNull
};

private _baseReady = _forwardBase getVariable ["WL2_forwardBaseReady", false];
if (!isNull _forwardBase && !_baseReady) exitWith {
    [false, "Forward base is still under construction."];
};

private _insufficientSupplies = _forwardBase getVariable ["WL2_forwardBaseSupplies", -1] < _cost;
if (!isNull _forwardBase && _insufficientSupplies) exitWith {
    [false, "Insufficient supplies in forward base."];
};

private _isLocked = _forwardBase getVariable ["WL2_forwardBaseLocked", false];
if (!isNull _forwardBase && _isLocked) exitWith {
    [false, "Forward base is locked."];
};

private _inRange = count _forwardBases > 0 || count _findCurrentSector > 0;

if (!_inRange && !("A" in _requirements) && !("W" in _requirements)) exitWith {
    [false, localize "STR_A3_WL_menu_arsenal_restr1"];
};

[true, ""];