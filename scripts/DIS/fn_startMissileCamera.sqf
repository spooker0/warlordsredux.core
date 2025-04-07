#include "constants.inc"
params ["_projectile", "_unit", ["_fov", 0.75], ["_defaultOpticsMode", -1]];

if (isDedicated) exitWith {};

private _settingsMap = profileNamespace getVariable ["WL2_settings", createHashMap];
private _disableCamera = _settingsMap getOrDefault ["disableMissileCameras", false];
private _isDisconnected = unitIsUAV _unit && isNull (getConnectedUAV player);
private _pipDisabled = (getVideoOptions getOrDefault ["pipQualityName", "None"]) == "Disabled";

if (!_disableCamera && !_isDisconnected && !_pipDisabled) then {
    private _existingProcess = uiNamespace getVariable ["APS_Camera_Process", objNull];
    private _existingCam = uiNamespace getVariable ["APS_Camera_Cam", objNull];

    if (!isNull _existingProcess) then {
        terminate _existingProcess;
    };

    if (!isNull _existingCam) then {
        _existingCam cameraEffect ["Terminate", "BACK TOP"];
        camDestroy _existingCam;
        "APS_Camera" cutFadeOut 0;
    };

    private _missileCamera = [_projectile, _unit, _fov, _defaultOpticsMode] spawn DIS_fnc_missileCamera;
    uiNamespace setVariable ["APS_Camera_Process", _missileCamera];
};