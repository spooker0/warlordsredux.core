#include "includes.inc"
params ["_commit"];

private _side = BIS_WL_playerSide;

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriorityTypeVar = format ["WL2_teamPriorityType_%1", _side];

private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
private _teamPriorityType = missionNamespace getVariable [_teamPriorityTypeVar, ""];

if (_teamPriorityType == "asset") exitWith {
    private _canTravelAsset = alive _teamPriority;
    if (_canTravelAsset) then {
        if (_commit) then {
            [_teamPriority] spawn WL2_fnc_executeFastTravelVehicle;
        };

        true;
    } else {
        false;
    };
};

if (_teamPriorityType == "fob") exitWith {
    private _canTravelFOB = ([_teamPriority, "fastTravelFOB"] call WL2_fnc_mapButtonConditions) == "ok";
    if (_canTravelFOB) then {
        if (_commit) then {
            BIS_WL_targetSector = nil;

            private _marker = createMarkerLocal ["WL2_fastTravelFOBMarker", getPosATL _teamPriority];
            _marker setMarkerShapeLocal "ELLIPSE";
            _marker setMarkerSizeLocal [WL_FOB_RANGE, WL_FOB_RANGE];
            _marker setMarkerAlphaLocal 0;

            [6, "WL2_fastTravelFOBMarker"] spawn WL2_fnc_executeFastTravel;
        };

        true;
    } else {
        false;
    };
};

if (_teamPriorityType == "stronghold") exitWith {
    private _findIsStronghold = (BIS_WL_sectorsArray # 2) select {
        (_x getVariable ["WL_stronghold", objNull]) == _teamPriority
    };

    if (count _findIsStronghold > 0) then {
        private _findSector = (BIS_WL_sectorsArray # 2) select {
            (_x getVariable ["WL_stronghold", objNull]) == _teamPriority
        };
        if (count _findSector == 0) then {
            false;
        } else {
            if (_commit) then {
                BIS_WL_targetSector = (_findSector # 0);
                [5, ""] spawn WL2_fnc_executeFastTravel;
            };
        };

        true;
    } else {
        false;
    };
};

if (_teamPriorityType == "sector") exitWith {
    private _sectorOwner = _teamPriority getVariable ["BIS_WL_owner", independent];
    if (_sectorOwner == _side) then {
        private _canTravelStronghold = ([_teamPriority, "fastTravelStrongholdTarget"] call WL2_fnc_mapButtonConditions) == "ok";
        if (_commit) then {
            if (_canTravelStronghold) then {
                BIS_WL_targetSector = _teamPriority;
                [5, ""] spawn WL2_fnc_executeFastTravel;
            } else {
                BIS_WL_targetSector = _teamPriority;
                [0, ""] spawn WL2_fnc_executeFastTravel;
            };
        };
        true;
    } else {
        private _asset = [_teamPriority, true] call WL2_fnc_getSectorFTAsset;
        if (isNull _asset) then {
            private _canAirAssault = ([_teamPriority, "airAssault"] call WL2_fnc_mapButtonConditions) == "ok";
            if (_canAirAssault) then {
                if (_commit) then {
                    BIS_WL_targetSector = _teamPriority;

                    private _fastTravelConflictCall = 2 call WL2_fnc_fastTravelConflictMarker;
                    private _marker = _fastTravelConflictCall # 0;
                    [2, _marker] call WL2_fnc_executeFastTravel;
                    deleteMarkerLocal _marker;

                    private _markerText = _fastTravelConflictCall # 1;
                    deleteMarkerLocal _markerText;
                };

                true;
            } else {
                false;
            };
        } else {
            if (_commit) then {
                [_asset] spawn WL2_fnc_executeFastTravelVehicle;
            };

            true;
        };
    };
};

false;