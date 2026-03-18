#include "includes.inc"
params ["_projectile"];

waitUntil {
    private _velocity = velocity _projectile;
    (_velocity # 2) < -1 || !alive _projectile
};
waitUntil {
    private _posAGL = _projectile modelToWorld [0, 0, 0];
    (_posAGL # 2) < 150 || !alive _projectile
};

if (!alive _projectile) exitWith {};

private _burstPos = _projectile modelToWorld [0, 0, 0];
private _shotParents = getShotParents _projectile;
private _instigator = _shotParents call WL2_fnc_handleInstigator;
private _isOwner = player == _instigator;

if (!_isOwner && cameraOn distance _burstPos > 4000) exitWith {};

private _forward = vectorNormalized (velocity _projectile);
if ((vectorMagnitude _forward) < 0.001) then {
    _forward = vectorNormalized (vectorDir _projectile);
};

private _upward = vectorNormalized (vectorUp _projectile);
private _right = vectorNormalized (_forward vectorCrossProduct _upward);

_upward = vectorNormalized (_right vectorCrossProduct _forward);

deleteVehicle _projectile;

private _grenadeSounds = [
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_01.wss",
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_02.wss",
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_03.wss",
    "a3\sounds_f\arsenal\explosives\grenades\explosion_gng_grenades_04.wss"
];

for "_i" from 1 to 5 do {
    playSound3D [selectRandom _grenadeSounds, objNull, false, _burstPos, 5];
    uiSleep 0.05;
};

private _strands = [];
private _fires = [];

private _coneHalfAngle = 18;
private _burstBiasUp = -0.01;

for "_i" from 1 to 20 do {
    private _posAGL = [
        (_burstPos # 0) + (random 3 - 1.5),
        (_burstPos # 1) + (random 3 - 1.5),
        (_burstPos # 2) + (random 2 - 1)
    ];

    private _speed = 50 + random 25;

    private _theta = random 360;
    private _phi = random _coneHalfAngle;

    private _x = (sin _phi) * cos _theta;
    private _y = cos _phi;
    private _z = (sin _phi) * sin _theta;

    private _dirLocal = vectorNormalized [_x, _y, _z + _burstBiasUp];

    private _dirVec = vectorNormalized [
        ((_right   # 0) * (_dirLocal # 0)) + ((_forward # 0) * (_dirLocal # 1)) + ((_upward # 0) * (_dirLocal # 2)),
        ((_right   # 1) * (_dirLocal # 0)) + ((_forward # 1) * (_dirLocal # 1)) + ((_upward # 1) * (_dirLocal # 2)),
        ((_right   # 2) * (_dirLocal # 0)) + ((_forward # 2) * (_dirLocal # 1)) + ((_upward # 2) * (_dirLocal # 2))
    ];

    private _vel = [
        (_dirVec # 0) * _speed,
        (_dirVec # 1) * _speed,
        (_dirVec # 2) * _speed
    ];

    private _head = "#particleSource" createVehicleLocal [0, 0, 0];
    _head setPosASL (AGLToASL _posAGL);
    _head setParticleClass "Cmeasures2";
    _head setDropInterval 0.0025;

    private _smoke = "#particleSource" createVehicleLocal [0, 0, 0];
    _smoke setPosASL (AGLToASL _posAGL);

    _smoke setParticleParams [
        ["\A3\data_f\ParticleEffects\Universal\Universal", 16, 12, 7, 0],
        "",
        "Billboard",
        1,
        2.4,
        [0, 0, 0],
        [0, 0, 0.30],
        0,
        1.277,
        1,
        0.025,
        [0.2, 1.1],
        [
            [1, 1, 1, 1],
            [1, 1, 1, 0.9]
        ],
        [0.2],
        1,
        0.04,
        "",
        "",
        _smoke
    ];

    _smoke setParticleRandom [
        0.3,
        [0.04, 0.04, 0.04],
        [0.24, 0.24, 0.10],
        3,
        0.06,
        [0, 0, 0, 1],
        0,
        0,
        360
    ];
    _smoke setDropInterval 0.01;

    _strands pushBack [
        AGLToASL _posAGL,
        _vel,
        _head,
        _smoke,
        0,
        20,
        false
    ];
};

private _dt = 0.01;
private _igniteHeight = 3.0;
private _fireLife = 12;

private _projectileHasKilled = false;
private _projectileIgnitions = [];

while { (count _strands > 0) || (count _fires > 0) } do {
    private _nextStrands = [];
    private _nextFires = [];

    {
        private _pos        = +(_x # 0);
        private _vel        = +(_x # 1);
        private _head       = _x # 2;
        private _smoke      = _x # 3;
        private _age        = (_x # 4) + _dt;
        private _life       = _x # 5;
        private _hasIgnited = _x # 6;

        _pos set [0, (_pos # 0) + ((_vel # 0) * _dt)];
        _pos set [1, (_pos # 1) + ((_vel # 1) * _dt)];
        _pos set [2, (_pos # 2) + ((_vel # 2) * _dt)];

        if (_age < 0.3) then {
            private _dragXY = 0.996 ^ (_dt / 0.03);
            private _dragZ  = 0.997 ^ (_dt / 0.03);

            _vel set [0, (_vel # 0) * _dragXY];
            _vel set [1, (_vel # 1) * _dragXY];
            _vel set [2, ((_vel # 2) * _dragZ) - (0.05 * (_dt / 0.03))];
        } else {
            private _dragXY = 0.985 ^ (_dt / 0.03);
            private _dragZ  = 0.992 ^ (_dt / 0.03);

            _vel set [0, (_vel # 0) * _dragXY];
            _vel set [1, (_vel # 1) * _dragXY];
            _vel set [2, ((_vel # 2) * _dragZ) - (0.09 * (_dt / 0.03))];
        };

        _head setPosASL _pos;
        _smoke setPosASL [
            (_pos # 0) - (_vel # 0) * 0.015,
            (_pos # 1) - (_vel # 1) * 0.015,
            (_pos # 2) - (_vel # 2) * 0.015
        ];

        private _altAGL = (ASLToAGL _pos) # 2;

        if ((!_hasIgnited) && (_altAGL <= _igniteHeight)) then {
            deleteVehicle _head;
            deleteVehicle _smoke;

            private _firePosAGL = ASLToAGL _pos;
            _firePosAGL set [2, 0.05 max ((_firePosAGL # 2) min 0.5)];

            _projectileIgnitions pushBack _pos;

            if (_isOwner && !_projectileHasKilled && count _projectileIgnitions >= 6) then {
                private _averageX = 0;
                private _averageY = 0;
                private _averageZ = 0;
                {
                    _averageX = _averageX + (_x # 0);
                    _averageY = _averageY + (_x # 1);
                    _averageZ = _averageZ + (_x # 2);
                } forEach _projectileIgnitions;

                private _count = count _projectileIgnitions;
                private _averagePos = [
                    _averageX / _count,
                    _averageY / _count,
                    _averageZ / _count
                ];

                [player, "incendiary", _averagePos, _shotParents] remoteExec ["WL2_fnc_handleClientRequest", 2];
                _projectileHasKilled = true;
            };

            private _fire = "#particleSource" createVehicleLocal [0,0,0];
            _fire setPosASL (AGLToASL _firePosAGL);
            _fire setParticleClass "BigDestructionFire";
            _fire setDropInterval 0.02;

            _nextFires pushBack [
                _fire,
                0,
                _fireLife
            ];
        } else {
            if ((_age < _life) && (_altAGL > 0.1)) then {
                _nextStrands pushBack [_pos, _vel, _head, _smoke, _age, _life, _hasIgnited];
            } else {
                deleteVehicle _head;
                deleteVehicle _smoke;
            };
        };
    } forEach _strands;

    {
        private _fire = _x # 0;
        private _age  = (_x # 1) + _dt;
        private _life = _x # 2;

        if (_age < _life) then {
            _nextFires pushBack [_fire, _age, _life];
        } else {
            deleteVehicle _fire;
        };
    } forEach _fires;

    _strands = _nextStrands;
    _fires = _nextFires;

    uiSleep _dt;
};