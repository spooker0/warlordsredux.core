#include "includes.inc"
params ["_sector", "_targetId"];
private _sectorName = _sector getVariable ["WL2_name", "Sector"];
_sector setVariable ["WL2_mapButtonText", _sectorName];

// Fast Travel Seized Button
private _fastTravelSeizedExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [0, ""] spawn WL2_fnc_executeFastTravel;
};
[
    _sector, _targetId,
    "ft",
    "Fast travel",
    _fastTravelSeizedExecute,
    true,
    "fastTravelSeized",
    [
        0,
        "FTSeized",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Home Button
private _fastTravelHomeExecute = {
    params ["_sector"];
    BIS_WL_targetSector = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
    [0, ""] spawn WL2_fnc_executeFastTravel;

    private _side = BIS_WL_playerSide;
    private _enemyGroups = allGroups select { side _x != _side };
    {
        _x forgetTarget player;
    } forEach _enemyGroups;
};
[
    _sector, _targetId,
    "ft-home",
    "Fast travel home",
    _fastTravelHomeExecute,
    true,
    "fastTravelHome",
    [
        0,
        "FTHome",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Stronghold
private _fastTravelStrongholdExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [5, ""] spawn WL2_fnc_executeFastTravel;
};
[
    _sector, _targetId,
    "ft-stronghold",
    "Fast travel stronghold",
    _fastTravelStrongholdExecute,
    true,
    "fastTravelStrongholdTarget",
    [
        0,
        "StrongholdFT",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Fast Travel Conflict Button
private _fastTravelConflictExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;

    private _fastTravelConflictCall = 1 call WL2_fnc_fastTravelConflictMarker;
    private _marker = _fastTravelConflictCall # 0;
    [1, _marker] call WL2_fnc_executeFastTravel;
    deleteMarkerLocal _marker;

    private _markerText = _fastTravelConflictCall # 1;
    deleteMarkerLocal _markerText;
};
[
    _sector, _targetId,
    "ft-conflict",
    "Fast travel contested",
    _fastTravelConflictExecute,
    true,
    "fastTravelConflict",
    [
        WL_COST_FTCONTESTED,
        "FTConflict",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Air Assault Button
private _airAssaultExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;

    private _fastTravelConflictCall = 2 call WL2_fnc_fastTravelConflictMarker;
    private _marker = _fastTravelConflictCall # 0;
    [2, _marker] call WL2_fnc_executeFastTravel;
    deleteMarkerLocal _marker;

    private _markerText = _fastTravelConflictCall # 1;
    deleteMarkerLocal _markerText;
};
[
    _sector, _targetId,
    "ft-air-assault",
    "Fast travel air assault",
    _airAssaultExecute,
    true,
    "airAssault",
    [
        WL_COST_AIRASSAULT,
        "FTAirAssault",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Vehicle Paradrop Button
private _vehicleParadropExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [3, ""] call WL2_fnc_executeFastTravel;
};
[
    _sector, _targetId,
    "vehicle-paradrop",
    "Vehicle paradrop",
    _vehicleParadropExecute,
    true,
    "vehicleParadrop",
    [
        WL_COST_PARADROP,
        "FTParadropVehicle",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Scan Button
private _scanExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [player, "scan", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    _sector, _targetId,
    "sector-scan",
    "Sector scan",
    _scanExecute,
    true,
    "scan",
    [
        WL_COST_SCAN,
        "Scan",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Combat air patrol button
private _combatAirExecute = {
    params ["_sector"];
    [player, "combatAir", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    _sector, _targetId,
    "order-cap",
    "Order combat air patrol",
    _combatAirExecute,
    true,
    "combatAirPatrol",
    [
        WL_COST_COMBATAIR,
        "CombatAir",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Debug combat air patrol button
#if WL_CAP_DEBUG
private _debugCombatAirExecute = {
    params ["_sector"];
    [player, "debugCombatAir", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
};
[
    _sector, _targetId,
    "order-cap-debug",
    "Debug: order combat air patrol",
    _debugCombatAirExecute,
    true,
    "combatAirPatrolDebug",
    [
        WL_COST_COMBATAIR,
        "CombatAir",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;
#endif

// Mark Sector button
private _markSectorExecuteLast = {
    params ["_sector"];
    [_sector, false] call WL2_fnc_sectorButtonMark;
};
private _markSectorExecuteNext = {
    params ["_sector"];
    [_sector, true] call WL2_fnc_sectorButtonMark;
};
[
    _sector, _targetId,
    "mark-sector",
    ([_sector, BIS_WL_playerSide] call WL2_fnc_sectorButtonMarker) # 0,
    [_markSectorExecuteNext, _markSectorExecuteLast],
    false,
    "markSector"
] call WL2_fnc_addTargetMapButton;