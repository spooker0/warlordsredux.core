#include "includes.inc"
params ["_sector", "_targetId"];
private _sectorName = _sector getVariable ["WL2_name", "Sector"];
_sector setVariable ["WL2_mapButtonText", _sectorName];

private _sectorFrontlineCheck = [false, _sector, "sector"] call WL2_fnc_travelTeamPriority;
if (_sectorFrontlineCheck) then {
    // Fast Travel Frontline Button
    private _fastTravelAssetExecute = {
        params ["_sector"];
        private _lastCheck = [true, _sector, "sector"] call WL2_fnc_travelTeamPriority;
        if (_lastCheck) then {
            playSoundUI ["AddItemOk"];
        } else {
            playSoundUI ["AddItemFailed"];
        };
    };
    [
        _sector, _targetId,
        "ft-asset",
        "<t color='#00ff00'>Fast travel frontline</t>",
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
    [0, _sector] spawn WL2_fnc_executeFastTravel;
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
    private _sideBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
    [0, _sideBase] spawn WL2_fnc_executeFastTravel;
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
    [5, _sector] spawn WL2_fnc_executeFastTravel;
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
    [1, _sector] call WL2_fnc_executeFastTravel;
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
    [2, _sector] call WL2_fnc_executeFastTravel;
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
    [3, _sector] call WL2_fnc_executeFastTravel;
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
    [_sector] spawn {
        params ["_sector"];
        private _message = format [
            "Are you sure you want to call in combat air patrol? This will cost you %1%2 and put it on a %3 minute cooldown.",
            WL_MONEY_SIGN, WL_COST_COMBATAIR, round (WL_COOLDOWN_CAP / 60)
        ];
        private _result = [_message, "Combat Air Patrol", "OK", "Cancel"] call BIS_fnc_guiMessage;

        if (!_result) exitWith {
            playSoundUI ["AddItemFailed"];
        };

        [player, "combatAir", [], _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
    };
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
        "ClearSectorDebug",
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
    }, true, "designateTeamPriority", [50, "DesignatePriority", "Strategy"]] call WL2_fnc_addTargetMapButton;
};