#include "includes.inc"
params ["_base", "_debriefing"];

if (cameraOn distance2D _base < 500 && cameraOn isKindOf "Air") then {
    ["Glow in the Dark"] call RWD_fnc_addBadge;
};

private _camera = "camera" camCreate [0, 0, 0];
_camera camCommit 0;
_camera switchCamera "EXTERNAL";

private _basePos = _base modelToWorld [0, 0, 0];

private _targetDistance = 2000;
private _initialX = random 2000;
if (random 1 < 0.5) then {
    _initialX = -1 * _initialX;
};
private _initialY = sqrt (_targetDistance ^ 2 - _initialX ^ 2);
if (random 1 < 0.5) then {
    _initialY = -1 * _initialY;
};

private _initialVector = [_initialX, _initialY, 300];
private _cameraPos = _base modelToWorld _initialVector;

private _targetVectorDirAndUp = [_cameraPos, _basePos] call BIS_fnc_findLookAt;
_camera setVectorDirAndUp _targetVectorDirAndUp;
_camera setPosASL (AGLtoASL _cameraPos);

_camera switchCamera "EXTERNAL";

uiSleep 2;

playSoundUI ["endgame", 5];

private _startPosition = _base getPos [500, random 360];
_startPosition set [2, 2000];

private _munition = "Rocket_03_HE_F" createVehicleLocal _startPosition;

private _lightPoint = "#lightpoint" createVehicleLocal _startPosition;
_lightPoint lightAttachObject [_munition, [0, 0, 0]];
_lightPoint setLightColor [1, 1, 1];
_lightPoint setLightAmbient [1, 1, 1];
_lightPoint setLightIntensity 1e8;
_lightPoint setLightDayLight true;
_lightPoint setLightAttenuation [0, 2, 4, 4, 0, 9, 10];

private _rocketTrail = "#particlesource" createVehicleLocal _startPosition;

_rocketTrail setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 7, 48, 1
    ],
    "",
    "Billboard",
    1,
    5,
    [0, 0, 0],
    [0, 0, 0],
    0,
    2,
    1,
    0.2,
    [5],
    [
        [0.2, 0.2, 0.2, 0.95],
        [0.2, 0.2, 0.2, 0.4]
    ],
    [1],
    0.2,
    0.05,
    "",
    "",
    _munition
];

_rocketTrail setParticleRandom [
    0,
    [5, 5, 0],
    [5, 5, 5],
    2,
    1.1,
    [0, 0, 0, 0],
    0,
    0
];

_rocketTrail setDropInterval 0.001;

private _endPosition = [_basePos # 0, _basePos # 1, 100];

private _startTime = time;
while { alive _munition && (time - _startTime < 5) && _munition distance2D _endPosition > 100 } do {
    private _initialVectorDirAndUp = [getPosASL _munition, AGLtoASL _endPosition] call BIS_fnc_findLookAt;
    _munition setVectorDirAndUp _initialVectorDirAndUp;
    _munition setVelocityModelSpace [0, 500, 0];

    uiSleep 0.1;
};

deleteVehicle _lightPoint;
deleteVehicle _munition;
deleteVehicle _rocketTrail;

private _stemPosition = [_basePos # 0, _basePos # 1, 400];
private _capPosition  = [_basePos # 0, _basePos # 1, 800];
private _groundPosition = [_basePos # 0, _basePos # 1, 0];

private _stemParticle = "#particlesource" createVehicleLocal _stemPosition;

_stemParticle setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 7, 48, 1
    ],
    "",
    "Billboard",
    1,
    2,
    [0, 0, 0],
    [0, 0, -50],
    0,
    2,
    1,
    0.02,
    [32],
    [[0.42, 0.42, 0.42, 0.95]],
    [0.5],
    0.2,
    0.05,
    "",
    "",
    _stemParticle
];

_stemParticle setParticleRandom [
    0,
    [20, 20, 400],
    [0, 0, 0],
    2,
    1.1,
    [0, 0, 0, 0],
    0,
    0,
    30,
    1
];

_stemParticle setDropInterval 0.005;

private _capParticle = "#particlesource" createVehicleLocal _capPosition;

_capParticle setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 3, 48, 1
    ],
    "",
    "Billboard",
    1,
    2,
    [0, 0, 0],
    [0, 0, 0],
    0,
    1,
    2,
    0.05,
    [70],
    [[0.58, 0.58, 0.58, 0.35]],
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
    [0, 0, 0],
    2,
    1.2,
    [0, 0, 0, 0],
    0,
    0,
    1
];

_capParticle setDropInterval 0.002;

private _groundSmoke = "#particlesource" createVehicleLocal _groundPosition;

_groundSmoke setParticleParams [
    [
        "\A3\Data_F\ParticleEffects\Universal\Universal",
        16, 7, 48, 1
    ],
    "",
    "Billboard",
    1,
    5,
    [0, 0, 10],
    [0, 0, -10],
    30,
    1.275,
    1,
    0.003,
    [80, 160],
    [
        [0.1, 0.1, 0.1, 0.95],
        [0.1, 0.1, 0.1, 0.2]
    ],
    [0.5],
    0.15,
    0.03,
    "",
    "",
    _groundSmoke
];

_groundSmoke setParticleCircle [50, [0, 250, 0]];

_groundSmoke setDropInterval 0.01;

private _defaultAperture = apertureParams # 0;
private _apertureSize = 0.001;
setAperture _apertureSize;

uiSleep 3;

while { _apertureSize < (_defaultAperture / 2) } do {
    setAperture _apertureSize;
    uiSleep 0.1;
    _apertureSize = _apertureSize + _defaultAperture / 100;
};

private _debriefingTitle = toUpper getText (missionConfigFile >> "CfgDebriefing" >> _debriefing >> "title");
private _debriefingSubtitle = toUpper getText (missionConfigFile >> "CfgDebriefing" >> _debriefing >> "subtitle");
[
    parseText format ["<t size='2'>%1 - %2</t>", _debriefingTitle, _debriefingSubtitle],
    parseText toUpper "Altis evacuation in progress. Elevated radiation levels detected. Head to your nearest emergency shelter."
] spawn BIS_fnc_AAN;

private _filmGrainHandle = ppEffectCreate ["FilmGrain", 500];
_filmGrainHandle ppEffectEnable true;
_filmGrainHandle ppEffectAdjust [
	0.2,
	1.25,
	1,
	0.75,
	1.0,
	0
];
_filmGrainHandle ppEffectCommit 5;

uiSleep 2;

enableCamShake true;
addCamShake [30, 3, 25];

playSoundUI ["Earthquake_03", 2];

uiSleep 3;

while { _apertureSize < _defaultAperture } do {
    setAperture _apertureSize;
    uiSleep 0.1;
    _apertureSize = _apertureSize + _defaultAperture / 50;
};

setAperture 0;

private _newCamPos = _camera modelToWorld [0, 1000, 0];
_camera camSetPos _newCamPos;
_camera camCommit 5;

private _display = uiNamespace getVariable ["RscWLScoreboardMenu", displayNull];
if (isNull _display) then {
    0 spawn WL2_fnc_scoreboard;
};