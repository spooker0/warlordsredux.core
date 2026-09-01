#include "includes.inc"
params ["_origin"];

playSoundUI ["endgame", 5];

private _startPosition = _origin getPos [3000, random 360];
_startPosition set [2, 100];

private _munition = "Rocket_03_HE_F" createVehicleLocal _startPosition;

private _lightPoint = "#lightpoint" createVehicleLocal _startPosition;
_lightPoint lightAttachObject [_munition, [0, 0, 0]];
_lightPoint setLightColor [1, 1, 1];
_lightPoint setLightAmbient [1, 1, 1];
_lightPoint setLightIntensity 1e8;
_lightPoint setLightDayLight true;
_lightPoint setLightAttenuation [0, 2, 4, 4, 0, 9, 10];

private _endPosition = [_origin # 0, _origin # 1, 100];

private _startTime = time;
while { alive _munition && (time - _startTime < 5) } do {
    private _initialVectorDirAndUp = [getPosASL _munition, AGLtoASL _endPosition] call BIS_fnc_findLookAt;
    _munition setVectorDirAndUp _initialVectorDirAndUp;
    _munition setVelocityModelSpace [0, 600, 0];

    uiSleep 0.1;
};

deleteVehicle _lightPoint;
deleteVehicle _munition;

private _stemPosition = [_origin # 0, _origin # 1, 400];
private _capPosition  = [_origin # 0, _origin # 1, 800];
private _groundPosition = [_origin # 0, _origin # 1, 0];

private _stemParticle = "#particlesource" createVehicleLocal _stemPosition;

_stemParticle setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 7, 48, 1
    ],
    "",
    "Billboard",
    1,
    40,
    [0, 0, 0],
    [0, 0, 0],
    0,
    1.275,
    1,
    0.25,
    [32, 32, 32, 32],
    [
        [0.42, 0.42, 0.42, 0.75],
        [0.42, 0.42, 0.42, 0.75],
        [0.42, 0.42, 0.42, 0.75],
        [0.42, 0.42, 0.42, 0.75]
    ],
    [0.5, 0.3, 0.25, 0.2, 0.18],
    0.2,
    0.05,
    "",
    "",
    _stemParticle,
    0,
    true
];

_stemParticle setParticleRandom [
    0,
    [20, 20, 400],
    [0, 0, 20],
    10,
    1.1,
    [0, 0, 0, 0],
    0,
    0,
    30,
    1
];

_stemParticle setDropInterval 0.003;

private _capParticle = "#particlesource" createVehicleLocal _capPosition;

_capParticle setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 3, 48, 1
    ],
    "",
    "Billboard",
    1,
    40,
    [0, 0, 0],
    [0, 0, 0],
    0,
    1.275,
    1,
    0.20,
    [70, 70, 70, 70],
    [
        [0.58, 0.58, 0.58, 0.35],
        [0.58, 0.58, 0.58, 0.35],
        [0.58, 0.58, 0.58, 0.35],
        [0.58, 0.58, 0.58, 0.35]
    ],
    [0.05],
    0.15,
    0.03,
    "",
    "",
    _capParticle
];

_capParticle setParticleRandom [
    0,
    [350, 350, 50],
    [20, 20, 0],
    10,
    1.2,
    [0, 0, 0, 0],
    0,
    0,
    1
];

_capParticle setDropInterval 0.002;

private _groundParticle = "#particlesource" createVehicleLocal _groundPosition;

_groundParticle setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 7, 48, 1
    ],
    "",
    "Billboard",
    1,
    40,
    [0, 0, 0],
    [0, 0, 0],
    0,
    1.275,
    1,
    0.20,
    [20, 20, 20, 20],
    [
        [0.1, 0.1, 0.1, 0.71],
        [0.1, 0.1, 0.1, 0.71],
        [0.1, 0.1, 0.1, 0.71],
        [0.1, 0.1, 0.1, 0.71]
    ],
    [0.5, 0.3, 0.25, 0.2, 0.18],
    0.15,
    0.03,
    "",
    "",
    _groundParticle
];

_groundParticle setParticleRandom [
    0,
    [750, 750, 10],
    [100, 100, 0],
    10,
    1.2,
    [0, 0, 0, 0],
    0,
    0,
    1
];

_groundParticle setDropInterval 0.001;

private _defaultAperture = apertureParams # 0;
private _apertureSize = _defaultAperture / 10;
setAperture _apertureSize;

uiSleep 2;

deleteVehicle _capParticle;
deleteVehicle _groundParticle;

uiSleep 1;

deleteVehicle _stemParticle;

while { _apertureSize < (_defaultAperture / 2) } do {
    setAperture _apertureSize;
    uiSleep 0.1;
    _apertureSize = _apertureSize + _defaultAperture / 100;
};

uiSleep 2;

playSoundUI ["Earthquake_03", 2];

uiSleep 3;

while { _apertureSize < _defaultAperture } do {
    setAperture _apertureSize;
    uiSleep 0.1;
    _apertureSize = _apertureSize + _defaultAperture / 50;
};

setAperture 0;

private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (isNull _display) then {
    0 spawn WL2_fnc_scoreboard;
};