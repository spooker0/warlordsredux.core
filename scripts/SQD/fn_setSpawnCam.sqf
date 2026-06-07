#include "includes.inc"
params ["_spawnTarget", "_specialSpawnTarget"];

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _hideSpawnMenuPiP = _settingsMap getOrDefault ["hideSpawnMenuPiP", false];
if (_hideSpawnMenuPiP) exitWith {};

private _spawnCamera = uiNamespace getVariable ["SQD_spawnCamera", objNull];
if (!alive _spawnCamera) then {
    _spawnCamera = "camera" camCreate [0, 0, 0];
    _spawnCamera cameraEffect ["Terminate", "BACK TOP", "spawnCam"];
    _spawnCamera cameraEffect ["Internal", "BACK TOP", "spawnCam"];
    _spawnCamera camCommit 0;
    uiNamespace setVariable ["SQD_spawnCamera", _spawnCamera];
};

private _targetObject = objNull;
private _targetOffset = [0, 0, 0];
if (!isNull _spawnTarget) then {
    _targetObject = _spawnTarget;
    _targetOffset = [0, -15, 10];
} else {
    _targetObject = if (_specialSpawnTarget select 1 == "stronghold") then {
        private _sector = _specialSpawnTarget select 0;
        _sector getVariable ["WL_stronghold", _sector]
    } else {
        _specialSpawnTarget select 0
    };
    _targetOffset = switch (_specialSpawnTarget select 1) do {
        case "airAssault": { [0, -50, 500] };
        case "seized": { [0, -50, 100] };
        case "squadmate": { [0, -4, 2] };
        default { [0, -15, 10] };
    };
};

if (!isNull _targetObject) then {
    private _cameraPosASL = _targetObject modelToWorldWorld _targetOffset;
    _spawnCamera setPosASL _cameraPosASL;

    private _targetVectorDirAndUp = [_cameraPosASL, getPosASL _targetObject] call BIS_fnc_findLookAt;
    _spawnCamera setVectorDirAndUp _targetVectorDirAndUp;
};