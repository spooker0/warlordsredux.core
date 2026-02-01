#include "includes.inc"

while { !BIS_WL_missionEnd } do {
	uiSleep 15;

    private _addedUnits = [];
	{
        private _sector = _x;

        private _sectorOwner = _sector getVariable ["BIS_WL_owner", sideUnknown];
        if (_sectorOwner != independent) then {
            continue;
        };

        private _sectorRespawnPool = _sector getVariable ["WL2_sectorRespawnPool", []];

        if (count _sectorRespawnPool == 0) then {
            continue;
        };

        private _sectorPop = _sector getVariable ["WL2_sectorPop", 0];
        private _spawnPosArr = [_sector] call WL2_fnc_findSpawnsInSector;
        {
            private _unitType = _x;

            _sectorPop = _sectorPop - 1;
            if (_sectorPop <= 0) then {
                break;
            };

            private _sectorDefenders = _sector getVariable ["WL2_sectorDefenders", []];
            _sectorDefenders = _sectorDefenders select { alive _x };

            private _sectorDefenderGroups = [];
            {
                _sectorDefenderGroups pushBackUnique (group _x);
            } forEach _sectorDefenders;

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
                getPosASL _unitInGroup;
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
            _newUnit call WL2_fnc_newAssetHandle;

            _newUnit setVariable ["WL2_sectorDefender", _sector];
            doStop _newUnit;
            _addedUnits pushBack _newUnit;

            _sectorDefenders pushBack _newUnit;
            _sector setVariable ["WL2_sectorDefenders", _sectorDefenders];
        } forEach _sectorRespawnPool;

        _sector setVariable ["WL2_sectorPop", _sectorPop, true];
        _sector setVariable ["WL2_sectorRespawnPool", []];
	} forEach BIS_WL_allSectors;

    private _ownedVehicles = missionNamespace getVariable ["BIS_WL_ownedVehicles_server", []];
    _ownedVehicles append _addedUnits;
    missionNamespace setVariable ["BIS_WL_ownedVehicles_server", _ownedVehicles];
};