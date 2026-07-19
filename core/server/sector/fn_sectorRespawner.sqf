#include "includes.inc"

private _unitsPool = [];
{
    private _class = _x;
    private _data = _y;
    private _unitSpawn = _data getOrDefault ["unitSpawn", 0];
    if (_unitSpawn > 0 && _class != "Green_Infantry") then {
        _unitsPool pushBack _class;
    };
} forEach WL_ASSET_DATA;

while { !BIS_WL_missionEnd } do {
	uiSleep 10;

    private _addedUnits = [];
	{
        private _sector = _x;

        private _sectorOwner = _sector getVariable ["BIS_WL_owner", independent];
        if (_sectorOwner != independent) then {
            continue;
        };

        private _sectorArea = _sector getVariable "objectAreaComplete";
        private _isAircraftCarrier = _sector getVariable ["WL2_isAircraftCarrier", false];

        private _sectorPop = _sector getVariable ["WL2_sectorPop", 0];
        if (_sectorPop <= 0) then {
            continue;
        };

        private _newSectorPop = _sectorPop;

        private _sectorValue = _sector getVariable ["BIS_WL_value", 50];
        private _garrisonSize = _sectorValue * WL_SECTOR_GARRISON;

        private _spawnPosArr = [_sector] call WL2_fnc_findSpawnsInSector;

        private _sectorDefenders = _sector getVariable ["WL2_sectorDefenders", []];
        _sectorDefenders = _sectorDefenders select { alive _x };

        private _sectorInfantryDefenders = _sectorDefenders select { _x isKindOf "Man" } select { vehicle _x == _x };
        while { count _sectorInfantryDefenders < _garrisonSize } do {
            private _unitType = selectRandom _unitsPool;

            if (_newSectorPop <= 0) then {
                break;
            };
            _newSectorPop = _newSectorPop - 1;

            private _sectorDefenderGroups = [];
            {
                _sectorDefenderGroups pushBackUnique (group _x);
            } forEach _sectorInfantryDefenders;

            _sectorDefenderGroups = _sectorDefenderGroups select {
                private _groupUnits = units _x select { alive _x };
                count _groupUnits < 8
            };

            private _infantryGroup = if (count _sectorDefenderGroups > 0) then {
                selectRandom _sectorDefenderGroups
            } else {
                createGroup [independent, true];
            };

            private _units = (units _infantryGroup) select { alive _x };

            private _spawnPos = if (count _units > 0) then {
                private _unitInGroup = selectRandom _units;
                private _groupPos = getPosASL _unitInGroup;
                if (_groupPos inArea _sectorArea) then {
                    _groupPos;
                } else {
                    if (count _spawnPosArr > 0) then {
                        selectRandom _spawnPosArr;
                    } else {
                        getPosASL _sector;
                    };
                };
            } else {
                if (count _spawnPosArr > 0) then {
                    selectRandom _spawnPosArr;
                } else {
                    getPosASL _sector;
                };
            };

            private _newUnit = _infantryGroup createUnit [_unitType, _spawnPos, [], 30, "NONE"];
            private _posAboveGround = getPosATL _newUnit;
            _posAboveGround set [2, 100];

            _newUnit setVehiclePosition [_posAboveGround, [], 0, "CAN_COLLIDE"];

            if (_isAircraftCarrier) then {
                private _spawnHeight = getPosASL _newUnit # 2;
                if (_spawnHeight < 10 || _spawnHeight > 30) then {
                    deleteVehicle _newUnit;
                    continue;
                };
            };

            _newUnit call WL2_fnc_newAssetHandle;

            _newUnit setVariable ["WL2_sectorDefender", _sector];
            doStop _newUnit;

            _sectorInfantryDefenders pushBack _newUnit;
            _addedUnits pushBack _newUnit;

            _sectorDefenders pushBack _newUnit;
            _sectorDefenders = _sectorDefenders select { alive _x };

            _sector setVariable ["WL2_sectorDefenders", _sectorDefenders];
        };

        if (_newSectorPop != _sectorPop) then {
            _sector setVariable ["WL2_sectorPop", _newSectorPop, true];
        };
	} forEach BIS_WL_allSectors;

    private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
    _ownedVehicles append _addedUnits;
    missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];
};