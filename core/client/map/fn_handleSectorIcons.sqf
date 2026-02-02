#include "includes.inc"
params ["_nearbySectors", "_map"];

// previous: no sectors, now: no sectors
if (count _nearbySectors == 0 && isNull WL_SectorActionTarget) exitWith {};

// previous: has sectors, now: no sectors
if (count _nearbySectors == 0) exitWith {
    BIS_WL_highlightedSector = objNull;
    WL_SectorActionTarget = objNull;
    _group setVariable ["WL2_groupNextRenderTime", 0];
    call WL2_fnc_updateSelectionState;
};

private _groupNextRenderTime = _group getVariable ["WL2_groupNextRenderTime", 0];
if (_groupNextRenderTime > serverTime) exitWith {};
_group setVariable ["WL2_groupNextRenderTime", serverTime + 1];

private _sector = _nearbySectors # 0;

private _conditions = ["fastTravelSeized", "fastTravelConflict", "airAssault", "vehicleParadrop", "scan"];
private _sectorHasOptions = false;
{
    private _condition = _x;
    private _eligible = [_sector, _condition] call WL2_fnc_mapButtonConditions;
    if (_eligible == "ok") then {
        _sectorHasOptions = true;
    };
} forEach _conditions;
WL_SectorActionTargetActive = _sectorHasOptions;

private _selectionActive = BIS_WL_currentSelection in [
    WL_ID_SELECTION_ORDERING_AIRCRAFT,
    WL_ID_SELECTION_FAST_TRAVEL,
    WL_ID_SELECTION_FAST_TRAVEL_CONTESTED,
    WL_ID_SELECTION_FAST_TRAVEL_VEHICLE,
    WL_ID_SELECTION_FAST_TRAVEL_STRONGHOLD,
    WL_ID_SELECTION_SCAN,
    WL_ID_SELECTION_COMBAT_AIR
];
private _votingActive = WL_VotePhase != 0;
private _services = _sector getVariable ["WL2_services", []];

private _side = BIS_WL_playerSide;

private _getTeamColor = {
    params ["_team"];
    [
        [0, 0.3, 0.6, 1],
        [0.5, 0, 0, 1],
        [0, 0.5, 0, 1]
    ] # ([west, east, independent] find _team);
};

private _getTeamName = {
    params ["_team"];
    ["BLUFOR", "OPFOR", "INDEP"] # ([west, east, independent] find _team);
};

private _percentage = _sector getVariable ["BIS_WL_captureProgress", 0];
private _revealed = _side in (_sector getVariable ["BIS_WL_revealedBy", []]);
if (!_revealed) then {
    _percentage = 0;
};

private _servicesText = [];
if ("A" in _services) then {
    _servicesText pushBack localize "STR_A3_WL_param32_title";
};
if ("H" in _services) then {
    _servicesText pushBack localize "STR_A3_WL_module_service_helipad";
};

private _lastScannedVar = format ["WL2_lastScanned_%1", _side];
private _lastScan = _sector getVariable [_lastScannedVar, -9999];
private _scanCD = (_lastScan + WL_COOLDOWN_SCAN - serverTime) max 0;
private _currentScannedSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
private _isScanning = _sector in _currentScannedSectors;

private _scanCooldown = if (_isScanning) then {
    ["Scan active", [0, 1, 0, 1]]
} else {
    if (_scanCD > 0) then {
        [
            format ["%1: %2", localize "STR_A3_WL_param_scan_timeout", [ceil _scanCD, "MM:SS"] call BIS_fnc_secondsToString],
            [1, 0, 0, 1]
        ];
    } else {
        ""
    };
};

private _nextCombatAir = _sector getVariable ["WL2_nextCombatAir", -9999];
private _combatAirCD = (_nextCombatAir - serverTime) max 0;
private _isCombatAirActive = _sector getVariable ["WL2_combatAirActive", false];

private _combatAirText = if (_isCombatAirActive) then {
    [
        format ["Combat air patrol active: %1", [_nextCombatAir - WL_COOLDOWN_CAP - serverTime, "MM:SS"] call BIS_fnc_secondsToString],
        [0, 1, 0, 1]
    ]
} else {
    if (_combatAirCD > 0) then {
        [
            format ["%1: %2", "Combat air patrol timeout", [ceil _combatAirCD, "MM:SS"] call BIS_fnc_secondsToString],
            [1, 0, 0, 1]
        ];
    } else {
        ""
    };
};

private _fortification = if (_revealed) then {
    private _previousOwners = _sector getVariable ["BIS_WL_previousOwners", []];
    if (count _previousOwners > 1) then {
        private _fortificationTime = _sector getVariable ["WL_fortificationTime", -1];
        private _fortificationETA = ceil (_fortificationTime - serverTime);
        _fortificationETA = _fortificationETA max 0;
        [
            format ["Fortifying %1", [_fortificationETA, "MM:SS"] call BIS_fnc_secondsToString],
            [0.4, 0, 0.5, 1]
        ]
    } else {
        ""
    }
} else {
    ""
};

private _sectorName = _sector getVariable ["WL2_name", "Sector"];
private _sectorIncome = if !(_sectorName in WL_SPECIAL_SECTORS) then {
    format ["Size: %1", _sector getVariable ["BIS_WL_value", 0]]
} else {
    ""
};

