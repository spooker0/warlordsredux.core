#include "includes.inc"
params ["_target", "_conditionName"];

switch (_conditionName) do {
    case "fastTravelSeized": {
        private _eligibleSectors = (BIS_WL_sectorsArray # 2) select {
            (_x getVariable ["BIS_WL_owner", independent]) == BIS_WL_playerSide
        };
        if (_target in _eligibleSectors && ([BIS_WL_playerSide] call WL2_fnc_getSideBase) != _target) then {
            "ok";
        } else {
            "";
        };
    };
    case "fastTravelFrontline": {
        private _homeBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
        if (_homeBase == _target) then {
            "";
        } else {
            "ok";
        };
    };
    case "fastTravelHome": {
        private _homeBase = [BIS_WL_playerSide] call WL2_fnc_getSideBase;
        if (_homeBase == _target) then {
            "ok";
        } else {
            "";
        };
    };
    case "fastTravelConflict";
    case "airAssault": {
        if (_target == WL_TARGET_FRIENDLY) then {
            "ok";
        } else {
            "";
        };
    };
    case "vehicleParadrop": {
        private _sectorAvailable = _target in (BIS_WL_sectorsArray # 2);
        if (!_sectorAvailable) exitWith { "" };

        private _isCarrierSector = _target getVariable ["WL2_isAircraftCarrier", false];
        if (_isCarrierSector) exitWith { "Cannot paradrop onto aircraft carriers." };

        if (_target == WL_TARGET_ENEMY) exitWith { "Cannot paradrop into contested sector." };

        "ok";
    };
    case "vehicleParadropFOB": {
        ""; // Disabled for now
    };
    case "scan": {
        private _allScannableSectors = BIS_WL_sectorsArray # 3;
        if !(_target in _allScannableSectors) exitWith { "" };

        private _scanningSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
        if (_target in _scanningSectors) exitWith { "Sector is already being scanned."};

        private _lastScanEligible = serverTime - WL_COOLDOWN_SCAN;
        private _lastScannedVar = format ["WL2_lastScanned_%1", BIS_WL_playerSide];
        private _lastScan = _target getVariable [_lastScannedVar, -9999];

        if (_lastScan > _lastScanEligible) exitWith { "Sector scan is on cooldown." };

        "ok";
    };
    case "combatAirPatrol": {
        private _airfieldSectors = (BIS_WL_sectorsArray # 2) select {
            private _services = _x getVariable ["WL2_services", []];
            "H" in _services;
        };
        if !(_target in _airfieldSectors) exitWith { "" };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "Combat air patrol is already active for this airbase." };

        private _nextCombatAirTime = _target getVariable ["WL2_nextCombatAir", -9999];
        if (_nextCombatAirTime > serverTime) exitWith { "Combat air patrol is on cooldown for this airbase." };

        "ok";
    };
    case "combatAirPatrolDebug": {
        private _airfieldSectors = (BIS_WL_sectorsArray # 2) select {
            private _services = _x getVariable ["WL2_services", []];
            "H" in _services;
        };
        if !(_target in _airfieldSectors) exitWith { "" };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "Combat air patrol is already active for this airbase." };

        "ok";
    };
    case "fastTravelSL": {
        if (_target == player) exitWith { "" };

        private _mySquadLeader = ["getSquadLeaderForPlayer", [getPlayerID player]] call SQD_fnc_query;
        if (_target isKindOf "Man") then {
            if (_target != _mySquadLeader) exitWith { "" };

            if (WL_ISDOWN(_target)) exitWith { "Squad leader is down." };

            private _position = getPosASL _target;
            if (surfaceIsWater _position && _position # 2 < 5) exitWith { "Squad leader is in water." };

            "ok";
        } else {
            if (!alive _target) exitWith { "" };

            private _crewSL = (crew _target) select { _x == _mySquadLeader };
            if (count _crewSL == 0) exitWith { "" };

            private _squadLeader = _crewSL # 0;
            if (WL_ISDOWN(_squadLeader)) exitWith { "Squad leader is down." };

            private _position = getPosASL _squadLeader;
            if (surfaceIsWater _position && _position # 2 < 5) exitWith { "Squad leader is in water." };

            "ok";
        };
    };
    case "fastTravelSquad": {
        if (_target == player) exitWith { "" };

        if (_target isKindOf "Man") then {
            if (!isPlayer _target) exitWith { "" };
            private _areInSquad = ["areInSquad", [getPlayerID _target, getPlayerID player]] call SQD_fnc_query;

            if (!_areInSquad) exitWith { "" };

            if (WL_ISDOWN(_target)) exitWith { "Squad member is down." };

            private _position = getPosASL _target;
            if (surfaceIsWater _position && _position # 2 < 5) exitWith { "Squad member is in water." };

            "ok";
        } else {
            if (!alive _target) exitWith { "" };

            private _crewMembers = crew _target;
            private _crewMembersInSquad = _crewMembers select {
                private _inSquad = ["areInSquad", [getPlayerID _x, getPlayerID player]] call SQD_fnc_query;
                _inSquad;
            };
            if (count _crewMembersInSquad == 0) exitWith { "" };

            private _aliveCrewMembersInSquad = _crewMembersInSquad select {
                WL_ISUP(_x)
            };
            if (count _aliveCrewMembersInSquad == 0) exitWith { "Squad member is down." };

            _aliveCrewMembersInSquad = _aliveCrewMembersInSquad select {
                private _position = getPosASL _x;
                !(surfaceIsWater _position) || (_position # 2 >= 5);
            };
            if (count _aliveCrewMembersInSquad == 0) exitWith { "Squad member is in water." };

            "ok";
        };
    };
    case "fastTravelAI": {
        if !(_target in (units player)) exitWith { "" };
        if (_target == player) exitWith { "" };
        if (WL_ISDOWN(_target)) exitWith { "AI is down." };
        private _position = getPosASL _target;
        if (surfaceIsWater _position && _position # 2 < 5) exitWith { "AI is in water." };
        "ok";
    };
    case "fastTravelStrongholdTarget": {
        private _findIsStronghold = (BIS_WL_sectorsArray # 2) select {
            !isNull (_x getVariable ["WL_stronghold", objNull]) && _x == _target
        };
        if (count _findIsStronghold > 0) then {
            "ok";
        } else {
            "";
        };
    };
    case "removeStronghold": {
        private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
        if !(_target in _strongholds) exitWith { "" };

        private _strongholdSector = _target getVariable ["WL_strongholdSector", objNull];
        private _isTargetedSector = _strongholdSector == WL_TARGET_ENEMY;
        if (_isTargetedSector) exitWith { "Cannot remove stronghold from map in contested sector." };

        private _hasIntruders = _target getVariable ["WL2_strongholdIntruders", false];
        if (_hasIntruders) exitWith { "Cannot remove stronghold with intruders present." };;

        "ok";
    };
    case "fortifyStronghold": {
        private _strongholds = missionNamespace getVariable ["WL_strongholds", []];
        if !(_target in _strongholds) exitWith { "" };

        private _sector = _target getVariable ["WL_strongholdSector", objNull];

        private _sectorIsVulnerable = count (_sector getVariable ["BIS_WL_previousOwners", []]) > 1;
        if (!_sectorIsVulnerable) exitWith { "Sector is not vulnerable." };

        private _sectorIsFortifying = _sector getVariable ["WL_fortificationTime", -1] > serverTime;
        if (!_sectorIsFortifying) exitWith { "Sector is not vulnerable." };

        private _sectorAlreadyFortified = _sector getVariable ["WL_strongholdFortified", false];
        if (_sectorAlreadyFortified) exitWith { "Sector is already being fortified." };

        "ok";
    };
    case "fastTravelFOB": {
        if (!alive _target) exitWith { "Forward base has been destroyed." };
        if (_target getVariable ["WL2_forwardBaseOwner", sideUnknown] != BIS_WL_playerSide) exitWith { "" };
        if !(_target getVariable ["WL2_forwardBaseReady", false]) exitWith { "Forward base under construction." };
        "ok";
    };
    case "markSector": {
        private _playerLevel = ["getLevel"] call WLC_fnc_getLevelInfo;
        if (_playerLevel >= 50) then {
            "ok";
        } else {
            "Must be at least Level 50 to mark sectors on the map.";
        };
    };
    case "lockFOB": {
        private _fobPlacer = _target getVariable ["WL2_forwardBasePlacer", ""];
        if (_fobPlacer != getPlayerUID player) exitWith {
            private _fobPlacerPlayer = _fobPlacer call BIS_fnc_getUnitByUid;
            format ["This forward base was placed by: %1", name _fobPlacerPlayer]
        };
        "ok";
    };
    case "deleteFOB": {
        private _fobPlacer = _target getVariable ["WL2_forwardBasePlacer", ""];
        if (_fobPlacer == "") exitWith { "ok" };
        if (_fobPlacer != getPlayerUID player) exitWith {
            private _fobPlacerPlayer = _fobPlacer call BIS_fnc_getUnitByUid;
            format ["This forward base was placed by: %1", name _fobPlacerPlayer]
        };
        "ok";
    };
    case "repairFOB": {
        private _fobOwner = _target getVariable ["WL2_forwardBaseOwner", sideUnknown];
        if (_fobOwner != BIS_WL_playerSide) exitWith { "" };

        if (!alive _target) exitWith { "Forward base has been destroyed." };

        private _maxHealth = _target getVariable ["WL2_demolitionMaxHealth", 12];
        private _currentHealth = _target getVariable ["WL2_demolitionHealth", _maxHealth];
        if (_currentHealth >= _maxHealth) exitWith { "Forward base is undamaged." };

        private _hasIntruders = _target getVariable ["WL2_forwardBaseIntruders", false];
        if (_hasIntruders) exitWith { "Cannot repair forward base with intruders present." };

        private _supplies = _target getVariable ["WL2_forwardBaseSupplies", -1];
        if (_supplies < WL_FOB_REPAIR_COST) exitWith { format ["Need %1 supplies to repair forward base.", WL_FOB_REPAIR_COST] };

        private _canRepairTime = _target getVariable ["WL2_canRepairTime", 0];
        if (serverTime < _canRepairTime) exitWith { "Forward base damaged too recently for repairs." };

        "ok";
    };
    case "combatAirPatrolFOB": {
        private _fobOwner = _target getVariable ["WL2_forwardBaseOwner", sideUnknown];
        if (_fobOwner != BIS_WL_playerSide) exitWith { "" };

        private _defenseLevel = _target getVariable ["WL2_forwardBaseDefenseLevel", 0];
        if (_defenseLevel < 4) exitWith { "" };

        if (!alive _target) exitWith { "Forward base has been destroyed." };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "Combat air patrol is already active for this airbase." };

        private _nextCombatAirTime = _target getVariable ["WL2_nextCombatAir", -9999];
        if (_nextCombatAirTime > serverTime) exitWith { "Combat air patrol is on cooldown for this airbase." };

        "ok";
    };
    case "defendFOB": {
        private _fobOwner = _target getVariable ["WL2_forwardBaseOwner", sideUnknown];
        if (_fobOwner != BIS_WL_playerSide) exitWith { "" };

        private _defenseLevel = _target getVariable ["WL2_forwardBaseDefenseLevel", 0];
        if (_defenseLevel >= 4) exitWith { "" };

        private _hasIntruders = _target getVariable ["WL2_forwardBaseIntruders", false];
        if (_hasIntruders) exitWith { "Cannot upgrade forward base with intruders present." };

        if (!alive _target) exitWith { "Forward base has been destroyed." };

        private _supplies = _target getVariable ["WL2_forwardBaseSupplies", -1];
        if (_supplies < WL_FOB_UPGRADE_COST) exitWith { format ["Need %1 supplies to add defenses to forward base.", WL_FOB_UPGRADE_COST] };

        "ok";
    };
    case "repairStronghold": {
        private _strongholdSector = _target getVariable ["WL_strongholdSector", objNull];
        if (isNull _strongholdSector) exitWith { "" };

        if (!alive _target) exitWith { "Stronghold has been destroyed." };

        private _maxHealth = _target getVariable ["WL2_demolitionMaxHealth", 8];
        private _currentHealth = _target getVariable ["WL2_demolitionHealth", _maxHealth];
        if (_currentHealth >= _maxHealth) exitWith { "Stronghold is undamaged." };

        private _hasIntruders = _target getVariable ["WL2_strongholdIntruders", false];
        if (_hasIntruders) exitWith { "Cannot repair stronghold with intruders present." };

        private _canRepairTime = _target getVariable ["WL2_canRepairTime", 0];
        if (serverTime < _canRepairTime) exitWith { "Stronghold damaged too recently for repairs." };

        "ok";
    };
    case "designateTeamPriority": {
        private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
        if (!_isSquadLeader) exitWith {
            "Must be squad leader to designate team priority.";
        };

        private _teamPriorityVar = format ["WL2_teamPriority_%1", BIS_WL_playerSide];
        private _currentPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
        if (_target == _currentPriority) exitWith {
            "This is already designated as your team's priority target.";
        };

        "ok";
    };

    default {
        "ok";
    };
};