#include "includes.inc"
params ["_projectile", "_position"];

private _bombClass = typeof _projectile;
private _penetrator = createVehicle [_bombClass, _position, [], 0, "NONE"];
_penetrator enableSimulation false;

private _inDestroyerArea = {
    _position inArea _x
} count ["marker_USS Liberty_outline", "marker_USS Freedom_outline", "marker_USS Independence_outline"] > 0;
if (_inDestroyerArea) then {
    _position set [2, 9.5];
    _penetrator setPosASL _position;
} else {
    private _inCarrierSector = {
        _position inArea (_x getVariable "objectAreaComplete") && _x getVariable ["WL2_isAircraftCarrier", false];
    } count BIS_WL_allSectors > 0;
    if (_inCarrierSector) then {
        _position set [2, 24.5];
        _penetrator setPosASL _position;
    } else {
        _position set [2, 0.5];
        _penetrator setPosATL _position;
    };
};

[_penetrator, [player, player]] remoteExec ["setShotParents", 2];

uiSleep 5;

_penetrator enableSimulation true;
triggerAmmo _penetrator;

private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
private _strongholdsInRange = _strongholds select {
    _x distance2D _position < 30;
};
if (count _strongholdsInRange > 0) then {
    private _stronghold = _strongholdsInRange # 0;
    [_stronghold, 5] call WL2_fnc_demolishStep;
};

private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _forwardBasesInRange = _forwardBases select {
    _x distance2D _position < 10;
};
if (count _forwardBasesInRange > 0) then {
    private _forwardBase = _forwardBasesInRange # 0;
    [_forwardBase, 5] call WL2_fnc_demolishStep;
};