#include "includes.inc"
params ["_turret"];

private _turretLimits = cameraOn getTurretLimits _turret;
_turretLimits params ["_minTurn", "_maxTurn", "_minElev", "_maxElev"];

private _radius = 100000000;

private _convertSafezoneToScreen = {
    params ["_input"];
    private _pt = worldToScreen _input;
    if ((count _pt) != 2) exitWith {[-1, -1]};
    private _sx = (_pt # 0 - safeZoneX) / safeZoneW;
    private _sy = (_pt # 1 - safeZoneY) / safeZoneH;
    [_sx, _sy];
};

private _pointFromAngles = {
    params ["_turn", "_elev"]; // azimuth (turn), elevation
    private _x = -_radius * (sin _turn) * (cos _elev);
    private _y =  _radius * (cos _turn) * (cos _elev);
    private _z =  _radius * (sin _elev);
    cameraOn modelToWorld [_x, _y, _z]
};

private _edgeSweepTurn = {
    params ["_turnA", "_turnB", "_elevConst", "_samples"];
    private _out = [];
    for "_i" from 0 to _samples do {
        private _t = _i / _samples;
        private _turn = _turnA + (_turnB - _turnA) * _t;
        _out pushBack ([_turn, _elevConst] call _pointFromAngles);
    };
    _out
};

private _edgeSweepElev = {
    params ["_elevA", "_elevB", "_turnConst", "_samples"];
    private _out = [];
    for "_i" from 0 to _samples do {
        private _t = _i / _samples;
        private _elev = _elevA + (_elevB - _elevA) * _t;
        _out pushBack ([_turnConst, _elev] call _pointFromAngles);
    };
    _out
};

private _topLeftPoint     = [_maxTurn, _maxElev] call _pointFromAngles;
private _topRightPoint    = [_minTurn, _maxElev] call _pointFromAngles;
private _bottomRightPoint = [_minTurn, _minElev] call _pointFromAngles;
private _bottomLeftPoint  = [_maxTurn, _minElev] call _pointFromAngles;

private _samplesTurnEdge  = 40;  // top/bottom (TURN sweep)
private _samplesElevEdge  = 2;   // left/right (ELEV sweep)

private _points = [];
_points append ([_maxTurn, _minTurn, _maxElev, _samplesTurnEdge] call _edgeSweepTurn);
_points append ([_maxElev, _minElev, _minTurn, _samplesElevEdge] call _edgeSweepElev);
_points append ([_minTurn, _maxTurn, _minElev, _samplesTurnEdge] call _edgeSweepTurn);
_points append ([_minElev, _maxElev, _maxTurn, _samplesElevEdge] call _edgeSweepElev);

private _weaponDirection = cameraOn weaponDirection (cameraOn currentWeaponTurret _turret);

private _vehicleAnimationsTable = createHashMapFromArray [
    ["B_T_VTOL_01_armed_F", [[], ["gatling_rot", "gatling_turret_rot"], ["cannon_rot", "cannon_turret_rot"]]]
];

if !(_turret isEqualTo [0]) then {
    private _vehicleAnimations = _vehicleAnimationsTable getOrDefault [typeOf cameraOn, []];

    if (count _vehicleAnimations > (_turret # 0)) then {
        private _animations = _vehicleAnimations select (_turret # 0);
        private _elevation = deg (cameraOn animationPhase (_animations # 0));
        private _azimuth = deg (cameraOn animationPhase (_animations # 1));
        _weaponDirection = [_azimuth, _elevation] call _pointFromAngles;
    };
};

_weaponDirection = _weaponDirection vectorMultiply 100000000;
private _weaponPoint = _weaponDirection vectorAdd (cameraOn modelToWorld [0, 0, 0]);

private _weaponScreenPoint = [_weaponPoint] call _convertSafezoneToScreen;

private _weapon = cameraOn currentWeaponTurret _turret;
private _weaponName = getText (configFile >> "CfgWeapons" >> _weapon >> "displayName");
private _weaponNameArr = toArray _weaponName;
_weaponName = toString (_weaponNameArr apply { if (_x == 160) then { 32 } else { _x }; });

if !(_weaponPoint isEqualTo [0,0,0]) then {
    _weaponScreenPoint pushBack _weaponName;
};

private _screenPoints = [];
{
    private _sp = [_x] call _convertSafezoneToScreen;
    _screenPoints pushBack [_sp # 0, _sp # 1];
} forEach _points;
_screenPoints pushBack [-1, -1];

[_screenPoints, _weaponScreenPoint];