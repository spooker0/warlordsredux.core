#include "includes.inc"
params ["_cameraPlayerModelSpace"];

private _visionMode = currentVisionMode [player];

private _camPosition = player modelToWorld _cameraPlayerModelSpace;
private _playerPosition = player modelToWorld [0, 0, 0];

private _intersections = lineIntersectsSurfaces [
    eyePos player,
    AGLtoASL _camPosition,
    player
];
if (count _intersections > 0) then {
    _camPosition = ASLtoAGL (_intersections # 0 # 0);
};

private _camera = "camera" camCreate _camPosition;
private _targetVectorDirAndUp = [getPosASL _camera, eyePos player] call BIS_fnc_findLookAt;
_camera setVectorDirAndUp _targetVectorDirAndUp;
_camera camCommit 0;

_camera cameraEffect ["Internal", "BACK"];

switch (_visionMode # 0) do {
    case 0: {
        camUseNVG false;
        false setCamUseTI 0;
    };
    case 1: {
        camUseNVG true;
    };
    case 2: {
        true setCamUseTI (_visionMode # 1);
    };
};

showCinemaBorder false;
cameraEffectEnableHUD true;