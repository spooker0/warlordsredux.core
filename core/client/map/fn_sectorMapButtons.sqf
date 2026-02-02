#include "includes.inc"
params ["_sector", "_targetId"];
private _sectorName = _sector getVariable ["WL2_name", "Sector"];
_sector setVariable ["WL2_mapButtonText", _sectorName];

private _sectorFtAsset = [_sector, true] call WL2_fnc_getSectorFTAsset;
if (!isNull _sectorFtAsset) then {
    private _assetName = [_sectorFtAsset] call WL2_fnc_getAssetTypeName;

    // Fast Travel Asset Button
    private _fastTravelAssetExecute = {
        params ["_sector"];
        private _asset = [_sector, true] call WL2_fnc_getSectorFTAsset;
        if (WL_ISDOWN(player)) exitWith {
            ["Cannot fast travel while dead."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };
        if (isWeaponDeployed player) exitWith {
            ["Cannot fast travel while weapon is deployed."] call WL2_fnc_smoothText;
            playSoundUI ["AddItemFailed"];
        };
        [_asset] spawn WL2_fnc_executeFastTravelVehicle;
    };
    [
        _sector, _targetId,
        "ft-asset",
        format ["<t color='#00ff00'>Fast travel frontline (%1)</t>", _assetName],
        _fastTravelAssetExecute,
        true,
        "fastTravelFrontline",
        [
            0,
            "FTSeized",
            "Fast Travel"
        ]
    ] call WL2_fnc_addTargetMapButton;
};

// Fast Travel Seized Button
private _fastTravelSeizedExecute = {
    params ["_sector"];
    BIS_WL_targetSector = _sector;
    [0, ""] spawn WL2_fnc_executeFastTravel;
};
[
    _sector, _targetId,
    "ft-regular",
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

#if WL_FASTTRAVEL_CONFLICT
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
#endif

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
    "ft-parachute",
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

#if WL_CLEAR_SECTOR_DEBUG
private _clearSectorExecute = {
    params ["_sector"];
    private _objectArea = _sector getVariable "objectAreaComplete";
    private _vehicles = (allUnits + vehicles) inAreaArray _objectArea;
    _vehicles = _vehicles select { _x != player && _x != vehicle player };
    {
        _x setDamage 1;
    } forEach _vehicles;
};
[
    _sector, _targetId,
    "order-clear-sector",
    "Debug: clear sector",
    _clearSectorExecute,
    true,
    "airAssault",
    [
        0,
        "FTSeized",
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

private _sectorFtNonInfantryAsset = [_sector, false] call WL2_fnc_getSectorFTAsset;
if (_sector in (BIS_WL_sectorsArray # 3) || (!isNull _sectorFtNonInfantryAsset)) then {
    [_sector, _targetId, "team-designate", "Designate team priority", {
        params ["_sector"];
        [_sector, "sector"] call WL2_fnc_designateTeamPriority;
    }, true, "designateTeamPriority", [0, "FTSeized", "Fast Travel"]] call WL2_fnc_addTargetMapButton;
};