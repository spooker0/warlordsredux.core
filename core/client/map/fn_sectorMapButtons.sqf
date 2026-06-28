#include "includes.inc"
params ["_sector", "_targetId"];
private _sectorName = _sector getVariable ["WL2_name", "Sector"];
_sector setVariable ["WL2_mapButtonText", _sectorName];

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
    "<t color='#00ff00'>Fast travel (automatic)</t>",
    _fastTravelAssetExecute,
    true,
    "fastTravelFrontline",
    [
        0,
        "FTSeized",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

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
    private _safeSpot = selectRandom ([_sector] call WL2_fnc_findSpawnsInSector);
    _safeSpot set [2, 500];
    [_safeSpot, getDir cameraOn, objNull, cameraOn] spawn WL2_fnc_executeParadrop;
};
[
    _sector, _targetId,
    "vehicle-paradrop",
    "Vehicle paradrop",
    _vehicleParadropExecute,
    true,
    "vehicleParadrop",
    [
        0,
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
        private _sectorName = _sector getVariable ["WL2_name", "Sector"];
        private _message = format [
            "Are you sure you want to establish a no-fly zone over %1? This will cost you %2%3 and put it on a %4 minute cooldown.",
            _sectorName, WL_MONEY_SIGN, WL_COST_COMBATAIR, round (WL_COOLDOWN_CAP / 60)
        ];
        private _result = [localize "STR_WL_combatAirPatrol", _message, "OK", "Cancel"] call WL2_fnc_prompt;

        if (!_result) exitWith {
            playSoundUI ["AddItemFailed"];
        };

        [player, "combatAir", BIS_WL_playerSide, _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
        playSoundUI ["a3\dubbing_f_jets\showcase_jets\30_reinforcements\showcase_jets_30_reinforcements_tower_0.wss"];
    };
};
[
    _sector, _targetId,
    "order-cap",
    localize "STR_WL_combatAirPatrol",
    _combatAirExecute,
    true,
    "combatAirPatrol",
    [
        WL_COST_COMBATAIR,
        "CombatAir",
        "Fast Travel"
    ]
] call WL2_fnc_addTargetMapButton;

// Combat air patrol home button
private _combatAirHomeExecute = {
    params ["_sector"];
    [_sector] spawn {
        params ["_sector"];
        private _message = format [
            "Are you sure you want to establish a no-fly zone over home base? This will cost you %1%2 and put it on a %3 minute cooldown. It will also reveal your home base to the enemy.",
            WL_MONEY_SIGN, WL_COST_COMBATAIR / 5, round (WL_COOLDOWN_CAPHOME / 60)
        ];
        private _result = [localize "STR_WL_combatAirPatrolHome", _message, "OK", "Cancel"] call WL2_fnc_prompt;

        if (!_result) exitWith {
            playSoundUI ["AddItemFailed"];
        };

        [player, "combatAirHome", BIS_WL_playerSide, _sector] remoteExec ["WL2_fnc_handleClientRequest", 2];
        playSoundUI ["a3\dubbing_f_jets\showcase_jets\30_reinforcements\showcase_jets_30_reinforcements_tower_0.wss"];
    };
};
[
    _sector, _targetId,
    "order-cap-home",
    localize "STR_WL_combatAirPatrolHome",
    _combatAirHomeExecute,
    true,
    "combatAirPatrolHome",
    [
        WL_COST_COMBATAIR / 5,
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

private _sectorFtAsset = [_sector, []] call WL2_fnc_getSectorFTAsset;
if (_sector in (BIS_WL_sectorsArray # 3) || (!isNull _sectorFtAsset)) then {
    [_sector, _targetId, "team-designate", "Designate team priority", {
        params ["_sector"];
        [_sector, "sector"] call WL2_fnc_designateTeamPriority;
    }, true, "designateTeamPriority", [0, "DesignatePriority", "Strategy"]] call WL2_fnc_addTargetMapButton;
};