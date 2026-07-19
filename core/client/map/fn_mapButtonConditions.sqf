#include "includes.inc"
params ["_target", "_conditionName"];

private _side = BIS_WL_playerSide;
switch (_conditionName) do {
    case "fastTravelSeized": {
        private _teamSectorsData = WL_SECTORS_DATA(_side);
        private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];
        private _base = _teamSectorsData getOrDefault ["base", objNull];
        if (_target in _linkedSectors && _base != _target) then {
            "ok";
        } else {
            "";
        };
    };
    case "fastTravelFrontline": {
        private _sectorFrontlineCheck = [false, _target, "sector"] call WL2_fnc_travelTeamPriority;
        if (!_sectorFrontlineCheck) exitWith { "" };

        private _homeBase = [_side] call WL2_fnc_getSideBase;
        if (_homeBase == _target) then {
            "";
        } else {
            "ok";
        };
    };
    case "fastTravelHome": {
        private _homeBase = [_side] call WL2_fnc_getSideBase;
        if (_homeBase == _target) then {
            "ok";
        } else {
            "";
        };
    };
    case "fastTravelConflict";
    case "airAssault": {
        if (_target == WL_TARGET_FRIENDLY) then {
            if (_target in WL_BASES) then {
                "Can't fast travel to enemy home base.";
            } else {
                "ok";
            };
        } else {
            "";
        };
    };
    case "paradrop": {
        if (!alive _target) exitWith { "" };

        private _position = _target modelToWorld [0, 0, 0];
        private _altitude = _position # 2;
        if (_altitude < 200) exitWith { "Target not high enough for paradrop." };

        "ok";
    };
    case "vehicleParadrop": {
        private _teamSectorsData = WL_SECTORS_DATA(_side);
        private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];
        if !(_target in _linkedSectors) exitWith { "" };

        private _base = _teamSectorsData getOrDefault ["base", objNull];
        if (_base == _target) exitWith { "" };

        private _isCarrierSector = _target getVariable ["WL2_isAircraftCarrier", false];
        if (_isCarrierSector) exitWith { "Cannot paradrop onto aircraft carriers." };

        private _defenders = _target getVariable ["WL2_defenders", 0];
        if (_defenders <= 0 && _target == WL_TARGET_ENEMY) then {
            "Sector has run out of reinforements. Resupply the sector to enable vehicle paradrop there.";
        } else {
            "ok";
        };
    };
    case "vehicleParadropFOB": {
        if (!alive _target) exitWith { "Forward base has been destroyed." };
        if (_target getVariable ["WL2_forwardBaseOwner", sideUnknown] != _side) exitWith { "" };
        if !(_target getVariable ["WL2_forwardBaseReady", false]) exitWith { "Forward base under construction." };
        "ok";
    };
    case "scan": {
        private _teamSectorsData = WL_SECTORS_DATA(_side);
        private _unlockedSectors = _teamSectorsData getOrDefault ["unlocked", []];

        if !(_target in _unlockedSectors) exitWith { "" };

        private _scanningSectors = missionNamespace getVariable ["WL2_scanningSectors", []];
        if (_target in _scanningSectors) exitWith { "Sector is already being scanned."};

        private _lastScanEligible = serverTime - WL_COOLDOWN_SCAN;
        private _lastScannedVar = format ["WL2_lastScanned_%1", _side];
        private _lastScan = _target getVariable [_lastScannedVar, -9999];

        if (_lastScan > _lastScanEligible) exitWith { "Sector scan is on cooldown." };

        private _defenders = _target getVariable ["WL2_defenders", 0];
        if (_defenders <= 0 && _target == WL_TARGET_ENEMY) then {
            "Sector has run out of reinforements. Resupply the sector to enable sector scan.";
        } else {
            "ok";
        };
    };
    case "combatAirPatrol": {
        private _teamSectorsData = WL_SECTORS_DATA(_side);
        private _base = _teamSectorsData getOrDefault ["base", objNull];
        if (_target == _base) exitWith { "" };

        private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];
        private _airfieldSectors = _linkedSectors select {
            private _services = _x getVariable ["WL2_services", []];
            "H" in _services;
        };
        if !(_target in _airfieldSectors) exitWith { "" };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "No-fly zone is already active for this airbase." };

        private _nextCombatAirTime = _target getVariable ["WL2_nextCombatAir", -9999];
        if (_nextCombatAirTime > serverTime) exitWith { "No-fly zone is on cooldown for this airbase." };

        "ok";
    };
    case "combatAirPatrolHome": {
        private _homeBase = [_side] call WL2_fnc_getSideBase;
        if (_target != _homeBase) exitWith { "" };

        private _timeSinceStart = WL_DURATION_MISSION - (estimatedEndServerTime - serverTime);
        if (_timeSinceStart < WL_COMBAT_AIR_HOME_TIME) exitWith {
            format ["No-fly zone for home base locked: %1", [WL_COMBAT_AIR_HOME_TIME - _timeSinceStart, "MM:SS"] call BIS_fnc_secondsToString]
        };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "No-fly zone is already active for this airbase." };

        private _nextCombatAirTime = _target getVariable ["WL2_nextCombatAir", -9999];
        if (_nextCombatAirTime > serverTime) exitWith { "No-fly zone is on cooldown for this airbase." };

        "ok";
    };
    case "combatAirPatrolDebug": {
        private _teamSectorsData = WL_SECTORS_DATA(_side);
        private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];
        private _airfieldSectors = _linkedSectors select {
            private _services = _x getVariable ["WL2_services", []];
            "H" in _services;
        };
        if !(_target in _airfieldSectors) exitWith { "" };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "No-fly zone is already active for this airbase." };

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
        if (_target == player) exitWith { "" };
        if (vehicle player != player) exitWith { "" };
        "ok";
    };
    case "fastTravelStrongholdTarget": {
        private _teamSectorsData = WL_SECTORS_DATA(_side);
        private _linkedSectors = _teamSectorsData getOrDefault ["linked", []];
        private _findIsStronghold = _linkedSectors select {
            !isNull (_x getVariable ["WL_stronghold", objNull])
        } select {
            _x == _target
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
    case "fastTravelFOB": {
        if (!alive _target) exitWith { "Forward base has been destroyed." };
        if (_target getVariable ["WL2_forwardBaseOwner", sideUnknown] != _side) exitWith { "" };
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
        if (_fobOwner != _side) exitWith { "" };

        if (!alive _target) exitWith { "Forward base has been destroyed." };

        private _maxHealth = _target getVariable ["WL2_demolitionMaxHealth", 12];
        private _currentHealth = _target getVariable ["WL2_demolitionHealth", _maxHealth];
        if (_currentHealth >= _maxHealth) exitWith { "Forward base is undamaged." };

        private _hasIntruders = _target getVariable ["WL2_forwardBaseIntruders", false];
        if (_hasIntruders) exitWith { "Cannot repair forward base with intruders present." };

        private _supplies = _target getVariable ["WL2_forwardBaseSupplies", -1];
        if (_supplies < WL_FOB_REPAIR_COST) exitWith { format ["Need %1 supplies to repair forward base.", WL_FOB_REPAIR_COST] };

        private _canRepairTime = _target getVariable ["WL2_canRepairTime", 0];
        if (serverTime < _canRepairTime) exitWith {
            format ["Forward base damaged too recently for repairs: %1", [_canRepairTime - serverTime, "MM:SS"] call BIS_fnc_secondsToString]
        };

        "ok";
    };
    case "combatAirPatrolFOB": {
        private _fobOwner = _target getVariable ["WL2_forwardBaseOwner", sideUnknown];
        if (_fobOwner != _side) exitWith { "" };

        private _defenseLevel = _target getVariable ["WL2_forwardBaseDefenseLevel", 0];
        if (_defenseLevel < 4) exitWith { "" };

        if (!alive _target) exitWith { "Forward base has been destroyed." };

        private _combatAirActive = _target getVariable ["WL2_combatAirActive", false];
        if (_combatAirActive) exitWith { "No-fly zone is already active for this airbase." };

        private _nextCombatAirTime = _target getVariable ["WL2_nextCombatAir", -9999];
        if (_nextCombatAirTime > serverTime) exitWith {
            private _timeRemaining = [(_nextCombatAirTime - serverTime) max 0, "MM:SS"] call BIS_fnc_secondsToString;
            format ["No-fly zone is on cooldown for this airbase: %1", _timeRemaining]
        };

        "ok";
    };
    case "orderParadropFOB": {
        if (!alive _target) exitWith { "Forward base has been destroyed." };
        if !(_target getVariable ["WL2_forwardBaseReady", false]) exitWith { "Forward base under construction." };
        private _fobPlacer = _target getVariable ["WL2_forwardBasePlacer", ""];
        if (_fobPlacer == "") exitWith { "ok" };
        if (_fobPlacer != getPlayerUID player) exitWith {
            private _fobPlacerPlayer = _fobPlacer call BIS_fnc_getUnitByUid;
            format ["Only the owner can call for a paradrop. This forward base was placed by: %1", name _fobPlacerPlayer]
        };
        "ok";
    };
    case "defendFOB": {
        private _fobOwner = _target getVariable ["WL2_forwardBaseOwner", sideUnknown];
        if (_fobOwner != _side) exitWith { "" };

        private _defenseLevel = _target getVariable ["WL2_forwardBaseDefenseLevel", 0];
        if (_defenseLevel >= 4) exitWith { "" };

        private _hasIntruders = _target getVariable ["WL2_forwardBaseIntruders", false];
        if (_hasIntruders) exitWith { "Cannot upgrade forward base with intruders present." };

        private _fobPlacer = _target getVariable ["WL2_forwardBasePlacer", ""];
        if (_fobPlacer != "" && _fobPlacer != getPlayerUID player) exitWith {
            private _fobPlacerPlayer = _fobPlacer call BIS_fnc_getUnitByUid;
            format ["This forward base was placed by: %1", name _fobPlacerPlayer]
        };

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
        if (serverTime < _canRepairTime) exitWith {
            format ["Stronghold damaged too recently for repairs: %1", [_canRepairTime - serverTime, "MM:SS"] call BIS_fnc_secondsToString]
        };

        "ok";
    };
    case "conscriptTeam": {
        private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
        if (!_isSquadLeader) exitWith {
            "Must be squad leader to designate team priority for conscription.";
        };

        "ok";
    };
    case "designateTeamPriority": {
        private _isSquadLeader = ["isSquadLeader", [getPlayerID player]] call SQD_fnc_query;
        if (!_isSquadLeader) exitWith {
            "Must be squad leader to designate team priority.";
        };

        private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
        private _currentPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
        if (_target == _currentPriority) exitWith {
            "This is already designated as your team's priority target.";
        };

        "ok";
    };
    case "assetRearm": {
        if (!alive _target) exitWith { "" };
        if (_target isKindOf "Man") exitWith { "" };

        private _cooldown = (_target getVariable ["BIS_WL_nextRearm", 0]) - serverTime;
        if (_cooldown > 0) exitWith {
            format ["Vehicle rearm is on cooldown: %1", [_cooldown, "MM:SS"] call BIS_fnc_secondsToString]
        };

        private _nearbyVehicles = (BIS_WL_westOwnedVehicles + BIS_WL_eastOwnedVehicles + BIS_WL_guerOwnedVehicles) select { alive _x } select {
            _x distance2D _target < WL_MAINTENANCE_RADIUS
        } select {
            _x getVariable ["WLM_ammoCargo", 0] > 250
        };
        if (count _nearbyVehicles > 0) then {
            "ok";
        } else {
            "No nearby vehicles available for rearm.";
        };
    };
    case "assetRefuel": {
        if (!alive _target) exitWith { "" };

        private _fuelCapacity = getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "fuelCapacity");
        if (_fuelCapacity <= 0) exitWith { "" };

        private _canRefuel = [_target, player] call WL2_fnc_refuelActionEligibility;
        if (!_canRefuel) exitWith {
            "Vehicle must be stopped near fuel tank to be eligible for refuel."
        };

        "ok";
    };
    case "assetRepair": {
        if (!alive _target) exitWith { "" };
        if (_target isKindOf "Man") exitWith { "" };

        private _nextRepairTime = _target getVariable ["WL2_nextRepair", 0];
        if (serverTime < _nextRepairTime) exitWith {
            format ["Vehicle repair is on cooldown: %1", [_nextRepairTime - serverTime, "MM:SS"] call BIS_fnc_secondsToString]
        };

        private _canRepair = [_target, player] call WL2_fnc_repairActionEligibility;
        if (!_canRepair) exitWith {
            "Vehicle must be near repair asset."
        };

        "ok";
    };
    case "bulkDeploy": {
        if (!alive _target) exitWith { "" };
        if (cameraOn distance2D _target > 100) exitWith {
            "You are too far from this obstacle to use it for bulk deployment.";
        };

        private _installable = _target getVariable ["WL2_installable", ""];
        if (_installable == "") exitWith { "" };
        if (WL_ASSET_TYPE(_target) != _installable) exitWith { "" };

        private _lastMarker = missionNamespace getVariable ["WL2_lastMarker", ""];
        private _markerPolyline = markerPolyline _lastMarker;
        if (count _markerPolyline == 0) exitWith {
            "No map marker found. Draw a line on the map to bulk deploy assets."
        };

        private _firstPoint = [_markerPolyline # 0, _markerPolyline # 1, 0];
        if (cameraOn distance2D _firstPoint > 200) exitWith {
            "You are too far from the marker start position. Move closer before bulk deploying assets.";
        };

        "ok";
    };
    case "rtb": {
        if (!alive _target) exitWith { "" };
        if (typeof _target != "Land_CraneRail_01_F") exitWith { "" };
        call WL2_fnc_rebaseActionEligibility;
    };
    case "rtbSector": {
        private _targetServices = _target getVariable ["WL2_services", []];
        if !("A" in _targetServices) exitWith { "" };
        call WL2_fnc_rebaseActionEligibility;
    };
    case "repairStructures": {
        private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
        private _playerVehicles = missionNamespace getVariable [_ownedVehicleVar, []];

        private _sectorArea = _target getVariable ["objectAreaComplete", objNull];
        private _structuresInSector = (_playerVehicles inAreaArray _sectorArea) select {
            alive _x
        } select {
            private _maxDemolitionHealth = _x getVariable ["WL2_demolitionMaxHealth", 0];
            private _currentDemolitionHealth = _x getVariable ["WL2_demolitionHealth", 0];
            _maxDemolitionHealth > 0 && _currentDemolitionHealth < _maxDemolitionHealth;
        };
        if (count _structuresInSector == 0) exitWith { "" };

        _structuresInSector = _structuresInSector select {
            private _canRepairTime = _x getVariable ["WL2_canRepairTime", 0];
            _canRepairTime < serverTime;
        };
        if (count _structuresInSector == 0) exitWith {
            "No demolishable structures ready for repair."
        };

        "ok";
    };
    case "repairStructuresFob": {
        private _ownedVehicleVar = format ["BIS_WL_ownedVehicles_%1", getPlayerUID player];
        private _playerVehicles = missionNamespace getVariable [_ownedVehicleVar, []];

        private _forwardBaseArea = [getPosASL _target, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
        private _structuresInFob = (_playerVehicles inAreaArray _forwardBaseArea) select {
            alive _x
        } select {
            private _maxDemolitionHealth = _x getVariable ["WL2_demolitionMaxHealth", 0];
            private _currentDemolitionHealth = _x getVariable ["WL2_demolitionHealth", 0];
            _maxDemolitionHealth > 0 && _currentDemolitionHealth < _maxDemolitionHealth;
        };
        if (count _structuresInFob == 0) exitWith { "" };

        _structuresInFob = _structuresInFob select {
            private _canRepairTime = _x getVariable ["WL2_canRepairTime", 0];
            _canRepairTime < serverTime;
        };
        if (count _structuresInFob == 0) exitWith {
            "No demolishable structures ready for repair."
        };

        "ok";
    };

    default {
        "ok";
    };
};