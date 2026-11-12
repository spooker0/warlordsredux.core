#include "includes.inc"
params ["_target", "_caller", ["_addSupplies", false], ["_finalCheck", false]];

if (!alive _target) exitWith {
    localize "STR_WL_fobDestroyedCheck"
};

if (!_finalCheck && _caller distance _target > 10) exitWith {
    localize "STR_WL_fobTooFarAway"
};

if (!isNull attachedTo _target || !isNull ropeAttachedTo _target) exitWith {
    localize "STR_WL_fobAttached"
};

if ((getPosASL _target) # 2 < -10) exitWith {
    localize "STR_WL_fobUnderwater"
};
if (!_finalCheck && _target getVariable ["WL2_deploying", false]) exitWith {
    localize "STR_WL_fobDeploying"
};

private _side = BIS_WL_playerSide;

private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _teamForwardBases = _currentForwardBases select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == _side
};
private _inRangeTeamForwardBases = _teamForwardBases select {
    _target distance2D _x < WL_FOB_RANGE
};
private _inRangeTeamFob = if (count _inRangeTeamForwardBases > 0) then {
    true
} else {
    private _teamSectorsData = WL_SECTORS_DATA(_side);
    private _ownedSectors = _teamSectorsData getOrDefault ["unlocked", []];
    private _sectorsInRange = _ownedSectors select {
        _target inArea (_x getVariable "objectAreaComplete")
    };
    count _sectorsInRange > 0
};

if (_addSupplies && !_inRangeTeamFob) exitWith {
    localize "STR_WL_fobNoFriendlyBaseRange"
};
if (_addSupplies && _inRangeTeamFob) exitWith {
    "";
};

if (count _teamForwardBases >= 4) exitWith {
    localize "STR_WL_fobLimitReached"
};

#if WL_FOB_REQUIREMENTS
private _isSquadLeader = ["isSquadLeader", [getPlayerID _caller]] call SQD_fnc_query;
if (!_isSquadLeader) exitWith {
    localize "STR_WL_fobNeedSquadLeader"
};

private _playerRating = _caller getVariable ["WL2_playerRating", WL_RATING_STARTER];
private _isQualifyingSL = if (_playerRating >= 2000) then {
    true
} else {
    ["isSquadLeaderOfSize", [getPlayerID _caller, 3]] call SQD_fnc_query;
};
if (!_isQualifyingSL) exitWith {
    localize "STR_WL_fobNeed3MembersOrElo"
};
#endif

private _sectorOverlap = {
    params ["_sector", "_circle", "_radius"];

    private _area = _sector getVariable "WL2_objectArea";
    _area params ["_axisA", "_axisB", "_angle", "_rectangle"];
    if (!_rectangle && _axisA < 0 && _axisB < 0) then {
        _axisA = abs _axisA;
        _axisB = abs _axisB;
    };

    if (_axisA <= 0 || _axisB <= 0) exitWith { -1 };

    private _sectorPos = getPosWorld _sector;
    private _circlePos = getPosWorld _circle;

    private _dx = (_circlePos # 0) - (_sectorPos # 0);
    private _dy = (_circlePos # 1) - (_sectorPos # 1);

    private _cos = cos _angle;
    private _sin = sin _angle;

    private _x = abs (_dx * _cos - _dy * _sin);
    private _y = abs (_dx * _sin + _dy * _cos);

    private _distance = if (_rectangle) then {
        private _ox = (_x - _axisA) max 0;
        private _oy = (_y - _axisB) max 0;

        sqrt ((_ox ^ 2) + (_oy ^ 2))
    } else {
        private _inside = ((_x / _axisA) ^ 2) + ((_y / _axisB) ^ 2) <= 1;
        if (_inside) exitWith { 0 };

        private _axisA2 = _axisA ^ 2;
        private _axisB2 = _axisB ^ 2;

        private _low = 0;
        private _high = 1;

        while {
            (((_axisA * _x) / (_high + _axisA2)) ^ 2) + (((_axisB * _y) / (_high + _axisB2)) ^ 2) > 1
        } do {
            _high = _high * 2;
        };

        for "_i" from 0 to 24 do {
            private _mid = (_low + _high) / 2;

            if ((((_axisA * _x) / (_mid + _axisA2)) ^ 2) + (((_axisB * _y) / (_mid + _axisB2)) ^ 2) > 1) then {
                _low = _mid;
            } else {
                _high = _mid;
            };
        };

        private _closestX = (_axisA2 * _x) / (_high + _axisA2);
        private _closestY = (_axisB2 * _y) / (_high + _axisB2);

        sqrt (((_x - _closestX) ^ 2) + ((_y - _closestY) ^ 2))
    };

    _radius - _distance
};

private _overlappingSectors = BIS_WL_allSectors select {
    _x distance2D _caller < 500
} apply {
    [_x, [_x, _caller, WL_FOB_RANGE + 5] call _sectorOverlap]
} select {
    _x # 1 >= 0
};

if (count _overlappingSectors > 0) exitWith {
    _overlappingSectors = _overlappingSectors apply {
        private _sector = _x # 0;
        private _overlap = _x # 1;

        format [
            "%1 (%2 m)",
            _sector getVariable ["WL2_name", localize "STR_WL_sector"],
            ceil _overlap
        ];
    };

    format [localize "STR_WL_fobOutsideSectors", _overlappingSectors joinString ", "];
};

private _nearbyTeamForwardBases = _teamForwardBases select {
    _caller distance2D _x < WL_FOB_MIN_DISTANCE
};
if (count _nearbyTeamForwardBases > 0) exitWith {
    format [localize "STR_WL_fobMinDistance", WL_FOB_MIN_DISTANCE];
};

"";