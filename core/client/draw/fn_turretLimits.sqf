#include "includes.inc"
params ["_vehicle", "_turret", "_projection", "_geometryCache"];

// Return separate visible segments and a weapon screen point.
private _turretLimits = _vehicle getTurretLimits _turret;
private _limits = _turretLimits select [0, 4];
if (count _limits != 4) exitWith { [[], []] };

private _directionFromAngles = {
    params ["_turn", "_elevation"];

    // Preserve the original visualizer's positive-left turn convention.
    private _directionRight = -sin _turn * cos _elevation;
    private _directionForward = cos _turn * cos _elevation;
    private _directionUp = sin _elevation;

    [_directionRight, _directionForward, _directionUp]
};

private _turretKey = str _turret;
private _cachedGeometry = _geometryCache getOrDefault [_turretKey, [[], []]];
private _cachedLimits = _cachedGeometry # 0;
if !(_cachedLimits isEqualTo _limits) then {
    _limits params ["_minTurn", "_maxTurn", "_minElevation", "_maxElevation"];

    private _fullTurn = (_maxTurn - _minTurn) >= 360;
    if (_fullTurn) then {
        _maxTurn = _minTurn + 360;
    };

    private _turnSpan = abs (_maxTurn - _minTurn);
    private _elevationSpan = abs (_maxElevation - _minElevation);
    private _turnSamples = 20 max (ceil (_turnSpan / 4));
    private _elevationSamples = 2 max (ceil (_elevationSpan / 15));
    private _edges = [
        [_maxTurn, _maxElevation, _minTurn, _maxElevation, _turnSamples],
        [_minTurn, _minElevation, _maxTurn, _minElevation, _turnSamples]
    ];

    // A fully traversable turret has no artificial vertical seam.
    if (!_fullTurn) then {
        _edges append [
            [_minTurn, _maxElevation, _minTurn, _minElevation, _elevationSamples],
            [_maxTurn, _minElevation, _maxTurn, _maxElevation, _elevationSamples]
        ];
    };

    private _outlines = [];
    {
        _x params ["_startTurn", "_startElevation", "_endTurn", "_endElevation", "_samples"];

        private _points = [];
        for "_sampleIndex" from 0 to _samples do {
            private _sampleFraction = _sampleIndex / _samples;
            private _sampleTurn = _startTurn + (_endTurn - _startTurn) * _sampleFraction;
            private _sampleElevation = _startElevation + (_endElevation - _startElevation) * _sampleFraction;
            private _sampleDirection = [_sampleTurn, _sampleElevation] call _directionFromAngles;

            _points pushBack _sampleDirection;
        };

        _outlines pushBack _points;
    } forEach _edges;

    _cachedGeometry = [+_limits, _outlines];
    _geometryCache set [_turretKey, _cachedGeometry];
};

private _segments = [];
private _outlines = _cachedGeometry # 1;
{
    private _directions = _x apply {
        _vehicle vectorModelToWorldVisual _x
    };

    for "_segmentIndex" from 0 to (count _directions - 2) do {
        private _startDirection = _directions # _segmentIndex;
        private _endDirection = _directions # (_segmentIndex + 1);
        private _segment = [_projection, _startDirection, _endDirection] call WL2_fnc_turretVisualizerProject;
        if (count _segment == 2) then {
            _segments pushBack _segment;
        };
    };
} forEach _outlines;

private _weapon = _vehicle currentWeaponTurret _turret;
private _weaponPoint = [];
if (_weapon != "") then {
    private _weaponDirection = _vehicle weaponDirection _weapon;
    private _vehicleAnimations = switch (typeOf _vehicle) do {
        case "B_T_VTOL_01_armed_F": {
            [[], ["gatling_rot", "gatling_turret_rot"], ["cannon_rot", "cannon_turret_rot"]]
        };
        case "B_Heli_Transport_03_F": {
            [[], ["gunner_1_aimdown1", "gunner_1_rot1"], ["gunner_2_aimdown1", "gunner_2_rot2"]]
        };
        default { [] };
    };

    // These overrides describe top-level turrets only, not their child turrets.
    if (count _turret == 1) then {
        private _turretIndex = _turret # 0;
        private _animations = _vehicleAnimations param [_turretIndex, []];
        if (count _animations == 2) then {
            _animations params ["_elevationAnimation", "_azimuthAnimation"];

            private _elevation = deg (_vehicle animationPhase _elevationAnimation);
            private _azimuth = deg (_vehicle animationPhase _azimuthAnimation);
            private _modelDirection = [_azimuth, _elevation] call _directionFromAngles;

            _weaponDirection = _vehicle vectorModelToWorldVisual _modelDirection;
        };
    };

    _weaponPoint = [_projection, _weaponDirection] call WL2_fnc_turretVisualizerProject;
};

[_segments, _weaponPoint]
