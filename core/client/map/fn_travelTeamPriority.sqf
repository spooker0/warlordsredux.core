#include "includes.inc"
params ["_commit", ["_overrideTarget", objNull], ["_overrideTargetType", ""]];

private _side = BIS_WL_playerSide;

private _teamPriorityVar = format ["WL2_teamPriority_%1", _side];
private _teamPriorityTypeVar = format ["WL2_teamPriorityType_%1", _side];

private _teamPriority = missionNamespace getVariable [_teamPriorityVar, objNull];
private _teamPriorityType = missionNamespace getVariable [_teamPriorityTypeVar, ""];

if (!isNull _overrideTarget) then {
    _teamPriority = _overrideTarget;
    _teamPriorityType = _overrideTargetType;
};

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
            private _forwardBaseArea = [getPosASL _teamPriority, WL_FOB_RANGE, WL_FOB_RANGE, 0, false];
            [6, _forwardBaseArea] spawn WL2_fnc_executeFastTravel;
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
                private _sector = (_findSector # 0);
                [5, _sector] spawn WL2_fnc_executeFastTravel;
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
                [5, _teamPriority] spawn WL2_fnc_executeFastTravel;
            } else {
                private _asset = [_teamPriority, true] call WL2_fnc_getSectorFTAsset;
                if (isNull _asset) then {
                    [0, _teamPriority] spawn WL2_fnc_executeFastTravel;
                } else {
                    [_asset] spawn WL2_fnc_executeFastTravelVehicle;
                };
            };
        };
        true;
    } else {
        private _asset = [_teamPriority, true] call WL2_fnc_getSectorFTAsset;
        if (isNull _asset) then {
            private _canAirAssault = ([_teamPriority, "airAssault"] call WL2_fnc_mapButtonConditions) == "ok";
            if (_canAirAssault) then {
                if (_commit) then {
                    [2, _teamPriority] call WL2_fnc_executeFastTravel;
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