private _sectorInfo = [
    _sectorName,
    _sectorIncome
];

private _captureDetails = _sector getVariable ["WL_captureDetails", []];
private _showCaptureDetails = if (_revealed) then {
    private _captureDetailPlayerTeamValid = _captureDetails select {
        _x # 0 == _side && _x # 1 >= 1
    };
    count _captureDetailPlayerTeamValid > 0
} else {
    false
};
if (_showCaptureDetails) then {
    private _captureDetailsArray = _captureDetails apply {
        private _side = _x # 0;
        private _sideName = [_side] call _getTeamName;
        private _score = floor (_x # 1);
        private _multiplier = _x # 2;
        if (_score < 1) then {
            "";
        } else {
            private _reserveText = if (_side == independent) then {
                private _reserves = _sector getVariable ["WL2_sectorPop", 0];
                if (_reserves > 0) then {
                    format [" (Reserves: %1)", round (_reserves * _multiplier)];
                } else {
                    " (Reserves depleted)"
                };
            } else {
                ""
            };
            [
                format ["%1 (%2x): %3%4", _sideName, _multiplier, _score, _reserveText],
                [_side] call _getTeamColor
            ];
        };
    };
    _sectorInfo append _captureDetailsArray;
};

_sectorInfo append [
    (_servicesText joinString ", "),
    _scanCooldown,
    _combatAirText,
    _fortification
];
_sectorInfo = _sectorInfo select {
    if (_x isEqualType "") then {
        _x != ""
    } else {
        count _x > 0
    };
};
_sector setVariable ["WL2_sectorInfo", _sectorInfo];

private _isNewSelection = WL_SectorActionTarget != _sector;

WL_SectorActionTarget = _sector;
call WL2_fnc_updateSelectionState;

if ((!_selectionActive && !_votingActive) || !(_sector in BIS_WL_selection_availableSectors)) exitWith {
    BIS_WL_highlightedSector = objNull;
};

BIS_WL_highlightedSector = _sector;
if (_isNewSelection) then {
    playSoundUI ["clickSoft", 1];
};

if (inputMouse 0 == 0) exitWith {};

private _singletonScriptHandle = uiNamespace getVariable ["WL2_mapSectorIconSingleton", scriptNull];
if (!isNull _singletonScriptHandle) exitWith {};

private _singletonScriptHandle = [_sector, _map] spawn {
    params ["_sector", "_map"];
    private _orderSelectionActive = BIS_WL_currentSelection in [
        WL_ID_SELECTION_ORDERING_AIRCRAFT,
        WL_ID_SELECTION_FAST_TRAVEL,
        WL_ID_SELECTION_FAST_TRAVEL_CONTESTED,
        WL_ID_SELECTION_FAST_TRAVEL_VEHICLE,
        WL_ID_SELECTION_FAST_TRAVEL_STRONGHOLD
    ];
    private _scanSelectionActive = BIS_WL_currentSelection == WL_ID_SELECTION_SCAN;
    private _combatAirActive = BIS_WL_currentSelection == WL_ID_SELECTION_COMBAT_AIR;
    private _votingActive = WL_VotePhase != 0;

    if !(_orderSelectionActive || _scanSelectionActive || _combatAirActive || _votingActive) exitWith {
        BIS_WL_highlightedSector = objNull;
        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };

    call WL2_fnc_updateSelectionState;

    private _availableSectors = BIS_WL_selection_availableSectors;

    if !(_sector in _availableSectors) exitWith {
        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };

    if (WL_VotePhase == 1) exitWith {
        BIS_WL_targetVote = _sector;
        BIS_WL_highlightedSector = _sector;
        private _targetVoteVar = format ["BIS_WL_targetVote_%1", getPlayerID player];
        missionNamespace setVariable [_targetVoteVar, _sector, 2];
        playSound "AddItemOK";
        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };

    if (_orderSelectionActive) exitWith {
        BIS_WL_targetSector = _sector;
        playSound "AddItemOK";

        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };

    private _side = BIS_WL_playerSide;
    private _lastScannedVar = format ["WL2_lastScanned_%1", _side];
    private _lastScan = _sector getVariable [_lastScannedVar, -9999];

    if (_scanSelectionActive) exitWith {
        if (_lastScan < serverTime - WL_COOLDOWN_SCAN) then {
            BIS_WL_targetSector = _sector;
            playSound "AddItemOK";
        } else {
            playSound "AddItemFailed";
        };

        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };

    if (_combatAirActive) exitWith {
        if ((_sector getVariable ["WL2_nextCombatAir", -9999]) < serverTime) then {
            BIS_WL_targetSector = _sector;
            playSound "AddItemOK";
        } else {
            playSound "AddItemFailed";
        };

        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };

    if (WL_VotePhase == 2) exitWith {
        BIS_WL_targetVote = _sector;
        BIS_WL_highlightedSector = _sector;
        private _targetVoteVar = format ["BIS_WL_targetVote_%1", getPlayerID player];
        missionNamespace setVariable [_targetVoteVar, _sector, 2];
        playSound "AddItemOK";

        waitUntil {
            uiSleep 0.001;
            inputMouse 0 == 0;
        };
    };
};

uiNamespace setVariable ["WL2_mapSectorIconSingleton", _singletonScriptHandle];