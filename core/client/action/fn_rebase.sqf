#include "includes.inc"
params ["_asset"];

private _airfieldSectors = (BIS_WL_sectorsArray # 2) select {
    private _services = _x getVariable ["WL2_services", []];
    "A" in _services;
};

private _allUnits = BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles;
private _forwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _railUnits = _allUnits select {
    typeof _x == "Land_CraneRail_01_F"
};
private _forwardBasesWithRail = _forwardBases select {
    private _railsInBase = _railUnits inAreaArray [getPosASL _x, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
    count _railsInBase > 0
};

private _landableAreas = _airfieldSectors + _forwardBasesWithRail;

if (count _landableAreas == 0) exitWith {
    ["No friendly airfields available!"] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

private _landableAreasByDistance = [_landableAreas, [], { cameraOn distance _x }, "ASCEND"] call BIS_fnc_sortBy;
private _closestLandableArea = _landableAreasByDistance # 0;

private _sectorName = _closestLandableArea getVariable ["WL2_name", "Forward Base"];

private _message = format ["Are you sure you want to return to %1 for %2%3?<br/>Make sure your landing gear is functional!", _sectorName, WL_MoneySign, WL_COST_JETRTB];
private _result = [_message, "Return to Nearest Airbase", "Rebase", "Cancel"] call BIS_fnc_guiMessage;

if (!_result) exitWith {
    playSoundUI ["AddItemFailed"];
};

private _spawnParams = if (_closestLandableArea isKindOf "Logic") then {
    [_closestLandableArea] call WL2_fnc_getAirSectorSpawn;
} else {
    private _railsInBase = _railUnits inAreaArray [getPosASL _closestLandableArea, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
    private _sortedRails = [_railsInBase, [], { cameraOn distance _x }, "ASCEND"] call BIS_fnc_sortBy;
    private _railForSpawn = _sortedRails # 0;
    [_railForSpawn modelToWorld [0, -10, 0], getDir _railForSpawn]
};

_spawnParams params ["_spawnPos", "_dir"];
if (count _spawnPos == 0) exitWith {
    ["No valid spawn position found at airbase!"] call WL2_fnc_smoothText;
    playSoundUI ["AddItemFailed"];
};

player action ["LandGear", _asset];

titleCut ["", "BLACK OUT", 1];

uiSleep 1;

private _startWaitTime = serverTime;
["Returning to base..."] call WL2_fnc_smoothText;
while { (serverTime - _startWaitTime) < 5 } do {
    _asset setAirplaneThrottle 0;
    _asset engineOn false;
    _asset setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
    _asset setVelocity [0, 0, 0];
    uiSleep 0.1;
};

_asset setVehiclePosition [_spawnPos, [], 0, "CAN_COLLIDE"];
_asset setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
_asset setDir _dir;
_asset setVelocity [0, 0, 0];

[player, "jetRTB"] remoteExec ["WL2_fnc_handleClientRequest", 2];

titleCut ["", "BLACK IN", 1];