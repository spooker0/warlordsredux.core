#include "includes.inc"
params ["_unit", "_source"];
if (_unit getVariable ["WL2_unconscious", false]) exitWith {};

private _originalDeathPos = getPosWorld _unit;

_unit setVelocity [0, 0, 0];

{
    _x disableAI "COMMAND";
} forEach (units group _unit);

_unit setCaptive true;
_unit setUnconscious true;
_unit setVariable ["WL2_unconscious", true, true];

private _capAreaModifiers = missionNamespace getVariable ["WL2_capAreaModifiers", [0, 0]];
private _sideIndex = if (side group _unit == west) then { 0 } else { 1 };
private _controlledMod = _capAreaModifiers # _sideIndex;
_controlledMod = ((_controlledMod min 1) max 0.66);

_unit setVariable ["WL2_expirationTime", serverTime + WL_DURATION_RESPAWN * _controlledMod, true];

private _deadAnimations = [
    "Acts_StaticDeath_01",
    "Acts_StaticDeath_02",
    "Acts_StaticDeath_03",
    "Acts_StaticDeath_05",
    "Acts_StaticDeath_06",
    "Acts_StaticDeath_08",
    "Acts_StaticDeath_09"
];
private _deadAnimation = selectRandom _deadAnimations;

private _startTime = serverTime;

// Killcam
if (!isNull _source) then {
    private _camera = "camera" camCreate (ASLToAGL (getPosASL _unit vectorAdd [0, 0, 2]));
    _camera camSetTarget _source;
    showCinemaBorder false;

    private _sourceBounds = boundingBoxReal _source;
    private _sourceRadius = (_sourceBounds # 2) max 0.5;
    private _sourceDistance = (_camera distance _source) max 1;
    private _targetFov = ((_sourceRadius * 1.5 / _sourceDistance) max 0.01) min 8.5;

    _camera camSetFov _targetFov;
    _camera camCommit 3;
    _camera cameraEffect ["Internal", "BACK"];

    uiSleep 5;

    _camera cameraEffect ["Terminate", "BACK"];
    camDestroy _camera;
};

private _downTime = serverTime - _startTime;
while { WL_ISDBNO(_unit) } do {
    if (animationState _unit != _deadAnimation) then {
        [_unit, [_deadAnimation]] remoteExec ["switchMove", 0];
    };
    if (_unit distance2D _originalDeathPos > 30) then {
        _unit setPosWorld _originalDeathPos;
        _unit setVelocity [0, 0, 0];
    };

    _downTime = serverTime - _startTime;
    setPlayerRespawnTime ((WL_DURATION_RESPAWN * _controlledMod - _downTime) max 1);

    private _expirationTime = _unit getVariable ["WL2_expirationTime", serverTime + WL_DURATION_RESPAWN * _controlledMod];
    if (serverTime > _expirationTime && !BIS_WL_missionEnd) then {
        forceRespawn _unit;
        break;
    };

    _unit setVariable ["WL_unconsciousTime", _downTime];
    uiSleep 0.1;
};
