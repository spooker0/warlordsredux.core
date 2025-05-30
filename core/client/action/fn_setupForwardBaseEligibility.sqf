#include "..\..\warlords_constants.inc"

params ["_target", "_caller", ["_addSupplies", false]];

if (!alive _target) exitWith {
    "Destroyed.";
};

if (!isNull attachedTo _target || !isNull ropeAttachedTo _target) exitWith {
    "Cannot be used while attached to another object.";
};

if ((getPosASL _target) # 2 < -10) exitWith {
    "Cannot be used underwater.";
};

if (_target getVariable ["WL2_deploying", false]) exitWith {
    "Deploying.";
};

private _currentForwardBases = missionNamespace getVariable ["WL2_forwardBases", []];
private _teamForwardBases = _currentForwardBases select {
    _x getVariable ["WL2_forwardBaseOwner", sideUnknown] == BIS_WL_playerSide
};
private _inRangeTeamForwardBases = _teamForwardBases select {
    _caller distance2D _x < WL_FOB_RANGE
};
private _inRangeTeamFob = if (count _inRangeTeamForwardBases > 0) then {
    _inRangeTeamForwardBases # 0
} else {
    objNull
};
if (!isNull _inRangeTeamFob && _inRangeTeamFob getVariable ["WL2_forwardBaseTime", 0] > serverTime) exitWith {
    "Cannot add supplies to forward base while it's under construction.";
};
if (_addSupplies && isNull _inRangeTeamFob) exitWith {
    "No friendly forward base in range.";
};
if (_addSupplies && !isNull _inRangeTeamFob) exitWith {
    "";
};

if (count _teamForwardBases >= 3) exitWith {
    format ["Forward base limit reached. Current: %1", count _teamForwardBases];
};

private _isSquadLeader = ["isSquadLeader", [getPlayerID _caller]] call SQD_fnc_client;
if (!_isSquadLeader) exitWith {
    "You need to be a squad leader to set up a forward base.";
};

private _squadMembersNeeded =
#if WL_FOB_SQUAD_REQUIREMENT
    3;
#else
    1;
#endif
private _isQualifyingSL = ["isSquadLeaderOfSize", [getPlayerID _caller, _squadMembersNeeded]] call SQD_fnc_client;
if (!_isQualifyingSL) exitWith {
    "You need at least 3 squad members to set up a forward base.";
};

private _calculateAxis = {
    params ["_sector"];
    private _sectorArea = _sector getVariable "WL2_objectArea";
    private _axis = if (_sectorArea # 3) then {
        private _axisA = _sectorArea # 0;
        private _axisB = _sectorArea # 1;
        sqrt ((_axisA ^ 2) + (_axisB ^ 2));
    } else {
        (_sectorArea # 0) max (_sectorArea # 1);
    };
    _axis;
};

private _overlappingSectors = BIS_WL_allSectors select {
    private _axis = [_x] call _calculateAxis;
    _x distance2D _caller < (_axis + WL_FOB_RANGE + 20)

};
if (count _overlappingSectors > 0) exitWith {
    _overlappingSectors = _overlappingSectors apply {
        private _axis = [_x] call _calculateAxis;
        private _distanceToCircleEdge = (_x distance2D _caller) -_axis - 20;
        format ["%1 (%2 M)", _x getVariable ["WL2_name", "Sector"], round (WL_FOB_RANGE - _distanceToCircleEdge)];
    };
    format ["Forward base must be deployed completely outside of sectors: %1", _overlappingSectors joinString ", "];
};

private _nearbyTeamForwardBases = _teamForwardBases select {
    _caller distance2D _x < WL_FOB_MIN_DISTANCE
};
if (count _nearbyTeamForwardBases > 0) exitWith {
    format ["Forward base must be deployed at least %1 M away from other forward bases.", WL_FOB_MIN_DISTANCE];
};

if (_caller distance _target > 10) exitWith {
    "You are too far away.";
};

"";