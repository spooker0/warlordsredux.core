#include "includes.inc"
params ["_target", "_conditionName"];

switch (_conditionName) do {
    case "fastTravelSeized": {
        private _eligibleSectors = (BIS_WL_sectorsArray # 2) select {
            (_x getVariable ["BIS_WL_owner", independent]) == (side (group player))
        };
        _target in _eligibleSectors;
    };
    case "fastTravelConflict";
    case "airAssault": {
        _target == WL_TARGET_FRIENDLY;
    };
    case "vehicleParadrop": {
        private _sectorAvailable = _target in (BIS_WL_sectorsArray # 2);
        private _isCarrierSector = _target getVariable ["WL2_isAircraftCarrier", false];
        _sectorAvailable && !_isCarrierSector;
    };
    case "vehicleParadropFOB": {
        // alive _target && _target getVariable ["WL2_forwardBaseTime", serverTime] < serverTime;
        false;
    };
    case "scan": {
        private _allScannableSectors = BIS_WL_sectorsArray # 3;
        private _lastScanEligible = serverTime - WL_COOLDOWN_SCAN;
        private _availableSectors = _allScannableSectors select {
            _x getVariable [format ["BIS_WL_lastScanEnd_%1", BIS_WL_playerSide], -9999] < _lastScanEligible
        };
        _target in _availableSectors;
    };
    case "fastTravelSL": {
        private _mySquadLeader = ['getMySquadLeader'] call SQD_fnc_client;
        private _isMySquadLeader = getPlayerID _target == _mySquadLeader || getPlayerID (vehicle _target) == _mySquadLeader;
        _target != player && isPlayer _target && _isMySquadLeader && alive _target && lifeState _target != "INCAPACITATED";
    };
    case "fastTravelSquad": {
        private _squadMember = if (vehicle _target == _target) then {
            _target
        } else {
            vehicle _target
        };
        private _areInSquad = ["areInSquad", [getPlayerID _squadMember, getPlayerID player]] call SQD_fnc_client;
        _target != player && isPlayer _target && _areInSquad && alive _target && lifeState _target != "INCAPACITATED";
    };
    case "fastTravelStronghold": {
        private _findIsStronghold = (BIS_WL_sectorsArray # 2) select {
            (_x getVariable ["WL_stronghold", objNull]) == _target
        };
        count _findIsStronghold > 0;
    };
    case "fastTravelStrongholdTarget": {
        private _findIsStronghold = (BIS_WL_sectorsArray # 2) select {
            !isNull (_x getVariable ["WL_stronghold", objNull]) && _x == _target
        };
        count _findIsStronghold > 0;
    };
    case "removeStronghold": {
        private _findIsStronghold = (BIS_WL_sectorsArray # 2) select {
            private _strongholdBuilding = _x getVariable ["WL_stronghold", objNull];
            if (_strongholdBuilding != _target) then {
                false
            } else {
                private _owner = _strongholdBuilding getVariable ["WL_strongholdOwner", objNull];
                private _hasIntruders = _strongholdBuilding getVariable ["WL2_strongholdIntruders", false];
                (isNull _owner || _owner == player) && !_hasIntruders;
            };
        };
        count _findIsStronghold > 0;
    };
    case "fortifyStronghold": {
        private _sectorHasValidStronghold = (BIS_WL_sectorsArray # 2) select {
            private _strongholdBuilding = _x getVariable ["WL_stronghold", objNull];
            if (_strongholdBuilding != _target) then {
                false
            } else {
                private _owner = _strongholdBuilding getVariable ["WL_strongholdOwner", objNull];
                isNull _owner || _owner == player;
            };
        };
        if (count _sectorHasValidStronghold == 0) then {
            false;
        } else {
            private _sector = _sectorHasValidStronghold # 0;
            private _sectorIsFortifying = _sector getVariable ["WL_fortificationTime", -1] > serverTime;
            private _sectorAlreadyFortified = _sector getVariable ["WL_strongholdFortified", false];
            private _sectorIsVulnerable = count (_sector getVariable ["BIS_WL_previousOwners", []]) > 1;
            _sectorIsFortifying && !_sectorAlreadyFortified && _sectorIsVulnerable;
        };
    };
    case "fastTravelFOB": {
        alive _target &&
        _target getVariable ["WL2_forwardBaseTime", serverTime] < serverTime &&
        _target getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
    };
    case "markSector": {
        true;
    };
    case "deleteFOB": {
        _target getVariable ["WL2_forwardBasePlacer", false];
    };
    case "repairFOB": {
        private _maxHealth = _target getVariable ["WL2_demolitionMaxHealth", 5];
        alive _target &&
        _target getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide &&
        _target getVariable ["WL2_forwardBaseSupplies", -1] >= WL_FOB_REPAIR_COST &&
        _target getVariable ["WL2_demolitionHealth", _maxHealth] < _maxHealth
    };
};